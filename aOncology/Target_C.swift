//
//  Target_C.swift
//  aOncology
//
//  Created by Philippe-Faurie on 4/25/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import Foundation



//------------------------------------------------------------------------------
// DRUG Class
class Drug_C {
    
    var id   : Int           // Id instead of Name
    var drugName : String    // plain name
    var allowed  : Bool      // user selection yes/no
    
    
    init (drugId: Int, drugName: String, allowed: Bool){
        self.id       = drugId
        self.drugName = drugName
        self.allowed  = allowed
    }
}


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

     init (id: Int, hugoName: String, aberration: String){
        aberDesc    = aberration

        super.init(geneId: id, hugoName: hugoName)
    }
}

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



// var targetDrugsL = [TargetDrugs_C]()
