//
//  DebugViewController.swift
//  aOncology
//
//  Created by Philippe-Faurie on 5/11/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import UIKit

class DebugViewController: UIViewController {
    
    var drugCount = 0    // number of drug to display
    var row = 0
    var str = ""

    @IBOutlet var dtRelText: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
       self.displayCombo()
    }
    

    func displayCombo () {
        let relList     : [DTRelation_C]
        var redund      : Bool
        var zeroHit     : Bool
        var redundProt  : Int
        var redundGen   : Int
        var protRnaCount : Int
        var genomicCount : Int
        var actionableCount : Int
        var actedCount    : Int
        
        
        
        relList         = comboL[drugCount-1][row].dtRelL
        redund          = comboL[drugCount-1][row].redundancy
        redundProt      = comboL[drugCount-1][row].redundPrRnaCount
        redundGen       = comboL[drugCount-1][row].redundGenomCount
        zeroHit         = comboL[drugCount-1][row].hasAZeroHit
        protRnaCount    = comboL[drugCount-1][row].protRnaCount
        genomicCount    = comboL[drugCount-1][row].genomicCount
        actionableCount = comboL[drugCount-1][row].actionableCount
        actedCount      = comboL[drugCount-1][row].actedCount
        
       // actedCount      = protRnaCount  + genomicCount
        
        
        str = "Redundancy: "     + String (redund) + "\n Redund Prot#: "  + String (redundProt) + "\n Redund Gen#: "  + String (redundGen) + "\n\n"
        str = str + "Markers:\n ProteinM: " + String (protRnaCount) + "\n GenomicM: "     + String (genomicCount) + " \nActionable#: "   + String ( actionableCount ) + " \nActed#: " + String(actedCount) + "\n\n"
        
        str = str + "Strength : " + String (comboL[drugCount-1][row].strengthScore) + "\n"
        str = str + "Match    : " + String (comboL[drugCount-1][row].matchScore) + "\n"  + "hasAZeroHit = " + String(zeroHit)  + "\n\n"
        
        for rel in relList {
            str = str + rel.drug.drugName + "\n"
            
            let targetList = rel.targetHitL!
            for t in  targetList {
                
                if (t.targetSubsL.count == 0) {
                    str = str + "               " + t.target.hugoName + " hs= " + String(t.hitScore) +  " Ic50 = " + String(t.Ic50!) + "\n"
                } else {
                    str = str + "               " + t.target.hugoName + " hs= " + String(t.hitScore) +   "\n"
                    for s in  t.targetSubsL {
                        
                        if (s.mode == SubsMode.indirect){
                            str = str + "                     Via " + s.target.hugoName +  " Pathway  hs= " + String(s.hitScore) +  " Ic50 = " + String(s.Ic50!) + "\n"
                        } else {
                            str = str + "                     Via " + s.target.hugoName + " hs= " + String(s.hitScore) +  " Ic50 = " + String(s.Ic50!) + "\n"
                        }
                    }
                }
            }
        }
        dtRelText.text = str + "\n\n" + rulesLog
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
