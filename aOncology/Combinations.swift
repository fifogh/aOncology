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
    
    
    var genomicCount       : Int
    var protRnaCount       : Int
    
    var redundPrRnaCount   : Int               // number of redundant protein/rna Markers
    var redundGenomCount   : Int               // number of redundant genomic markers

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
        
        self.genomicCount     = 0
        self.protRnaCount     = 0
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
        
        let totalRedundTargets = self.redundPrRnaCount + self.redundGenomCount
        let comboActedTargets  = self.genomicCount + self.protRnaCount
        let comboLen = self.dtRelL.count
        
        let actedSquare = (comboActedTargets + totalRedundTargets) * (comboActedTargets + totalRedundTargets)
        let numerator   = redundFact * hitSum * Double (actedSquare)
        let denominator = Double (comboLen * (self.actionableCount + totalRedundTargets))
        
        self.matchScore  = numerator / denominator
        
    }
    
    
   
    // -------------------------------------------------------------------
    // func proteinCount return {genomic, Rna+Protein)
    func markersCount () ->(Int,Int) {
        
        var prrnaCount = 0    // protein + rna count
        var genomCount = 0    // genomic count

        for dtRel in self.dtRelL {
            for t in dtRel.targetHitL{
                if t.target.markerType == .genomic {
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
    
    
    func isPairRedundant (dtRel1: DTRelation_C, dtRel2: DTRelation_C) -> Bool{
     
        var Better1G = 0     // rel1 is better Genomic marker
        var Better2G = 0     // rel2 is better Genomic marker
        
        var Better1P = 0     // rel1  is better Pr/Rna marker
        var Better2P = 0     // rel2  is better Pr/Rna marker
        
        var t1L = [String] ()
        var t2L = [String] ()
        
        for t in dtRel1.targetHitL{
            t1L.append (t.target.hugoName)
        }
        
        for t in dtRel2.targetHitL{
            t2L.append (t.target.hugoName)
        }
        
        let set1:Set<String> = Set(t1L)
        let set2:Set<String> = Set(t2L)
        
        let intersecSet = set1.intersection(set2)
        
        if (intersecSet.count < set1.count) &&  (intersecSet.count < set2.count) {
            return (false)
            
        } else {
            for tName in intersecSet {
                let pos1 = dtRel1.targetHitL.index( where: {  ($0.target.hugoName == tName)  })
                let pos2 = dtRel2.targetHitL.index( where: {  ($0.target.hugoName == tName)  })

                if (( dtRel2.targetHitL[pos2!].hitScore - dtRel1.targetHitL[pos1!].hitScore) > hitThreshold ) {
                    if (dtRel2.targetHitL[pos2!].target.markerType == .genomic) {
                        Better2G = Better2G + 1
                    } else {
                        Better2P = Better2P + 1
                    }
                    
                } else  if (( dtRel1.targetHitL[pos1!].hitScore - dtRel2.targetHitL[pos2!].hitScore) > hitThreshold ) {
                    if (dtRel2.targetHitL[pos2!].target.markerType == .genomic) {
                        Better1G = Better1G + 1
                    } else {
                        Better1P = Better1P + 1
                    }
                }
                
                // update the redundCounter in all cases
                if (dtRel2.targetHitL[pos2!].target.markerType == .genomic) {
                    self.redundGenomCount = self.redundGenomCount + 1
                } else {
                    self.redundPrRnaCount = self.redundPrRnaCount + 1
               }
                    
                
            }
            
            // if a target is never better that teh other
            // then does not allow teh redundancy
            if ( (Better1G + Better1P) != 0  ) && ( (Better2G + Better2P) != 0) {
                return (false)
            } else {
                return (true)
            }
        }
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
