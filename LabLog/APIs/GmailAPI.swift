//
//  GmailAPI.swift
//  LabLog
//
//  Created by Sophie Chew on 10/8/24.
//

import Foundation
import GoogleSignIn
import GoogleAPIClientForREST_Gmail
// so apparently service accounts cannot send emails... maybe come from mathlab email

struct GmailAPI {
    
    private static func sendEmail(to recipient: String, subject: String, body: String, completion: @escaping(Error?)-> Void) { // likely now unusable
        
        let emailContent =  """
        From: \(ServiceAccount.email)
        To: \(recipient)
        Subject: \(subject)

        \(body)
        """
        
        do {
            guard let base64URLEncodedEmail = emailContent.data(using: .utf8)?
                .base64EncodedString()
                .replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: "=", with: "") else {
                throw NSError(domain: "GmailAPIError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode email content"])
            }
            
            let userId = "me"
            let urlString = "https://gmail.googleapis.com/upload/gmail/v1/users/\(userId)/messages/send"
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }
            
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(ServiceAccount.accessToken)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let requestBody: [String: Any] = ["raw": base64URLEncodedEmail]
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print(error.localizedDescription)
                    completion(error)
                }
                
                print("Email sent successfully!")
                
            }.resume()
                    

            
            
        } catch {
            print("Failed to send email")
            
        }
        
        
        
    }
    static func sendStudentEmailReceipt (recipient:String, labName:String) {
        
        sendEmail(
            to: recipient,
            subject: "\(labName) Check Out Confirmation",
            body: "You have successfully checked out of \(labName)."
        ) { error in
            if let error = error {
                print(error.localizedDescription)
            }
            
        }
        
        
    }
}
