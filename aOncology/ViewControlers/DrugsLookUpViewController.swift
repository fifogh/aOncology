//
//  DrugsLookUpViewController.swift
//  aOncology
//
//  Created by Philippe-Faurie on 8/8/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import UIKit


var equivDrugL   = [String]()
var drug2TargetL = [String]()

class DrugsLookUpViewController: UIViewController {

    
    @IBOutlet var drugName: SearchTextField!
    
    @IBOutlet var equivDrugTableView:   UITableView!
    @IBOutlet var drug2TargetTableView: UITableView!
 
    @IBOutlet var equivDrugNum: UILabel!
    @IBOutlet var targetNum: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let allDrugsL = Array(dTargetL.keys)
        drugName.filterStrings(allDrugsL)
        
        // remove tab bar text asistant
        let item : UITextInputAssistantItem = drugName.inputAssistantItem
        item.leadingBarButtonGroups = []
        item.trailingBarButtonGroups = []
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func goDrugLookUp(_ sender: Any) {
        
        
        // hide KP and new entry will erase field
        drugName.becomeFirstResponder()
        drugName.resignFirstResponder();
        
        
        equivDrugL.removeAll()
        drug2TargetL.removeAll()
        var sortedTargetL = [String]()
        
        // Drug2Target
        if dTargetL[drugName.text!] != nil {
           drug2TargetL = dTargetL[drugName.text! ]!
           sortedTargetL = drug2TargetL.sorted()
        }
        
        for d in dTargetL.keys {
            
            if dTargetL [ d ] != nil {
                let sorteddTargetL = dTargetL [ d ]!.sorted()
                if sorteddTargetL == sortedTargetL{
                    //drequivalent
                    equivDrugL.append(d)
                }
            }
        }
        
        
        drug2TargetTableView.reloadData()
        equivDrugTableView.reloadData()
        
    
    
        
        // Counts
        equivDrugNum.text = String (equivDrugL.count)
        targetNum.text    = String (drug2TargetL.count)
        
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

//------------------------------------------------------------------------
// TABLEVIEW DELEGATE
extension DrugsLookUpViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableView == equivDrugTableView){
            return equivDrugL.count
            
        } else if (tableView == drug2TargetTableView){
            return drug2TargetL.count
            
            
        } else {
            return 0
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (tableView == equivDrugTableView){
            let cell = tableView.dequeueReusableCell(withIdentifier: "equivDrugCellId")
            
            cell?.textLabel?.text = equivDrugL[indexPath.row]
            return cell!
            
            
            // } else if (tableView == childTableView){
            
        } else /*if (tableView == targetTableView)*/ {
            let cell = tableView.dequeueReusableCell(withIdentifier: "drug2TargetCellId")
            cell?.textLabel?.text = drug2TargetL[indexPath.row]
            return cell!
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
   /*     if (tableView == parentTableView){
            geneName.text = parentL[indexPath.row]
            self.go (self)
            
        } else  if (tableView == childTableView){
            geneName.text = childL[indexPath.row]
            self.go (self)
        }
 
        tableView.deselectRow(at: indexPath , animated: true)
         
    */
    }
}
    
//------------------------------------------------------------------------
// TEXTFIELD DELEGATE
extension DrugsLookUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        
        if (textField == drugName) {
            self.goDrugLookUp (self)
        }
        
        return true;
    }
}



