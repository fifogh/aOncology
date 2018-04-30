//
//  DTRelation.swift
//  aOncology
//
//  Created by Philippe-Faurie on 4/28/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import Foundation


//------------------------------------------------------------------------------
// TARGET Class
class TargetHitMode_C : Target_C  {
    
    var mode         : String?       // direct/indirect/semi_direct
    var markerType   : String?       // genomic, protein, rna
    
    var Ic50     : Double
    var hitScore : Double
 
    
    init (id: Int, hugoName: String, aberration: String, mode: String, Ic50: Double){
        

        self.mode       = mode
        self.Ic50       = Ic50
        self.markerType = "genomic"
        self.hitScore   = 0

        super.init (id: id, hugoName: hugoName, aberration: aberration)
        
        self.hitScore   = self.calcHitScore()

    }
    
    
    func ic50ToHit () -> Double {
        var ret: Double
        let Vm = 7.0
        let Km = 250.0
        let IC50m = 16.04
        
        let fnIC50 = ((Vm - (Vm * (Ic50 - IC50m) / (Km + (Ic50 - IC50m)))));
        
        ret = 0.981242 * fnIC50 - 2.384326;
        return (ret)
    }
    
    func calcHitScore () -> Double {
        
        //-------------------
        // normal formula
        
        if (Ic50 < 51){
            hitScore = 5;
            
        } else if (Ic50 < 501){
            hitScore = self.ic50ToHit();
          
        } else {
            hitScore = 0;
        }
        
        //------------------
        // Adaptations
        
        // Only get 75% of score for Pathways ( indirect )
        if (mode == "indirect") {
            hitScore = 3*hitScore/4;
        }
        
        // in case of protein Marker : half of the calculated score
        if ( markerType == "protein" ) {
            hitScore = hitScore / 2 ;
         }
        
        
         //------------------
        // house cleaning
        if ( hitScore < 0 ) {
            print ("!!!! Warning Neg hit \( hitScore ) !!!!\n");
            hitScore = 0
            
        } else if ( hitScore > 5 ) {
            print ("!!!! Warning >5 hit \( hitScore ) !!!!\n");
            hitScore = 5
        }

        return (hitScore)
    }
  
}



