//
//  Target_C.swift
//  aOncology
//
//  Created by Philippe-Faurie on 4/25/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import Foundation


enum MarkerType :Int {case genomic, protein, rna }         // Markers Types


var  protMarkerL  = [ "positive","negative","pos","neg", "+","-","high","low","hi","lo" ]
var  rnaMarkerL   = [ "overexpr", "over"]
var  keyWordAberL = [ "gain", "amp", "ampl", "amplification","loss" ]

var  allKeyWordL  = protMarkerL + rnaMarkerL + keyWordAberL



//------------------------------------------------------------------------------
// GENE Class
class Gene_C {
    var id         : Int           // Id instead of Name
    var hugoName   : String        // plain name
    var synoName   : String!       // Synonym

    init (geneId: Int, hugoName: String){
        self.id       = geneId
        self.hugoName = hugoName
    }
}


//------------------------------------------------------------------------------
// TARGET Class
class Target_C : Gene_C  {
    
    
    var aberDesc   : String?       // aberration Description
    var aberDisp   : String?       // keyword is displayed and AberDesc is set to ""
    var actionable : Bool
    var markerType : MarkerType
    var keyword    : String?       // in case of protein, rna marker, or keyword

    init (id: Int, hugoName:String, aberration: String){

        self.aberDesc    = aberration      // might be erased
        self.aberDisp    = aberration      // keep this one for display
        self.actionable  = true
        self.markerType  = .genomic        // will be set after self.init


        super.init(geneId: id, hugoName: hugoName)
        self.setMarkerType()
        
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
}

