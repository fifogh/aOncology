//
//  LookUpViewController.swift
//  aOncology
//
//  Created by Philippe-Faurie on 6/16/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import UIKit

var parentL = [String]()
var childL  = [String]()
var ddrugL  = [String]()


class LookUpViewController: UIViewController {

    @IBOutlet var geneName: SearchTextField!
    
    @IBOutlet var childTableView:  UITableView!
    @IBOutlet var parentTableView: UITableView!
    @IBOutlet var drugTableView: UITableView!
    
    @IBOutlet var childNum: UILabel!
    @IBOutlet var parentNum: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // newGeneName.filterStrings(dicDTRelL.keys)
       // geneName.filterStrings(Array(geneDataList))
        
        let allGenes = Array (list1.union(list2))
        geneName.filterStrings(allGenes)
        
        geneName.maxNumberOfResults = 5
        geneName.minCharactersNumberToStartFiltering = 2
        
       
        // remove tab bar text asistant
        let item : UITextInputAssistantItem = geneName.inputAssistantItem
        item.leadingBarButtonGroups = []
        item.trailingBarButtonGroups = []
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func go(_ sender: Any) {
        let theGene = geneName.text!
        
        geneName.becomeFirstResponder()
        geneName.resignFirstResponder();

        
        childL.removeAll()
        parentL.removeAll()
        ddrugL.removeAll()

        
        //------------------
        // Child
        
        if let theChildL = dicTSubsL [theGene] {
           childL.removeAll()
           for (theChild, _ ) in theChildL {
               childL.append(theChild)
           }
        }
        childTableView.reloadData()
        
        
        
        
        //------------------
        // Parent

        for (theParent) in dicTSubsL.keys {
            for theChild in dicTSubsL[theParent]!.keys {

                if (theChild == theGene){
                        parentL.append(theParent)
                }
             }
        }
        parentTableView.reloadData()

        parentNum.text = String (parentL.count)
        childNum.text  = String (childL.count)
        
        
        
        //------------------
        // Drug
        
        
        if  dicDTRelL [theGene] != nil {
           let drugIc50L =  dicDTRelL [theGene]! [""]
           for (drug, ic50) in drugIc50L! {
               ddrugL.append (drug)
           }
        }
        drugTableView.reloadData()
        
        
    }
}


//------------------------------------------------------------------------
// TABLEVIEW DELEGATE
extension LookUpViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == parentTableView){
            return parentL.count
            
        } else if (tableView == childTableView){
            return childL.count
            
        } else if (tableView == drugTableView){
            return ddrugL.count
            
        } else {
            return 0
        }
            
    }
    
    
    
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        if (tableView == parentTableView){
            let cell = tableView.dequeueReusableCell(withIdentifier: "parentCellId")

            cell?.textLabel?.text = parentL[indexPath.row]
            return cell!
            
            
       // } else if (tableView == childTableView){
            
        } else if (tableView == drugTableView){
             let cell = tableView.dequeueReusableCell(withIdentifier: "ddrugCellId")
            cell?.textLabel?.text = ddrugL[indexPath.row]
            return cell!

    
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "childCellId")
            
            cell?.textLabel?.text = childL[indexPath.row]
            return cell!
        }
    
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (tableView == parentTableView){
            geneName.text = parentL[indexPath.row]
            self.go (self)

        } else  if (tableView == childTableView){
           geneName.text = childL[indexPath.row]
           self.go (self)
        }
        
        tableView.deselectRow(at: indexPath , animated: true)
    }
    
    
}
//------------------------------------------------------------------------
// TEXTFIELD DELEGATE

extension LookUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        
        if (textField == geneName) {
            self.go (self)
        }
        
        return true;
    }
}
