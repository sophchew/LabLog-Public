//
//  LabData.swift
//  LabLog
//
//  Created by Sophie Chew on 5/27/24.
//

import Foundation


class LabData: ObservableObject, Identifiable {
    @Published var activeUserList = [ActiveUser]()
    var name: String
    var sheetId: String
    var id = UUID()
    
    
    init(name: String, sheetId: String){
        self.name = name
        self.sheetId = sheetId
    }
    
    func updateActiveUserList(){
        
        SheetsAPI.getActiveUsers(sheetId: sheetId) { users in
            DispatchQueue.main.async {
                self.activeUserList.removeAll()
                for user in users {
                    if user != []{
                        self.activeUserList.append(ActiveUser(name: user[0], year: user[1], teacher: user[2], checkedInDate: user[3], labName: self.name))
                    }
                    
                }
            }
        }
        
    }
    
    
}
