//
//  Combinations.swift
//  aOncology
//
//  Created by Philippe-Faurie on 4/29/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import Foundation

var rules22added : Bool = false

var EGFRDrugL  = Array(dicDTRelL ["EGFR"]! [""]!.keys)
var ERBB2DrugL = Array(dicDTRelL ["ERBB2"]![""]!.keys)
var BRAFDrugL  = Array(dicDTRelL ["BRAF"]![""]!.keys)
var MAP2KDrugL = Array(dicDTRelL ["MAP2K1"]![""]!.keys)   //suppose drug list for map2k1 & map2k2 are the same

var toto50 = true



// indices for bollean presence of drug types
let IMU_IDX = 0
let NIB_IDX = 1
let MAB_IDX = 2
let OTH_IDX = 3


//------------------------------------------------------------------------------
// CLASS Combination

class Combination_C   {
    
    var strengthScore : Double
    var matchScore    : Double
    var dtRelL        : [DTRelation_C]
    var redundancy    : Bool                   // true if redundancy detected
    var immunoStatus  : ImmunoState
    var toFilterOut   : Bool
    
    var approvedCount      : Int               // number of drugs appro
    var genomicCount       : Int
    var protRnaCount       : Int
    
    var redundPrRnaCount   : Int               // number of redundant protein/rna Markers
    var redundGenomCount   : Int               // number of redundant genomic markers

    var filter        : Bool                   // in manual mode do not force 0 when redundnacies or zero hit
    var hasAZeroHit   : Bool
    var hasWarning    : Bool
    var hitSum        : Double
    var redundFact    : Double
    
    var actionableCount   : Int
    var actedCount        : Int
    var actedImmunoCount  : Int

    var pathogenicCount : Int
    
    var diversityPres  = [Bool] (repeating: false, count :4)
    var diversityScore :Int

    
 
    init (dtRelList: [DTRelation_C], filter: Bool,  genomCount : Int, prrnaCount: Int, actionableCount : Int, immunoStatus: ImmunoState  ){
        
        self.dtRelL = dtRelList
       
        self.strengthScore    = 0.0
        self.matchScore       = 0.0
        self.redundFact       = 1.0
        self.hitSum           = 0.0
        self.redundancy       = false
        self.hasWarning       = false
        self.immunoStatus     = immunoStatus
        self.toFilterOut      = false
 
        self.filter           = filter
        
        self.approvedCount    = 0
        self.genomicCount     = genomCount
        self.protRnaCount     = prrnaCount
        
        self.redundPrRnaCount = 0
        self.redundGenomCount = 0
        
        self.hasAZeroHit      = false
        
        self.actionableCount  = actionableCount
       // self.actionableCount = genomCount + prrnaCount
        self.pathogenicCount  = genomCount + prrnaCount
        self.actedCount       = 0
        self.actedImmunoCount = 0
        
        self.diversityScore   = 0    // +1 of each drug type the more type the higher is count

        self.checkRedundant()
        self.checkZeroHit ()
        self.checkWarning ()
        self.calcStrengthScore ()
        self.calcMatchScore ()
        self.calcDiversityScore ()

        
    }
    
    deinit {
        self.dtRelL.removeAll()
    }
    
    
    //-------------------------------------------------
    // Save diversity
    func saveDiversityPresence ( dtRel: DTRelation_C ) {
        
        switch (dtRel.drug.drugType ){
            
        case .immunotherapy:
            diversityPres [IMU_IDX] = true
            break
        case .antibody:
            diversityPres [MAB_IDX] = true
            break
        case .inhibitor:
            diversityPres [NIB_IDX] = true
            break
        case .other:
            diversityPres [OTH_IDX] = true
            break
            
        }//switch
    }
    
    //-------------------------------------------------
    // Save diversity
    func calcDiversityScore () {
    
        self.diversityScore = 0
        for pres in diversityPres {
            self.diversityScore += pres == true ? 1: 0
        }
    
    }
    
    
    //-------------------------------------------------
    // Strength calculation
    func calcStrengthScore () {
        
        // force to zero whne the combo is to be avoided
        // Note: in manual mode, filter is false
        if ( ((redundancy == true)  && ( filter == true)) || ( hasAZeroHit == true ) ) {
            strengthScore = 0
            return
        }
        
        self.approvedCount    = 0
        self.actedCount       = 0
        self.actedImmunoCount = 0
        
        var hugoL = [String]()
        
        // make the sum aof all Hitscores
        // do not count immuno
        for dtRel in self.dtRelL {
            
            saveDiversityPresence (dtRel: dtRel)
            
            for target in dtRel.targetHitL {
                if (dtRel.drug.drugType != .immunotherapy) {
                    
                    // Non Immuno
                    hitSum = hitSum + target.hitScore
                    if hugoL.contains (target.target.hugoName) == false {
                        hugoL.append(target.target.hugoName)
                        self.actedCount += 1
                    }
                } else {
                    //  Immuno
                   if hugoL.contains (target.target.hugoName) == false {
                      hugoL.append(target.target.hugoName)
                      self.actedImmunoCount += 1
                    }
                }
            }
            self.approvedCount += dtRel.drug.approved
        }
        hugoL.removeAll()
        
        
        // actual scores calculation
        ( redundGenomCount, redundPrRnaCount ) = redundCount ()
     /*
        if (self.actedImmunoCount != 0) {
            
            if ( immunoStatus == .mediumImmuno) {
            
                // medium Immuno
                strengthScore =      50.0 * hitSum /
                                    (( 5.0 * (Double(genomicCount) + Double(redundGenomCount))) +
                                    ( 2.5 * (Double(protRnaCount) + Double(redundPrRnaCount))) )
                 strengthScore += 50
                
                
            } else {
                // High Immuno
                strengthScore =      20.0 * hitSum /
                                    (( 5.0 * (Double(genomicCount) + Double(redundGenomCount))) +
                                    ( 2.5 * (Double(protRnaCount) + Double(redundPrRnaCount))) )
                strengthScore += 80
                
            }
            
        } else {
            // no Immuno
            strengthScore =     100.0 * hitSum /
                                (( 5.0 * (Double(genomicCount) + Double(redundGenomCount))) +
                                ( 2.5 * (Double(protRnaCount) + Double(redundPrRnaCount))) )
        }
        */
        
        switch immunoStatus{
        case .noImmuno :
            
            strengthScore =   100.0 * hitSum /
                            (( 5.0 * (Double(genomicCount) + Double(redundGenomCount))) +
                             ( 2.5 * (Double(protRnaCount) + Double(redundPrRnaCount))) )
            break
            
        case .mediumImmuno :
            strengthScore =   50.0 * hitSum /
                            (( 5.0 * (Double(genomicCount) + Double(redundGenomCount))) +
                             ( 2.5 * (Double(protRnaCount) + Double(redundPrRnaCount))) )
            
            if (self.actedImmunoCount != 0) {
                strengthScore +=  50.0
            }
            
            break
            
        case .highImmuno :
            strengthScore =   20.0 * hitSum /
                            (( 5.0 * (Double(genomicCount) + Double(redundGenomCount))) +
                             ( 2.5 * (Double(protRnaCount) + Double(redundPrRnaCount))) )
            
            if (self.actedImmunoCount != 0) {
                strengthScore +=  80.0
            }
            break
        }

        
        
        let fuzzyFact = (100.0 - Double(self.dtRelL.count)) / 100.0
        strengthScore = strengthScore * fuzzyFact
        
    }
    
    
        
    
    
    //-------------------------------------------------
    // Match calculation
    func calcMatchScore () {
        
        let totalRedundTargets = self.redundPrRnaCount + self.redundGenomCount
        let comboLen           = self.dtRelL.count

        var actedSquare : Double
        var numerator   : Double
        
        if (self.actedImmunoCount != 0) {
            
            if ( immunoStatus == .mediumImmuno) {
                
                if (comboLen == 3) {
                   var toto = 3
                    toto = toto - 1
                }
                
                // medium Immuno
                numerator    = redundFact * ((0.5 * Double(genomicCount) * 5.0) + (0.5 * hitSum))
                actedSquare  = Double( self.genomicCount + self.actedCount + totalRedundTargets )
                actedSquare  = actedSquare * actedSquare
                numerator    = numerator * actedSquare
                
                
            } else {
                // High Immuno
                numerator    = redundFact * ((0.8 * Double(genomicCount) * 5.0) + (0.2 * hitSum))
                actedSquare  = Double( self.genomicCount + self.actedCount + totalRedundTargets )
                actedSquare  = actedSquare * actedSquare
                numerator    = numerator * actedSquare
            }
            
        } else {
            // no Immuno
            actedSquare = Double( (self.actedCount + totalRedundTargets) * (self.actedCount + totalRedundTargets))
            numerator   = redundFact * hitSum * Double (actedSquare)
        }
        
        /*
        
        switch immunoStatus{
        case .noImmuno :
            
            actedSquare = Double( (self.actedCount + totalRedundTargets) * (self.actedCount + totalRedundTargets))
            numerator   = redundFact * hitSum * Double (actedSquare)
            break
            
        case .mediumImmuno :
            numerator    = redundFact * ((0.5 * Double(genomicCount) * 5.0) + (0.5 * hitSum))
            actedSquare  = Double( self.actedImmunoCount + self.actedCount + totalRedundTargets )
            actedSquare  = actedSquare * actedSquare
            numerator    = numerator * actedSquare
            
            break
            
        case .highImmuno :
            numerator    = redundFact * ((0.8 * Double(genomicCount) * 5.0) + (0.2 * hitSum))
            actedSquare  = Double( self.actedImmunoCount + self.actedCount + totalRedundTargets )
            actedSquare  = actedSquare * actedSquare
            numerator    = numerator * actedSquare
            
           
            break
        }
        */
        let denominator  = Double (comboLen * (self.actionableCount + totalRedundTargets))
        self.matchScore  = numerator / denominator
        
    }
    
    
   
    // -------------------------------------------------------------------
    // func proteinCount return {genomic, Rna+Protein)
    func redundCount () ->(Int,Int) {
        
        var prrnaCountRed = 0    // redundant protein + rna count
        var genomCountRed = 0    // redundantgenomic count

        var tList = [TargetHit_C]()
        for dtRel in self.dtRelL {
            for t in dtRel.targetHitL{
                if ( tList.contains( where : { $0.target.hugoName  == t.target.hugoName} ) == false ) {
                    tList.append (t)
                } else {
                    if (t.target.markerType == .genomic) || (t.target.forceGenomic == true) {
                        genomCountRed = genomCountRed + 1
                        
                    } else {
                        prrnaCountRed = prrnaCountRed + 1
                        
                    }
                }
            }
        }
        tList.removeAll()
        return (genomCountRed, prrnaCountRed )
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
    // func check contains a zero Hit on a target
    func checkWarning () {
        hasWarning = redundancy
        /*
        self.hasWarning = false
        for dtRel in self.dtRelL {
            if dtRel.drug.blackBox == true {
                self.hasWarning = true
            }
        }
       */
    }
    
    func isPairRedundant (dtRel1: DTRelation_C, dtRel2: DTRelation_C) -> Bool {
     
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
        
        if (intersecSet.count < set1.count) && (intersecSet.count < set2.count) {
            return (false)
         
        // rule 53
        // allow MAP2K1 + Anti BRAF for colon cancer
        // for all cancers 1==1
            
        } else if ( ((BRAFDrugL.contains(dtRel1.drug.drugName) == true ) && (MAP2KDrugL.contains(dtRel2.drug.drugName) == true)) ||
                    ((BRAFDrugL.contains(dtRel2.drug.drugName) == true ) && (MAP2KDrugL.contains(dtRel1.drug.drugName) == true)) ) {
            
            if (rules22added == false) {
                rulesLog += "(#22) Accept redundancy of [BRAF inhib.] X [MEK inhib.] \n"
                rules22added = true
            }
            return ( false )
        
       /* } else if   ( pathoClass == "Colon Cancer" || 1==1 ) &&
                    ((((dtRel1.drug.drugName == "cobimetinib" ) || (dtRel1.drug.drugName == "trametinib"  )) &&
                      ((dtRel2.drug.drugName == "dabrafenib" )  || (dtRel2.drug.drugName == "vemurafenib" ))) ||
                        
                     (((dtRel2.drug.drugName == "cobimetinib" ) || (dtRel2.drug.drugName == "trametinib"  )) &&
                      ((dtRel1.drug.drugName == "dabrafenib" )  || (dtRel1.drug.drugName == "vemurafenib" )))) {
            
            
                if (rules22added == false) {
                    rulesLog += "(#22) Accept redundancy of [cobimetinib, dabrafenib] X [trametinib, vemurafenib] \n"
                    rules22added = true
                }
                return ( false )
          
         
        // rule 34 59 60 71
        */
        } else if (( EGFRAmp == true ) && EGFRDrugL.contains (dtRel1.drug.drugName) && EGFRDrugL.contains (dtRel2.drug.drugName) ) &&
              ( (( dtRel1.drug.drugName.hasSuffix("nib") == true) && ( dtRel2.drug.drugName.hasSuffix("mab") == true)) ||
                (( dtRel2.drug.drugName.hasSuffix("nib") == true) && ( dtRel1.drug.drugName.hasSuffix("mab") == true)) ) {
                /*
                 (( dtRel1.drug.drugName.hasSuffix("mab") == true) && ( dtRel2.drug.drugName.hasSuffix("mab") == true)) ) {
                */
                
               
          //      rulesLog += "(#34 #59 #60 #71) EGFR Ampilfied redundancy \n"
                rulesLog += " EGFR Ampilfied redundancy of" + String(dtRel1.drug.drugName) + "+" + String(dtRel2.drug.drugName) + "\n"
                return ( false )
        
        } else if (( ERBB2Mutated == true ) && ERBB2DrugL.contains (dtRel1.drug.drugName) && ERBB2DrugL.contains (dtRel2.drug.drugName) ) &&
            
            ( (( dtRel1.drug.drugName == "pertuzumab") && ( dtRel2.drug.drugName == "trastuzumab")) ||
              (( dtRel2.drug.drugName == "pertuzumab") && ( dtRel1.drug.drugName == "trastuzumab")) ){
            
            /*  ( (( dtRel1.drug.drugName.hasSuffix("nib") == true) && ( dtRel2.drug.drugName.hasSuffix("mab") == true)) ||
                (( dtRel2.drug.drugName.hasSuffix("nib") == true) && ( dtRel1.drug.drugName.hasSuffix("mab") == true)) ||
                (( dtRel1.drug.drugName.hasSuffix("mab") == true) && ( dtRel2.drug.drugName.hasSuffix("mab") == true)) ) {
            */
            
                
          //      rulesLog += "(#34 #59 #60 #71) ERBB2 Mutated redundancy \n"
                rulesLog += " ERBB2 Mutated redundancy of" + String(dtRel1.drug.drugName) + "+" + String(dtRel2.drug.drugName) + "is OK \n"
                return ( false )
            
        // rule 67
        } else if (  EGFRC797S  == true )  &&
            ( (( dtRel1.drug.drugName == "brigatinib") && ( dtRel2.drug.drugName == "cetuximab")) ||
              (( dtRel2.drug.drugName == "brigatinib") && ( dtRel1.drug.drugName == "cetuximab")) ) {
            
            rulesLog += "(#67) Accept redundancy of brigatinib and cetuximab whit EGFR C797S  \n"
            return ( false )
            
        } else if ( PTGS1Mutated == true ) || ( PTGS2Mutated == true)   &&
            ( (( dtRel1.drug.drugName == "sulindac") && ( dtRel2.drug.drugName == "celecoxib")) ||
              (( dtRel2.drug.drugName == "sulindac") && ( dtRel1.drug.drugName == "celecoxib")) ) {
            
            rulesLog += "(#39) Accept redundancy of sulindac and celecoxib when PTGS1/2 Mutated  \n"
            return ( false )
            
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
            }
            
            // if a target is never better that the other
            // then does not allow the redundancy
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
          
            // No 3 times the same target
            // to be repalced by a set comparison instead of just first elt of the TragetHitL
            if ((self.dtRelL[0].targetHitL[0].target.hugoName == self.dtRelL[1].targetHitL[0].target.hugoName ) &&
                (self.dtRelL[0].targetHitL[0].target.hugoName == self.dtRelL[2].targetHitL[0].target.hugoName )){
                self.redundancy = true
                return
            }

            
        }
    }
}
