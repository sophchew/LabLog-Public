//
//  Account.swift
//  LabLog
//
//  Created by Sophie Chew on 6/3/24.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift

class Account: ObservableObject {
    
    @Published var name: String
    @Published var state: State = .signedOut
    @Published var email: String
    @Published var labData: [LabData] = []
    
    init() {
        self.name = ""
        self.email = ""
        self.state = .signedOut
        DispatchQueue.main.async {
            
            
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                if let e = error {
                    print(e)
                    return
                }
                /*
                 when i want to reset the user defaults
                 UserDefaults.standard.removeObject(forKey: "googleId")
                 UserDefaults.standard.removeObject(forKey: "\((user?.userID)!)_mathLabSheetId")
                 UserDefaults.standard.removeObject(forKey: "\((user?.userID)!)_writingLabSheetId")
                 */
                print("Relogged In")
                //  isUserSignedIn = true
                
                
            }
        }
        checkUserState()
    }
    
    
    func checkUserState(){
        if(GIDSignIn.sharedInstance.currentUser != nil){
            let user = GIDSignIn.sharedInstance.currentUser!
            self.name = user.profile?.givenName ?? ""
            self.email = user.profile?.email ?? ""
            self.state = .signedIn(user)
        } else {
            self.state = .signedOut
        }
    }
    
    func signIn(completion: @escaping()-> Void) {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            print("There is no root view controller!")
            return
        }
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController, hint: "Sheets", additionalScopes: ["https://www.googleapis.com/auth/spreadsheets", "https://www.googleapis.com/auth/drive.file"]) { signInResult, error in
            
            if let e = error {
                print(e)
                return
            }
            print("Successfully logged in!")
            self.state = .signedIn(GIDSignIn.sharedInstance.currentUser!)
            completion()
            
        }
        
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        self.name = ""
        self.email = ""
        self.state = .signedOut
        self.labData = []
        print("Successfully signed Out")
    }
    
    
    let defaults = UserDefaults.standard
    
    func setLabs(labs: [[String]]) {
        self.labData = []
        let sortedLabs = labs.sorted { (a, b) -> Bool in
            guard let firstA = a.first, let firstB = b.first else {
                return false
            }
            return firstA < firstB
        }
        print(sortedLabs)
        
        for lab in sortedLabs {
            self.labData.append(LabData(name: lab[0], sheetId: lab[1]))
        }
    }
    
   
    
    
    
}



extension Account {
    /// An enumeration representing logged in status.
    enum State {
        /// The user is logged in and is the associated value of this case.
        case signedIn(GIDGoogleUser)
        /// The user is logged out.
        case signedOut
    }
    
    
}
