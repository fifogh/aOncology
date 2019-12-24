//
//  CaseModel.swift
//  aOncology
//
//  Created by Philippe-Faurie on 5/31/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import UIKit

protocol CaseModelProtocol: class {
    func casesDownloaded(items: [Case_C])
}


let baseUrlPath   = "http://www.feugnes.com/"
let getCaseList   = "getCases.php"
let getTargetList = "getTargets.php"
let setCase       = "setCases.php"
let setTarget     = "setTargets.php"
let delCase       = "delCase.php"


class CaseModel: NSObject {
    
    //properties
    
    weak var delegate: CaseModelProtocol!

    var targetList = [Target_C]()
    var caseList   = [Case_C]()

    var caseListIn   = false
    var targetListIn = false
    
    
    //-----------------------------------
    // reques to download the case lists
    
    func loadCases () {
        
        caseListIn   = false
        targetListIn = false

        targetList.removeAll()
        caseList.removeAll()

        self.downloadCases()
        self.downloadTargets()
    }
    
    
    //-----------------------------------
    // activate protocol
    
    func checkAllIn () {
        if ((caseListIn == true ) && ( targetListIn == true)) {
            
            //add now list of targets in each case
            for c in caseList {
                for t in targetList {
                    if t.id == c.caseId{
                        c.targetL.append(t)
                    }
                }
            }
            self.delegate.casesDownloaded(items: caseList)
        }
    }
    
    //-----------------------------------
    // save a cases and the targets
    
    func saveCase (index : Int) {
        let theCase = caseL[index]
        savetheCase(theCase: theCase)
        
        for t in theCase.targetL {
            saveTarget(theCase: theCase, theTarget: t)
        }
    }
    
        
    func savetheCase (theCase: Case_C) {
        let url = NSURL(string: baseUrlPath + setCase) // locahost MAMP - change to point to your database server
        
        var request = URLRequest(url: url! as URL)
        request.httpMethod = "POST"
        
        // set the string
        var dataString = ""
        
        dataString = dataString + "&user=PFA"
        dataString = dataString + "&case=\(theCase.caseId)"
        dataString = dataString + "&nick=\(theCase.nickName)"
        dataString = dataString + "&diag=\(theCase.diagnosis)"
        dataString = dataString + "&age=\(theCase.age)"
        
        // convert the post string to utf8 format
        let dataD = dataString.data(using: .utf8)
        
        do
        {
            // the upload task, uploadJob, is defined here
            let uploadJob = URLSession.shared.uploadTask(with: request, from: dataD)
            {
                data, response, error in
                if error != nil {
                    
                    // display an alert if there is an error inside the DispatchQueue.main.async
                    DispatchQueue.main.async {
                        print ( "Queue Case Didn't Work?")
                    }
                }
                else
                {
                    if let unwrappedData = data {
                        
                        // Response from web server hosting the database
                        let returnedData = NSString(data: unwrappedData, encoding: String.Encoding.utf8.rawValue)
                        
                        // insert into database did not worked
                        if returnedData != "1" {
                            // display an alert if an error and database insert didn't worked (return != 1) inside the DispatchQueue.main.async
                            DispatchQueue.main.async {
                                  print ( "Upload Case Didn't Work?")
                            }
                        }
                    }
                }
            }
            uploadJob.resume()
        }
    }
    
        
    //-----------------------------------
    // save a cases and the targets
    
    func saveTarget (theCase: Case_C, theTarget : Target_C) {
        
        let url = NSURL(string: baseUrlPath + setTarget)
        
        var request = URLRequest(url: url! as URL)
        request.httpMethod = "POST"
        
        // set the string
        var dataString = ""
        
        dataString = dataString + "&user=PFA"
        dataString = dataString + "&case=\(theCase.caseId)"
        dataString = dataString + "&hugo=\(theTarget.hugoName)"
        if let aberDesc = theTarget.aberDisp {
            dataString = dataString + "&aber=\(aberDesc)"
        }
 
        // convert the post string to utf8 format
        let dataD = dataString.data(using: .utf8)
        
        do
        {
            // the upload task, uploadJob, is defined here
            let uploadJob = URLSession.shared.uploadTask(with: request, from: dataD)
            {
                data, response, error in
                if error != nil {
                    
                    // display an alert if there is an error inside the DispatchQueue.main.async
                    DispatchQueue.main.async {
                        print ( "Queue Target Didn't Work?")
                    }
                }
                else
                {
                    if let unwrappedData = data {
                        
                        // Response from web server hosting the database
                        let returnedData = NSString(data: unwrappedData, encoding: String.Encoding.utf8.rawValue)
                        
                        // insert into database did not worked
                        if returnedData != "1" {
                            // display an alert if an error and database insert didn't worked (return != 1) inside the DispatchQueue.main.async
                            DispatchQueue.main.async {
                                print ( "Upload Target Didn't Work?")
                            }
                        }
                    }
                }
            }
            uploadJob.resume()
        }
    }
    
    
    //-----------------------------------
    // the case without the targets
    func deleteCase(theCase: Case_C) {
        
        let caseId = "&case=" + theCase.caseId
        // TMP !!!
        let urlPath = baseUrlPath + delCase + "?user=PFA" + caseId
        
        let url: URL = URL(string: urlPath)!
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        
        let task = defaultSession.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                print("Failed to delete the case")
            }else {
                print("Case Deleted")
            }
        }
        task.resume()
    }
    
    
    //-----------------------------------
    // the case without the targets
    func downloadCases() {

        // TMP !!!
        let urlPath = baseUrlPath + getCaseList + "?user=PFA"
        
        let url: URL = URL(string: urlPath)!
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        
        let task = defaultSession.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                print("Failed to download data")
            }else {
                print("Data downloaded")
                self.parseJSONCases(data!)
            }
        }
        task.resume()
    }
    
    
    
    //-----------------------------------
    // the targets separately
    
    func downloadTargets() {
        
        // TMP !!!
        let urlPath = baseUrlPath + getTargetList + "?user=PFA"
        
        let url: URL = URL(string: urlPath)!
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        
        let task = defaultSession.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                print("Failed to download targets")
            }else {
                print("Targets downloaded")
                self.parseJSONTargets(data!)
            }
        }
        task.resume()
    }

    
    //-----------------------------------
    // parse the targets
    
    func parseJSONTargets(_ data:Data) {
        
        var jsonResult = NSArray()
        
        do{
            jsonResult = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
            
        } catch let error as NSError {
            print(error)
            
        }
        
        var jsonElement = NSDictionary()
        
        for i in 0 ..< jsonResult.count
        {
            
            jsonElement = jsonResult[i] as! NSDictionary
            
            //the following insures none of the JsonElement values are nil through optional binding
            
            if  let caseId      = jsonElement["caseId"]     as? String,
                let hugoName    = jsonElement["hugoName"]   as? String,
                let aberration  = jsonElement["aberration"] as? String
            {
                
                let theTarget = Target_C (id: caseId, hugoName:hugoName, aberration: aberration)
                targetList.append(theTarget)
            }
        }
        
        DispatchQueue.main.async(execute: { () -> Void in
        
            self.targetListIn = true
            self.checkAllIn()

        
        })
    }
    
    //-----------------------------------
    // parse the cases

    func parseJSONCases(_ data:Data) {
        
        var jsonResult = NSArray()
        
        do{
            jsonResult = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
            
        } catch let error as NSError {
            print(error)
            
        }
        
        var jsonElement = NSDictionary()
        
        for i in 0 ..< jsonResult.count
        {
            
            jsonElement = jsonResult[i] as! NSDictionary

            //the following insures none of the JsonElement values are nil through optional binding
            
            if  let caseId    = jsonElement["caseId"]    as? String,
                let nickName  = jsonElement["nickName"]  as? String,
                let age       = jsonElement["age"]       as? String,
                let diagnosis = jsonElement["diagnosis"] as? String
            {
                let theCase = Case_C (caseId: caseId, nickName:nickName, age: age, targetL : [Target_C](), diagnosis: diagnosis)
                caseList.append (theCase)

            }
            
        }
        
        DispatchQueue.main.async(execute: { () -> Void in
            
            self.caseListIn = true
            self.checkAllIn()
            
        })
    }
}



