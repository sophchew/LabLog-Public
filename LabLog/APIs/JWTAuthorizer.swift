//
//  JWTAuthorizer.swift
//  LabLog
//
//  Created by Sophie Chew on 6/22/24.
//

import Foundation
import SwiftUI
import GTMAppAuth
import GoogleAPIClientForRESTCore
import GoogleAPIClientForREST_Sheets

class JWTAuthorizer: NSObject, GTMSessionFetcherAuthorizer {
    
    var userEmail: String?
    
    private let token: String

    init(token: String) {
        self.token = token
        print("init")
        super.init()
    }
    
    func authorize(_ request: NSMutableURLRequest) {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("Authorization header set: \(request.allHTTPHeaderFields?["Authorization"] ?? "None")")
    }

    func authorizeRequest(_ request: NSMutableURLRequest?, completionHandler: @escaping (Error?) -> Void) {
        if let safeReq = request {
            print("running?")
            authorize(safeReq)
        }
        
        completionHandler(nil)
    }
    
    func authorizeRequest(_ request: NSMutableURLRequest?, delegate: Any, didFinish sel: Selector) {
        if let safeReq = request {
            authorize(safeReq)
        }
        let _ = (delegate as AnyObject).perform(sel, with: nil)
    }
    
    func isAuthorizingRequest(_ request: URLRequest) -> Bool {
        return true
    }
    
    func isAuthorizedRequest(_ request: URLRequest) -> Bool {
        return true
    }
    
    func stopAuthorization() {}
    
    func stopAuthorization(for request: URLRequest) {
    }

    func stopAuthorization(completion: (() -> Void)? = nil) {
        completion?()
    }
}
