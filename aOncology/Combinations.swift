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
    
    init (dtRelList: [DTRelation_C] ){
        
        self.dtRelL = dtRelList
        self.matchScore    = 0
        self.strengthScore = 0
        self.redundancy    = false

        self.checkRedundant()
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
        if (redundancy == true){
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
    
    
    //-------------------------------------------------
    //set the combo as redundant if 2 drugs are
    
    func checkRedundant () {
        
        // 1 drug combo no redudancies
        if (dtRelL.count == 1 ) {
            return
        }
        
        // 2 drugs Combos
        else if (dtRelL.count == 2 ) {
            if dtRelL[0].allTargetFound(inL: dtRelL[1].targetHitL) {
                self.redundancy = true
                return
            }
            
        // 3 drugs Combos
        } else {
            if dtRelL[0].allTargetFound(inL: dtRelL[1].targetHitL) {
                self.redundancy = true
                return
            }
            if dtRelL[0].allTargetFound(inL: dtRelL[2].targetHitL) {
                self.redundancy = true
                return
            }
            
            if dtRelL[1].allTargetFound(inL: dtRelL[2].targetHitL) {
                self.redundancy = true
                return
            }
        }
    }
    
}
