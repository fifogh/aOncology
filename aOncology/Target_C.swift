//
//  Target_C.swift
//  aOncology
//
//  Created by Philippe-Faurie on 4/25/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import Foundation


enum MarkerType :Int {case genomic, protein, rna }         // Markers Types


var  protMarkerL  = [ "Positive","Negative", "+","-","High","Low", ]
var  rnaMarkerL   = [ "Overexpression", "Underexpression"]
var  keyWordAberL = [ "Gain", "Amplification","Loss" ]

var  allKeyWordL  = protMarkerL + rnaMarkerL + keyWordAberL



//------------------------------------------------------------------------------
// GENE Class
class Gene_C {
    var id         : String           // Id instead of Name
    var hugoName   : String        // plain name
    var synoName   : String!       // Synonym

    init (geneId: String, hugoName: String){
        self.id       = geneId
        self.hugoName = hugoName
    }
}


//------------------------------------------------------------------------------
// TARGET Class
class Target_C : Gene_C  {
    
    
    var aberDesc    : String?       // aberration Description
    var aberDisp    : String?       // keyword is displayed and AberDesc is set to ""
    var actionable  : Bool
    var markerType  : MarkerType
    var forceGenomic: Bool          // proteinPenalty = 1/2 histscore
    var keyword     : String?       // in case of protein, rna marker, or keyword
    var allowed     : Bool          // user selection yes/no


    init (id: String, hugoName:String, aberration: String){

        self.aberDesc     = aberration      // might be erased
        self.aberDisp     = aberration      // keep this one for display
        self.actionable   = false           // until we find a drug
        self.allowed      = true            // unless explicit (user, rule)
        self.forceGenomic = false           // by default: not forced to genomic

        self.markerType  = .genomic        // will be set after self.init


        super.init(geneId: id, hugoName: hugoName)
        self.setMarkerType()
        self.setProtPenalty()
        
    }
    
    func setMarkerType (){
        if ( protMarkerL.contains(where: { ($0 == aberDesc) }) == true) {
            self.markerType  = MarkerType.protein
            self.keyword     = aberDesc
            self.aberDesc    = ""
            
        } else if ( rnaMarkerL.contains(where: { ($0 == aberDesc) }) == true) {
            self.markerType  = MarkerType.rna
            self.keyword     = aberDesc
            self.aberDesc    = ""
            
        } else  if ( keyWordAberL.contains(where: { ($0 == aberDesc) }) == true) {
            self.keyword     = aberDesc
            self.aberDesc    = ""
        } else {
           // nothing to do
        }
        
    }
    
    func setProtPenalty (){
        
        if ((hugoName == "CD274") || (hugoName == "ERBB2") ||
            (hugoName == "AR")    || (hugoName == "ESR1")) {
            
            if ( (markerType == MarkerType.protein ) || ( markerType == MarkerType.rna)) {
                rulesLog += "Void Protein/Rna Penalty on: " + String(hugoName) + "\n"
                forceGenomic = true
            }
        }
        
    }
    
}

