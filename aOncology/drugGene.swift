//
//  drugGene.swift
//  aOncology
//
//  Created by Philippe-Faurie on 4/17/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import Foundation





//------------------------------------------------------------------------------
// PROTOCOL -
//           the DTRelList is ready

protocol targetChangeDelegate{
    func drugListAdjusted (outDrugL: [DTRelation_C])
}


//------------------------------------------------------------------------------
// CLASS geneDRUG
class geneDrugs {
    
    var newGeneConfigDelegate : targetChangeDelegate!
    
    //--------------------------------------------------------------------------
    // Update DrugTarg Relation list after a target was added
    
     func targetToAdd (theTarget: Target_C,  inDrugL: [DTRelation_C], allowed: Bool) {

        var updDTRelL = self.checkAndAdd   (theTarget: theTarget, inDTRelL: inDrugL,   allowed: allowed)
            updDTRelL = self.targetSubsAdd (theTarget: theTarget, inDTRelL: updDTRelL, allowed: allowed)
        
        updDTRelL.sort(by: { $0.drug.drugName < $1.drug.drugName })
        newGeneConfigDelegate.drugListAdjusted (outDrugL : updDTRelL )
    }
    
    
    
    //--------------------------------------------------------------------------
    // Rebuild entirely Drug list after a target was removed

    func rebuildAll (inTargetL: [Target_C], inDTRelL: [DTRelation_C], allowed: Bool) {
 
        var newDTRelL = [DTRelation_C]()
        for target in inTargetL {
            newDTRelL = self.checkAndAdd   (theTarget: target, inDTRelL: newDTRelL, allowed: allowed)
            newDTRelL = self.targetSubsAdd (theTarget: target, inDTRelL: newDTRelL, allowed: allowed)
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
    // Does all the job of adding a drug Target relation in the DTRelation List
    
   
    
    func targetSubsAdd (theTarget: Target_C,  inDTRelL: [DTRelation_C], allowed: Bool) -> [DTRelation_C] {
        var updDTRelL  = inDTRelL
        var theTargetHit : TargetHit_C
        
        if ( dicTSubsL [theTarget.hugoName] != nil) {
            
            // Target Substitution exists
            // for all targets inteh list add them as substitution Targets
            let targetSubsL = dicTSubsL [theTarget.hugoName]!
            
            for (theTargetSubs, mode ) in targetSubsL {
                if ( dicDTRelL[theTargetSubs] != nil ) {
                    // a Target Substitution exist
                    // go through all the drugs associated to it
                    
                    let drugIc50L =  dicDTRelL [theTargetSubs]! [""]
                    for (drug, ic50) in drugIc50L! {
                        if let index = updDTRelL.index (where: { $0.drug.drugName == drug  }) {
                            // a drug exists for that target Subs
                            // if the Target is already in the list, also add teh subsitution now
                            
                            var targetHitL = updDTRelL [index].targetHitL!
                            if   let pos = targetHitL.index( where: {  (($0.hugoName == theTarget.hugoName) && ($0.aberDesc! == "" ))  }) {
                                
                                // the target exists.. adds the substitution
                                let targetSubs = TargetHit_C (id: 0,   hugoName: theTargetSubs, aberration: "",
                                                               mode: mode == 1 ? SubsMode.indirect: SubsMode.semidirect, Ic50: ic50 )
                                theTargetHit = targetHitL[pos]
                                theTargetHit.targetSubsL.append(targetSubs)
                                    
                            } else {
                                // add that thetarget an the Subs in the list of targets for that drug
                                theTargetHit = TargetHit_C (id: 0,   hugoName: theTarget.hugoName, aberration: "",
                                                            mode: mode == 1 ? SubsMode.indirect: SubsMode.semidirect )
                                let targetSubs = TargetHit_C (id: 0,   hugoName: theTargetSubs, aberration: "",
                                                             mode: mode == 1 ? SubsMode.indirect: SubsMode.semidirect,Ic50: ic50 )
                                theTargetHit.targetSubsL.append(targetSubs)
                                
                                targetHitL.append (theTargetHit)
                            }
                            
                           theTargetHit.calcSubsHitScore()
                            
                        } else {
                            // add teh drug. teh target and teh substitution
                            
                            // Drug does not exist yet
                            // Create a new Drug-Target relation and add it to teh list
                            let newDrug = Drug_C ( drugId: 0, drugName : drug, allowed: allowed )
                            let newDTRelation = DTRelation_C ( drug: newDrug )
                            
                            theTargetHit = TargetHit_C (id: 0, hugoName: theTarget.hugoName,
                                                        aberration: theTarget.aberDesc!, mode: SubsMode.direct )
                            let targetSubs = TargetHit_C (id: 0,   hugoName: theTargetSubs, aberration: "",
                                                          mode: mode == 1 ? SubsMode.indirect: SubsMode.semidirect, Ic50: ic50 )
                            
                            theTargetHit.targetSubsL.append(targetSubs)
                            theTargetHit.calcSubsHitScore()
                            
                            newDTRelation.targetHitL.append ( theTargetHit )
                            
                            updDTRelL.append ( newDTRelation )
                            
                        }
                    
                    //DrugsIC50 List exist for that Substitution
                    
                } //for
                    
                
            }
                
        } // for all TargetSubs
    }//Substitutions exists
        
        
        return (updDTRelL)
    }
    
    //--------------------------------------------------------------------------
    // Does all the job of adding a drug Target relation in the DTRelation List

    func checkAndAdd (theTarget: Target_C,  inDTRelL: [DTRelation_C], allowed: Bool) -> [DTRelation_C] {
        var updDTRelL  = inDTRelL
        
        var theTargetHit : TargetHit_C
        
        if ( dicDTRelL[theTarget.hugoName] != nil ) {
            // The HugoName exist
            // an aberration exist at least with empty string otherwise the hugo name is not even present
            // so if no Drug is found for that particular aberration look for the list with no aberration
            
            let aberration = theTarget.aberDesc
            var drugIc50L =  dicDTRelL [theTarget.hugoName]! [aberration!]
            if (drugIc50L == nil) {
                drugIc50L =  dicDTRelL [theTarget.hugoName]! [""]
            }
 
            // for each drug of the DrugIC50list
            // if the drug  already exist in the list append the new TargetHit (if not already there)
            // if the drug does not exist in the list create the drug and the first Target attached to it
            
            for (drug, ic50) in drugIc50L! {
                if let index = updDTRelL.index (where: { $0.drug.drugName == drug  }) {
 
                    // Drug already exist.
                    // Add theTarget in Target List if not yet in
                    var targetHitL = updDTRelL [index].targetHitL!
                    if   let pos  = targetHitL.index( where: {  (($0.hugoName == theTarget.hugoName) && ($0.aberDesc == theTarget.aberDesc ))  }) {
                         theTargetHit = targetHitL[pos]
                        
                    } else {
                        // add that target in the list of targets for that drug
                        theTargetHit = TargetHit_C (id: 0,   hugoName: theTarget.hugoName,
                                                           aberration: theTarget.aberDesc!,mode: SubsMode.direct, Ic50: ic50 )
                        
                        targetHitL.append (theTargetHit)
                    }
                        
                } else {
                    
                    // Drug does not exist yet
                    // Create a new Drug-Target relation and add it to teh list
                    let newDrug = Drug_C ( drugId: 0, drugName : drug, allowed: allowed )
                    let newDTRelation = DTRelation_C ( drug: newDrug )

                    theTargetHit = TargetHit_C (id: 0, hugoName: theTarget.hugoName,
                                                            aberration: theTarget.aberDesc!, mode: SubsMode.direct, Ic50: ic50 )
                
                    newDTRelation.targetHitL.append ( theTargetHit )

                    updDTRelL.append ( newDTRelation )
                }
            }//for
            
            // Look also at target Substitutions if any
            // coz a drug may serve another target and thsi one throug its Targets substitution
            
        }
        return (updDTRelL)
    }
}






