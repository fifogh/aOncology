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
    func drugListAdjusted (outDrugL: [Drug_C])
}

/*
var dicGDL0 = ["BRAF": ["d1", "d2"],
               "MTOR": ["d2", "d3"],
               "EGFR": ["d4", "d5", "d6"] ]
*/

var dicGDL1   =
              [ "BRAF": [("d1",3.0), ("d2",2.1)],
                "EGFR": [("d4",2.0), ("d5",2.5), ("d6",5)] ]

var dicGDL2  : [String: [String:Double]] =
    
    [  "BRAF": ["d1":3.14, "d2":2.1],
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
        
        ic50 = dicGDL2 ["BRAF"]!["d1"]!

        print (ic50)
    }

    
    func geneToAdd (theGene: String,  inDrugL: [Drug_C]) {
        if (dicGDL[theGene] != nil){
            var updDrugL :[Drug_C] = inDrugL
            let dicDrugIc50 = dicGDL[theGene]!
            let newDrugL    = [String](dicDrugIc50.keys)

            for d in newDrugL {
                if inDrugL.contains(where: { $0.drugName == d  }) {
                    //drug already in there
                } else {
                    updDrugL.append ( Drug_C (id:0, name : d))
                }
            }
            newGeneDelegate.drugListAdjusted (outDrugL : updDrugL )
        }
    }
    
    
    func genesToRebuild (geneL: [String]){
        var newDrugL = [Drug_C]()
        
        // rebuild the entire drug list
        for gene in geneL {
            let dicDrugIc50 = dicGDL[gene]!
            let dicDrugL    = [String](dicDrugIc50.keys)
            
            for d in dicDrugL {
                if newDrugL.contains(where: { $0.drugName == d  }) {
                    //drug already in there
                } else {
                    newDrugL.append ( Drug_C (id:0, name : d))
                }
            }
        }
        newGeneDelegate.drugListAdjusted (outDrugL : newDrugL )
    }
    
    
}






