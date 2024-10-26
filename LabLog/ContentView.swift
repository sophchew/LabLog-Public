//
//  ContentView.swift
//  LabLog
//
//  Created by Sophie Chew on 5/22/24.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct ContentView: View {
    
    @EnvironmentObject var currentAccount: Account
    @State var buttonHover = false
    
    var body: some View {
        
        NavigationStack {
            VStack {
                
                if (GIDSignIn.sharedInstance.currentUser != nil){ // user signed in and has saved ids
                    if (!currentAccount.labData.isEmpty){
                        LabsView()
                    } else {
                        VStack(alignment:.center){
                            Text("Loading...")
                                .font(.custom("Poppins-Regular", size: 40))
                            Text("(If this appears for too long, restart the app.)")
                                .font(.custom("Poppins-Regular", size: 20))
                        }
                        
                        
                    }
                        
                    
                } else  {
                    // user not signed in
                    OnboardingView()
                    
                }
            }
            .padding()
            
            .toolbar(content: {
                if (GIDSignIn.sharedInstance.currentUser != nil){
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        CustomButton(color: .appOrange, size: .small) {
                            currentAccount.signOut()
                        } label: {
                            Text("Sign Out")
                        }
                       .padding(.top, 10)
                       
                       
                    }
                    
                }
            })
            
        }
        .disabled(SheetsAPI.isReady)
        .onAppear(){
            
        }
        
        
    }
    
    
}

#Preview {
    ContentView()
}
