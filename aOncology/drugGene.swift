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
    func drugListAdjusted (outDrugL: [DTRelation_C])
}

/*
var dicGDL0 = ["BRAF": ["d1", "d2"],
               "MTOR": ["d2", "d3"],
               "EGFR": ["d4", "d5", "d6"] ]
*/
//var dr1L : [AberDrugL_C] = AberDrugL_C (_aberration: "V600E", DrugIc50L: [DrugIc50_C(drugId:1, drugName:"toto",_Ic50:3.5)] )



var dr2L = [(1, "toto", true), (2, "titi", true)]

//var dr3L = dr2L as! [Drug_C]


var dicGDL1   =
              [ "BRAF": [("d1",3.0), ("d2",2.1)],
                "EGFR": [("d4",2.0), ("d5",2.5), ("d6",5)] ]

var dicGDL2  : [String: [String:Double]] =
    
    [  "BRAF": ["d1":3.14, "d2":2.1],
       "EGFR": ["d4":2.0, "d5":2.5, "d6":5] ]


var dicGDL3  : [String: [String: [String:Double]]] =


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





class geneDrugs {
   var gene:   String
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

    
    func targetToAdd (theTarget: Target_C,  inDrugL: [DTRelation_C]) {
       
       // var updDrugL :[DrugIc50_C] = inDrugL
    //    var updDrugL :[DrugIc50_C] = [DrugIc50_C]()
        var updDrugL :[DTRelation_C] = [DTRelation_C]()

        
        if let aberL = dicGDL3[theTarget.hugoName] {
            // the HugoName exist with some aberrations
            // aberration exist at least with empty string
            
            let aberration = theTarget.aberDesc
            if let drugIc50L =  dicGDL3 [theTarget.hugoName]! [aberration!] {
                // drugIc50 List exist for that aberration
                
                for (drug, ic50) in drugIc50L {
                    
//                    if updDrugL.contains(where: { $0.drugName == drug  }){
                    if updDrugL.contains (where: { $0.drugIc50.drugName == drug  }){
                        //already in there
                    } else {
                        print ("Real aberration Added \(drug) \n")
                        let newDrugIc50 = DrugIc50_C ( drugId: 0, drugName : drug , _Ic50: ic50)
                        let newTargetMode = TargetMode_C (id: 0, hugoName: theTarget.hugoName, aberration: theTarget.aberDesc!, mode: "direct")
                        //       updDrugL.append (DrugIc50_C ( drugId:0, drugName: drug, _Ic50: ic50) )
                         updDrugL.append (DTRelation_C (drugIc50: newDrugIc50, targetMode:newTargetMode) )
                    }
                }
            } else {
                // no DrugIc50 List exist for that aberration
                print ("No Ic50 for that aberration\n")
            }
        }
        
        /*
            // if aberDesc != nil but no drugList the force aberDesc to Nil to match nil(aberrations) entries
            
            let drugIc50L =  dicGDL3 [theTarget.hugoName]! [theTarget.aberDesc!]!
            if (drugIc50L != nil){
            for (drug, ic50) in drugIc50L {
                if updDrugL.contains(where: { $0.drugName == drug  }){
                    //already in there
                } else {
                    updDrugL.append (DrugIc50_C ( drugId:0, drugName: drug, _Ic50: ic50) )
                }
                
            }
            }
        }
        print (updDrugL)
   
            
            if (dicGDL3[theTarget.hugoName])
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
            updDrugL.sort(by: { $0.drugName < $1.drugName })
            newGeneDelegate.drugListAdjusted (outDrugL : updDrugL )
        }*/
    }
    
    
    func geneToSub (target: Target_C){
        /*
        var newDrugL = [Drug_C]()
      
        // rebuild the entire drug list
        for target in targetL {
           
            let dicDrugIc50 = dicGDL[target]!
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
      */
    }
 
    
}






