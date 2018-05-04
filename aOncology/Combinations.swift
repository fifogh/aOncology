//
//  Combinations.swift
//  aOncology
//
//  Created by Philippe-Faurie on 4/29/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import Foundation



//------------------------------------------------------------------------------
// CLASS Combination

class Combination_C   {
    
    var strengthScore : Double
    var matchScore    : Double
    var dtRelL        : [DTRelation_C]
    var redundancy    : Bool
    var hasAZeroHit   : Bool

    init (dtRelList: [DTRelation_C] ){
        
        self.dtRelL = dtRelList
        self.dtRelL.sort(by: {$0.drug.drugName < $1.drug.drugName})
        
        self.matchScore    = 0
        self.strengthScore = 0
        self.redundancy    = false
        self.hasAZeroHit   = false

        self.checkRedundant()
        self.checkZeroHit ()
        self.calcStrengthScore ()
    }
    
    
    deinit {
        dtRelL.removeAll()
    }
    
    
    //-------------------------------------------------
    // Strength calculation
    func calcStrengthScore () {
        
        var hitSum = 0.0
        var count  = 0.0
        if (redundancy == true) || ( hasAZeroHit == true ){
            strengthScore = 0
            return
        }
        for dtRel in dtRelL {
            for target in dtRel.targetHitL {
                hitSum = hitSum + target.hitScore
                count = count + 1
            }
        }
        strengthScore = 100.0 * hitSum / (5.0 * count)
    }
    
   
    // -------------------------------------------------------------------
    // func check contains a zero Hit on a target
    func checkZeroHit () {
        for dtRel in dtRelL {
            for t in dtRel.targetHitL{
                if t.hitScore == 0{
                    self.hasAZeroHit = true
                }
                
            }
            
        }
        
        
        
    }
    
    
    // -------------------------------------------------------------------
    // func check pair redundant
    // 1 - select the smaller list
    // 2 - for each target of the small list
    //      check if the target is also in the other list
    //      (will check too that the hit score is not lower by 3)
    // if that is teh case then there is redundancy between these 2 drugs
    
    func isPairRedundant (dtRel1: DTRelation_C, dtRel2: DTRelation_C) -> Bool{
        var small : DTRelation_C
        var large : DTRelation_C
        
        if ( dtRel1.targetHitL.count < dtRel2.targetHitL.count ) {
            small = dtRel1
            large = dtRel2
        } else {
            small = dtRel2
            large = dtRel1
        }
        
        if ( small.isIncluded (inDTRel: large) == true ) {
            return (true)
        } else {
            return (false)
        }
        
    }
        
        
    
    
    //-------------------------------------------------
    //set the combo as redundant if 2 drugs are
    
    func checkRedundant () {
        
        // 1 drug combo no redudancies
        
        if (dtRelL.count == 1 ) {
            self.redundancy = false
        }
        
            
        // 2 drugs Combos
            
        else if (dtRelL.count == 2 ) {
            if ( isPairRedundant(dtRel1: dtRelL[0], dtRel2:dtRelL[1]) == true ){
                self.redundancy = true
                return
            }
            
            
        // 3 drugs Combos
            
        } else {
            if ( isPairRedundant(dtRel1: dtRelL[0], dtRel2:dtRelL[1]) == true ){
                self.redundancy = true
                return
            }
            if ( isPairRedundant(dtRel1: dtRelL[0], dtRel2:dtRelL[2]) == true ){
                self.redundancy = true
                return
            }
            if ( isPairRedundant(dtRel1: dtRelL[1], dtRel2:dtRelL[2]) == true ){
                self.redundancy = true
                return
            }
        }
    }
}
