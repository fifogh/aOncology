//
//  Combinations.swift
//  aOncology
//
//  Created by Philippe-Faurie on 4/29/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import Foundation



//------------------------------------------------------------------------------
// TargetDrugRelation Class

class DTRelation_C  {
    
    var drug        : Drug_C              // HugoName of the Gene Description
    var targetModeL : [TargetHitMode_C]!  // list of aberration/ Drug lists
    
    init (drug: Drug_C){
        self.drug        = drug
        self.targetModeL = [TargetHitMode_C]()
    }
    
    deinit {
        targetModeL.removeAll()
    }
    
}



//------------------------------------------------------------------------------
// TargetDrugRelation Class

class Combination_C   {
    
    var strengthScore : Double
    var matchScore    : Double
    
 //   var comboLen      : Int
    var dtRelL        : [DTRelation_C]
    
    init (dtRelList: [DTRelation_C] ){
        
        self.dtRelL = dtRelList
        self.matchScore    = 0
        self.strengthScore = 0
     //   self.comboLen      = 1
        
        self.calcStrengthScore ()

    }
    deinit {
        dtRelL.removeAll()
    }
    
    
    func calcStrengthScore () {
        
        var hitSum = 0.0
        var count  = 0.0
         for dtRel in dtRelL {
            for target in dtRel.targetModeL {
                hitSum = hitSum + target.hitScore
                count = count + 1
            }
        }
        strengthScore = 100.0 * hitSum / (5.0 * count)
    }
   
    
    
    
}
