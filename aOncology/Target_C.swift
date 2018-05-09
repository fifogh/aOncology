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

     init (id: Int, hugoName: String, aberration: String){
        self.aberDesc    = aberration      // might be erased
        self.aberDisp    = aberration      // keep this one for display
        self.actionable  = true
        self.markerType  = MarkerType.genomic

        super.init(geneId: id, hugoName: hugoName)
        self.setMarkerType()
        
    }
    
    func setMarkerType (){
        if protMarkerL.contains(where: { ($0 == aberDesc) }) {
            self.markerType  = MarkerType.protein
            self.keyword     = aberDesc
            self.aberDesc    = ""
            
        } else if rnaMarkerL.contains(where: { ($0 == aberDesc) }) {
            self.markerType  = MarkerType.protein
            self.keyword     = aberDesc
            self.aberDesc    = ""
            
        } else  if keyWordAberL.contains(where: { ($0 == aberDesc) }) {
            self.keyword     = aberDesc
            self.aberDesc    = ""
        }
        
    }
    
}
/*
//------------------------------------------------------------------------------
// TARGET Substitution
class TargetSubs_C : Gene_C  {
    
    var subsName   : String
    var mode       : Int
    
    init (id: Int, hugoName: String, subsName: String, mode: Int ){
       
        self.subsName = subsName
        self.mode     = mode
        super.init(geneId: id, hugoName: hugoName)
    }
}


//------------------------------------------------------------------------------
// DrugIc50 Class
class DrugIc50_C : Drug_C {
    
    var Ic50    : Double    // Ic50 value
    
    init ( drugId: Int, drugName : String, allowed: Bool, _Ic50: Double){
        self.Ic50 = _Ic50

        super.init ( drugId: drugId, drugName: drugName, allowed: allowed)

    }
}

//------------------------------------------------------------------------------
// AberDrugL Class
class AberDrugL_C  {
    
    var aberration : String           // Aberration Description
    var drugIc50L  : [DrugIc50_C]!    // Ic50 value
    
    init (aberration: String){
        self.aberration = aberration
        drugIc50L  = [DrugIc50_C]()
    }
}

//------------------------------------------------------------------------------
// TargetDrug Class
class TargetDrugs_C  {
    
    var gene : Gene_C                   // HugoName of the Gene Description
    var aberDrugL  : [AberDrugL_C ]!    // list of aberration/ Drug lists
    
    init (gene: Gene_C){
        self.gene = gene
        self.aberDrugL = [AberDrugL_C ]()
    }
}

*/

// var targetDrugsL = [TargetDrugs_C]()
