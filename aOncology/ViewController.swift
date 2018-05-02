//
//  ViewController.swift
//  aOncology
//
//  Created by Philippe-Faurie on 4/17/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import UIKit

enum CalcMode {case auto, manual}

var drugNumberL = ["1", "2", "3"]

var targetL   = [Target_C]()              // Tragets list
var dtRelL    = [DTRelation_C] ()         // Drug-Target relation list

var combo1L   = [Combination_C]()        // 1 drug Combos
var combo2L   = [Combination_C]()        // 2 drug Combos
var combo3L   = [Combination_C]()        // 3 drug Combos

var noDrugNameL  = [String]()             // Forbidden drugs list
var myCombMaker  = CombMaker_C ()         // Combinatory utilitary

class ViewController: UIViewController  {
    
    var comboLen = 1
    var myGeneDrug = geneDrugs ()
    var loggedIn : Bool!
    var calcMode = CalcMode.auto
    
    
    @IBOutlet var folderImage: UIImageView!
    
    @IBOutlet var newGeneName: UITextField!
    @IBOutlet var newAberrationName: UITextField!

    @IBOutlet var targetInputTableView: UITableView!
    @IBOutlet var drugListTableview: UITableView!
    @IBOutlet var combListTableview: UITableView!
    
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var loggedName: UILabel!
    
    @IBOutlet var drugCount: UILabel!
    @IBOutlet var geneCount: UILabel!
    @IBOutlet var combCount: UILabel!
  
    //------------------------------------
    // The Mode Auto/Manual has changed
    @IBAction func autoManualChange(_ sender: UISegmentedControl) {
        
        let index = sender.selectedSegmentIndex
        if (index == 0) {
            //Automatic mode
            calcMode = CalcMode.auto
            for t in dtRelL{
                t.drug.allowed = true
            }
            
        } else {
            // Manual mode
            calcMode = CalcMode.manual
            for t in dtRelL{
                t.drug.allowed = false
            }
        }
        
        drugListTableview.reloadData()
        buildAllCombos ()
        updateCounterDisplay()
    }
    

   // func prepare( for segue:UIStoryboardSegue, sender: AnyObject?) {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toLoginSegue"
        {
            if let destinationVC = segue.destination as? loginViewController {
                destinationVC.loginDelegate = self
                destinationVC.isLogged = loggedIn

            }
        } else if segue.identifier == "toDrugDetail" {
            
            if let destinationVC = segue.destination as? DrugDetailViewController{
                let myIndexPath = self.drugListTableview.indexPathForSelectedRow!
                let row = myIndexPath.row
                destinationVC.navigationItem.title = dtRelL[row].drug.drugName
              //  destinationVC.drugName = drugNameL[row]
                destinationVC.drugName = dtRelL[row].drug.drugName
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loggedIn = false
        // Do any additional setup after loading the view, typically from a nib.
     }

    override func viewWillAppear(_ animated: Bool) {
       if loggedIn == true {
           self.folderImage.isHidden = false
       } else {
           self.folderImage.isHidden = true
       }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //------------------------------------
    // a Target has been entered
    @IBAction func addGeneTaped(_ sender: Any) {
        
        if let inputGene = newGeneName.text {
            
            // the Gene input is not left blank
            // remove leading and trailing space
            let trimmedGene  = inputGene.trimmingCharacters(in: .whitespaces)
            var trimmedAber : String
            if let inputAber = newAberrationName.text {
                trimmedAber = inputAber.trimmingCharacters(in: .whitespaces)
            } else {
                trimmedAber = ""
            }
            
            // create the target object and add it in the list
            let target : Target_C = Target_C (id: 0, hugoName: trimmedGene, aberration: trimmedAber )
            self.addTarget (target: target)
            newGeneName.text! = ""
            newAberrationName.text! = ""
            
        }
    }

    
    //------------------------------------
    // a Target has been addeed
    func addTarget (target: Target_C) {

        if targetL.contains(where: { ($0.hugoName == target.hugoName) && ($0.aberDesc == target.aberDesc)}) {
            let alert = UIAlertController(title: "Target already In", message: "No need to input twice", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            
        }else{
            targetL.append(target)
            
            self.targetInputTableView.beginUpdates()
            self.targetInputTableView.insertRows(at: [IndexPath.init(row: targetL.count-1, section: 0)], with: .automatic)
            self.targetInputTableView.endUpdates()
            
            myGeneDrug.newGeneConfigDelegate  = self
            myGeneDrug.targetToAdd (theTarget: target,  inDrugL: dtRelL, allowed: calcMode == CalcMode.auto )
            geneCount.text = String( targetL.count)
            
         }
    }
    
    //------------------------------------
    // a Target has been removed
    func subTarget  () {
        
        myGeneDrug.rebuildAll   ( inTargetL: targetL, inDTRelL: dtRelL, allowed: calcMode == CalcMode.auto )
        updateCounterDisplay()
    }

    
    
    //------------------------------------
    // return number of elts in each combo
    func comboCount () -> Int {
        var countNb = 0;
        
        if (comboLen == 1) {
            countNb = combo1L.count
            
        } else if (comboLen == 2) {
            countNb = combo2L.count

        } else {
            countNb = combo3L.count
        }
        return countNb
    }

    
    
    //------------------------------------
    // Update all counters text for display
    func updateCounterDisplay() {
        geneCount.text = String( targetL.count)
        drugCount.text = String( dtRelL.count )
        combCount.text = String( comboCount() )
    }
}


//------------------------------------------------------------------------
// TABLEVIEW DELEGATE
extension ViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == targetInputTableView){
            return targetL.count
            
        } else if (tableView == drugListTableview){
            return dtRelL.count
            
        } else {
            return self.comboCount ()
        }
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (tableView == targetInputTableView){
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellTargetId") as! TargetTableViewCell
            let gene = targetL[indexPath.row].hugoName
            let aberration = targetL[indexPath.row].aberDesc
            cell.gene.text = gene
            cell.aberration.text = aberration
            
            return cell
            
        } else if (tableView == drugListTableview){
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellDrugId") as! DrugTableViewCell
            let text = dtRelL[indexPath.row].drug.drugName
            cell.drugName?.text = text
            cell.delegate = self
            cell.indexPath = indexPath
            
            if (dtRelL[indexPath.row].drug.allowed == false ) {
                cell.checkMark.alpha = 0.3
                cell.drugName.textColor = UIColor.lightGray
                
            } else {
                cell.checkMark.alpha = 1.0
                cell.drugName.textColor = UIColor.black
            }
            
            return cell
            
        } else {
            //Combo
            
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 1
            
            if (self.comboLen == 1 ){
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellComb1Id") as! Comb1TableViewCell
                let drug1Name = combo1L[indexPath.row].dtRelL[0].drug.drugName
                let score     = formatter.string (from: combo1L[indexPath.row].strengthScore as NSNumber )
                cell.drug1.text = drug1Name
                cell.score.text = score
                return cell
                
            } else if (self.comboLen == 2) {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellComb2Id") as! Comb2TableViewCell
                let drug1Name = combo2L[indexPath.row].dtRelL[0].drug.drugName
                let drug2Name = combo2L[indexPath.row].dtRelL[1].drug.drugName
                
                let score = formatter.string (from: combo2L[indexPath.row].strengthScore as NSNumber )
                cell.drug1.text = drug1Name
                cell.drug2.text = drug2Name
                cell.score.text = score
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellComb3Id") as! Comb3TableViewCell
                let drug1Name = combo3L[indexPath.row].dtRelL[0].drug.drugName
                let drug2Name = combo3L[indexPath.row].dtRelL[1].drug.drugName
                let drug3Name = combo3L[indexPath.row].dtRelL[2].drug.drugName
                
                let score = formatter.string (from: combo3L[indexPath.row].strengthScore as NSNumber )
                cell.drug1.text = drug1Name
                cell.drug2.text = drug2Name
                cell.drug3.text = drug3Name
                cell.score.text = score
                return cell
           }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if (tableView == targetInputTableView){
                targetL.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                self.subTarget ()

            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath , animated: true)
    }
    
}

//------------------------------------------------------------------------
// OPTION BUTTON (TABLEVIEW ) DELEGATE
extension ViewController: OptionButtonsDelegate {
    func checkMarkTapped(at index:IndexPath){
        
        
        // a drug has been added or removed
        
        let cell = drugListTableview.cellForRow(at: index) as! DrugTableViewCell
        let label = cell.drugName

        if (dtRelL[index.row].drug.allowed == true ) {
            dtRelL[index.row].drug.allowed = false
            label!.textColor = UIColor.lightGray
            cell.checkMark.alpha = 0.3
            
        } else {
            dtRelL[index.row].drug.allowed = true
            label!.textColor = UIColor.black
            cell.checkMark.alpha = 1.0
        }
        
        // rebuild now the combos
        self.buildAllCombos ()
        self.updateCounterDisplay()
    }
}


//------------------------------------------------------------------------
// TEXTFIELD DELEGATE
extension ViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("TextField should return method called")
        textField.resignFirstResponder();
        if (textField == newGeneName) {
            self.newGeneName = textField
        } else  {
            self.newAberrationName = textField
        }
        return true;
    }
}


//------------------------------------------------------------------------
// PICKER DELEGATE
extension ViewController:  UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        comboLen = row + 1

        combListTableview.reloadData()
        
        // no need to rebuild combos
        // they all exist but need to adjust counters
        updateCounterDisplay()

        return (drugNumberL [row ])
    }

}

//------------------------------------------------------------------------
// GENE ADDED DELEGATE
extension ViewController: targetChangeDelegate {
    
    func buildAllCombos () {
        
        //delete all previous
        combo1L.removeAll()
        combo2L.removeAll()
        combo3L.removeAll()
        
        
        // Create the list of combinations 1, 2 and 3 drugs
        var combosxx : [[DTRelation_C]]
        var dtRelLxx = [DTRelation_C] ()
        
        
        //Take the non forbidden Drugs Only
        for dt in dtRelL{
            if (dt.drug.allowed == true) {
                dtRelLxx.append(dt)
            }
        }
        
        combosxx =  myCombMaker.combinationsWithoutRepetitionFrom (elements: dtRelLxx, taking: 1)
        for elem in combosxx{
            let combElem = Combination_C (dtRelList: elem )
            combo1L.append ( combElem )
        }
        combo1L.sort(by: { $0.strengthScore > $1.strengthScore })
        
        combosxx =  myCombMaker.combinationsWithoutRepetitionFrom (elements: dtRelLxx, taking: 2)
        for elem in combosxx{
            let combElem = Combination_C (dtRelList: elem )
            combo2L.append ( combElem )
        }
        combo2L.sort(by: { $0.strengthScore > $1.strengthScore })
        
        combosxx =  myCombMaker.combinationsWithoutRepetitionFrom (elements: dtRelLxx, taking: 3)
        for elem in combosxx{
            let combElem = Combination_C (dtRelList: elem )
            combo3L.append ( combElem )
        }
        combo3L.sort(by: { $0.strengthScore > $1.strengthScore })
        
        dtRelLxx.removeAll()
        
        combListTableview.reloadData()
        
    }
    
    func drugListAdjusted ( outDrugL: [DTRelation_C] ){
        
        // free previous Drug Target Relation list
        // and take teh new one
        dtRelL.removeAll()
        dtRelL = outDrugL
        drugListTableview.reloadData()
        
        // generate all combos
        // and update counters
        self.buildAllCombos ()
        self.updateCounterDisplay()

    }

}

//------------------------------------------------------------------------
// LOGIN SCREEN DELEGATE
extension ViewController: loginScreenDelegate {
    func didLogin (hasLogged: Bool, name :String){
        loggedName.text = name
        loggedIn = hasLogged
        if (loggedIn == true ){
            loginButton.setImage(UIImage(named: "rounded doctor"), for: .normal)
        }else{
            loginButton.setImage(UIImage(named: "person-generic"), for: .normal)
        }
        
    }
}



