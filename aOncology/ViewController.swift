//
//  ViewController.swift
//  aOncology
//
//  Created by Philippe-Faurie on 4/17/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import UIKit

enum CalcMode  {case auto,  manual}
enum SortMode  {case score, onLabel}
enum MutBurden {case unknown, low, medium, high}
enum MicroSat  {case unknown, low, high }


 // picker view labels
var drugNumberL  = ["1", "2", "3"]

var mutBurdenL   = ["Unknown", "low ( < 6 /Mb )", "medium ( 6-20 /Mb )", "high( > 20 /Mb )"]
var microsatIL   = ["Unknown", "low", "high"]

var targetL   = [Target_C]()                 // Tragets list: all pathogenic
var dtRelL    = [DTRelation_C] ()            // Drug-Target relation list
var caseL     = [Case_C]()                   // Cases List


var combo1L   = [Combination_C]()           // 1 drug Combos
var combo2L   = [Combination_C]()           // 2 drug Combos
var combo3L   = [Combination_C]()           // 3 drug Combos
var comboL    = [combo1L,combo2L,combo3L]   // list( 1d, 2d, 3d)  of combinations list
var pathoClass = ""                         // Pathology Class

var noDrugNameL  = [String]()               // Forbidden drugs list to remember
var myCombMaker  = CombMaker_C ()           // Combinatory utilitary

var targetIndex  = IndexPath ()

let rules = Rules ()                        // to acces to rules

class ViewController: UIViewController  {
    
    var comboLen = 1
    var loggedIn : Bool!
    var calcMode = CalcMode.auto
    var sortMode = SortMode.score

    var drugDisabled = 0                        // manual toggle on drugs
    
    var MMRState = false
    var OctState = false
    
    var mutBurden = MutBurden.low
    var microSat  = MicroSat.low
    
    var myGeneDrug = geneDrugs ()

    @IBOutlet var folderImage: UIImageView!
    
    @IBOutlet var newCaseID: UILabel!
    @IBOutlet var newMemo: UITextField!
    @IBOutlet var newAge: UITextField!

    @IBOutlet var newGeneName: SearchTextField!
    @IBOutlet var newAberrationName: SearchTextField!
    @IBOutlet var newPathologyName: SearchTextField!
    
    
    @IBOutlet var targetInputTableView: UITableView!
    @IBOutlet var drugListTableview: UITableView!
    @IBOutlet var combListTableview: UITableView!
    
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var loggedName: UILabel!
    
    @IBOutlet var drugCount: UILabel!
    @IBOutlet var geneCount: UILabel!
    @IBOutlet var combCount: UILabel!
  
    @IBOutlet var MMRCheckImage: UIImageView!
    @IBOutlet var OctrCheckImage: UIImageView!
    
    
    //------------------------------------
    // Save case
    
    @IBAction func saveTapped(_ sender: Any) {
        let newCase = Case_C (caseId: "", nickName: newMemo.text!, age: newAge.text!, targetL : targetL , diagnosis: self.newPathologyName.text!)
        
        newCase.loadCases()
        
        caseL.append ( newCase )
        
        newCaseID.text = newCase.caseId
        
        let theTitle = "Case " + newCaseID.text!
        let alert = UIAlertController(title: theTitle, message: "saved", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
        self.present(alert, animated: true)
        
        newCase.saveCases()
    }
    
    //------------------------------------
    // Clear All
    
    @IBAction func resetTapped(_ sender: Any) {
        targetL.removeAll()
        self.subTarget ()
        targetInputTableView.reloadData()
        newPathologyName.text = ""
        newAge.text    = ""
        newMemo.text   = ""
        newCaseID.text = ""
    }
    
    //------------------------------------
    // MMR Status
    @IBAction func MMRToggle(_ sender: Any) {
        if (MMRState == false) {
            MMRState = true
            MMRCheckImage.alpha = 1
        } else {
            MMRState = false
            MMRCheckImage.alpha = 0.3
        }
    }
    
    
    //------------------------------------
    // Octreotide status
    @IBAction func OctToggle(_ sender: Any) {
        if (OctState == false) {
            OctState = true
            OctrCheckImage.alpha = 1
        } else {
            OctState = false
            OctrCheckImage.alpha = 0.3
        }
    }
    
    
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
        
        dtRelL.sort(by: { $0.drug.allowed  != $1.drug.allowed  ? $0.drug.allowed && !$1.drug.allowed :
            $0.drug.approved != $1.drug.approved ? $0.drug.approved == 1  && $1.drug.approved == 0 :
            ($0.drug.drugName < $1.drug.drugName)  })
        
        drugListTableview.reloadData()
        buildAllCombos ()
        updateCounterDisplay()
    }
    
    
    @IBAction func comboSortChange(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        
        if (index == 0) {
            // Score
            sortMode = .score
        } else {
            sortMode = .onLabel
        }
        
        self.buildAllCombos()
    }
    
    //------------------------------------
   // Segue stuff
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
                destinationVC.drugName = dtRelL[row].drug.drugName
            }
            
        } else if segue.identifier == "toComboDetail" {
            if let destinationVC = segue.destination as? ComboDetailViewController{
                let myIndexPath = self.combListTableview.indexPathForSelectedRow!
                
                destinationVC.row = myIndexPath.row
                destinationVC.drugCount = self.comboLen
                //destinationVC.reducedCombo = self.calcMode == .manual
                destinationVC.reducedCombo = self.drugDisabled != 0
 
                destinationVC.navigationItem.title = "Combination Detail"

            }
        } else if segue.identifier == "caseListSegue" {
            
            if let destinationVC = segue.destination as? CaseViewController {
                destinationVC.caseSelectDelegate = self
            }
 
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        myGeneDrug.newGeneConfigDelegate  = self
        
        
        loggedIn = false
        // Do any additional setup after loading the view, typically from a nib.
        
       // newGeneName.filterStrings(dicDTRelL.keys)
        newGeneName.filterStrings(Array(geneDataList))
        newGeneName.maxNumberOfResults = 5
        newGeneName.minCharactersNumberToStartFiltering = 2
        
        
        newAberrationName.filterStrings(Array(allKeyWordL))
        newAberrationName.maxNumberOfResults = 5
        newAberrationName.minCharactersNumberToStartFiltering = 1
        
        newPathologyName.filterStrings(Array(pathoSynL))
        newPathologyName.maxNumberOfResults = 10
        newPathologyName.minCharactersNumberToStartFiltering = 2
        
        
        // remove tab bar text asistant
        var item : UITextInputAssistantItem = newGeneName.inputAssistantItem
        item.leadingBarButtonGroups = []
        item.trailingBarButtonGroups = []
        
        item  = newAberrationName.inputAssistantItem
        item.leadingBarButtonGroups = []
        item.trailingBarButtonGroups = []
        
        item  = newPathologyName.inputAssistantItem
        item.leadingBarButtonGroups = []
        item.trailingBarButtonGroups = []
       
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
        
        var theHugoName = ""
        var theSynoName = ""
        
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
            
            
            if (synoGeneData[trimmedGene] != nil){
                theHugoName = synoGeneData[trimmedGene]!
                theSynoName = trimmedGene
            } else {
                theHugoName = trimmedGene
                theSynoName = ""
            }
            let target : Target_C = Target_C (id: 0, hugoName: theHugoName, aberration: trimmedAber )
            target.synoName = theSynoName
            
            self.addTarget (target: target)
            newGeneName.text! = ""
            newAberrationName.text! = ""
            
        }
    }

    
    //------------------------------------
    // a Target has been addeed
    func addTarget (target: Target_C) {

        if targetL.contains(where: { ($0.hugoName == target.hugoName) && ($0.aberDisp == target.aberDisp)}) {
            let alert = UIAlertController(title: "Target already Entered", message: "No need to input twice", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            
        }else{
            targetL.append(target)
            let index = IndexPath(row:targetL.count-1, section: 0)
           
            self.targetInputTableView.beginUpdates()
            self.targetInputTableView.insertRows(at: [IndexPath.init(row: targetL.count-1, section: 0)], with: .automatic)
            self.targetInputTableView.endUpdates()
            
            myGeneDrug.newGeneConfigDelegate  = self
            myGeneDrug.targetToAdd (theTarget: target,  inDrugL: dtRelL, allowed: calcMode == CalcMode.auto )
            geneCount.text = String( targetL.count)
            self.targetInputTableView.scrollToRow(at: index, at: .middle, animated: true)
           
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
        
        let countNb = comboL[comboLen-1].count
        return ( countNb )
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
            let hugo = targetL[indexPath.row].hugoName
            let syno = targetL[indexPath.row].synoName
            
            let aberration = targetL[indexPath.row].aberDisp
            cell.hugoName.text = hugo
            cell.synoName.text = syno

            cell.aberration.text = aberration
            if (targetL[indexPath.row].actionable == false ) {
                cell.hugoName.textColor = UIColor.lightGray
            }else{
                cell.hugoName.textColor = UIColor.black
            }
            
            if (targetL[indexPath.row].markerType == .protein ) || (targetL[indexPath.row].markerType == .rna ) {
                cell.symbolImage.image = UIImage ( named: "letterP" )
                cell.symbolImage.isHidden = false
            } else {
                cell.symbolImage.isHidden = true
            }
            
            return cell
            
        } else if (tableView == drugListTableview){
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellDrugId") as! DrugTableViewCell
            let text = dtRelL[indexPath.row].drug.drugName
            cell.drugName?.text = text
            cell.delegate = self
            cell.indexPath = indexPath
            
            if (dtRelL[indexPath.row].drug.allowed == false ) {
                cell.checkMark.alpha = 0.3
                cell.approved.alpha  = 0.3
                cell.warning.alpha   = 0.3
                
                cell.drugName.textColor = UIColor.lightGray
                
            } else {
                cell.checkMark.alpha = 1.0
                cell.approved.alpha  = 1.0
                cell.warning.alpha   = 1.0

                cell.drugName.textColor = UIColor.black
            }
            
            cell.approved.isHidden = dtRelL[indexPath.row].drug.approved == 0
            cell.warning.isHidden = dtRelL[indexPath.row].drug.blackBox == false
            
            return cell
            
        } else {
            //Combo
            
            let formatter = NumberFormatter()
            let formatter2 = NumberFormatter()
            formatter.maximumFractionDigits = 1
            formatter2.maximumFractionDigits = 2

            if (self.comboLen == 1 ){
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellComb1Id") as! Comb1TableViewCell
                let drug1Name = comboL[0][indexPath.row].dtRelL[0].drug.drugName
                
                let score       = formatter.string (from: comboL[0][indexPath.row].strengthScore as NSNumber )
                let matchScore  = formatter2.string(from: comboL[0][indexPath.row].matchScore as NSNumber )
                cell.drug1.text = drug1Name
                cell.score.text = score
                cell.matchScore.text = matchScore

                //Warning Image
                if (comboL[0][indexPath.row].redundancy == true) {
                    cell.warning.isHidden = false
                } else {
                    cell.warning.isHidden = true
                }
                
                // On Compendia image, blackBox Warning
                cell.approved.isHidden = comboL[0][indexPath.row].dtRelL[0].drug.approved == 0
                cell.warning.isHidden  = comboL[0][indexPath.row].hasWarning == false

                return cell
                
            } else if (self.comboLen == 2) {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellComb2Id") as! Comb2TableViewCell
                let drug1Name = comboL[1][indexPath.row].dtRelL[0].drug.drugName
                let drug2Name = comboL[1][indexPath.row].dtRelL[1].drug.drugName
                
                let score      = formatter.string (from: comboL[1][indexPath.row].strengthScore as NSNumber )
                let matchScore = formatter2.string(from: comboL[1][indexPath.row].matchScore as NSNumber )

                cell.drug1.text = drug1Name
                cell.drug2.text = drug2Name
                cell.score.text = score
                cell.matchScore.text = matchScore

                
                //Warning Image
                if (comboL[1][indexPath.row].redundancy == true) {
                    cell.warning.isHidden = false
                } else {
                    cell.warning.isHidden = true
                }
                
                // On Compendia image
                cell.approved1.isHidden = comboL[1][indexPath.row].dtRelL[0].drug.approved == 0
                cell.approved2.isHidden = comboL[1][indexPath.row].dtRelL[1].drug.approved == 0
                cell.warning.isHidden   = comboL[1][indexPath.row].hasWarning == false


                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellComb3Id") as! Comb3TableViewCell
                let drug1Name = comboL[2][indexPath.row].dtRelL[0].drug.drugName
                let drug2Name = comboL[2][indexPath.row].dtRelL[1].drug.drugName
                let drug3Name = comboL[2][indexPath.row].dtRelL[2].drug.drugName
                
                let score      = formatter.string (from: comboL[2][indexPath.row].strengthScore as NSNumber )
                let matchScore = formatter2.string(from: comboL[2][indexPath.row].matchScore as NSNumber )

                cell.drug1.text = drug1Name
                cell.drug2.text = drug2Name
                cell.drug3.text = drug3Name
                cell.score.text = score
                cell.matchScore.text = matchScore

                
                //Warning Image
                if (comboL[2][indexPath.row].redundancy == true) {
                    cell.warning.isHidden = false
                } else {
                    cell.warning.isHidden = true
                }
                // On Compendia image
                cell.approved1.isHidden = comboL[2][indexPath.row].dtRelL[0].drug.approved == 0
                cell.approved2.isHidden = comboL[2][indexPath.row].dtRelL[1].drug.approved == 0
                cell.approved3.isHidden = comboL[2][indexPath.row].dtRelL[2].drug.approved == 0
                cell.warning.isHidden   = comboL[2][indexPath.row].hasWarning == false

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
// OPTION BUTTON (DRUG LIST TABLEVIEW ) DELEGATE
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
        
        dtRelL.sort(by: { $0.drug.allowed  != $1.drug.allowed  ? $0.drug.allowed && !$1.drug.allowed :
            $0.drug.approved != $1.drug.approved ? $0.drug.approved == 1  && $1.drug.approved == 0 :
            ($0.drug.drugName < $1.drug.drugName)  })
        //dtRelL.sort(by: { ($0.drug.drugName < $1.drug.drugName) })
        
        let index = IndexPath(row:0, section: 0)
        drugListTableview.reloadData()
        drugListTableview.scrollToRow(at:index, at: .top , animated: true)

        
        // rebuild now the combos
        self.buildAllCombos ()
        self.updateCounterDisplay()
    }
    
    func warningTapped(at index:IndexPath){
        
        // a drug has been added or removed
        //let cell = drugListTableview.cellForRow(at: index) as! DrugTableViewCell
        //let label = cell.drugName
        
        let dName = dtRelL[index.row].drug.drugName
        let msg =  "Black Box Warning for " + dName
        
        let alert = UIAlertController(title: msg, message: drugLabels [dName]!, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
        self.present(alert, animated: true)

    }
    
}


//------------------------------------------------------------------------
// TEXTFIELD DELEGATE

extension ViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        if (textField == newGeneName) {
            self.newGeneName = textField as! SearchTextField
            
        } else if (textField == newAberrationName)  {
            self.newAberrationName = textField as! SearchTextField
            
        } else if (textField == newPathologyName) {
            
            self.newPathologyName = textField as! SearchTextField
            changePathologyClass (pathoName : self.newPathologyName.text!)
        }
        
        return true;
    }


   func textFieldDidEndEditing(_ textField: UITextField) {
      if (textField == newPathologyName) {
        
          self.newPathologyName = textField as! SearchTextField
          changePathologyClass (pathoName : self.newPathologyName.text!)
      }
    }

    
    func changePathologyClass (pathoName : String) {
        
        if ( pathoSynData [pathoName] != nil ){
            pathoClass = pathoSynData [pathoName]!
        } else {
            pathoClass = ""
        }
        print (pathoClass)
        
        for d in dtRelL {
            d.drug.markApproved(pathoClass: pathoClass)
        }
        
        dtRelL.sort(by: { $0.drug.allowed  != $1.drug.allowed  ? $0.drug.allowed && !$1.drug.allowed :
            $0.drug.approved != $1.drug.approved ? $0.drug.approved == 1  && $1.drug.approved == 0 :
            ($0.drug.drugName < $1.drug.drugName)  })
        
        self.drugListTableview.reloadData()
        self.combListTableview.reloadData()
        
    }
}


//------------------------------------------------------------------------
// PICKER DELEGATE
extension ViewController:  UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView.tag == 2){
            return microsatIL.count
            
        } else if (pickerView.tag == 1){
            return mutBurdenL.count
            
        } else {
            // drug # 
            return 3
        }
    }
    
    //---------------------------------------------------
    // Picker row display
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont.systemFont(ofSize: 17.0)
            pickerLabel?.textAlignment = .center
        }
        
        
        if (pickerView.tag == 0){
            pickerLabel?.text = drugNumberL [row]
            
        } else if (pickerView.tag == 1){
            pickerLabel?.text = mutBurdenL [row]
            
        } else if (pickerView.tag == 2){
            pickerLabel?.text = microsatIL [row]
        }
            
        pickerLabel?.textColor = UIColor.black
        
        
        return pickerLabel!
    }
    
    //---------------------------------------------------
    // Picker row selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        // no need to rebuild combos
        // they all exist but need to adjust counters
        
        if (pickerView.tag == 0){
            // Number of drugs
            comboLen = row + 1
            reArrangeAllCombos ()
            updateCounterDisplay()
            
        } else if (pickerView.tag == 1){
            // Mutation burden
            switch row {
            case 0 :
                self.mutBurden = MutBurden.unknown
                break
            case 1 :
                self.mutBurden = MutBurden.low
                break
            case 2 :
                self.mutBurden = MutBurden.medium
                break
            case 3 :
                self.mutBurden = MutBurden.high
                break
                
            default:
                break
            }
            
        } else if (pickerView.tag == 2){
            // Microsatellite status
            switch row {
            case 0 :
                self.microSat = MicroSat.unknown
                break
            case 1 :
                self.microSat = MicroSat.low
                break
            case 2 :
                self.microSat = MicroSat.high
               
            default:
                break
            }
        }
    }
}

//------------------------------------------------------------------------
// GENE ADDED DELEGATE
extension ViewController: targetChangeDelegate {
    
    
    //------------------------
    // reArrange the combos
    func reArrangeAllCombos () {
        
        // reArrange combos 1d, 2d, &3d
        var drugNb = 1
        while (drugNb < 4){
            // re-sort
            if ( sortMode == .onLabel) {
                comboL[drugNb-1].sort(by: { ($0.approvedCount > $1.approvedCount) })
            } else {
                comboL[drugNb-1].sort(by: { ($0.matchScore > $1.matchScore) })
            }
            drugNb += 1
        }
        
        // redisplay the combo
        combListTableview.reloadData()
    }
    
    //------------------------
    // Recount the markers
    func markersCount () ->(Int,Int) {
        
        var prrnaCount = 0       // protein + rna count
        var genomCount = 0       // genomic count
        
        var tList = [Target_C]()
        
        for t in targetL {
            if ( tList.contains( where : { $0.hugoName  == t.hugoName} ) == false ) {
                tList.append (t)
                if t.markerType == .genomic {
                   genomCount +=  1
               } else {
                   prrnaCount += 1
               }
            }
        }
        return ( genomCount, prrnaCount)
    }
        
    
    //------------------------
    // Rebuild the combos
    func buildAllCombos () {

        // specific rules
        rules.allRules ()
        
        var prrnaCount = 0       // protein + rna count
        var genomCount = 0       // genomic count

        ( genomCount , prrnaCount ) = self.markersCount ()
        
        // reset counter
         self.drugDisabled = 0
        
        //Take the non forbidden Drugs Only
        var dtRelLxx = [DTRelation_C] ()
        var dtRelLyy = [DTRelation_C] ()
        for dt in dtRelL{
            if (dt.drug.allowed == true) {
                dtRelLxx.append(dt)
            } else {
                dtRelLyy.append(dt)
                self.drugDisabled = self.drugDisabled + 1
            }
        }
        
        // recalculate combos 1d,2d,& 3d
        var drugNb = 1
        while (drugNb < 4){
       
            comboL[drugNb-1].removeAll()
            
            let combosxx =  myCombMaker.combinationsWithoutRepetitionFrom (elements: dtRelLxx, taking: drugNb)
            for elem in combosxx{
                let combElem = Combination_C (dtRelList: elem, filter : (calcMode == .auto),
                                              genomCount : genomCount, prrnaCount: prrnaCount, pathogenicCount : targetL.count )
                comboL[drugNb-1].append ( combElem )
            }
            
            // Remove zero scored combos in Auto Mode
            if (calcMode == .auto) {
               comboL[drugNb-1].sort(by: { ($0.strengthScore > $1.strengthScore) })
               var c = comboL[drugNb-1].last
               while ((c != nil) && (c!.strengthScore == 0 ) ) {
                   comboL[drugNb-1].removeLast()
                   c = comboL[drugNb-1].last
            }
            }
        
            // take care of next size combo
            drugNb = drugNb + 1
        }
        
      
        // clean tmp variables
        dtRelLxx.removeAll()
        dtRelLyy.removeAll()
        
        // Sort and Display
        reArrangeAllCombos ()
        
    }
    
    func drugListAdjusted ( outDrugL: [DTRelation_C], actionable: Bool, rebuilt: Bool ){
        
        // free previous Drug Target Relation list
        // and take the new one
        
        if ( actionable == true ) {
           
            dtRelL.removeAll()
            dtRelL = outDrugL
            
            // generate all combos
            // and update counters
            self.buildAllCombos ()
            self.updateCounterDisplay()
            
            // after buildAll Combos coz rules may delete DTRelations
            drugListTableview.reloadData()

            
        } else {
            
            // mark the Gene as not actionable
            if (targetL.count != 0) {
                targetL.last!.actionable = false  // remember not acctionnable
            }
            
            targetInputTableView.reloadData()
        }

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
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        
        }else{
            loginButton.setImage(UIImage(named: "person-generic"), for: .normal)
            self.navigationItem.rightBarButtonItem?.isEnabled = false

        }
        
    }
}

//------------------------------------------------------------------------
// CASE SELECTION DELEGATE
extension ViewController: caseSelectionDelegate {
    
    func didSelectCase (caseRow: Int){
        let theCase = caseL [caseRow]
        
        // clear all and load the config
        self.resetTapped (self)
        
        
        newPathologyName.text = theCase.diagnosis
        newMemo.text = theCase.nickName
        newAge.text = theCase.age
        newCaseID.text = theCase.caseId
        
        for t in theCase.targetL {
             self.addTarget (target: t)
        }
    
    }
}



