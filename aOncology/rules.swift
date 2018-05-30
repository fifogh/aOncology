//
//  rules.swift
//  aOncology
//
//  Created by Philippe-Faurie on 5/16/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import Foundation

class Rules {
    
    func findDrug (drugName : String) -> Int? {
        let drugPos = dtRelL.index (where: { $0.drug.drugName == drugName  }) ;
        return drugPos
    }
    
    //----------------------------
    // find Gene in a relation
    func findGene (geneName : String, dtRelation : DTRelation_C) -> Int? {
        let genePos = dtRelation.targetHitL.index (where: { $0.target.hugoName == geneName  }) ;
        return genePos
    }
    
    //----------------------------
    // find Gene in the input
    func findGene (geneName : String) -> Int? {
        let genePos = targetL.index (where: { $0.hugoName == geneName  }) ;
        return genePos
    }
    
    //----------------------------
    // find Gene in the input
    func findTarget (target : Target_C) -> Int? {
        let genePos = targetL.index (where: { $0.hugoName == target.hugoName && $0.aberDesc == target.aberDesc  }) ;
        return genePos
    }
    
    
    //----------------------------
    // Set Hit Score Drug + Gene
    func setHitScore (drugName: String, geneName: String, score: Double) {
        if let drugPos = findDrug (drugName : drugName) {
            if let genPos = findGene ( geneName: geneName, dtRelation: dtRelL[drugPos]) {
                dtRelL[drugPos].targetHitL[genPos].hitScore = score
            }
        }
    }
    
    //----------------------------
    // Half Hit Score Drug + Gene
    func halfHitScore (drugName: String, geneName: String) {
        if let drugPos = findDrug (drugName : drugName) {
            if let genePos = findGene ( geneName: geneName, dtRelation: dtRelL[drugPos]) {
                dtRelL[drugPos].targetHitL[genePos].hitScore = 0.5 * dtRelL[drugPos].targetHitL[genePos].hitScore
            }
        }
    }
    
    //----------------------------
    // Half ALL Hit Scores Drug
    func halfHitScores (drugName: String) {
        if let drugPos = findDrug (drugName : drugName) {
            for tHit in dtRelL[drugPos].targetHitL {
                tHit.hitScore = tHit.hitScoreRuled ? tHit.hitScore : 0.5 * tHit.hitScore
                tHit.hitScoreRuled = true
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
    
    
    
    // ---------------------
    //-- R65
    //Braf inhibitors (vemurafenib, dabrafenib) can not be used in the absence of a BRAF mutation.
    
    func removeDrugs () {
        if  findGene (geneName: "BRAF") == nil {
            if let drugPos = findDrug ( drugName: "vemurafenib") {
                dtRelL.remove (at: drugPos)
            }
            
            if let drugPos = findDrug ( drugName: "dabrafenib") {
                dtRelL.remove (at: drugPos)
            }
        }
       
      //  if (disease == brain tumor"
        if  findGene (geneName: "ALK") != nil {
            if let drugPos = findDrug ( drugName: "crizotinib") {
                dtRelL.remove (at: drugPos)
            }
            
            if let drugPos = findDrug ( drugName: "ceritinib") {
                dtRelL.remove (at: drugPos)
            }
        }
        
    }
    
    // ---------------------
    // Rule 10
    func setDiseaseRelationScore () {
        //if ( diagnosis = "Gastro Intestinal")
        setHitScore (drugName: "imatinib", geneName: "KIT",    score: 5.0)
        setHitScore (drugName: "imatinib", geneName: "PDGFRA", score: 5.0)
    }
    
    
    // ---------------------
    // Rule 14
    func setRelationScore () {
        setHitScore (drugName: "regorafenib", geneName: "BRAF", score: 0.0)
        setHitScore (drugName: "sorafenib",   geneName: "BRAF", score: 0.0)
        
    }
    
    // ---------------------
    // Rule 12 49 78
    func halfScores () {
        halfHitScores (drugName: "ponatinib")
        halfHitScores (drugName: "mytomicin")
        halfHitScores (drugName: "ranibizumab")

    }
    

    
    func allRules() {
        removeDrugs ()
        setDiseaseRelationScore()
        setRelationScore ()
        halfScores ()
    }
    
}
