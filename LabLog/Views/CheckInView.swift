//
//  CheckInView.swift
//  LabLog
//
//  Created by Sophie Chew on 5/22/24.
//

import SwiftUI
// v1
//public var studentList: [(String, String)] = []

struct CheckInView: View {
    @EnvironmentObject var currentAccount: Account
    @State private var gradYear = ""
    @State private var user = ""
    @State private var teacher = ""
    @State private var gradYearsList = [""]
    @State private var studentList: [(String, String)] = []
    @State private var teacherList = [""]
    @State var pickerPressed = false
    @State var showError = false
    @State var showConfirmation = false
    @State var showUserAlrCheckedIn = false
    @State var studentSearch = ""
    @State var hover1 = false
    @State var hover2 = false
    @State var hover3 = false
    var sharedData: LabData
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        
        NavigationStack{
            ZStack {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                            .frame(width:220)
                        RoundedRectangle(cornerSize: CGSize(width: 30, height: 30))
                            .foregroundStyle(.appBlue.opacity(0.22))
                            .frame(width: 1000, height: 700)
                        Spacer()
                    }
                    Spacer()
                }
                VStack {
                    CustomNavTitle(text: "Check In")
                    
                    VStack (alignment: .leading){
                        Spacer()
                        
                        HStack {
                            Spacer()
                                .frame(width:250)
                            VStack(alignment:.leading){
                                Text("Name")
                                    .font(.custom("Poppins-Medium", size: 25))
                                
                                
                                NavigationLink{
                                    Form{
                                        Picker("Select student's name:",selection: $user) {
                                            ForEach(studentListFiltered, id: \.self){ student in
                                                if(student != ""){
                                                    Text(student).tag(student)
                                                        .font(.custom("Poppins-Regular", size: 20))
                                                        .frame(height:50)
                                                        .foregroundStyle(.foreground)
                                                }
                                                
                                            }
                                        }
                                        .pickerStyle(.inline)
                                        
                                        
                                    }
                                    .searchable(text: $studentSearch)
                                    .scrollContentBackground(.hidden)
                                    
                                    
                                    
                                    
                                } label: {
                                    LabeledContent {
                                        HStack {
                                            Text(user)
                                                .font(.custom("Poppins-Regular", size:20))
                                                .padding(.trailing, 10)
                                            Image(systemName: "arrowtriangle.right.fill")
                                                .foregroundStyle(.appBlue)
                                        }
                                        
                                    } label: {
                                        Text("Select student's name:")
                                            .font(.custom("Poppins-Regular", size:20))
                                    }
                                    
                                    
                                }
                                .frame(width:800, height:30)
                                .padding(20)
                                .onHover(perform: { hovering in
                                    hover2 = hovering
                                })
                                .foregroundStyle((studentList.count<=1) ? Color.myForeground.opacity(0.5) : .myForeground)
                                .background(hover2 ? .appBlue.opacity(0.15) : .clear)
                                .clipShape(Capsule())
                                .overlay(Capsule().strokeBorder(.appBlue, lineWidth: 2))
                                .disabled(studentList.count <= 1)
                                
                            }
                            .padding(.bottom, 50)
                            
                            Spacer()
                        } // end name hstack
                        
                        HStack {
                            Spacer()
                                .frame(width:250)
                            VStack (alignment: .leading) {
                                Text("Teacher")
                                    .font(.custom("Poppins-Medium", size: 25))
                                
                                NavigationLink {
                                    Form {
                                        Picker("Select student's teacher:",selection: $teacher) {
                                            ForEach(teacherList, id: \.self){ teacher in
                                                if(teacher != ""){
                                                    Text(teacher).tag(teacher)
                                                        .font(.custom("Poppins-Regular", size: 20))
                                                        .frame(height:50)
                                                        .foregroundStyle(.foreground)
                                                }
                                                
                                            }
                                        }
                                        .pickerStyle(.inline)
                                        
                                    }
                                    .scrollContentBackground(.hidden)
                                    
                                    
                                    
                                } label: {
                                    LabeledContent {
                                        HStack {
                                            Text(teacher)
                                                .font(.custom("Poppins-Regular", size:20))
                                                .padding(.trailing, 10)
                                            Image(systemName: "arrowtriangle.right.fill")
                                                .foregroundStyle(.appBlue)
                                        }
                                        
                                    } label: {
                                        Text("Select student's teacher:")
                                            .font(.custom("Poppins-Regular", size:20))
                                    }
                                }
                                .frame(width:800, height:30)
                                .padding(20)
                                .onHover(perform: { hovering in
                                    hover3 = hovering
                                })
                                .foregroundStyle((teacherList.count<=1) ? Color.myForeground.opacity(0.5) : .myForeground)
                                .background(hover3 ? .appBlue.opacity(0.15) : .clear)
                                .clipShape(Capsule())
                                .overlay(Capsule().strokeBorder(.appBlue, lineWidth: 2))
                                .disabled(teacherList.count <= 1)
                            }
                            .padding(.bottom, 50)
                            Spacer()
                        } // end teacher h stack
                        
                        HStack {
                            Spacer()
                                .frame(width:650)
                            CustomButton(color: .appOrange) {
                                checkIn()
                            } label: {
                                Text("Check In")
                            }
                            .padding(.bottom, 70)
                            
                            .alert(isPresented: $showError) {
                                Alert(title: Text("No graduation year selected"))
                            }
                            .alert(isPresented: $showConfirmation, content: { // confirmation alert to check in user
                                Alert(title: Text("Is this information correct?"), message: Text("Name: \(user)\nTeacher: \(teacher)"), primaryButton: .destructive(Text("Confirm"), action: {
                                    print("Checking in...")
                                    SheetsAPI.checkInUser(sheetId: sharedData.sheetId, name: user, year: gradYear, teacher: teacher) { success in
                                        DispatchQueue.main.async{
                                            if success {
                                                dismiss()
                                            } else {
                                                showUserAlrCheckedIn = true
                                                print("user alr checked in")
                                            }
                                            
                                        }
                                    }
                                    
                                }), secondaryButton: .cancel())
                            })
                            
                            Spacer()
                                .alert(isPresented: $showUserAlrCheckedIn, content: {
                                    Alert(title: Text("\(user) is already checked in."))
                                })
                        }
                        
                        Spacer()
                    }
                    .onAppear(perform: {
                        SheetsAPI.getStudents(sheetId: sharedData.sheetId) { students in
                            if(!students.isEmpty) {
                                studentList = students
                                
                                SheetsAPI.getTeachers(sheetId: sharedData.sheetId) { teachers in
                                    teacherList = teachers
                                    
                                }
                            } else {
                                SheetsAPI.getLabs { labs in
                                    currentAccount.setLabs(labs: labs)
                                }
                                
                                dismiss()
                            }
                        }
                        
                    })
                    .onChange(of: user) {
                        for (student, year) in studentList {
                            if(student == user) {
                                gradYear = year
                            }
                        }
                    }
                }
            }
        }
        
        
        
        
        
        
        
        
        
    }
    
    
    var studentListFiltered: [String] {
        
        if studentSearch.isEmpty {
            return studentList.map{$0.0}
        } else {
            
            return studentList.filter{$0.0.localizedCaseInsensitiveContains(studentSearch)}.map{$0.0}
        }
    }
    
    
    
    
    func checkIn(){
        // Write to sheets as active session
        if(user == "Select your graduation year first!"){
            showError = true
            return
        }
        showConfirmation = true
        
        
        
    }
}

#Preview {
    CheckInView(sharedData: LabData(name: "Math Lab", sheetId: "1s_y5nKtnuk7QSq9GJxk_zMkXFZQ59pIcvHjBNQiqruM"))
}
