//
//  ServiceAccount.swift
//  JWTTesting
//
//  Created by Joey Uriarte on 6/17/24.
//

import Foundation
import JWTKit

public class ServiceAccount {
    
    static var accessToken = ""
    static let email = ProcessInfo.processInfo.environment["SERVICE_ACCOUNT_EMAIL"] ?? ""
    
    static func generate() async -> String {
        let serviceAccountURL = URL(fileURLWithPath: "lablogService.json")
        //let serviceAccountData = try? Data(contentsOf: serviceAccountURL)
        //  let serviceAccount = try? JSONDecoder().decode(ServiceAccount.self, from: serviceAccountData!)
        
        let payload = GooglePayload(
            iss: "lablogservice@extrahelptracker.iam.gserviceaccount.com" ,
            aud: "https://oauth2.googleapis.com/token",
            scope: "https://www.googleapis.com/auth/spreadsheets https://www.googleapis.com/auth/gmail.send",
            exp:Date().advanced(by: 1000).timeIntervalSince1970,
            iat: Date().timeIntervalSince1970
        )
        
        
        
        let privateKeyData2 = """
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDmxljvjjCbN6s5
xbOFKkYS2ZO9XELdZamfFKMSdUESOeX6T/wH5LUxQgEb1KtDfkwMhJep2prPPmDU
5enUnR9X0LxokjWO5h6DT9pJvk10YIlQMCFicTWqSH+wmKYAUD7j966zRG5YveFU
TkdGGPk56ag+dqc38Gx/BA+G9uAysdxRhn99csAaWMtqlsYRYgguS8XlYDRA/XKV
x9DzpGK285wq6YCwsmSvl7fl+IpyXqDK0Bx7RGeIEpqcwSRgzmligRYkATxoB3QV
UfbldsLuCMk9JCG4HQgyCAN8hJxyA10Q6l/xdkdj4Fy3J1S4OED3hQFuud5pMnOv
sITg/novAgMBAAECggEAIIgMaHSkYHUYA5RdiqObbjPSskpruJcIsr6vgD4cNqwH
weH9lsVET5XM3zX7EJAgu1EDqjOBSD60Wr6wWELv9KqdrKYTu7mvynX6wRN9Cq9D
HBU015I67O68ZVIXcIrfWraDH41BeuwFdCN2w6holaPdDjUevHF9cehKIg3yK+MH
LsRbn93x5RQ2tubVkIXi/RzPBuuLg4dIlRkQBL0sF7nF3v+b/ZrgUAt56QYIRosY
kacxk9DmD//9qlRbcziLH49GsS2B3UoI1lXpYsQfRFIZ3g3cgEnmCSszyXxldc5p
0SInK52906jxTLBY1xC2M6NyU9Sh+SE/WkEM9lkTRQKBgQD4mo67GZwJfyWuVRQi
4dcPvkg927TGMTtCv9FRkGweVpUVN6n9EkHOLtpIf37ZcTsoVCY2tk1QwIThC1x7
DyEBe+s16LTKi/sGnIFuKnkr2gvkPTUHCEMSNTxMYYYJ+Hc5HqlNw/YPqRIGUeJL
dc7MLO05infDgXcx/aUivls60wKBgQDto//HQ/90K6nUWwid6TAti0W2khIck/ED
juyIV+wxkGiRw3LcfkIXtBtG2LZB6Zaoj7hepAS9VYLYFO67s9rB/1HMi3x3GjgR
TDxnSxG07/Raxv9JEcuuYfV2N4tsmnFeeAMFBZY8JvcLdrkV2ymeWMwSHo+6AmyP
czblZqaxtQKBgQCiHKdWeqy1xKPdur0Wwg5rxbl2HP8U/qWWMV9dwL/ASNWOsG25
CV7ABO1yuTEOujfJZJZGtzpTnjcISVBVLthnD1eiH81FB2L6PLRqEmhRoC6A9yjN
HSYfiXd4l1/AwLV+GfBtNYwPSkDmvh7C9l+T5PgMva67XoFLqAs3TMpQ4QKBgDAr
IdleKxV9FDt7CFAZyC4zILpU+V7ZjezOt5sbV0DkqI2DNHEFFph/ZVgC7U6G7obU
OubUEDHgd1kdRRa+6gSQoB/51gy+P8ch0MyPJtOqH7mWxIAnH0YFjR+dOqGU3I3t
fY8zBrTCoSits+5+Mf1qulKh5zgo7aBWFjaBjCBRAoGBAKsujwYRhsM7wuU8Zajp
1pGx1Oodon7Guw4TeW/9xZ25aSdI2nJ34Bo45nt1udVrg4egzb4Q5lNpwNb54eaL
6plSQoWBVAWNQuqz+LiPA4b7NjzIoy2u3uFToXe3LLEaA2TRYZoCKp3C2+ScsGuQ
cvWj7GerjGtQ8MOOuE+PVBWa
-----END PRIVATE KEY-----
"""
        //   .replacingOccurrences(of: "\\n", with: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        
    //    print("Private Key Data: \(privateKeyData2)")
        //   let jwk = try JWK(json: "lablogService.json")
        do {
            let keys = JWTKeyCollection()
            let key = try Insecure.RSA.PrivateKey(pem: privateKeyData2)
            await keys.add(rsa: key, digestAlgorithm: .sha256)
            let jwt = try await keys.sign(payload)
            
            //print("\nToken:\n" + jwt + "\n end\n")
            
            await getAuthToken(token: jwt)
            print("token created!")
            return accessToken
            
            
        }
        catch {
            print("Error: \(error.localizedDescription)")
            return ""
        }
    }
    
    private static func getAuthToken(token: String) async{
        
        guard let url = URL(string: "https://oauth2.googleapis.com/token") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

                
        let parameters: [String: Any] = [
            "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
            "assertion": token
        ]
        
        let bodyString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
        
        await withCheckedContinuation { cont in
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    
                    let decoder = JSONDecoder()
                    do {
                       let tokenResponse = try decoder.decode(AccessTokenJSON.self, from: data)
                        
                        accessToken = tokenResponse.access_token

                        cont.resume()
                        
                    } catch {
                        print("Failed to decode JSON response: \(error.localizedDescription)")
                        cont.resume()
                    }
                
                } else if let error = error {
                    print(error)
                    cont.resume()
                }
            }.resume()
        }
        
        
        

        
    }
    
    
    struct GooglePayload: JWTPayload {
        
        func verify(using key: some JWTAlgorithm) throws {
            print(self.exp > Date().timeIntervalSince1970)
            fatalError()
        }
        var iss: IssuerClaim
        var aud: AudienceClaim
         var scope: String
        var exp: Double
        var iat: Double
        
        
    }
    
    struct AccessTokenJSON: Decodable {
        
        let access_token: String
        let expires_in: Int
        let token_type: String
        
    }
    

    
}
