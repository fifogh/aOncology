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
        let relList : [DTRelation_C]
        var redund : Bool
        
        if ( drugCount == 1 ) {
            relList = combo1L[row].dtRelL
            redund = combo1L[row].redundancy
            
        } else if ( drugCount == 2 ) {
            relList = combo2L[row].dtRelL
            redund = combo2L[row].redundancy
            
        } else {
            relList = combo3L[row].dtRelL
            redund = combo3L[row].redundancy
        }
        
        str = "redundancy = " + String (redund) + "\n"
        
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
