//
//  LabLogApp.swift
//  LabLog
//
//  Created by Sophie Chew on 5/22/24.
//

import SwiftUI
import GoogleSignInSwift
import GoogleSignIn

@main
struct LabLogApp: App {
    @StateObject var currentAccount: Account = Account()
    @State var isActive = false
    var body: some Scene {
        WindowGroup {
            
            ZStack {
                if self.isActive {
                    ContentView()
                        //.frame(minWidth: 1000, minHeight: 1000)
                } else {
                    SplashView()
                }
            }
            .task {
                SheetsAPI.prepareService() {
                    SheetsAPI.getLabs { labs in
                        currentAccount.setLabs(labs: labs)
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
            }

            .environmentObject(currentAccount)
            
            
                
        }
        .windowResizability(.contentMinSize)

    }
}
