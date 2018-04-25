//
//  Drug_C.swift
//  aOncology
//
//  Created by Philippe-Faurie on 4/24/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import Foundation
class Drug_C {
    
    var Id : Int
    var drugName : String
    var allowed : Bool
   
    
    init (id: Int, name: String){
        drugName = name
        Id       = id
        allowed  = true
    }
}
