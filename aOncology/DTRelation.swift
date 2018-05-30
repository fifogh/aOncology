//
//  DTRelation.swift
//  aOncology
//
//  Created by Philippe-Faurie on 4/28/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import Foundation

let hitThreshold = 3.0      // above this 2 Hitscore make 2 drugs non redundant on the same target

//------------------------------------------------------------------------------
// TYPES
enum SubsMode :  Int {case direct, semidirect, indirect }    // Substitutions Types




//------------------------------------------------------------------------------
// DRUG Class
class Drug_C {
    
    var id   : Int           // Id instead of Name
    var drugName : String    // plain name
    var allowed  : Bool      // user selection yes/no
    var approved : Int       // approved with diagnosis
    var blackBox : Bool      // has a FDA black Box Warning
    
    
    init (drugId: Int, drugName: String, allowed: Bool){
        self.id       = drugId
        self.drugName = drugName
        self.allowed  = allowed
        self.approved = 0
        self.blackBox = false
    }
    
    func markApproved ( pathoClass: String ){
        
        self.approved = 0
        
        if  let drugL = pathoDrugsData [pathoClass] {
            if ( drugL.index (where: { $0 == self.drugName  }) != nil ){
                self.approved = 1
            }
        }
        
        if ( bbWarningL.index (where: { $0 == self.drugName  }) != nil ){
            self.blackBox = true
        }
        
    }
    
}




//------------------------------------------------------------------------------
// // CLASS DTRelation

class DTRelation_C  {
    
    var drug        : Drug_C         // HugoName of the Gene Description
    var targetHitL : [TargetHit_C]!  // list of aberration/ Drug lists
    
    init (drug: Drug_C){
        self.drug        = drug
        self.targetHitL = [TargetHit_C]()
    }
    
    deinit {
        targetHitL.removeAll()
    }
    
    
    
    //-------------------------------------------------------
    // Function sameTargetL
    // check if 2 target list contain same elts
    // if true, return the number each time a target is better
    func sameTargetL (asInTL: [TargetHit_C] ) -> (Bool, Int, Int, Int, Int) {
        
        var iBetterG = 0     // self  is better Genomic marker
        var oBetterG = 0     // other is better Genomic marker
        
        var iBetterP = 0     // self  is better Pr/Rna marker
        var oBetterP = 0     // other is better Pr/Rna marker
        
        for t in self.targetHitL {
            
            if let pos = t.targetPos (inL: asInTL) {
                // compare the HitScores
                if (( t.hitScore - asInTL[pos].hitScore) > hitThreshold ) {
                    if (t.target.markerType == .genomic) {
                         iBetterG = iBetterG + 1
                    } else {
                         iBetterP = iBetterP + 1
                    }
                    
                } else  if ((asInTL[pos].hitScore -  t.hitScore) > hitThreshold ) {
                    if (t.target.markerType == .genomic) {
                        oBetterG = oBetterG + 1
                    } else {
                        oBetterP = oBetterP + 1
                    }
                   
                }
                
            } else {
                // differents targets
                // counters are nin relevant
                return (false, iBetterG, iBetterP, oBetterG, oBetterP)
            }
        }
        
        return (true, iBetterG, iBetterP, oBetterG, oBetterP)
    }
                
 
}


//------------------------------------------------------------------------------
// CLASS TargetHit
class TargetHit_C {
 
    var target        : Target_C
    var mode          : SubsMode            // direct/indirect/semi_direct
    var forceMode     : Bool                // Some Targets always calulate HitScore as genomic
    var Ic50          : Double?             // doesn not exist if Hit through Substitutions only
    var hitScore      : Double              // Calculated
    var hitScoreRuled : Bool                // hitScore has been affected by a special rule
    
 
    var targetSubsL  : [TargetHit_C]       // List of targets substitution
    
    init (id: Int,  target: Target_C , mode: SubsMode , Ic50: Double  ) {

        self.target      = target
        self.mode        = mode
        self.forceMode   = false

        self.Ic50          = Ic50
        self.hitScore      = 0
        self.hitScoreRuled = false
        self.targetSubsL   = [TargetHit_C]()
        
        self.hitScore   = self.calcHitScore()
        self.forceMode  = self.voidProteinMarker()
    }
    
    // partial init without Ic50 - Hit is through target substitutions
    init (id: Int, target: Target_C, mode: SubsMode){
        
        self.target      = target
        self.mode        = mode
        self.forceMode   = false

        self.hitScore    = 0
        self.hitScoreRuled = false

        self.targetSubsL = [TargetHit_C]()
        self.forceMode  = self.voidProteinMarker()

    }

    // Except Rule 13
    func voidProteinMarker() -> Bool {
        if ((target.hugoName == "CD274") || (target.hugoName == "ERBB2") ||
            (target.hugoName == "AR")    || (target.hugoName == "ESR1")) {
            
            return (true)
        } else {
            return (false)
        }
    }
    
    
    
    func ic50ToHit () -> Double {
        var ret: Double
        let Vm = 7.0
        let Km = 250.0
        let IC50m = 16.04
        
        let fnIC50 = ((Vm - (Vm * (Ic50! - IC50m) / (Km + (Ic50! - IC50m)))));
        
        ret = 0.981242 * fnIC50 - 2.384326;
        return (ret)
    }

    
    func isIndirectHitScore ()  {
        // Only get 75% of score for Pathways ( indirect )
        if (mode == SubsMode.indirect) {
            hitScore = 3*hitScore/4;
        }
    }
    
     func isProteinHitScore ()  {
        
        // in case of protein Marker : half of the calculated score
        // unless this marker is always counted as genomic
        if ((( target.markerType == MarkerType.protein ) ||
             ( target.markerType == MarkerType.rna)) && (forceMode == false)) {
            hitScore = hitScore / 2 ;
        }
    }
    
    func cleanHitScore ()  {
        if ( hitScore < 0 ) {
            print ("!!!! Warning Neg hit \( hitScore ) !!!!\n");
            hitScore = 0
            
        } else if ( hitScore > 5 ) {
            print ("!!!! Warning >5 hit \( hitScore ) !!!!\n");
            hitScore = 5
        }
    }
    
    func calcHitScore () -> Double {
        
        //-------------------
        // base formula
        hitScore = 0;
        
        // substitution no drug hit
        if (Ic50 == nil){
           return hitScore
        }
        
        
        if (Ic50! < 51){
            hitScore = 5;
        } else if (Ic50! < 501){
            hitScore = self.ic50ToHit();
        } else {
            hitScore = 0;
        }
        
     //self.isIndirectHitScore()
        self.isProteinHitScore()
        self.cleanHitScore()
        
        return (hitScore)
    }
    
    //-------------------------------------------------------
    // Hitscore calculation
    func calcSubsHitScore ()  {
        
        // the Mean of target Substitution HitScores
        
        var hitSum = 0.0
        if (targetSubsL.count == 0 ) {
            return
            
        } else {
            for s in targetSubsL {
                hitSum = hitSum + s.hitScore
            }
            self.hitScore = hitSum / Double (targetSubsL.count)
        }
        
        self.isIndirectHitScore()
        self.isProteinHitScore()
    }
    
    //-------------------------------------------------------------------------
    // Hitscore calculation
    func calcTreeHitScore (targetHit: TargetHit_C, mode : SubsMode) -> Double {
        if (targetHit.mode == .direct) {
            return targetHit.calcHitScore()
            
        } else {
            var sHit = 0.0
            for tSubs in targetHit.targetSubsL {
                sHit += calcTreeHitScore (targetHit: tSubs, mode: tSubs.mode)
            }
            sHit = sHit / Double(targetHit.targetSubsL.count)
            return sHit
        }
        
    }
    
    //-------------------------------------------------------
    //Same target with same hit exist in a Target Hit list?
    // if self has a better hit by 3 then we consider that
    // it does not exist in the other list
    func targetPos (inL : [TargetHit_C]) -> Int? {

         let pos = inL.index( where: {  ($0.target.hugoName == self.target.hugoName)  })
         return pos
     
    }
  
}



