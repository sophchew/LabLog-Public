//
//  GoogleAdminAPI.swift
//  LabLog
//
//  Created by Sophie Chew on 9/9/24.
//

import Foundation
import SwiftUI
import GTMAppAuth
import GTMSessionFetcherCore
import GTMSessionFetcherFull
import GoogleAPIClientForRESTCore
import GoogleAPIClientForREST_Directory
import GoogleSignIn



struct GoogleAdminAPI {
    
    static let service = GTLRDirectoryService();
    static var users: [SearchedDomainUser] = [SearchedDomainUser]()
    private static var endOfPages: Bool = false
    
    
    static func prepareService() {
        service.authorizer = GIDSignIn.sharedInstance.currentUser?.fetcherAuthorizer
    }
    
    static func getDomainUsers(completion: @escaping(Bool) -> Void) {
        prepareService()
        
        let query = GTLRDirectoryQuery_UsersList.query()
        query.domain = "saintandrews.net" // make scalable
        query.viewType = kGTLRDirectoryViewTypeDomainPublic
        query.maxResults = 500
        service.shouldFetchNextPages = true
        
        //query.query = "orgUnitPath = '/Users/'"
    
        service.executeQuery(query) { ticket, res, error in
            if let se = error {
                print("error accessing users in domain: \(se)")
                completion(false)
                
            }
            if let safeRes = res as? GTLRDirectory_Users {
                if let returnedUsers = safeRes.users {
                    users = returnedUsers.map({ gUser in
                        SearchedDomainUser(name: gUser.name?.fullName ?? "", email: gUser.primaryEmail ?? "")
                    })
                    

                    print("Done grabbing domain users! \(users.count)"  )
                    completion(true)
                }
                
            }
            
        }
    }
    
    

    
    
}
