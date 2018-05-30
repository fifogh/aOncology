//
//  drugGene.swift
//  aOncology
//
//  Created by Philippe-Faurie on 4/17/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import Foundation



var outDTRelL = [DTRelation_C]()

//------------------------------------------------------------------------------
// PROTOCOL -
//           the DTRelList is ready

protocol targetChangeDelegate{
    func drugListAdjusted (outDrugL: [DTRelation_C], actionable: Bool, rebuilt: Bool)
}


//------------------------------------------------------------------------------
// CLASS geneDRUG
class geneDrugs {
    
    var newGeneConfigDelegate : targetChangeDelegate!
    var actionableTarget      : Bool
    
    init () {
        actionableTarget = false
    }
    
    
    //--------------------------------------------------------------------------
    // Give the list of Drugs for a Target

    func giveDrugList (theTarget: Target_C) -> [String: Double]  {
    
        // The HugoName exist
        // an aberration exist at least with empty string otherwise the hugo name is not even present
        // so if no Drug is found for that particular aberration look for the list with no aberration
            
        let aberration = theTarget.aberDesc
        var drugIc50L =  dicDTRelL [theTarget.hugoName]! [aberration!]
        if (drugIc50L == nil) {
            drugIc50L =  dicDTRelL [theTarget.hugoName]! [""]
        }
        return drugIc50L!
    }
    
    //--------------------------------------------------------------------------
    // Give the list of Subsititutions for a Target
    
    func giveSubstitutionList (theHugoName: String) -> [String: Int]  {
        return dicTSubsL [theHugoName]!
    }
    

    //--------------------------------------------------------------------------
    // create the direct DT relation

    func addDTRelation (inDTRelL: inout [DTRelation_C], theTarget: Target_C, theDrug : String, theIc50: Double, allowed: Bool) {
        
        if let drugPos = dtRelL.index (where: { $0.drug.drugName == theDrug  }) {
            
            // Drug already exist.
            // Add theTarget in Target List if not yet in
            // var targetHitL  = updDTRelL [drugPos].targetHitL!
            if  (inDTRelL [drugPos].targetHitL!.index ( where: { (($0.target.hugoName == theTarget.hugoName) && ($0.target.aberDesc == theTarget.aberDesc ))  }) != nil) {
                
                // nothing to do
                // theTargetHit = targetHitL[pos]
                print ("Nothing to do \n")
                
            } else {
                // add that target in the list of targets for that drug
                let theTargetHit = TargetHit_C (id: 0,  target: theTarget, mode: SubsMode.direct, Ic50: theIc50 )
                inDTRelL [drugPos].targetHitL!.append(theTargetHit)
            }
            
        } else {
            
            // Drug does not exist yet
            // Create a new Drug-Target relation and add it to the list
            let newDrug = Drug_C ( drugId: 0, drugName : theDrug, allowed: allowed )
            newDrug.markApproved(pathoClass: pathoClass)
            
            let newDTRelation = DTRelation_C ( drug: newDrug )
            
            let theTargetHit = TargetHit_C (id: 0,  target: theTarget, mode: SubsMode.direct, Ic50: theIc50 )
            newDTRelation.targetHitL.append ( theTargetHit )
            inDTRelL.append ( newDTRelation )
        }
       
    }

    
    //--------------------------------------------------------------------------
    // create the subs DT relation
    
    func addSubsRelation (inDTRelL: inout [DTRelation_C], theTarget: Target_C, theDrug : String, theIc50: Double, allowed: Bool) {
    
    }

 /*
    //------------------
    // Thr Big ~one
    func buildRelations ( theTarget: Target_C,  inDTRelL: inout [DTRelation_C], allowed: Bool) {
        
        
        //-----------------
        // the direct Drugs
        
        if ( dicDTRelL[theTarget.hugoName] != nil ) {
            let drugIc50L = giveDrugList ( theTarget: theTarget )
            
            for (drugName, Ic50) in drugIc50L {
                addDTRelation (inDTRelL: &inDTRelL, theTarget: theTarget, theDrug: drugName, theIc50: Ic50, allowed: allowed)
            }
        }
        
        //-----------------
        // the substitution
       
        if ( dicTSubsL [theTarget.hugoName] != nil) {
            let targetModeL = giveSubstitutionList (theHugoName: theTarget.hugoName)
            for (hugoSubs, mode) in targetModeL {
                addSubsRelations ( theTarget: Target_C (id:0, hugoName:hugoSubs, aberration : ""),  inDTRelL: &inDTRelL, allowed: allowed)
              //  addSubsDTRelation ()
            }
            //theTarget.calcSubsHitScore()
            // calculate subscore of the Target ( fn mode)
        }
        
        
    }

*/
    //--------------------------------------------------------------------------
    // Update DrugTarg Relation list after a target was added
    
     func targetToAdd (theTarget: Target_C,  inDrugL: [DTRelation_C], allowed: Bool) {
    
   /*
        //TRY THIS...
        var otherDTRel = [DTRelation_C]()
        buildRelations ( theTarget: theTarget,  inDTRelL: &otherDTRel, allowed: allowed)
     */
        
        actionableTarget = false

        var updDTRelL = self.checkAndAdd   (theTarget: theTarget, inDTRelL: inDrugL,   allowed: allowed)
            updDTRelL = self.targetSubsAdd (theTarget: theTarget, inDTRelL: updDTRelL, allowed: allowed)
        
        updDTRelL.sort(by: { $0.drug.allowed  != $1.drug.allowed  ? $0.drug.allowed && !$1.drug.allowed :
            $0.drug.approved != $1.drug.approved ? $0.drug.approved == 1  && $1.drug.approved == 0 :
            ($0.drug.drugName < $1.drug.drugName)  })
        newGeneConfigDelegate.drugListAdjusted (outDrugL : updDTRelL,  actionable:  self.actionableTarget, rebuilt: false  )
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
        
        newDTRelL.sort(by: { $0.drug.allowed  != $1.drug.allowed  ? $0.drug.allowed && !$1.drug.allowed :
            $0.drug.approved != $1.drug.approved ? $0.drug.approved == 1  && $1.drug.approved == 0 :
            ($0.drug.drugName < $1.drug.drugName)  })
        newGeneConfigDelegate.drugListAdjusted (outDrugL : newDTRelL, actionable: self.actionableTarget, rebuilt: true )
    }

    //--------------------------------------------------------------------------
    // Does all the job of adding a drug Target relation in the DTRelation List
    
   
    
    func targetSubsAdd (theTarget: Target_C,  inDTRelL: [DTRelation_C], allowed: Bool) -> [DTRelation_C] {
        var updDTRelL  = inDTRelL
        var theTargetHit : TargetHit_C
        
        if ( dicTSubsL [theTarget.hugoName] != nil) {
            
            // an entry exist ...
            actionableTarget = true
            
            // Target Substitution exists
            // for all targets inteh list add them as substitution Targets
            let targetSubsL = dicTSubsL [theTarget.hugoName]!
            
            for (theTargetSubs, mode ) in targetSubsL {
                if ( dicDTRelL[theTargetSubs] != nil ) {
                    // a Target Substitution exist
                    // go through all the drugs associated to it
                    
                    let drugIc50L =  dicDTRelL [theTargetSubs]! [""]
                    for (drug, ic50) in drugIc50L! {
                        if let drugPos = updDTRelL.index (where: { $0.drug.drugName == drug  }) {
                            // a drug exists for that target Subs
                            // if the Target is already in the list, also add the subsitution now
                            
                             if let tgtPos = updDTRelL [drugPos].targetHitL!.index( where: {  (($0.target.hugoName == theTarget.hugoName) && ($0.target.aberDesc! == "" ))  }) {
 
                                // if the subs already exist then pass else add the substitution
                                if ( updDTRelL [drugPos].targetHitL! [tgtPos].targetSubsL.index (where: { (($0.target.hugoName == theTargetSubs) && ($0.target.aberDesc! == "" ))  }) == nil ) {
                                    
                                    let locTargetSubs = Target_C    (id:0, hugoName: theTargetSubs, aberration: "")
                                    let targetSubs    = TargetHit_C (id: 0,  target: locTargetSubs, mode: .direct, Ic50: ic50 )
                                    
                                    updDTRelL [drugPos].targetHitL![tgtPos].targetSubsL.append(targetSubs)
                                    updDTRelL [drugPos].targetHitL![tgtPos].calcSubsHitScore()
                                }
                                
                            } else {
                                // add the target and the Subs in the list of targets for that drug
                                theTargetHit   = TargetHit_C (id: 0, target: theTarget, mode: mode == 1 ? SubsMode.indirect: SubsMode.semidirect)
                                let locTargetSubs = Target_C (id: 0, hugoName: theTargetSubs, aberration: "")
                               // let targetSubs = TargetHit_C (id: 0, target: locTargetSubs, mode: .direct, Ic50: ic50 )
                                 let targetSubs = TargetHit_C (id: 0, target: locTargetSubs, mode: mode == 1 ? SubsMode.indirect: SubsMode.semidirect, Ic50: ic50 )


                                theTargetHit.targetSubsL.append(targetSubs)
                                updDTRelL [drugPos].targetHitL!.append (theTargetHit)
                                updDTRelL [drugPos].targetHitL!.last!.calcSubsHitScore()
                            }
                            
                        } else {
                            // add the drug. the target and the substitution
                            
                            // Drug does not exist yet
                            // Create a new Drug-Target relation and add it to teh list
                            let newDrug = Drug_C ( drugId: 0, drugName : drug, allowed: allowed )
                            newDrug.markApproved(pathoClass: pathoClass)
                            
                            let newDTRelation = DTRelation_C ( drug: newDrug )
                            
                            theTargetHit   = TargetHit_C (id: 0, target: theTarget, mode: mode == 1 ? SubsMode.indirect: SubsMode.semidirect)
                            let locTargetSubs = Target_C (id: 0, hugoName: theTargetSubs, aberration: "")
                          //  let targetSubs = TargetHit_C (id: 0, target: locTargetSubs, mode: .direct, Ic50: ic50 )
                            let targetSubs = TargetHit_C (id: 0, target: locTargetSubs, mode: mode == 1 ? SubsMode.indirect: SubsMode.semidirect, Ic50: ic50 )

                            
                            theTargetHit.targetSubsL.append(targetSubs)
                            
                            newDTRelation.targetHitL.append ( theTargetHit )
                            theTargetHit.calcSubsHitScore()

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
            
            // an entry exist ...
            actionableTarget = true
            
            let aberration = theTarget.aberDesc
            var drugIc50L =  dicDTRelL [theTarget.hugoName]! [aberration!]
            if (drugIc50L == nil) {
                drugIc50L =  dicDTRelL [theTarget.hugoName]! [""]
            }
 
            // for each drug of the DrugIC50list
            // if the drug  already exist in the list append the new TargetHit (if not already there)
            // if the drug does not exist in the list create the drug and the first Target attached to it
            
            for (drug, ic50) in drugIc50L! {
                if let drugPos = updDTRelL.index (where: { $0.drug.drugName == drug  }) {
 
                    // Drug already exist.
                    // Add theTarget in Target List if not yet in
                    // var targetHitL  = updDTRelL [drugPos].targetHitL!
                    if  (updDTRelL [drugPos].targetHitL!.index ( where: { (($0.target.hugoName == theTarget.hugoName) && ($0.target.aberDesc == theTarget.aberDesc ))  }) != nil) {
                        
                        // nothing to do
                        // theTargetHit = targetHitL[pos]
                        print ("Nothing to do \n")
                        
                    } else {
                        // add that target in the list of targets for that drug
                        theTargetHit = TargetHit_C (id: 0,  target: theTarget, mode: SubsMode.direct, Ic50: ic50 )
                        updDTRelL [drugPos].targetHitL!.append(theTargetHit)
                    }
                        
                } else {
                    
                    // Drug does not exist yet
                    // Create a new Drug-Target relation and add it to the list
                    let newDrug = Drug_C ( drugId: 0, drugName : drug, allowed: allowed )
                    newDrug.markApproved(pathoClass: pathoClass)

                    let newDTRelation = DTRelation_C ( drug: newDrug )
                    
                    theTargetHit = TargetHit_C (id: 0,  target: theTarget, mode: SubsMode.direct, Ic50: ic50 )
                    newDTRelation.targetHitL.append ( theTargetHit )

                    updDTRelL.append ( newDTRelation )
                }
            }//for
            
        }
        return (updDTRelL)
    }
}






