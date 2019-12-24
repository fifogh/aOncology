//
//  rules.swift
//  aOncology
//
//  Created by Philippe-Faurie on 5/16/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import Foundation


// dirty Globals to speed up process
var ALKMutated   = false
var BRAFMutated  = false
var ERBB2Mutated = false
var EGFRAmp      = false
var EGFRC797S    = false
var CCNE1Amp     = false
var PTGS1Mutated = false
var PTGS2Mutated = false
var MDM24Amp     = false

var rulesLog  = ""       // Keep log of trigerred rules



class Rules {
    
    func findDrug (drugName : String) -> Int? {
        let drugPos = dtRelL.index (where: { $0.drug.drugName == drugName  }) ;
        return drugPos
    }
    
    //----------------------------
    // find Gene in a relation
    func findGene (geneName : String, dtRelation : DTRelation_C) -> Int? {
        let genePos = dtRelation.targetHitL.index (where: { $0.target.hugoName == geneName && $0.target.allowed == true  }) ;
        return genePos
    }
    
    //----------------------------
    // find Gene in the input
    func findGene (geneName : String) -> Int? {
        let genePos = targetL.index (where: { $0.hugoName == geneName && $0.allowed == true }) ;
        return genePos
    }
    
    //----------------------------
    // find Gene in the input
    func findTarget (target : Target_C) -> Int? {
        let genePos = targetL.index (where: { $0.hugoName == target.hugoName && $0.aberDesc == target.aberDesc && $0.allowed == true  }) ;
        return genePos
    }
    
    
    //----------------------------
    // Set Hit Score Drug + Gene
    func setHitScore (drugName: String, geneName: String, score: Double) {
        if let drugPos = findDrug (drugName : drugName) {
            if let genPos = findGene ( geneName: geneName, dtRelation: dtRelL[drugPos]) {
                dtRelL[drugPos].targetHitL[genPos].hitScore = score
                
                rulesLog += "      force hitScore: " + String (score) + " for " +  String (drugName) + " on " + String (geneName) + "\n"
                
            }
        }
    }
    
    //----------------------------
    // Set Hit Score Drug + Gene
    func setHitScore (drugName: String, score: Double) {
        if let drugPos = findDrug (drugName : drugName) {
            for targetHit in dtRelL[drugPos].targetHitL {
                targetHit.hitScore = score
                
                rulesLog += "      force hitScore: " + String (score) + " for " +  String (drugName) + "\n"
                
            }
        }
    }
    
    //----------------------------
    // Half Hit Score Drug + Gene
    func halfHitScore (drugName: String, geneName: String) {
        if let drugPos = findDrug (drugName : drugName) {
            if let genePos = findGene ( geneName: geneName, dtRelation: dtRelL[drugPos]) {
                dtRelL[drugPos].targetHitL[genePos].hitScore = dtRelL[drugPos].targetHitL[genePos].hitScoreRuled ?
                    0.5 * dtRelL[drugPos].targetHitL[genePos].hitScore : dtRelL[drugPos].targetHitL[genePos].hitScore
                dtRelL[drugPos].targetHitL[genePos].hitScoreRuled = true
                
                rulesLog += "      half hitScore for " +  String (drugName) + " on " + String (geneName) + "\n"

                
            }
        }
    }
    
    //----------------------------
    // Half ALL Hit Scores Drug
    func halfHitScores (drugName: String) {
        if let drugPos = findDrug (drugName : drugName) {
            for tHit in dtRelL[drugPos].targetHitL {
                tHit.hitScore = tHit.hitScoreRuled ? tHit.hitScore : 0.5 * tHit.hitScore
                tHit.hitScoreRuled = true   // half score only once
                
                rulesLog += "      half hitScore for " +  String (drugName) + "\n"

            }
        }
    }
   
    func rememberMutations () {
        
        ALKMutated   = false
        BRAFMutated  = false
        ERBB2Mutated = false
        EGFRAmp      = false
        CCNE1Amp     = false
        PTGS1Mutated = false
        PTGS2Mutated = false
        MDM24Amp     = false
        
        for target in targetL {
            
            if (target.hugoName == "BRAF") {
                BRAFMutated = true
                
            } else if (target.hugoName == "ERBB2") && ( (target.aberDisp != "Neg")  &&
                                                        (target.aberDisp != "Loss") && (target.aberDisp != "Neg") &&
                                                        (target.aberDisp != "Low")  && (target.aberDisp != "-")) {
                ERBB2Mutated = true
           
            } else if (target.hugoName == "ALK") {
                ALKMutated = true
           
            } else if (target.hugoName == "EGFR") && ((target.aberDisp == "Amplification") ||
                                                      (target.aberDisp == "Amp") ||
                                                      (target.aberDisp == "Ampl")) {
                EGFRAmp = true
                
            } else if (target.hugoName == "EGFR") && (target.aberDisp == "C797S") {
                
                EGFRC797S = true
                
            } else if (target.hugoName == "CCNE1") && ( (target.aberDisp == "Amplification") ||
                                                        (target.aberDisp == "Amp") ||
                                                        (target.aberDisp == "Ampl")) {
                CCNE1Amp = true
                
            } else  if (target.hugoName == "PTGS1") {
                PTGS1Mutated = true
                
            } else  if (target.hugoName == "PTGS2") {
                PTGS2Mutated = true
                
            } else  if ( ((target.hugoName == "MDM2") || (target.hugoName == "MDM4")) &&
                                                        ( (target.aberDisp == "Amplification") ||
                                                          (target.aberDisp == "Amp")           ||
                                                          (target.aberDisp == "Ampl")) ){
                
                MDM24Amp = true
            }
            
            
            
        }
    }
    
    // ---------------------
    //-- R22 TODO
    /*When the diagnosis is 'colorectal' or 'colon' or 'rectum' or 'rectal' cancer, and BRAF is mutated, the program should consider the association of drugs:
    cetuximab/panitumumab (anti-EGFR) + trametinib/cobimetinib (anti MAP2K1/2)
    Or cetuximab/panitumumab (anti-EGFR) + dabrafenib (anti BRAF)
    Or cetuximab/panitumumab (anti-EGFR) + vemurafenib (anti BRAF)
    Or dabrafenib/vemurafenib (anti BRAF) + trametinib/cobimetinib (anti MAP2K1/2)
    Or any of the above that include cetuximab/panitumumab adding in irinotecan (anti TOP1)
    Or cetuximab/panitumumab (anti-EGFR) + dabrafenib (anti-BRAF) + trametinib (anti-MAP2K1/2)
    When an additional mutation exists (e.g. BRAF and KIT mutated), the program should come up with the combinations above, and after, regular calculation xxx.
   */
    
    func addLog (strLog : inout String, drug : String) -> Bool {
        strLog += "      " + drug + "\n"
        return (true)
    }
    
    
    func removeDrugs () {
        
        var ruleTriggered = false
        
        let initStr  = "REMOVAL of DRUGS \n"
        var removeStr = initStr
        
        // rule 37
        if (( findGene (geneName : "BRAF") != nil ) ||
            ( findGene (geneName : "KRAS") != nil ) ||
            ( findGene (geneName : "NRAS") != nil ) ||
            ( findGene (geneName : "HRAS") != nil )) {
        
            removeStr += "   (#37) BRAF or RAS family present \n"
            
            if let drugPos = findDrug ( drugName: "idelalisib") {
                dtRelL [drugPos].drug.allowed = false
                ruleTriggered = addLog (strLog: &removeStr, drug: "idelalisib")
            }
            
            if let drugPos = findDrug ( drugName: "copanlisib") {
                 dtRelL [drugPos].drug.allowed = false
                 ruleTriggered = addLog (strLog: &removeStr, drug: "copanlisib")
            }
            
            if let drugPos = findDrug ( drugName: "metformin") {
                dtRelL [drugPos].drug.allowed = false
                ruleTriggered = addLog (strLog: &removeStr, drug: "metformin")
             }
            
            if let drugPos = findDrug ( drugName: "everolimus") {
                 dtRelL [drugPos].drug.allowed = false
                 ruleTriggered = addLog (strLog: &removeStr, drug: "everolimus")
             }
            
            if let drugPos = findDrug ( drugName: "sirolimus") {
                 dtRelL [drugPos].drug.allowed = false
                 ruleTriggered = addLog (strLog: &removeStr, drug: "sirolimus")
             }
            
            if let drugPos = findDrug ( drugName: "temsirolimus") {
                 dtRelL [drugPos].drug.allowed = false
                 ruleTriggered = addLog (strLog: &removeStr, drug: "temsirolimus")
            }
            
            // Now add to the Log
            if ruleTriggered == true {
                rulesLog += removeStr
                ruleTriggered = false
            }
        }
        
        // rule 54
        if  (MDM24Amp == true) {
            
            removeStr += "\n   (#54) MDM2 or MDM4 Amplified \n"
            if let drugPos = findDrug ( drugName: "atezolizumab") {
                dtRelL [drugPos].drug.allowed = false
                ruleTriggered = addLog (strLog: &removeStr, drug: "atezolizumab")
             }
            
            if let drugPos = findDrug ( drugName: "durvalumab") {
                dtRelL [drugPos].drug.allowed = false
                ruleTriggered = addLog (strLog: &removeStr, drug: "durvalumab")
             }
            
            if let drugPos = findDrug ( drugName: "avelumab") {
                dtRelL [drugPos].drug.allowed = false
                ruleTriggered = addLog (strLog: &removeStr, drug: "avelumab")
             }
            
            if let drugPos = findDrug ( drugName: "pembrolizumab") {
                dtRelL [drugPos].drug.allowed = false
                ruleTriggered = addLog (strLog: &removeStr, drug: "pembrolizumab")
             }
            
            if let drugPos = findDrug ( drugName: "nivolumab") {
                dtRelL [drugPos].drug.allowed = false
                ruleTriggered = addLog (strLog: &removeStr, drug: "nivolumab")
             }
            
            // Now add to the Log
            if ruleTriggered == true {
                rulesLog += removeStr
                ruleTriggered = false
            }
        }

        // rule 62
        // CCNE1 Amplfied
        if  (CCNE1Amp == true) {
            
            removeStr += "\n   CCNE1 Amplified \n"

            if let drugPos = findDrug ( drugName: "palbociclib") {
                 dtRelL [drugPos].drug.allowed = false
                 ruleTriggered = addLog (strLog: &removeStr, drug: "palbociclib")
            }
            
            if let drugPos = findDrug ( drugName: "ribociclib") {
                dtRelL [drugPos].drug.allowed = false
                ruleTriggered = addLog (strLog: &removeStr, drug: "ribociclib")
            }
            
            if let drugPos = findDrug ( drugName: "abemaciclib") {
                dtRelL [drugPos].drug.allowed = false
                ruleTriggered = addLog (strLog: &removeStr, drug: "abemaciclib")
            }
            
            // Now add to the Log
            if ruleTriggered == true {
                rulesLog += removeStr
                ruleTriggered = false
            }
        }
        
        
        // rule 65
        // do not use Braf inhibitors (vemurafenib, dabrafenib) in the absence of a BRAF mutation.
        if  (BRAFMutated == false) {
            removeStr += "\n   BRAF is not mutated \n"

            if let drugPos = findDrug ( drugName: "vemurafenib") {
                dtRelL [drugPos].drug.allowed = false
                ruleTriggered = addLog (strLog: &removeStr, drug: "vemurafenib")
            }
            
            if let drugPos = findDrug ( drugName: "dabrafenib") {
                 dtRelL [drugPos].drug.allowed = false
                 ruleTriggered = addLog (strLog: &removeStr, drug: "dabrafenib")
            }
            
            // Now add to the Log
            if ruleTriggered == true {
                rulesLog += removeStr
                ruleTriggered = false
            }
        }
        
       
        //-----------------------
        // Rule 74
        if (pathoClass == "Central Nervous System Cancers") {
            if  (ALKMutated == true)  {
                
                removeStr += "\n   ALK is mutated in Central Nervous System Cancers \n"

                if let drugPos = findDrug ( drugName: "crizotinib") {
                    dtRelL [drugPos].drug.allowed = false
                    ruleTriggered = addLog (strLog: &removeStr, drug: "crizotinib")
                }
            
                if let drugPos = findDrug ( drugName: "ceritinib") {
                    dtRelL [drugPos].drug.allowed = false
                    ruleTriggered = addLog (strLog: &removeStr, drug: "ceritinib")
                }
            }
            
            // Now add to the Log
            if ruleTriggered == true {
                rulesLog += removeStr
                ruleTriggered = false
            }
        }

    }
    
    // ---------------------
    // Rule 10
    func setDiseaseRelationScore () {
        
         if (pathoClass == "Gastric Cancer") {
            
            rulesLog += "Because of " + String (pathoClass) + "\n"
            
            setHitScore (drugName: "imatinib", geneName: "KIT",    score: 5.0)
            setHitScore (drugName: "imatinib", geneName: "PDGFRA", score: 5.0)
        }
    }
    
    
    // ---------------------
    // Rule 13 in DTRelation
    // ---------------------
    
    func setRelationScore () {
        
        rulesLog += "ARBITRARY CHANGE OF SCORES" + "\n"
        
        // Rule 14
        setHitScore (drugName: "regorafenib", geneName: "BRAF", score: 0.0)
        setHitScore (drugName: "sorafenib",   geneName: "BRAF", score: 0.0)
        
        // Rule 63
        setHitScore (drugName: "trametinib",  geneName: "BRAF", score: 5.0)
        setHitScore (drugName: "cobimetinib", geneName: "BRAF", score: 5.0)

        
        // Rule 77
        setHitScore (drugName: "belinostat",   geneName: "H3F3A", score: 1.88)
        setHitScore (drugName: "panobinostat", geneName: "H3F3A", score: 1.88)
        setHitScore (drugName: "romidepsin",   geneName: "H3F3A", score: 1.88)
        setHitScore (drugName: "tamoxifen",    geneName: "H3F3A", score: 1.88)
        setHitScore (drugName: "vorinostat",   geneName: "H3F3A", score: 1.88)
        
        
        
         // Rule 72
        setHitScore (drugName:  "cisplatin",   score: 5.0)
        setHitScore (drugName:  "oxaliplatin", score: 5.0)
        setHitScore (drugName:  "carboplatin", score: 5.0)
        setHitScore (drugName:  "olaparib",    score: 5.0)
        setHitScore (drugName:  "rucaparib",   score: 5.0)
        setHitScore (drugName:  "niraparib",   score: 5.0)
        setHitScore (drugName:  "mitomycin C", score: 5.0)
        
         // rule 66 - 72
        setHitScore (drugName:  "cisplatin" ,   geneName: "TERT", score: 1.88)
        setHitScore (drugName:  "oxaliplatin" , geneName: "TERT", score: 1.88)
        setHitScore (drugName:  "carboplatin" , geneName: "TERT", score: 1.88)
        setHitScore (drugName:  "olaparib" ,    geneName: "TERT", score: 1.88)
        setHitScore (drugName:  "rucaparib" ,   geneName: "TERT", score: 1.88)
        setHitScore (drugName:  "niraparib" ,   geneName: "TERT", score: 1.88)
        setHitScore (drugName:  "mitomycin C",  geneName: "TERT", score: 1.88)

        setHitScore (drugName:  "cisplatin" ,   geneName: "MUTYH", score: 1.88)
        setHitScore (drugName:  "oxaliplatin" , geneName: "MUTYH", score: 1.88)
        setHitScore (drugName:  "carboplatin" , geneName: "MUTYH", score: 1.88)
        setHitScore (drugName:  "olaparib" ,    geneName: "MUTYH", score: 1.88)
        setHitScore (drugName:  "rucaparib" ,   geneName: "MUTYH", score: 1.88)
        setHitScore (drugName:  "niraparib" ,   geneName: "MUTYH", score: 1.88)
        setHitScore (drugName:  "mitomycin C",  geneName: "MUTYH", score: 1.88)


        
        // TP53: VEGFA/KDR FLT1 Trick
        
        //FLT1 - KDR
        setHitScore (drugName:  "ceritinib" ,    geneName: "TP53", score: 0.0)
        setHitScore (drugName:  "ramucirumab" ,  geneName: "TP53", score: 1.88)

        setHitScore (drugName:  "axitinib" ,     geneName: "TP53", score: 3.75)
        setHitScore (drugName:  "bevacizumab" ,  geneName: "TP53", score: 3.75)
        setHitScore (drugName:  "cabozantinib" , geneName: "TP53", score: 3.75)
        setHitScore (drugName:  "lenvatinib" ,   geneName: "TP53", score: 3.75)
        setHitScore (drugName:  "midostaurin" ,  geneName: "TP53", score: 3.75)
        setHitScore (drugName:  "nintedanib" ,   geneName: "TP53", score: 3.75)
        setHitScore (drugName:  "pazopanib" ,    geneName: "TP53", score: 3.75)
        setHitScore (drugName:  "ponatinib" ,    geneName: "TP53", score: 3.75)
        setHitScore (drugName:  "regorafenib" ,  geneName: "TP53", score: 3.75)
        setHitScore (drugName:  "sorafenib" ,    geneName: "TP53", score: 3.75)
        setHitScore (drugName:  "sunitinib" ,    geneName: "TP53", score: 3.75)
        setHitScore (drugName:  "vandetanib" ,   geneName: "TP53", score: 3.75)

        //VEGFA
        setHitScore (drugName:  "bevacizumab" ,      geneName: "TP53", score: 3.75)
        setHitScore (drugName:  "ranibizumab" ,      geneName: "TP53", score: 3.75)
        setHitScore (drugName:  "ziv-aflibercept" ,  geneName: "TP53", score: 3.75)

    }
    
    // ---------------------
    // Rule 12
    // Rule 49
    // Rule 78
    func halfScores () {
        rulesLog += "ARBITRARY HALF HITSCORES" + "\n"

        halfHitScores (drugName: "ponatinib")
        halfHitScores (drugName: "mitomycin")
        halfHitScores (drugName: "ranibizumab")

    }
    

    
    func allRules() {
        
        rememberMutations ()          // mark some mutations to speed up later
        removeDrugs ()
        setDiseaseRelationScore()
        setRelationScore ()
        halfScores ()
    }
    
}
