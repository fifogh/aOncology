//
//  Score_c.swift
//  aOncology
//
//  Created by Philippe-Faurie on 4/26/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import Foundation

class Score_C {
    
    
    func ic50ToHit (ic50: Double) -> Double {
        var hs : Double
        let Vm = 7.0
        let Km = 250.0
        let IC50m = 16.04
        
        let fnIC50 = ((Vm - (Vm * (ic50 - IC50m) / (Km + (ic50 - IC50m)))));

        hs = 0.981242 * fnIC50 - 2.384326;
        return (hs)
        
    }
    
    func hitScore (ic50: Double, mode: Int, marker: Int ) -> Double {
        
      return (0.0)
    }
    
    
}
