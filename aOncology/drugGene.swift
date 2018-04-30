//
//  drugGene.swift
//  aOncology
//
//  Created by Philippe-Faurie on 4/17/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import Foundation


protocol geneAddedDelegate{
    func drugListAdjusted (outDrugL: [DTRelation_C])
}

/*
var dicGDL1   =
              [ "BRAF": [("d1",3.0), ("d2",2.1)],
                "EGFR": [("d4",2.0), ("d5",2.5), ("d6",5)] ]

var dicGDL2  : [String: [String:Double]] =
    
    [  "BRAF": ["d1":3.14, "d2":2.1],
       "EGFR": ["d4":2.0, "d5":2.5, "d6":5] ]




var dicGDL3 : [String: [String: [String:Double]]] =


    [  "BRAF":
            ["V600E": ["d1":3.14, "d2":2.1] ,
             "V700E": ["d4":2.0,  "d5":2.5, "d6":5] ,
             "":      ["d1":2.0,  "d15":2.5, "d16":5] ],
        
        "EGFR" :
            ["" :      ["d13":2.0, "d15":2.5, "d16":5] ,
             "T790M" : ["d3":2.0,  "d5":2.5,  "d6":5] ],
        
        "MTOR" :
            ["TOTO"  : ["d13":2.0, "d15":2.5, "d16":5] ,
             "T790M" : ["d3":2.0,  "d5":2.5,  "d6":5] ]
    ]

*/

var dicGDL3  = dicDTRelL


//------------------------------------------------------------------------------
// DRUG Class

class geneDrugs {
    
    var newGeneDelegate : geneAddedDelegate!
    
    //--------------------------------------------------------------------------
    // Build new Drug list after a target was added
    
    func targetToAdd (theTarget: Target_C,  inDrugL: [DTRelation_C]) {
        
        var updDrugL = checkAndAdd (theTarget: theTarget,  inDrugL: inDrugL)
        updDrugL.sort(by: { $0.drug.drugName < $1.drug.drugName })
        newGeneDelegate.drugListAdjusted (outDrugL : updDrugL )
    }
    
    
    
    //--------------------------------------------------------------------------
    // Rebuild entirely Drug list after a target was removed

    func rebuildAll (inTargetL: [Target_C]) {
        
        var newDrugL = [DTRelation_C]()
        for target in inTargetL {
            newDrugL = self.checkAndAdd (theTarget: target,  inDrugL: newDrugL)
            targetToAdd (theTarget: target,  inDrugL: newDrugL)
        }
        
        newDrugL.sort(by: { $0.drug.drugName < $1.drug.drugName })
        newGeneDelegate.drugListAdjusted (outDrugL : newDrugL )
    }

    
    //--------------------------------------------------------------------------
    // Does all the job of adding a drug in the list

    func checkAndAdd (theTarget: Target_C,  inDrugL: [DTRelation_C]) -> [DTRelation_C] {
        var updDrugL  = inDrugL
        
        if ( dicGDL3[theTarget.hugoName] != nil ) {
            // the HugoName exist with some aberrations
            // aberration exist at least with empty string
            let aberration = theTarget.aberDesc
            var drugIc50L =  dicGDL3 [theTarget.hugoName]! [aberration!]

            // if let drugIc50L =  dicGDL3 [theTarget.hugoName]! [aberration!] {
            if (drugIc50L == nil) {
                drugIc50L =  dicGDL3 [theTarget.hugoName]! [""]
            }
            if (true){

                // drugIc50 List exist for that aberration
                for (drug, ic50) in drugIc50L! {
                    
                    let index = updDrugL.index (where: { $0.drug.drugName == drug  })
                    if (index != nil) {
                        
                         // Drug already exist. add the target in Target List
                        var targetModeL = updDrugL [index!].targetModeL!
                        if targetModeL.contains (where: {($0.hugoName == theTarget.hugoName)&&($0.aberDesc == theTarget.aberDesc ) }) {
                            
                            // target already in here
                            
                        } else {
                            
                            // add that target in the list of targets for that drug
                            targetModeL.append (TargetHitMode_C (id: 0, hugoName: theTarget.hugoName,
                                                                 aberration: theTarget.aberDesc!,mode: "direct", Ic50: ic50 ))
                        }
                        
                    } else {
                        
                        //  create a new Drug-Target relation and add it
                        let newDrug = Drug_C ( drugId: 0, drugName : drug)
                        let newTargetMode = TargetHitMode_C (id: 0, hugoName: theTarget.hugoName,
                                                             aberration: theTarget.aberDesc!, mode: "direct", Ic50: ic50 )
                
                        
                        let newDTRelation = DTRelation_C ( drug: newDrug )
                        newDTRelation.targetModeL.append ( newTargetMode )

                        updDrugL.append ( newDTRelation )
                    }
                }//for
            }
        }
        return (updDrugL)
    }
}






