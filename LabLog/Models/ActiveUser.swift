//
//  User.swift
//  LabLog
//
//  Created by Sophie Chew on 5/26/24.
//

import Foundation

class ActiveUser: Identifiable{
    let name: String
    let year: String
    let teacher: String
    let checkedInDate: String
    let labName: String
    var checkedInTime = ""
    var notes = ""
    var id = UUID()
    
    init(name: String, year: String, teacher: String, checkedInDate: String, labName: String) {
        self.name = name
        self.year = year
        self.teacher = teacher
        self.labName = labName
        self.checkedInDate = checkedInDate
        self.checkedInTime = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let date = dateFormatter.date(from: checkedInDate) {
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH:mm a"
                let timeString = timeFormatter.string(from: date)
                return timeString
            }
            return ""
        }()
        self.id = UUID()
    }
    
    
    
}
