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
enum MarkerType :Int {case genomic, protein, rna }         // Markers Types


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
    
    func allTargetFound (inL: [TargetHit_C] ) -> Bool {
        
        if (inL.count != targetHitL.count) {
            return (false)
        }
        
        for t in targetHitL {
            if (t.targetExist ( inL : inL  )){
                continue
            } else {
                return (false)
            }
        }
        return (true)
    }
}


//------------------------------------------------------------------------------
// CLASS TargetHit
class TargetHit_C : Target_C  {
    
    var mode         : SubsMode            // direct/indirect/semi_direct
    var markerType   : MarkerType          // genomic, protein, rna
    
    var Ic50         : Double?             // doesn not exist if Hit through Substitutions only
    var hitScore     : Double              // Calculated
 
    var targetSubsL  : [TargetHit_C]       // List of targets substitution
    
    
    // full init with Ic50 - a direct Hit Exist - calculate Hitscore
    init (id: Int, hugoName: String, aberration: String, mode: SubsMode, Ic50: Double){
        
        self.mode        = mode
        self.Ic50        = Ic50
        self.markerType  = MarkerType.genomic
        self.hitScore    = 0
        self.targetSubsL = [TargetHit_C]()
        
        super.init (id: id, hugoName: hugoName, aberration: aberration)
        
        self.hitScore   = self.calcHitScore()

    }
    
    // partial init without Ic50 - Hit is through target substitutions
    init (id: Int, hugoName: String, aberration: String, mode: SubsMode){
        self.mode        = mode
        self.markerType  = MarkerType.genomic
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
        if ( markerType == MarkerType.protein ) {
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
    // same target with same hit exist in a Target Hit list?
    func targetExist (inL : [TargetHit_C]) -> Bool {

        var ret = false
    
        if let pos = inL.index( where: {  (($0.hugoName == self.hugoName) && ($0.aberDesc! == self.aberDesc ))  }) {
            var betterHit = inL[pos].hitScore - self.hitScore
            betterHit = betterHit > 0 ? betterHit : -betterHit
            if (betterHit < hitThreshold) {
                ret = true
            }
        }
        return ret
    }
  
}



