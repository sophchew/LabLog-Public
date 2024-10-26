//
//  FeedbackView.swift
//  LabLog
//
//  Created by Sophie Chew on 10/21/24.
//

import SwiftUI

struct FeedbackView: View {
    @State var email: String = ""
    @State var trouble: String = ""
    @State var like: String = ""
    @State var suggestion: String = ""
    static var feedbackSubmitted = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            Form {
                CustomNavTitle(text: "Feedback Form")
                    .listRowSeparator(.hidden)
                Text("Teachers, thank you for testing this app before we deploy it to our larger community. This form is anonymous, but please include your email if you want us to reply with a solution or response. ")
                    .font(.custom("Poppins-Regular", size: 20))
                    .padding(20)
                    .listRowSeparator(.hidden)
                Text("Email")
                    .font(.custom("Poppins-Medium", size: 30))
                    .padding(.leading, 20)
                    .listRowSeparator(.hidden)
                TextField("Email (optional)", text: $email)
                    .font(.custom("Poppins-Regular", size: 20))
                    .padding(20)
                    .foregroundStyle(.myForeground)
                    .clipShape(Capsule())
                    .overlay(Capsule().strokeBorder(colorScheme == .dark ? .white : .appBlue, lineWidth: 2))
                    .frame(width:800)
                    .padding(.leading, 15)
                    .listRowSeparator(.hidden)
                Text("I had trouble with this app because:")
                    .font(.custom("Poppins-Medium", size: 30))
                    .padding(.leading, 20)
                    .listRowSeparator(.hidden)
                TextField("Did you have any issues when using the app? Describe, if any, bugs you encountered.", text: $trouble, axis: .vertical)
                    .frame(width:1000)
                    .multilineTextAlignment(.leading)
                    .lineLimit(6, reservesSpace: true)
                    .padding(10)
                    .font(.custom("Poppins-Regular", size: 20))
                    .foregroundStyle(.myForeground)
                    .overlay(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)).strokeBorder(colorScheme == .dark ? .white : .appBlue, lineWidth: 2))
                    .listRowSeparator(.hidden)
                    .padding(.leading, 15)
                Text("I liked that this app:")
                    .font(.custom("Poppins-Medium", size: 30))
                    .padding(.leading, 20)
                    .listRowSeparator(.hidden)
                TextField("What do you like about the app?  What does it improve?", text: $like, axis: .vertical)
                    .frame(width:1000)
                    .multilineTextAlignment(.leading)
                    .lineLimit(6, reservesSpace: true)
                    .padding(10)
                    .font(.custom("Poppins-Regular", size: 20))
                    .foregroundStyle(.myForeground)
                    .overlay(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)).strokeBorder(colorScheme == .dark ? .white : .appBlue, lineWidth: 2))
                    .listRowSeparator(.hidden)
                    .padding(.leading, 15)
                Text("Here are some of my thoughts:")
                    .font(.custom("Poppins-Medium", size: 30))
                    .padding(.leading, 20)
                    .listRowSeparator(.hidden)
                TextField("Any suggestions on how the app should improve? Anything else you want to add about your experience?", text: $suggestion, axis: .vertical)
                    .frame(width:1000)
                    .multilineTextAlignment(.leading)
                    .lineLimit(6, reservesSpace: true)
                    .padding(10)
                    .font(.custom("Poppins-Regular", size: 20))
                    .foregroundStyle(.myForeground)
                    .overlay(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)).strokeBorder(colorScheme == .dark ? .white : .appBlue, lineWidth: 2))
                    .listRowSeparator(.hidden)
                    .padding(.leading, 15)
                HStack {
                    Spacer()
                    CustomButton(color: .appOrange, size: .normal) {
                        if(email == "") {
                            email = "Anonymous"
                        }
                        SheetsAPI.submitFeedback(email: email, trouble: trouble, like: like, suggestion: suggestion) { success in
                            if(success) {
                                DispatchQueue.main.async {
                                    FeedbackView.feedbackSubmitted = true
                                    dismiss()
                                }
                                    
                                
                            }
                        }
                    } label: {
                        Text("Submit")
                    }
                    .padding(.bottom, 20)
                    Spacer()
                }

                    
                   
                    
                
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        
    }
}

#Preview {
    FeedbackView()
}
