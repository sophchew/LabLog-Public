//
//  SheetsAPI.swift
//  LabLog
//
//  Created by Sophie Chew on 5/23/24.
//

import Foundation
import SwiftUI
import GTMAppAuth
import GTMSessionFetcherCore
import GTMSessionFetcherFull
import GoogleAPIClientForRESTCore
import GoogleAPIClientForREST_Sheets
import GoogleAPIClientForREST_Drive
import GoogleSignIn



struct SheetsAPI {
    
    private static let baseURL = "https://sheets.googleapis.com/v4/spreadsheets"
    private static var token = ""
    static let service = GTLRSheetsService()
    @State static var isReady = false
    
    static func prepareService(completion: @escaping()->Void)  { //keep trying so REST API can be used
        Task {
            let jwtToken = await ServiceAccount.generate()
           
            token = jwtToken

            isReady = true
            completion()
//            let authorizer = JWTAuthorizer(token: jwtToken)
//            DispatchQueue.main.async {
//                service.authorizer = authorizer
//           
//            }
        }
      //  service.authorizer = GIDSignIn.sharedInstance.currentUser?.fetcherAuthorizer
    }
    
    enum MajorDimension {
        case rows
        case columns
    }
    
    private static func get(sheetId: String, range: String, majorDim: MajorDimension = .rows, completion: @escaping (SheetResponse?, Error?) -> Void){
        
        do{
            var urlString = "\(baseURL)/\(sheetId)/values/\(range)?majorDimension="
            
            switch majorDim {
                case .rows:
                urlString.append("ROWS")
            case .columns:
                urlString.append("COLUMNS")
            }
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                
                if let error = error {
                    completion(nil, error)
                }
                do {
                    if let safeData = data {
                        let body = try JSONDecoder().decode(SheetResponse.self, from: safeData)
                        completion(body, nil)
                    } else {
                        print("im not working?")
                    }
                    
                    
                    
                } catch {
                    print("Error retrieving data")
                }
                
            }.resume()
            
        }
        catch {
            print("?")
        }
       
    }
    
    
    private static func write(sheetId: String, range: String, data: [[String]], completion: @escaping (Error?) -> Void) {
        
        let urlString = "\(baseURL)/\(sheetId)/values/\(range):append?valueInputOption=USER_ENTERED&insertDataOption=INSERT_ROWS"
        

        guard let url = URL(string: urlString) else {
            completion(NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["values": data]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(NSError(domain: "Invalid response", code: 0, userInfo: nil))
                return
            }
            
            completion(nil)
        }
        .resume()
    }
    
    private static func update(sheetId: String, range: String, data: [[String]], completion: @escaping(Error?) -> Void) {
        
        let urlString = "\(baseURL)/\(sheetId)/values/\(range)?valueInputOption=USER_ENTERED"
        
        guard let url = URL(string: urlString) else {
            completion(NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["values": data]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(NSError(domain: "Invalid response", code: 0, userInfo: nil))
                return
            }
            
            completion(nil)
        }
        .resume()
        
        
        
    }


    
    static func checkSheetId(sheetId: String, completion: @escaping(Bool) -> Void){
 
        let range = "Check Ins"
        service.authorizer = GIDSignIn.sharedInstance.currentUser?.fetcherAuthorizer
        
//        get(sheetId: sheetId, range: range) { data, error in
//            if let e = error {
//                print(e.localizedDescription)
//                completion(false)
//            }
//            completion(true)
//            
//        }
       
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId:sheetId,range: range)
        service.executeQuery(query) { ticket, result, error in
            if let e = error {
                print("no values found at: " + sheetId)
                completion(false)
            } else {
                completion(true)
            }
        
        }
         
    }
    
    static func getGradYears(sheetId : String, completion: @escaping(Array<String>) -> Void ){ // not in use, maybe future use case?
      
        let range = "Students!1:1"
        
        get(sheetId: sheetId, range: range) { data, error in
            if let e = error {
                print(e.localizedDescription)
                return
            }
            
            if let data = data, let rowArray = data.values {
                let row = rowArray[0]
                completion(row)
            } else {
                SheetsAPI.prepareService() {
                    completion([])
                }
                
            }
        }
        
        /*RESTAPI
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId:sheetId,range: range)
        service.executeQuery(query) { ticket, result, error in
            if let e = error {
                print(e)
                return
            }
            
            if let safeResult = result as? GTLRSheets_ValueRange {
                let row = safeResult.values![0] as! Array<String>
                completion(row)
            }
        }*/
    }
    
    static func getStudents(sheetId: String, completion: @escaping(Array<(String, String)>)->Void){
       
        let range = "Students"
        
        get(sheetId: sheetId, range: range, majorDim: .columns) { data, error in
            
            if let e = error {
                print(e.localizedDescription)
                return
            }
            
            if let data = data, let cols = data.values {
                var studentList:[(String, String)] = []
                for year in cols {
                    for student in Array(year.dropFirst()) {
                        studentList.append((student, year[0]))
                    }
                }
                completion(studentList.sorted(by: {$0.0.lowercased() < $1.0.lowercased()}))
            } else {
                SheetsAPI.prepareService() {
                    completion([])
                }
            }
            
        }
        
        /*REST API
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId:sheetId,range: range)
        query.majorDimension = kGTLRSheetsMajorDimensionColumns
        service.executeQuery(query) { t, result, e in
            if let se = e {
                print(se)
                return
            }
            
            if let safeResult = result as? GTLRSheets_ValueRange {
                let cols = safeResult.values! as! Array<Array<String>>
                for year in cols {
                    if (year[0] == gradYear) {
                        
                        completion(Array(year.dropFirst()))
                    }
                }
            }
        }
         */
        
    }
    
    static func getTeachers(sheetId: String, completion: @escaping(Array<String>) -> Void) {
       
        let range = "Teachers!A2:A"
        
        get(sheetId: sheetId, range: range, majorDim: .columns) { data, error in
            
            if let e = error {
                print(e.localizedDescription)
                return
            }
            
            if let data = data {
                let col = data.values![0]
                completion(col)
            }
        }
        
        /* REST API RIP
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: sheetId, range: range)
        query.majorDimension = kGTLRSheetsMajorDimensionColumns
        service.executeQuery(query) { t, r, e in
            if let se = e{
                print(se)
                return
                
            }
            
            if let safeR = r as? GTLRSheets_ValueRange{
                let col = safeR.values![0] as! Array<String>
                completion(col)
            }
        }
         */
    }
    
    static func checkInUser(sheetId: String, name: String, year: String, teacher: String, completion: @escaping(Bool)->Void){
        
        let range = "Check Ins"
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: currentDate)

        searchUserRow(sheetId: sheetId, user: name) { i in
            print(i)
            if (i != 0){
               
                completion(false); // found user already checked in
                return;
            } else {
               
                let rowData = [[name, year, teacher, "" + dateString]]
                
                write(sheetId: sheetId, range: range, data: rowData) { error in
                    if let e = error {
                        print(e.localizedDescription)
                        completion(false)
                        return
                    }
                    print("Values added successfully to Google Sheet.")
                    completion(true)
                    
                }
            }
            
        }
        
       
        /* REST API
        let valueRange = GTLRSheets_ValueRange()
        valueRange.majorDimension = "ROWS"
        valueRange.range = range
        valueRange.values = rowData
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(withObject: valueRange, spreadsheetId: sheetId, range: range)
        query.insertDataOption = "INSERT_ROWS"
        query.valueInputOption = "USER_ENTERED"
        
        service.executeQuery(query) { (ticket, result, error) in
            if let e = error {
                print(e)
                completion(false)
                return
            }
            print("Values added successfully to Google Sheet.")
            completion(true)
        }
        */
    }
    
    static func getActiveUsers(sheetId: String, completion: @escaping([[String]])->Void){
        let range = "Check Ins!A2:E"
        
        get(sheetId: sheetId, range: range) { data, error in
            
            if let e = error {
                print(e)
                return
            }
            if let data = data {
                if let rows = data.values {
                    var activeUsers = [[String]]()
                    for user in rows {
                        if(user.count != 5){
                            activeUsers.append(user)
                        }
                        
                    }

                    completion(activeUsers)
                }
            }
        }
        
        /* REST API (RIP :( )
         
        let query =  GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: sheetId, range: range)
        service.executeQuery(query) { t, result, e in
            if let se = e {
                print(se)
                return
            }
            
            if let safeResult = result as? GTLRSheets_ValueRange {
                if let rows = (safeResult.values as? Array<Array<String>>) {
                    var activeUsers = [Array<String>]()
                    for user in rows {
                        if(user.count != 5){
                            activeUsers.append(user)
                        }
                        
                    }

                    completion(activeUsers)
                }
                
            }
        }
         */
        
    }
    
    static func searchUserRow(sheetId: String, user: String, completion: @escaping(Int)-> Void)  {
        
        let range = "Check Ins!A:E"
        
        get(sheetId: sheetId, range: range) { data, error in
            if let e = error {
                print(e)
                completion(0)
            }
            if let data = data {
                if let rows = data.values {
                    for (index, row) in rows.enumerated(){
                        if (row[0] == user) {
                            if (row.count == 4){ // empty checkout found
                                print("Empty check out for user found")
                                completion(1 + index)
                                return
                            }
                        }
                        
                    }
                    completion(0)
                    return
                }
                
            }
        }
        
        
        
        /* REST API RIP
        let query =  GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: sheetId, range: range)
        service.executeQuery(query) { t, result, e in
            if let se = e{
                print(se)
                return
            }
            
            if let safeResult = result as? GTLRSheets_ValueRange {
                let rows = safeResult.values!
                
                for (index, row) in rows.enumerated(){
                    if (row[0] as! String == user) {
                        if (row.count == 4){ // empty checkout found
                            print("Empty check out for user found")
                            completion(1 + index)
                        }
                    }
                    
                }
            }
        }
        */
    }
    
    static func checkOutUser(sheetId:String, user: ActiveUser, completion: @escaping(Bool)->Void)   {
        
        searchUserRow(sheetId: sheetId, user: user.name) { row in
            let range = "Check Ins!E\(row):G\(row)"
            print("User found at " + range)
            let currentDate = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = dateFormatter.string(from: currentDate)
            
            
            if let checkedInTime = dateFormatter.date(from: user.checkedInDate) {
                let duration = checkedInTime.distance(to: currentDate)
                let timeFormatter = DateComponentsFormatter()
                timeFormatter.unitsStyle = .abbreviated
                timeFormatter.allowedUnits = [.hour, .minute]
                let durationString = timeFormatter.string(from: duration)!
                print("User was checked in for " + durationString)
                
                
                let rowData = [[dateString, durationString, user.notes]]
                
                update(sheetId: sheetId, range: range, data: rowData) { error in
                    if let e = error {
                        print(e.localizedDescription)
                        completion(false)
                        return
                    }
                    print("User checked out successfully")
                    
                    
                    completion(true)
                    
                    
                }
            }
           
            
           
            
            /* REST API
            let valueRange = GTLRSheets_ValueRange()
            valueRange.range = range
            valueRange.values = rowData
            
            let update = GTLRSheetsQuery_SpreadsheetsValuesUpdate.query(withObject: valueRange, spreadsheetId: sheetId, range: range)
            update.valueInputOption = "USER_ENTERED"
            
            service.executeQuery(update) { t, result, e in
                if let se = e{
                    print(se)
                    return
                }
                print("User checked out successfully")
                completion(true)
            }
             */
            
        }
             
        
    }
    
    
    static func getLabs(completion:@escaping([[String]])->Void){
        get(sheetId: "12mpvqifjWvSRe5jnKK78Weip7BrcFHlDm3bWVG2ZXFM", range: "Lab Sheet Data") { data, error in
            
            if let e = error {
                print(e.localizedDescription)
                return
            }
          
            if let data = data {
                if var rows = data.values {
                    rows = Array(rows.dropFirst())
                    var labs = [[String]]()
                    let dispatchGroup = DispatchGroup()
                    for row in rows {
                        dispatchGroup.enter()
                        checkSheetId(sheetId: row[1]) { success in
                            if success {
                                print("This user has access to \(row[0])")
                                labs.append(row)
                            } else {
                                print("This user has no access to \(row[0])")
                            }
                            dispatchGroup.leave()
                            
                        }
                    }
                    dispatchGroup.notify(queue: .main) {
                        completion(labs)
                    }
                    
                } else {
                    print("uh")
                }
            }
            
        }
    }
    
    static func createNewSheet(name: String, completion: @escaping(Bool) -> Void){ ///Creates a new sheet within the Google user's Google Drive
        
        //Rest API create a new sheet in user's drive
        //get ahold of sheetId and add to main sheet, maybe separate function bc using service account
        //share sheet with lab log service account
        
        let newSpreadsheet = GTLRSheets_Spreadsheet()
        let properties = GTLRSheets_SpreadsheetProperties()
        properties.title = name + " Check Ins"  // change to club/lab name
        newSpreadsheet.properties = properties
        
        let studentSheet = GTLRSheets_Sheet()
        let studentProperties = GTLRSheets_SheetProperties()
       
        studentProperties.title = "Students"
        studentSheet.properties = studentProperties
        
        let adminSheet = GTLRSheets_Sheet()
        let adminProperties = GTLRSheets_SheetProperties()
        adminProperties.title = "Teachers"
        adminSheet.properties = adminProperties
        
        let checkInSheet = GTLRSheets_Sheet()
        let checkInProps = GTLRSheets_SheetProperties()
       // let checkInBandedRange = GTLRSheets_BandedRange()

        checkInProps.title = "Check Ins"
      //  checkInBandedRange.rowProperties = GTLRSheets_BandingProperties()
//        let color1 = GTLRSheets_ColorStyle(); template alternating color
//        color1.rgbColor = GTLRSheets_Color()
//        color1.rgbColor.
     //   checkInBandedRange.rowProperties?.firstBandColorStyle = GTLRSheets_ColorStyle().rgbColor.
        checkInSheet.properties = checkInProps
        
        newSpreadsheet.sheets = [studentSheet, adminSheet, checkInSheet]
        
        let query = GTLRSheetsQuery_SpreadsheetsCreate.query(withObject: newSpreadsheet)
        
        service.executeQuery(query) { ticket, result, error in
            if let se = error {
                print(se.localizedDescription)
                completion(false)
            }
            
            if let createdSpreadsheet = result as? GTLRSheets_Spreadsheet{
                
                
                let sheetId = createdSpreadsheet.spreadsheetId!
                print("SheetId=\(sheetId)")
                shareSheetWithService(sheetId: sheetId) { success in
                    if success {
                        // writing to sheet to create template
                        
                        write(sheetId: sheetId, range: "Check Ins", data: [["Student", "Grad Year", "Teacher", "Time Checked In", "Time Checked Out", "Note"]]) { error in
                            if let e = error {
                                print(e)
                                completion(false)
                            }
                            print("Template created")
                        }
                      
                        
                        
                        write(sheetId: "12mpvqifjWvSRe5jnKK78Weip7BrcFHlDm3bWVG2ZXFM", range: "Lab Sheet Data", data: [[name, sheetId]]) { error in
                            if let e = error {
                                print(e)
                                completion(false)
                            }
                            print("Lab added successfully to Google Sheet.")
                            completion(true)
                            
                        }
                    }
                }
                
            }
        }
        
        
    }
    
    static func shareSheetWithService(sheetId: String, completion: @escaping(Bool) -> Void) {
        let driveService = GTLRDriveService()
        driveService.authorizer = GIDSignIn.sharedInstance.currentUser?.fetcherAuthorizer
        
        let perms = GTLRDrive_Permission()
        perms.type = "user"
        perms.role = "writer"
        perms.emailAddress = ServiceAccount.email
        let query = GTLRDriveQuery_PermissionsCreate.query(withObject: perms, fileId: sheetId)
        query.sendNotificationEmail = false
        
        driveService.executeQuery(query) { ticket, res, e in
            if let se = e {
                print("Error sharing spreadsheet: \(se.localizedDescription)")
                completion(false)
            }
            print("Spreadsheet shared successfully with service account.")
            completion(true)
        }
        
        
    }
    
    static func submitFeedback(email: String, trouble: String, like: String, suggestion: String, completion: @escaping(Bool) -> Void) {
        write(sheetId: "1f-Z3IoYkguP2YnulWiLg3fWXWGpZsNQtG2_r158nBAQ", range: "Feedback", data: [[email, trouble, like, suggestion]]) { error in
            if let e = error {
                print(e.localizedDescription)
                completion(false)
            }
            print("Feedback submitted!")
            completion(true)
        }
        
    }
    
}

struct SheetResponse: Codable {
    let values: [[String]]?
}
