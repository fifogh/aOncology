//
//  ComboDetailViewController.swift
//  aOncology
//
//  Created by Philippe-Faurie on 5/2/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import UIKit

class ComboDetailViewController: UIViewController {
    
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
        var redundCount : Int
        
        relList      = comboL[drugCount-1][row].dtRelL
        redund       = comboL[drugCount-1][row].redundancy
        redundCount  = comboL[drugCount-1][row].redundPrRnaCount + comboL[drugCount-1][row].redundGenomCount
        zeroHit      = comboL[drugCount-1][row].hasAZeroHit

        str = "redundancy = " + String (redund) + "\nRedund Target # : " + String (redundCount) + "\nhasAZeroHit = " + String(zeroHit) + "\n\n"
        str = str + "Strength : " + String (comboL[drugCount-1][row].strengthScore) + "\n"
        str = str + "Match    : " + String (comboL[drugCount-1][row].matchScore) + "\n"

        for rel in relList {
            str = str + rel.drug.drugName + "\n"
            
            let targetList = rel.targetHitL!
            for t in  targetList {
              
                if (t.targetSubsL.count == 0) {
                    str = str + "               " + t.hugoName + " hs= " + String(t.hitScore) + "\n"
                } else {
                    str = str + "               " + t.hugoName + " hs= " + String(t.hitScore) + "\n"
                    for s in  t.targetSubsL {
                        
                        if (s.mode == SubsMode.indirect){
                            str = str + "                     Via " + s.hugoName +  " Pathway  hs= " + String(t.hitScore) + "\n"
                        } else {
                            str = str + "                     Via " + s.hugoName + " hs= " + String(t.hitScore) + "\n"
                        }
                    }
                }
            }
         }
        dtRelText.text = str
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
