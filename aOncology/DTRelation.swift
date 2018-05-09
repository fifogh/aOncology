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
    
    
    init (drugId: Int, drugName: String, allowed: Bool){
        self.id       = drugId
        self.drugName = drugName
        self.allowed  = allowed
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
                    if (t.markerType == .genomic) {
                         iBetterG = iBetterG + 1
                    } else {
                         iBetterP = iBetterP + 1
                    }
                    
                } else  if ((asInTL[pos].hitScore -  t.hitScore) > hitThreshold ) {
                    if (t.markerType == .genomic) {
                        oBetterG = oBetterG + 1
                    } else {
                        oBetterP = oBetterP + 1
                    }
                   
                }
                
            } else {
                // differents targets
                // counters are nin relevant
                return (false, 0, 0, 0, 0)
            }
        }
        
        return (true, iBetterG, iBetterP, oBetterG, oBetterP)
    }
                
 
}


//------------------------------------------------------------------------------
// CLASS TargetHit
class TargetHit_C : Target_C  {
    
    var mode         : SubsMode            // direct/indirect/semi_direct
    
    
    var Ic50         : Double?             // doesn not exist if Hit through Substitutions only
    var hitScore     : Double              // Calculated
 
    var targetSubsL  : [TargetHit_C]       // List of targets substitution
    
    
    // full init with Ic50 - a direct Hit Exist - calculate Hitscore
    init (id: Int, hugoName: String, aberration: String, mode: SubsMode, Ic50: Double){
        
        self.mode        = mode
        self.Ic50        = Ic50
        self.hitScore    = 0
        self.targetSubsL = [TargetHit_C]()
        
        super.init (id: id, hugoName: hugoName, aberration: aberration)
        
        self.hitScore   = self.calcHitScore()

    }
    
    // partial init without Ic50 - Hit is through target substitutions
    init (id: Int, hugoName: String, aberration: String, mode: SubsMode){
        self.mode        = mode
        self.hitScore    = 0
        self.targetSubsL = [TargetHit_C]()
        
        super.init (id: id, hugoName: hugoName, aberration: aberration)
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
    
    func calcHitScore () -> Double {
        
        //-------------------
        // base formula
        
        if (Ic50! < 51){
            hitScore = 5;
            
        } else if (Ic50! < 501){
            hitScore = self.ic50ToHit();
        } else {
            hitScore = 0;
        }
        
        // Only get 75% of score for Pathways ( indirect )
        if (mode == SubsMode.indirect) {
            hitScore = 3*hitScore/4;
        }
        
        // in case of protein Marker : half of the calculated score
        if (( markerType == MarkerType.protein ) || ( markerType == MarkerType.rna)) {
            hitScore = hitScore / 2 ;
         }
        
        
        // house cleaning
        if ( hitScore < 0 ) {
            print ("!!!! Warning Neg hit \( hitScore ) !!!!\n");
            hitScore = 0
            
        } else if ( hitScore > 5 ) {
            print ("!!!! Warning >5 hit \( hitScore ) !!!!\n");
            hitScore = 5
        }

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

    }
    
    //-------------------------------------------------------
    //Same target with same hit exist in a Target Hit list?
    // if self has a better hit by 3 then we consider that
    // it does not exist in the other list
    func targetPos (inL : [TargetHit_C]) -> Int? {

         let pos = inL.index( where: {  ($0.hugoName == self.hugoName)  })
         return pos
     
    }
  
}



