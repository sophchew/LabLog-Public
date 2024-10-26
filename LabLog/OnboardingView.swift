//
//  OnboardingView.swift
//  LabLog
//
//  Created by Sophie Chew on 6/16/24.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct OnboardingView: View {
    @State var buttonHover = false
    @EnvironmentObject var currentAccount: Account
    
    var body: some View {
        Image("onboardingimage")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 400)
        Text("Welcome to LabLog!")
            .font(.custom("Poppins-Medium", size: 50))
            .padding(.bottom, 80)

        CustomButton(color: .appBlue, size:.large) {
            currentAccount.signIn(){
                SheetsAPI.getLabs { labs in
                    currentAccount.setLabs(labs: labs)
                }
            }
        } label: {
            Text("Google Sign In")
                
        }
        
    }
}

#Preview {
    OnboardingView()
}
