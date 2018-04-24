//
//  drugGene.swift
//  aOncology
//
//  Created by Philippe-Faurie on 4/17/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import Foundation

//var  drugNameL = [drugName] ()
//var geneNameL = ["EGFR", "BRAF", "ALK"]
//var geneDrugs1 : geneDrugs = geneDrugs(igene:"EGFR", idrugL: drugl1)
/*
 var allGL = ["EGFR", "BRAF", "ALK"]
 var allGDL : [geneDrugs] = [ geneDrugs (igene: "EGFR", idrugL: ["d1", "d2", "d3"]),
 geneDrugs (igene: "BRAF", idrugL: ["d1", "d4", "d5"]),
 geneDrugs (igene: "ALK",  idrugL: ["d6", "d7"])]
 */

/*
 func geneToAdd2 ( name: String, inDrugL:[String]) {
 let index =  allGL.index(of:name)
 if (index != nil) {
 newGeneDelegate.drugListFound( drugL : allGDL[index!].drugL)
 }
 }
 */


protocol geneAddedDelegate{
    func drugListAdjusted (outDrugL: [String])
}

/*
var dicGDL0 = ["BRAF": ["d1", "d2"],
               "MTOR": ["d2", "d3"],
               "EGFR": ["d4", "d5", "d6"] ]
*/

var dicGDL1  = [ "BRAF": [("d1",3.0), ("d2",2.1)],
                "EGFR": [("d4",2.0), ("d5",2.5), ("d6",5)] ]

var dicGDL2  = [  "BRAF": ["d1":3.14, "d2":2.1],
                  "EGFR": ["d4":2.0, "d5":2.5, "d6":5] ]


class geneDrugs {
   var gene: String
   var drugL: [String]
    
    var ic50 :Double
    
    
 
   var newGeneDelegate : geneAddedDelegate!

    init (igene:String, idrugL: [String]) {
       gene  = igene
       drugL = idrugL
        ic50 = 0;
        
        
       
       // titi = dicGDL2 ["BRAF"]!
       // ic50 = titi["d1"]!
        
        ic50 = dicGDL2 ["BRAF"]!["d1"]!

        print (ic50)
        
    }

    
    func geneToAdd (name: String,  inDrugL: [String]){
        if(dicGDL[name] != nil){
           newGeneDelegate.drugListAdjusted (outDrugL : Array (Set ( dicGDL[name]! + inDrugL ) ).sorted() )
        }
    }
    
    
    func genesToRebuild (geneL: [String]){
        var outDrugL = [String]()
        
        // rebuild the entire drug list
        for (gene) in geneL {
            outDrugL = Array (Set ( dicGDL[gene]! + outDrugL ) )
        }
        newGeneDelegate.drugListAdjusted (outDrugL : outDrugL.sorted() )
    }
    
}






