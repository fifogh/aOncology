//
//  Case_C.swift
//  aOncology
//
//  Created by Philippe-Faurie on 5/29/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import Foundation



//------------------------------------------------------------------------------
// Case Class

//class Case_C : NSObject, NSCoding {

class Case_C {

    var caseId    : String
    var nickName  : String
    var age       : String
    var targetL   : [Target_C]
    var diagnosis : String
    

    init (nickName:String, age: String, targetL : [Target_C], diagnosis: String){
        
        self.caseId    = ""
        self.nickName  = nickName
        self.age       = age
        self.targetL   = targetL
        self.diagnosis = diagnosis
        
        self.caseId = self.createId()
        
    }
    
    init (caseId: String, nickName:String, age: String, targetL : [Target_C], diagnosis: String){
        
        self.caseId    = caseId
        self.nickName  = nickName
        self.age       = age
        self.targetL   = targetL
        self.diagnosis = diagnosis
        
    }
    
    func createId () -> String {

        var dateComponents = DateComponents()
        
 
        dateComponents.year = 2016
        dateComponents.month = 11
        dateComponents.day = 04
        dateComponents.hour = 13
        dateComponents.minute = 8
        dateComponents.second = 0
        
        // Create date from components
        let userCalendar = Calendar.current // user calendar
        let dateRef = userCalendar.date(from: dateComponents)
        
        let elapsed = Date().timeIntervalSince(dateRef!)
        return String ( elapsed )
    }

   

}
