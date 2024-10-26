//
//  LabsView.swift
//  LabLog
//
//  Created by Sophie Chew on 6/21/24.
//

import SwiftUI

struct LabsView: View {
    @EnvironmentObject var currentAccount: Account
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    var images = ["image1", "image2", "image3", "image4"]
    @State private var hoveredItemIndex: Int?
    @State var showFeedbackConfirm = false

    var body: some View {
        NavigationView{
            VStack {
                CustomNavTitle(text: "Your Labs")
                    .padding(.bottom, 20)
                
                
                NavigationStack{
                    ScrollView {
                        LazyVGrid(columns: columns, content: {
                            ForEach(Array(currentAccount.labData.enumerated()), id: \.element.id) { i, lab in
                                NavigationLink(destination: GeneralLog(sharedData: lab)){
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 20)
                                            .foregroundStyle(hoveredItemIndex == i ? Color.appBlue.opacity(0.8) : Color.appBlue)
                                            .frame(width: 300, height:300)
                                        VStack {
                                            Image(images[i%images.count])
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(height: 220)
                                                .padding(.top, 20)
                                                .padding(.bottom, -18)
                                            
                                            Text(lab.name)
                                                .frame(width:190)
                                                .lineLimit(1)
                                                .font(.custom("Poppins-Medium", size: 40))
                                                .minimumScaleFactor(0.7)
                                                .foregroundStyle(.foreground)
                                        }
                                        .frame(width: 280)
                                        
                                        
                                        
                                        
                                    }
                                    .onHover(perform: { hovering in
                                        hoveredItemIndex = hovering ? i : nil
                                    })
                                }
                                
                            }
                        })
                        .padding(20)
                        
                        
                        
                    }
                    
                    NavigationStack {
                        NavigationLink(destination: FeedbackView()) {
                            CustomNavLinkLabel(color: .appOrange) {
                                Text("Submit Feedback")
                            }
                        }
                    }
                    
                    
                    
                    
                    
                    
                    /* Add Lab View (Hidden)
                     NavigationStack {
                     NavigationLink(destination: AddLabView()) {
                     CustomNavLinkLabel(color: .appOrange, size: .large) {
                     Text("+ Add")
                     }
                     }
                     .padding(20)
                     }
                     */
                    
                }
                .onAppear(){
                    if(FeedbackView.feedbackSubmitted) {
                        showFeedbackConfirm = true
                        
                        
                    }
                    
                }
                .alert(isPresented: $showFeedbackConfirm, content: {
                    Alert(title: Text("Feedback Submitted!"), message: Text("Thank you for your feedback.  If applicable, we will reach out with a response shortly."), dismissButton: .cancel(Text("OK"), action: {
                        showFeedbackConfirm = false
                        FeedbackView.feedbackSubmitted = false
                    }))
                })
                
            }
        }
        .navigationViewStyle(.stack)
        
        
       
        
    }
}

#Preview {
    LabsView()
}
