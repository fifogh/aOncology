//
//  drugGene.swift
//  aOncology
//
//  Created by Philippe-Faurie on 4/17/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import Foundation

enum SubsMode {case direct, semidirect, indirect }


protocol targetChangeDelegate{
    func drugListAdjusted (outDrugL: [DTRelation_C])
}

var dicGDL3  = dicDTRelL


//------------------------------------------------------------------------------
// GeneDRUG Class

class geneDrugs {
    
    var newGeneConfigDelegate : targetChangeDelegate!
    
    //--------------------------------------------------------------------------
    // Update DrugTarg Relation list after a target was added
    
     func targetToAdd (theTarget: Target_C,  inDrugL: [DTRelation_C], allowed: Bool) {

        var updDTRelL = checkAndAdd (theTarget: theTarget,  inDTRelL: inDrugL, allowed: allowed)
        updDTRelL.sort(by: { $0.drug.drugName < $1.drug.drugName })
        newGeneConfigDelegate.drugListAdjusted (outDrugL : updDTRelL )
    }
    
    
    
    //--------------------------------------------------------------------------
    // Rebuild entirely Drug list after a target was removed

    func rebuildAll (inTargetL: [Target_C], inDTRelL: [DTRelation_C], allowed: Bool) {
 
        var newDTRelL = [DTRelation_C]()
        for target in inTargetL {
            newDTRelL = self.checkAndAdd (theTarget: target,  inDTRelL: newDTRelL, allowed: allowed)
            targetToAdd (theTarget: target,  inDrugL: newDTRelL, allowed: allowed)
         }
        
        // retrieve and reassign the drug.allowed field 
        for t in newDTRelL {
            let pos  = inDTRelL.index( where: {  ($0.drug.drugName == t.drug.drugName)  })            
            if (pos != nil) {
                t.drug.allowed = inDTRelL [pos!].drug.allowed
            }
        }
        
        newDTRelL.sort(by: { $0.drug.drugName < $1.drug.drugName })
        newGeneConfigDelegate.drugListAdjusted (outDrugL : newDTRelL )
    }

    
    //--------------------------------------------------------------------------
    // Does all the job of adding a drug in the list

    func checkAndAdd (theTarget: Target_C,  inDTRelL: [DTRelation_C], allowed: Bool) -> [DTRelation_C] {
        var updDTRelL  = inDTRelL
        
        var theTargetMode : TargetHitMode_C?
        
        if ( dicGDL3[theTarget.hugoName] != nil ) {
            // The HugoName exist
            // note: an aberration exist at least with empty string
            // otherwise the hugo name is ot even present
            
            let aberration = theTarget.aberDesc
            var drugIc50L =  dicGDL3 [theTarget.hugoName]! [aberration!]

            // if no Drug for that particular aberration
            // look for the list with no aberration
            if (drugIc50L == nil) {
                drugIc50L =  dicGDL3 [theTarget.hugoName]! [""]
            }
 
            // Go through the drugIc50 List
            // there is at least one element
            for (drug, ic50) in drugIc50L! {
                
                // Check if we already know that drug
                let index = updDTRelL.index (where: { $0.drug.drugName == drug  })
                if (index != nil) {
                        
                    // Drug already exist. add the target in Target List
                    var targetModeL = updDTRelL [index!].targetModeL!
                    if targetModeL.contains (where: {($0.hugoName == theTarget.hugoName)&&($0.aberDesc == theTarget.aberDesc ) }) {
                        
                       let pos  = targetModeL.index( where: {  (($0.hugoName == theTarget.hugoName) && ($0.aberDesc == theTarget.aberDesc ))  })
                        // target already in here for that drug
                        theTargetMode = targetModeL[pos!]
                        
                    } else {
                            
                        // add that target in the list of targets for that drug
                        theTargetMode = TargetHitMode_C (id: 0, hugoName: theTarget.hugoName,
                                                                aberration: theTarget.aberDesc!,mode: SubsMode.direct, Ic50: ic50 )
                        
                        targetModeL.append (theTargetMode!)
                    }
                        
                } else {
                        
                    //  create a new Drug-Target relation and add it
                    let newDrug = Drug_C ( drugId: 0, drugName : drug, allowed: allowed )
                    theTargetMode = TargetHitMode_C (id: 0, hugoName: theTarget.hugoName,
                                                            aberration: theTarget.aberDesc!, mode: SubsMode.direct, Ic50: ic50 )
                
                    let newDTRelation = DTRelation_C ( drug: newDrug )
                    newDTRelation.targetModeL.append ( theTargetMode! )

                    updDTRelL.append ( newDTRelation )
                }
            }//for
            
            // Look also at target Substitutions if any
            // coz a drug may serve another target and thsi one throug its Targets substitution
            
            
        }
/*
        // Look at all
        // Target Substitution ?
        if ( dicTSubsL [theTarget.hugoName] != nil) {
            
            // an entry for target Substitution exists
            // get the table and go trhough all elts
            let targetSubsL = dicTSubsL [theTarget.hugoName]!
            
            
            for (targetSubs, mode ) in targetSubsL {
                
                // what mode are you talking about?
                var subsMode : SubsMode
                var theTargetSubs : TargetHitMode_C
                
                if (mode == 1) {
                    subsMode = SubsMode.semidirect
                } else {
                    subsMode = SubsMode.semidirect
                }
                
                // do not look at aberrations here: aber = ""
                let drugIc50L =  dicGDL3 [targetSubs]! [""]
                
                // Go through the drugIc50 List
                // there is at least one element
                for (drug, ic50) in drugIc50L! {
                    
                    // Check if we already know that drug Target
                    let index = updDTRelL.index (where: { $0.drug.drugName == drug  })
                    if (index != nil) {
                        
                        // Drug already exist. add the target in Target List
                        var targetModeL = updDTRelL [index!].targetModeL!
                        if targetModeL.contains (where: {$0.hugoName == targetSubs}) {
                            let pos  = targetModeL.index( where: {  ( $0.hugoName == targetSubs ) })
                            // target already in here for that drug
                            theTargetSubs = targetModeL[pos!]
                            // target already in here
                            
                        } else {
                            
                            // add that target in the list of targets for that drug
                            theTargetSubs = TargetHitMode_C (id: 0, hugoName: targetSubs,
                                                             aberration:"", mode: subsMode, Ic50: ic50 )
                            targetModeL.append (theTargetSubs)
                        }
                        
                    } else {
                        
                        //  create a new Drug-Target relation and add it
                        let newDrug = Drug_C ( drugId: 0, drugName : drug, allowed: allowed )
                        let theTargetSubs  = TargetHitMode_C (id: 0, hugoName: targetSubs,
                                                             aberration: "", mode: subsMode, Ic50: ic50 )
                        
                        let newDTRelation = DTRelation_C ( drug: newDrug )
                        newDTRelation.targetModeL.append ( theTargetSubs  )
                        
                        updDTRelL.append ( newDTRelation )
                    }
                    
                    theTargetMode.targetSubsL.append (theTargetSubs)
                    
                }//for
                
           }
            
            
        }// target subs entry exist
        
        */
        
        return (updDTRelL)
    }
}






