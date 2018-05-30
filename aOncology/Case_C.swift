//
//  Case_C.swift
//  aOncology
//
//  Created by Philippe-Faurie on 5/29/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import Foundation




let baseCase = "OCLTR_185_"
var counter = 81

//------------------------------------------------------------------------------
// Case Class

class Case_C : NSObject, NSCoding {

    var caseId    : String
    var nickName  : String
    var age       : String
    var targetL   : [Target_C]
    var diagnosis : String
    
    init (caseId: String, nickName:String, age: String, targetL : [Target_C], diagnosis: String){
        
        counter += 1
        self.caseId    = baseCase + String (counter)
        self.nickName  = nickName
        self.age       = age
        self.targetL   = targetL
        self.diagnosis = diagnosis
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        self.caseId = aDecoder.decodeObject(forKey: "caseId") as? String ?? ""
        self.nickName = aDecoder.decodeObject(forKey: "nickName") as? String ?? ""
        self.age = aDecoder.decodeObject(forKey: "age") as? String ?? ""
        self.diagnosis = aDecoder.decodeObject(forKey: "diagnosis") as? String ?? ""
        self.targetL = [Target_C]()

    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(caseId, forKey: "caseId")
        aCoder.encode(nickName, forKey: "nickName")
        aCoder.encode(age, forKey: "age")
        aCoder.encode(diagnosis, forKey: "diagnosis")
    }

    
    func saveCases () {
        let casesData = NSKeyedArchiver.archivedData(withRootObject: caseL)
        UserDefaults.standard.set(casesData, forKey: "cases")
    }
    
    func loadCases () {
        guard let casesData = UserDefaults.standard.object(forKey: "cases") as? NSData else {
            print("'cases' not found in UserDefaults")
            return
        }
        
        guard let restoredCaseL = NSKeyedUnarchiver.unarchiveObject(with: casesData as Data) as? [Case_C] else {
            print("Could not unarchive from casesesData")
            return
        }
        
        caseL = restoredCaseL
    }
    
    
}
