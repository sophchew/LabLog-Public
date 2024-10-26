//
//  AddLabView.swift
//  LabLog
//
//  Created by Sophie Chew on 8/23/24.
//

import SwiftUI

struct AddLabView: View {
    @State var labName: String = ""
    @State var adminUserSearch: String = ""
    @State var rosterSearch: String = ""
    @State var showDisclaimer: Bool = false
    @State var filteredAdminUserList: [SearchedDomainUser] = []
    @State var filteredRosterList: [SearchedDomainUser] = []
    @State var isLoading = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var currentAccount: Account
    
    var body: some View {
        
        NavigationStack {
            ScrollView {
                ZStack {
                    VStack {
                        Spacer()
                            .frame(height:200)
                        HStack {
                            Spacer()
                                .frame(width:220)
                            RoundedRectangle(cornerSize: CGSize(width: 30, height: 30))
                                .foregroundStyle(.appBlue.opacity(0.22))
                                .frame(width: 1000, height: 1000)
                            Spacer()
                        }
                    }
                    
                    VStack{
                        CustomNavTitle(text: "Add Lab/Club")
                            .padding(20)
                        
                        
                        
                        
                        
                        VStack(alignment:.leading) {
                            Spacer()
                            HStack{
                                Spacer()
                                    .frame(width:250)
                                
                                Text("Create your own check-in log for your lab/club. Upon submitting this form, a Google Spreadsheet titled \"Your Lab Check Ins\" \nwill be automatically created in your Google Drive. To ensure that the spreadsheet remains synced with this app, \ndo not remove edit permissions from \(ServiceAccount.email)")
                                    .font(.custom("Poppins-Regular", size: 15))
                                
                                Spacer()
                            }
                            .padding(.bottom, 20)
                            
                            HStack { // name hstack
                                Spacer()
                                    .frame(width:250)
                                VStack (alignment:.leading){
                                    Text("Lab/Club*")
                                        .font(.custom("Poppins-Medium", size: 25))
                                    
                                    TextField("Name", text: $labName)
                                        .font(.custom("Poppins-Regular", size: 20))
                                        .padding(20)
                                        .foregroundStyle(.myForeground)
                                        .clipShape(Capsule())
                                        .overlay(Capsule().strokeBorder(.appBlue, lineWidth: 2))
                                        .frame(width:300)
                                    if(showDisclaimer) {
                                        Text("Please enter lab/club name before creating!")
                                            .font(.custom("Poppins-Regular", size: 20))
                                            .foregroundStyle(.red.opacity(0.8))
                                    }
                                        
                                }
                                .padding(.bottom, 30)
                                Spacer()
                            } // end name hstack
                            HStack { // admin user hstack
                                Spacer()
                                    .frame(width:250)
                                
                                VStack(alignment: .leading) {
                                    Text("Admin Users")
                                        .font(.custom("Poppins-Medium", size: 25))
                                    Text("Users who who should have edit access to the sheet. (Club leaders, teachers, etc.)")
                                        .foregroundStyle(.gray)
                                        .font(.custom("Poppins-Regular", size: 15))
                                        .padding(.bottom, 15)
                                    TextField("Add administrative users...", text: $adminUserSearch)
                                        .font(.custom("Poppins-Regular", size: 20))
                                        .padding(20)
                                        .foregroundStyle(.myForeground)
                                        .clipShape(Capsule())
                                        .overlay(Capsule().strokeBorder(.appBlue, lineWidth: 2))
                                        .frame(width:500)
                                    
                                    if(!adminUserSearch.isEmpty){
                                        if(isLoading){
                                            ProgressView()
                                                .padding(10)
                                                
                                        } else {
                                            List {
                                                ForEach(filteredAdminUserList.prefix(5), id: \.self) { user in
                                                    ListUserView(name: user.name, email: user.email)
                                                       
                                                       
                                                    
                                                }
                                                .listRowBackground( Color.appBlue.opacity(0.22))
                                                
                                            }
                                            
                                            .scrollContentBackground(.hidden)
                                            .frame(width:500)
                                        }
                                    }
                                        
                                }
                                .padding(.bottom, 30)
                                Spacer()
                            } //end admin user hstack
                            .onChange(of: adminUserSearch) {
                                filteredAdminUserList = GoogleAdminAPI.users.filter({ user in
                                    user.name.localizedCaseInsensitiveContains(adminUserSearch)
                                })
                                
                            }
                            
                            HStack { //roster hstack
                                Spacer()
                                    .frame(width:250)
                                VStack(alignment:.leading) {
                                    Text("Roster")
                                        .font(.custom("Poppins-Medium", size: 25))
                                    TextField("Add students...", text: $rosterSearch)
                                        .font(.custom("Poppins-Regular", size: 20))
                                        .padding(20)
                                        .foregroundStyle(.myForeground)
                                        .clipShape(Capsule())
                                        .overlay(Capsule().strokeBorder(.appBlue, lineWidth: 2))
                                        .frame(width:500)
                                        
                                    if(!rosterSearch.isEmpty){
                                        if(isLoading){
                                            ProgressView()
                                                .padding(10)
                                                
                                        } else {
                                            List {
                                                ForEach(filteredRosterList.prefix(5), id: \.self) { user in
                                                    ListUserView(name: user.name, email: user.email)
                                                    
                                                }
                                                .listRowBackground( Color.appBlue.opacity(0.22))
                                                
                                            }
                                            .scrollContentBackground(.hidden)
                                            .frame(width:500)
                                        }
                                    }
                                    
                                }
                                Spacer()
                            }//end roster hstack
                            .onChange(of: rosterSearch) {
                                filteredRosterList = GoogleAdminAPI.users
                                    .filter({ user in
                                        user.name.localizedCaseInsensitiveContains(rosterSearch)
                                    })
                            }
                            
                            HStack {
                                Spacer()
                                    .frame(width:690)
                                CustomButton(color: .appBlue) {
                                    if(!labName.isEmpty){
                                        dismiss()
                                        
                                        SheetsAPI.createNewSheet(name:labName) { success in
                                            SheetsAPI.getLabs { labs in
                                                currentAccount.setLabs(labs: labs)
                                                
                                            }
                                        }
                                        
                                        
                                    } else {
                                       showDisclaimer = true
                                    }
                                    
                                } label: {
                                    Text("Create")
                                }
                                .padding(.bottom, 70)
                                Spacer()
                            }
                            
                           Spacer()
                        }
                       
                    }
                    .onChange(of: labName) {
                        showDisclaimer = false
                    }
                    .onAppear(){
                        isLoading = true
                        GoogleAdminAPI.getDomainUsers() { success in
                            if(success) {
                                filteredAdminUserList = GoogleAdminAPI.users.filter({ user in
                                    user.name.localizedCaseInsensitiveContains(adminUserSearch)
                                })
                                filteredRosterList = GoogleAdminAPI.users.filter({ user in
                                    user.name.localizedCaseInsensitiveContains(rosterSearch)
                                })
                                isLoading = false
                            }
                            
                        }
                        
                    }
                    
                }
            }
        }
    }
}

struct ListUserView: View {
    var name: String
    var email: String
    @State var selected: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(name)
                    .padding(.bottom, 10)
                    .font(.custom("Poppins-Regular", size: 20))
                Text(email)
                    .font(.custom("Poppins-Regular", size: 15))
            }
            if(selected){
                Image(systemName: "checkmark")
            }
        }
        .onTapGesture {
            selected.toggle()
        }
    }
}

#Preview {
    AddLabView()
}
