//
//  GeneralLog.swift
//  LabLog
//
//  Created by Sophie Chew on 5/22/24.
//

import SwiftUI

struct GeneralLog: View {
    
    @ObservedObject var sharedData: LabData
    @State var showConfirmation = false
    @State var notes = ""
    @State var color1 = true
    @State var buttonHover = false
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        NavigationStack {
            VStack {
                
                CustomNavTitle(text: "\(sharedData.name) Check Ins")
                
                    List {
                        if(sharedData.activeUserList.isEmpty){
                            Text("No students are currently checked in.")
                                .font(.custom("Poppins-Medium", size: 30))
                                .foregroundStyle(.foreground.opacity(0.5))
                        } else {
                            ForEach(Array(sharedData.activeUserList.enumerated()), id: \.element.id) { index, user in
                                ActiveUserView(user: user, sharedData: sharedData, notes: user.notes)
                                    .frame(height: 80)
                                    .listRowBackground(index % 2 == 0 ? Color.appBlue.opacity(0.22) : Color.appOrange.opacity(0.22))
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .padding(.top, -30)
                    .frame(maxWidth: 1500)
                    
                if (!sharedData.activeUserList.isEmpty) {
                    
                    CustomButton(color: .appBlue) {
                        showConfirmation = true
                    } label: {
                        Text("Check Out All")
                    }
                    
                }
                
                    
                NavigationLink {
                    CheckInView(sharedData: sharedData)
                } label: {
                    Text("Check In")
                        .font(.custom("Poppins-Medium", size: 40))
                        .padding(.horizontal, 40)
                        .padding(.vertical, 20)
                        .foregroundStyle(.foreground)
                        .background(buttonHover ? .appOrange.opacity(0.8) : .appOrange)
                       .clipShape(Capsule())
                       .onHover(perform: { hovering in
                           if hovering {
                              buttonHover = true
                           } else {
                               buttonHover = false
                           }
                       })
                }
                .padding(80)
                
                
            }
            .environmentObject(sharedData)
        }
        .onAppear(perform: {
            DispatchQueue.main.async {
                sharedData.updateActiveUserList()
            }
            
            
            
        })
      
        .sheet(isPresented: $showConfirmation, content: {
            NavigationStack {
                VStack {
                    CustomNavTitle(text: "Check Out All", size:.small)
                    VStack (alignment: .center) {
                        TextField("Write an optional note for all students...", text: $notes, axis: .vertical)
                            .font(.custom("Poppins-Regular", size: 20))
                            .frame(width: 300, height:150)
                            .padding(20)
                            .border(Color.accentColor)
                        
                        CustomButton(color: .appOrange) {
                            showConfirmation.toggle()
                            checkOutAll(notes: notes)
                        } label: {
                            Text("Check Out")
                        }
                        .padding(50)
                    }
                    .toolbar(content: {
                        Button(action: {
                            showConfirmation.toggle()
                        }, label: {
                            Image(systemName:"xmark")
                        })
                })
                }
            }
            
        })
        
        
        
    }
    
    func checkOutAll(notes: String){
        for user in sharedData.activeUserList {
            user.notes = notes
            SheetsAPI.checkOutUser(sheetId: sharedData.sheetId, user: user) { _ in
                DispatchQueue.main.async {
                    sharedData.updateActiveUserList()
                }
                
            }
        }
    }
}

#Preview {
    GeneralLog(sharedData: LabData(name: "Math Lab", sheetId: "1s_y5nKtnuk7QSq9GJxk_zMkXFZQ59pIcvHjBNQiqruM"))
}

struct ActiveUserView: View {
    var user: ActiveUser
    let sharedData: LabData
    @State var notes: String
    @State var showConfirmation = false
    var body: some View {
        HStack (alignment:.center) {
            Text(user.name)
                .font(.custom("Poppins-Regular", fixedSize: 20))
                .lineLimit(1)
                .padding(20)
                .frame(width: 400, alignment:.leading)
                
            
            Spacer().frame(width:100)
            
            Text("Checked In At: " + user.checkedInTime)
                .font(.custom("Poppins-Regular", fixedSize: 20))
                .padding(20)
                .lineLimit(1)
            
            Spacer()
            
            CustomButton(color: .appBlue) {
                showConfirmation = true
            } label: {
                Text("Check Out")
            }
            
                .padding(20)
                .sheet(isPresented: $showConfirmation, content: {
                    NavigationStack {
                        VStack {
                            CustomNavTitle(text: "\(user.name)", size:.small)
                            VStack (alignment: .center) {
                                TextField("Write an optional note...", text: $notes, axis: .vertical)
                                    .font(.custom("Poppins-Regular", size: 20))
                                    .frame(width: 300, height:150)
                                    .padding(20)
                                    .border(Color.accentColor)
                                
                                CustomButton(color: .appOrange) {
                                    showConfirmation.toggle()
                                    SheetsAPI.checkOutUser(sheetId: sharedData.sheetId, user: user) { success in
                                        DispatchQueue.main.async {
                                            if success {
                                                sharedData.updateActiveUserList()
                                            } else {
                                                // alert maybe
                                                print("Failed to check out user")
                                            }
                                        }
                                    }
                                } label: {
                                    Text("Check Out")
                                }

                                .padding(50)
                            }
                            .toolbar(content: {
                                Button(action: {
                                    showConfirmation.toggle()
                                }, label: {
                                    Image(systemName:"xmark")
                                })
                        })
                        }
                    }
                    
                })
                .onChange(of: notes) {
                    user.notes = notes
                }
        }
        
        
        
        
        
    }
}
