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
    var redundancy    : Bool                   // true if redundancy detected
    
    var redundPrRnaCount   : Int               // number of redundant protein/rna Markers
    var redundGenomCount   : Int               // number of redundant genomic markers

  //  var redundCount   : Int                    // number of redundant targets
    var hasAZeroHit   : Bool
    var hitSum        : Double
    var redundFact    : Double
    
    var actionableCount : Int
    var pathogenicCount : Int

    init (dtRelList: [DTRelation_C], actionableCount: Int, pathogenicCount : Int  ){
        
        self.dtRelL = dtRelList
        self.dtRelL.sort(by: {$0.drug.drugName < $1.drug.drugName})
       
        self.strengthScore    = 0.0
        self.matchScore       = 0.0
        self.redundFact       = 1.0
        self.hitSum           = 0.0
        self.redundancy       = false
        self.redundPrRnaCount = 0
        self.redundGenomCount = 0
        self.hasAZeroHit      = false
        
        self.actionableCount = actionableCount
        self.pathogenicCount = pathogenicCount

        self.checkRedundant()
        self.checkZeroHit ()
        self.calcStrengthScore ()
        self.calcMatchScore ()
    }
    
    
    deinit {
        self.dtRelL.removeAll()
    }
    
    
    //-------------------------------------------------
    // Strength calculation
    func calcStrengthScore () {
        
        
       // ss = 100 * hitSum / (((genMarkNb + redundGeneNb) * 5 ) + ((protMarkNb + redundProtNb) * 2.5));

        var genomicCount  = 0
        var protRnaCount  = 0


        if (redundancy == true) || ( hasAZeroHit == true ){
            strengthScore = 0
            return
        }
        
        for dtRel in self.dtRelL {
            for target in dtRel.targetHitL {
                hitSum = hitSum + target.hitScore
                //count = count + 1
            }
        }
        ( genomicCount, protRnaCount ) = markersCount ()
        strengthScore =   100.0 * hitSum /
                       (( 5.0 * (Double(genomicCount) + Double(redundGenomCount))) +
                        ( 2.5 * (Double(protRnaCount) + Double(redundPrRnaCount))) )
        
        let fuzzyFact = (100.0 - Double(self.dtRelL.count)) / 100.0
        strengthScore = strengthScore * fuzzyFact
    }
    
    
    
    
    //-------------------------------------------------
    // Match calculation
    func calcMatchScore () {
        
        let totalRedundTargets = Double (redundPrRnaCount + redundGenomCount)
        let comboActedTargets  = Double (self.dtRelL.count)
        let comboLen = Double (self.dtRelL.count)
        
        matchScore  = redundFact * hitSum / (comboLen) * (comboActedTargets + totalRedundTargets) * (comboActedTargets + totalRedundTargets) /
                                            (Double (actionableCount) + totalRedundTargets)
    }
    
    
   
    // -------------------------------------------------------------------
    // func proteinCount return {genomic, Rna+Protein)
    func markersCount () ->(Int,Int) {
        
        var prrnaCount = 0    // protein + rna count
        var genomCount = 0    // genomic count

        for dtRel in self.dtRelL {
            for t in dtRel.targetHitL{
                if t.markerType == .genomic {
                    genomCount = genomCount + 1

                } else {
                    prrnaCount = prrnaCount + 1

                }
            }
        }
        return ( genomCount, prrnaCount)
    }
    
    
    // -------------------------------------------------------------------
    // func check contains a zero Hit on a target
    func checkZeroHit () {
        for dtRel in self.dtRelL {
            for t in dtRel.targetHitL{
                if t.hitScore == 0{
                    self.hasAZeroHit = true
                }
                
            }
            
        }
    }
    
    
    // -------------------------------------------------------------------
    // return True if the pair is redundant ie
    // i.e. same target list with no difference of Hitscore > 3
 
    func isPairRedundant (dtRel1: DTRelation_C, dtRel2: DTRelation_C) -> Bool{
    
        var same = (false, 0, 0, 0, 0)      // different target List no better one
                                            // .1 .2 from dtRel1; .3.4 from dtRel2
        
        if ( dtRel1.targetHitL.count != dtRel2.targetHitL.count ){
            // Not even the same number of targets
            // one drug bring additional target
            return (false)
            
        } else {
            same = dtRel1.sameTargetL (asInTL: dtRel2.targetHitL)
            if ( same.0  == false ) {
                // same number of targets but
                // not same targets
                return (false)
                
            } else {
                // update the redundCounter in all cases
                self.redundGenomCount = same.1 + same.3     // target 1 Genomic, Target 2 Proteomic
                self.redundPrRnaCount = same.2 + same.4

                if ( (same.1 + same.2 != 0) && ( same.3 + same.4 != 0) ){
                    // each target is sometimes better than the other
                    return (false)
                }
            }
        }
        return (true)
    }
        
    
    
    //-------------------------------------------------
    //set the combo as redundant if 2 drugs are
    
    func checkRedundant () {
        
        // 1 drug combo no redudancies
        
        if (self.dtRelL.count == 1 ) {
            self.redundancy = false
        }
        
            
        // 2 drugs Combos
            
        else if (self.dtRelL.count == 2 ) {
            if ( isPairRedundant(dtRel1: self.dtRelL[0], dtRel2: self.dtRelL[1]) == true ){
                self.redundancy = true
                return
            }
            
            
        // 3 drugs Combos
            
        } else {
            if ( isPairRedundant(dtRel1: self.dtRelL[0], dtRel2:self.dtRelL[1]) == true ){
                self.redundancy = true
                return
            }
            if ( isPairRedundant(dtRel1: self.dtRelL[0], dtRel2:self.dtRelL[2]) == true ){
                self.redundancy = true
                return
            }
            if ( isPairRedundant(dtRel1: self.dtRelL[1], dtRel2:self.dtRelL[2]) == true ){
                self.redundancy = true
                return
            }
        }
    }
}
