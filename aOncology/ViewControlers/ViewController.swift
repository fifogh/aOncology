//
//  ViewController.swift
//  aOncology
//
//  Created by Philippe-Faurie on 4/17/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import UIKit

enum CalcMode      {case auto,  manual}
enum SortMode      {case score, onLabel}
enum MutBurden     {case unknown, low, medium, high}
enum MicroSat      {case unknown, low, high }
enum MMRDef        {case unknown, yes, no }
enum ImmunoChoice  {case auto, force, no }
enum ImmunoState   {case noImmuno, mediumImmuno, highImmuno }

//var targetLImmuno = ["MSH2", "MSH3", "MSH6", "PMS1", "PMS2", "MLH1", "MLH3", "CD274", "PDCD1LG2" ]
var targetLImmuno = [ "CD274", "PDCD1LG2" ]

let GHOST_TARGET = "zimmuno"
var drugNumberL  = ["1", "2", "3"]

var mutBurdenL     = ["Unknown", "low ( < 6 /Mb )", "medium ( 6-20 /Mb )", "high( > 20 /Mb )"]
var microsatIL     = ["Unknown", "low", "high"]
var mmrDefL        = ["Unknown", "Yes", "No"]


var targetL   = [Target_C]()                 // Tragets list: all pathogenic
var dtRelL    = [DTRelation_C] ()            // Drug-Target relation list
var caseL     = [Case_C]()                   // Cases List

var combo1L   = [Combination_C]()           // 1 drug Combos
var combo2L   = [Combination_C]()           // 2 drug Combos
var combo3L   = [Combination_C]()           // 3 drug Combos
var comboL    = [combo1L,combo2L,combo3L]   // list( 1d, 2d, 3d)  of combinations list

var pathoClass  = ""                         // Pathology Class

var filterDrug1 = ""                         // Drug to remove from combo
var filterDrug2 = ""                         // Drug to remove from combo
var filterDrug3 = ""                         // Drug to remove from combo

var loggedIn : Bool!

var noDrugNameL  = [String]()               // Forbidden drugs list to remember
var myCombMaker  = CombMaker_C ()           // Combinatory utilitary

var targetIndex  = IndexPath ()

let rules = Rules ()                        // to acces to rules






class ViewController: UIViewController  {
    
    var comboLen = 1
 //   var loggedIn : Bool!
    var calcMode = CalcMode.auto
    var sortMode = SortMode.score

    var drugDisabled = 0                        // manual toggle on drugs
    
    var MMRState     = false
    var OctState     = false
    
    var immunoStatus = ImmunoState.noImmuno

    
    var mutBurden    = MutBurden.low
    var microSat     = MicroSat.low
    var immunoChoice = ImmunoChoice.auto
    var mmrDef       = MMRDef.unknown

    var myCaseModel = CaseModel ()
    var myGeneDrug  = geneDrugs ()

    @IBOutlet var folderImage: UIImageView!
    @IBOutlet var immunoImage: UIImageView!
    
    @IBOutlet var newCaseID: UILabel!
    @IBOutlet var newMemo: UITextField!
    @IBOutlet var newAge: UITextField!

    @IBOutlet var newGeneName: SearchTextField!
    @IBOutlet var newAberrationName: SearchTextField!
    @IBOutlet var newPathologyName: SearchTextField!
    
    @IBOutlet var comboLenPickerView: UIPickerView!
    @IBOutlet var mmrPickerView: UIPickerView!
    @IBOutlet var mutBPickerView: UIPickerView!
    @IBOutlet var msiPickerView: UIPickerView!
    
    @IBOutlet var targetInputTableView: UITableView!
    @IBOutlet var drugListTableview: UITableView!
    @IBOutlet var combListTableview: UITableView!
    
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var loggedName: UILabel!
    @IBOutlet var recordsButton: UIButton!
    
    @IBOutlet var drugCount: UILabel!
    @IBOutlet var geneCount: UILabel!
    @IBOutlet var combCount: UILabel!
  
    @IBOutlet var MMRCheckImage: UIImageView!
    @IBOutlet var OctrCheckImage: UIImageView!
    
    @IBOutlet var filterInpurD1: SearchTextField!
    @IBOutlet var filterInpurD2: SearchTextField!
    @IBOutlet var filterInpurD3: SearchTextField!
    
    @IBOutlet var drugSegment: UISegmentedControl!
    @IBOutlet var immunoSegment: UISegmentedControl!
    
    @IBOutlet var indicatorCalc: UIActivityIndicatorView!
    
    //------------------------------------
    // Save case
    
    @IBAction func saveTapped(_ sender: Any) {
        let newCase = Case_C (nickName: newMemo.text!, age: newAge.text!, targetL : targetL , diagnosis: self.newPathologyName.text!)
        
        // 
        //newCase.loadCases()
        
        caseL.append ( newCase )
        
        newCaseID.text = newCase.caseId
        
        let theTitle = "Case " + newCaseID.text!
        let alert = UIAlertController(title: theTitle, message: "saved", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
        self.present(alert, animated: true)
        
        myCaseModel.saveCase(index: caseL.count - 1)
    }
    
    //------------------------------------
    // Clear All
    
    @IBAction func resetTapped(_ sender: Any) {
        
        // raz lists
        targetL.removeAll()
        myGeneDrug.rebuildAll   ( inTargetL: targetL, inDTRelL: dtRelL, allowed: calcMode == CalcMode.auto )
        targetInputTableView.reloadData()
        
        // Reset user interfaces
        // and associated variables
        mmrPickerView.selectRow (0, inComponent: 0, animated: true)
        msiPickerView.selectRow (0, inComponent: 0, animated: true)
        mutBPickerView.selectRow(0, inComponent: 0, animated: true)
        comboLenPickerView.selectRow(0, inComponent: 0, animated: true)
        immunoSegment.selectedSegmentIndex = 0
        drugSegment.selectedSegmentIndex = 0
        immunoImage.isHidden = true
        
        comboLen = 1
        filterInpurD2.isHidden = true
        filterInpurD3.isHidden = true

        filterInpurD1.text = ""
        filterInpurD2.text = ""
        filterInpurD3.text = ""
        filterDrug1 = ""
        filterDrug2 = ""
        filterDrug3 = ""

        mutBurden    = MutBurden.low
        microSat     = MicroSat.low
        mmrDef       = MMRDef.unknown
        immunoChoice = .auto
        calcMode     = .auto

        newPathologyName.text = ""
        pathoClass = ""
        
        newAge.text    = ""
        newMemo.text   = ""
        newCaseID.text = ""
        
    }
    
    
    //------------------------------------
    // The Immuno Mode

    @IBAction func immunoModeChange(_ sender: UISegmentedControl) {
        
        let index = sender.selectedSegmentIndex
        if (index == 0) {
            self.immunoChoice = .auto
            
        } else if (index == 1) {
            self.immunoChoice = .force
            
        } else {
            self.immunoChoice = .no
        }
        
        // if this induces a change then rebuildAll relations
        if ( self.checkImmunoChange() == true ) {
            myGeneDrug.rebuildAll   ( inTargetL: targetL, inDTRelL: dtRelL, allowed: calcMode == CalcMode.auto )
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
        applyUserFilter ()
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
        applyUserFilter ()
        updateCounterDisplay()


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
                
                destinationVC.caseID = newCaseID.text!
                destinationVC.memo   = newMemo.text!
                destinationVC.diag   = newPathologyName.text!

 
                destinationVC.navigationItem.title = "Combination Detail"

            }
        } else if segue.identifier == "caseListSegue" {
            
            if let destinationVC = segue.destination as? CaseViewController {
                destinationVC.caseSelectDelegate = self
            }
 
        }
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
            let target : Target_C = Target_C (id: "", hugoName: theHugoName, aberration: trimmedAber )
            target.synoName = theSynoName
            
            self.addTarget (target: target)
            newGeneName.text! = ""
            newAberrationName.text! = ""
            
            // place the cursor on gene
            // and hide the keyboard
            newGeneName.becomeFirstResponder()
            newGeneName.resignFirstResponder();
            newAberrationName.resignFirstResponder()
            
        }
    }

    //------------------------------------
    // a Target has been addeed
    func addTarget (target: Target_C) {

     //   if targetL.contains(where: { ($0.hugoName == target.hugoName) && ($0.aberDisp == target.aberDisp) && (target.allowed == true)}) {
        
        if targetL.contains(where: { ($0.hugoName == target.hugoName) && ($0.aberDisp == target.aberDisp)}) {
            let alert = UIAlertController(title: "Target already Entered", message: "No need to input twice", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            
        }else{
       /*
            if (target.allowed == true) {
               // new target
               targetL.append(target)
            }
        */
            
            // add the target
            // check for immuno needs
            // rebuild all DTRel (in all cases)
            
            targetL.append(target)
            let needRebuild = self.checkImmunoChange()
            if (needRebuild == true) || (1 == 1) {
                myGeneDrug.rebuildAll   ( inTargetL: targetL, inDTRelL: dtRelL, allowed: calcMode == CalcMode.auto )
            }
            
            targetL.sort(by: { $0.hugoName < $1.hugoName })
            self.targetInputTableView.reloadData()
            
         }
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
        
        var targetCountToDisp = targetL.count
        
        if targetL.contains ( where: {$0.hugoName == GHOST_TARGET} ) {
            targetCountToDisp -= 1
        }
        
        geneCount.text = String( targetCountToDisp )
        drugCount.text = String( dtRelL.count )
        combCount.text = String( comboCount() )
    }
    
    
    //-----------------------------------------
    // Check if we have a immuno high condition
    func checkImmunoHigh () -> Bool {
        var immunoHigh = false
        
        // rule 23 -A
        
        if  (   ( mutBurden == .high ) ||
                ( microSat  == .high ) ||
                ( mmrDef    == .yes)   ||
                (targetL.contains ( where: {$0.hugoName == "MSH2" && $0.allowed  == true} ) == true) ||
                (targetL.contains ( where: {$0.hugoName == "MSH3" && $0.allowed  == true} ) == true) ||
                (targetL.contains ( where: {$0.hugoName == "MSH6" && $0.allowed  == true} ) == true) ||
                (targetL.contains ( where: {$0.hugoName == "MLH1" && $0.allowed  == true} ) == true) ||
                (targetL.contains ( where: {$0.hugoName == "MLH3" && $0.allowed  == true} ) == true) ||
                (targetL.contains ( where: {$0.hugoName == "PMS1" && $0.allowed  == true} ) == true) ||
                (targetL.contains ( where: {$0.hugoName == "PMS2" && $0.allowed  == true} ) == true) ||
            
                (targetL.contains ( where: {$0.hugoName == "CD274"    && $0.aberDisp == "Amplification" && $0.allowed  == true} ) == true) ||
                (targetL.contains ( where: {$0.hugoName == "PDCD1LG2" && $0.aberDisp == "Amplification" && $0.allowed  == true} ) == true) ){
            
            immunoHigh = true
        }
        
        return (immunoHigh)
    }
    
    //--------------------------------------------
    // Check if we have a immuno medium condition
    func checkImmunoMed () -> Bool {
        var immunoMed = false
        
        // rule 23 -B
        
        if  ( (mutBurden == .medium) ||
              //(targetL.count >= 8 )  ||
              (targetL.contains ( where: {$0.hugoName == "CD274"     && $0.allowed  == true} ) == true) ||
              (targetL.contains ( where: {$0.hugoName == "PBRM1"     && $0.allowed  == true} ) == true) ||      // rule 76
              ( (pathoClass == "Central Nervous System Cancers") &&
                (targetL.contains ( where: {$0.hugoName == "ARID1A"  && $0.allowed  == true} ) == true )) ||    // rule 75
              (targetL.contains ( where: {$0.hugoName == "PDCD1LG2"  && $0.allowed  == true} ) == true )) {
              //(targetL.contains ( where: {$0.hugoName == "PDCD1" } )   == true)) {
            
            
            immunoMed = true
        }
        
        return (immunoMed)
    }
    
    //------------------------------------
    // Check what to do with Immuno
    func checkImmunoChange() -> Bool {
        
        var newImmunoStatus   = ImmunoState.noImmuno
        var immunoChanged     = false
        
        var ghostTargetImmunoInL = targetL.contains ( where: {$0.hugoName == GHOST_TARGET} ) == true
        
        // AutoMode let's check
        if (immunoChoice == .auto) {
            
            if ( checkImmunoMed() == true ) {
                newImmunoStatus = .mediumImmuno
                
            } else if ( checkImmunoHigh() == true ) {
                newImmunoStatus = .highImmuno
            }
            
            
        } else if (immunoChoice == .force) {
            // keep previous status if immuno was already detected
            // take highImmuno is crieria are repsect medium otherwise
            if (immunoStatus == .highImmuno) || (immunoStatus == .mediumImmuno) {
                newImmunoStatus = immunoStatus
            } else {
                newImmunoStatus = (checkImmunoHigh() == true) ? .highImmuno : .mediumImmuno
            }
            
        } else if (immunoChoice == .no) {
            newImmunoStatus = .noImmuno
        }
        
        // look if something new about immuno
        immunoChanged = (newImmunoStatus != immunoStatus)
        immunoStatus = newImmunoStatus
        
        
        if (immunoStatus != .noImmuno) {
            // add Immuno if not in
            // and (re)allow Immuno drugs
            
            immunoImage.isHidden = false
            if ( newImmunoStatus == .mediumImmuno ) {
                immunoImage.alpha = 0.5
            } else {
                immunoImage.alpha = 1
            }
            
            // Add here only if not other immuno Tragets are present: No need for zimmuno...
            var needZimmuno = true
            for t in targetL {
                if (targetLImmuno.contains (t.hugoName)){
                    t.allowed   = true
                    needZimmuno = false
                }
            }
            if ((ghostTargetImmunoInL == false) && (needZimmuno == true) ){
                ghostTargetImmunoInL = true
                targetL.append(Target_C (id: "", hugoName: GHOST_TARGET, aberration: "" ))
 
            }
            
        } else {
            // remove Immuno if it was in
            // and forbidd targets that bring immuno
            
             immunoImage.isHidden = true
            
            if (ghostTargetImmunoInL == true){
                ghostTargetImmunoInL = false
                targetL.removeLast()   // Zimmuno is always the last Target
            }
            
            for t in targetL {
                if (targetLImmuno.contains (t.hugoName)){
                    t.allowed = false
                }
            }
            
        }

        targetInputTableView.reloadData()
        
        return(immunoChanged)
    }
    
    //------------------------------------
    // Check if we want to add EGFR
    
    func checkEGFR() {
        if ( pathoClass == "Colon Cancer" ) && (targetL.contains(where: {$0.hugoName == "BRAF"}) == true) &&
            (targetL.contains(where: {$0.hugoName == "EGFR"}) == false ){
            
            self.addTarget (target : Target_C  (id: "", hugoName: "EGFR", aberration:""))
            rulesLog += "(#22) Colon Cancer with BRAF mutated add anti-EGFR drugs \n"

        }
    }
    
    
    //------------------------------------
    //Usual stuff

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        myGeneDrug.newGeneConfigDelegate  = self
        
        myCaseModel.delegate = self
        loggedIn = false
        folderImage.isHidden = true
        recordsButton.isEnabled = false
        immunoImage.isHidden = true
        
        self.comboLen = 1
        filterInpurD2.isHidden = true
        filterInpurD3.isHidden = true

        
        // Do any additional setup after loading the view, typically from a nib.
        
        newGeneName.filterStrings(Array(geneDataList))
        newGeneName.maxNumberOfResults = 5
        newGeneName.minCharactersNumberToStartFiltering = 2
        
        
        newAberrationName.filterStrings(Array(allKeyWordL))
        newAberrationName.maxNumberOfResults = 5
        newAberrationName.minCharactersNumberToStartFiltering = 1
        
        newPathologyName.filterStrings(Array(pathoSynL))
        newPathologyName.maxNumberOfResults = 10
        newPathologyName.minCharactersNumberToStartFiltering = 2
        
        
        let allDrugsL = Array(dTargetL.keys)

        filterInpurD1.filterStrings(allDrugsL)
        filterInpurD1.maxNumberOfResults = 10
        filterInpurD1.minCharactersNumberToStartFiltering = 2
        
        filterInpurD2.filterStrings(allDrugsL)
        filterInpurD2.maxNumberOfResults = 10
        filterInpurD2.minCharactersNumberToStartFiltering = 2
        
        filterInpurD3.filterStrings(allDrugsL)
        filterInpurD3.maxNumberOfResults = 10
        filterInpurD3.minCharactersNumberToStartFiltering = 2
        
        
        // remove tab bar text asistant
        var item : UITextInputAssistantItem

        item = newGeneName.inputAssistantItem
        item.leadingBarButtonGroups = []
        item.trailingBarButtonGroups = []
        
        item  = newAberrationName.inputAssistantItem
        item.leadingBarButtonGroups = []
        item.trailingBarButtonGroups = []
        
        item  = newPathologyName.inputAssistantItem
        item.leadingBarButtonGroups = []
        item.trailingBarButtonGroups = []
        
        item = filterInpurD1.inputAssistantItem
        item.leadingBarButtonGroups = []
        item.trailingBarButtonGroups = []

        item = filterInpurD2.inputAssistantItem
        item.leadingBarButtonGroups = []
        item.trailingBarButtonGroups = []
        
        item = filterInpurD3.inputAssistantItem
        item.leadingBarButtonGroups = []
        item.trailingBarButtonGroups = []

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            
            // Immuno trick display
            if (hugo == GHOST_TARGET) {
                cell.hugoName.text = ""
                cell.checkMark.isHidden = true
                cell.checkButton.isEnabled = false
                
            } else {
                cell.hugoName.text = hugo
                cell.checkMark.isHidden = false
                cell.checkButton.isEnabled = true

            }
            
            cell.synoName.text = syno
            
            cell.delegate = self
            cell.indexPath = indexPath
            cell.aberration.text = aberration
            
            
            if (targetL[indexPath.row].actionable == false ) {
                cell.hugoName.textColor   = UIColor.lightGray
                cell.aberration.textColor = UIColor.lightGray
                
            }else if (targetL[indexPath.row].allowed == false){
                cell.hugoName.textColor   = UIColor.lightGray
                cell.synoName.textColor   = UIColor.lightGray
                cell.aberration.textColor = UIColor.lightGray
                cell.checkMark.alpha = 0.3
                
            } else {
                cell.hugoName.textColor   = UIColor.black
                cell.synoName.textColor   = UIColor.black
                cell.aberration.textColor = UIColor.black
                cell.checkMark.alpha = 1.0
            }
        
            
            
            if (targetL[indexPath.row].markerType == .protein )  {
                cell.symbolImage.image = UIImage ( named: "letterP" )
                cell.symbolImage.isHidden = false
                
            } else if (targetL[indexPath.row].markerType == .rna)  {
                cell.symbolImage.image = UIImage ( named: "letterR" )
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
                cell.row.text = "# " + String(indexPath.row + 1)

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
                cell.row.text = "# " + String(indexPath.row + 1)

                
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
                cell.row.text = "# " + String(indexPath.row + 1)

                
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
            if (tableView == targetInputTableView) {
            
                if (targetL[indexPath.row].hugoName != GHOST_TARGET) {  // trick used to add Immuno
                    targetL.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    myGeneDrug.rebuildAll   ( inTargetL: targetL, inDTRelL: dtRelL, allowed: calcMode == CalcMode.auto )

                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath , animated: true)
    }
    
}

//------------------------------------------------------------------------
// OPTION BUTTON (DRUG LIST TABLEVIEW ) DELEGATE
extension ViewController: SelectButtonsDelegate {
    
    func toggleTargetTapped(at index:IndexPath){
        // a drug has been added or removed
        let cell    = targetInputTableView.cellForRow(at: index) as! TargetTableViewCell

        if (targetL[index.row].allowed == true ) {
            
            targetL[index.row].allowed = false
            cell.checkMark.alpha = 0.3
            
        } else {
            
            cell.checkMark.alpha = 1.0
            targetL[index.row].allowed = true
        }
        
        // in all case we rebuild the TargetList
        let needRebuild = self.checkImmunoChange()
        if (needRebuild == true) || (1 == 1) {
            myGeneDrug.rebuildAll   ( inTargetL: targetL, inDTRelL: dtRelL, allowed: calcMode == CalcMode.auto )
        }
        
        targetInputTableView.reloadData()
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
        
       // dtRelL.sort(by: { $0.drug.allowed  != $1.drug.allowed  ? $0.drug.allowed && !$1.drug.allowed :
       //     $0.drug.approved != $1.drug.approved ? $0.drug.approved == 1  && $1.drug.approved == 0 :
       //     ($0.drug.drugName < $1.drug.drugName)  })
       // dtRelL.sort(by: { ($0.drug.drugName < $1.drug.drugName) })
        
        drugListTableview.reloadData()
        
        // rebuild now the combos
        self.buildAllCombos ()
        self.applyUserFilter ()
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
            
            // some specials rules may change the whole thing
            buildAllCombos()
            applyUserFilter ()
            updateCounterDisplay()


        }  else if (textField == filterInpurD1) || (textField == filterInpurD2) || (textField == filterInpurD3)  {
 
            buildAllCombos()
            applyUserFilter ()
            updateCounterDisplay()
            combListTableview.reloadData()
        }
        
        return true;
    }


   func textFieldDidEndEditing(_ textField: UITextField) {
      if (textField == newPathologyName) {
        
          self.newPathologyName = textField as! SearchTextField
          changePathologyClass (pathoName : self.newPathologyName.text!)
        
          // some specials rules may change the whole thing
          buildAllCombos()
          applyUserFilter ()
          updateCounterDisplay()


      } else if (textField == filterInpurD1) ||  (textField == filterInpurD2) || (textField == filterInpurD3)  {
        buildAllCombos()
        applyUserFilter ()
        updateCounterDisplay()
        inputFilterDisplay ()
        combListTableview.reloadData()
        
      }
    }

    
    func changePathologyClass (pathoName : String) {
        
        if ( pathoSynData [pathoName] != nil ){            
            // we got a pathology class
            pathoClass = pathoSynData [pathoName]!
            self.newPathologyName.textColor  = UIColor.black
            
        } else {
            // we did not find any matching pathology class
            self.newPathologyName.textColor  = UIColor.lightGray
            pathoClass = ""
        }
        

        // change status and display labels
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
        if (pickerView.tag == 1){
            return mutBurdenL.count
            
        } else if (pickerView.tag == 2){
            return microsatIL.count

        } else if (pickerView.tag == 4){
            return mmrDefL.count
            
        } else /*if (pickerView.tag == 0)*/{
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
            
        } else if (pickerView.tag == 4){
            pickerLabel?.text = mmrDefL [row]
        }
            
        pickerLabel?.textColor = UIColor.black
        
        
        return pickerLabel!
    }
   
    
    //---------------------------------------------------
    //Mange the display of filter inputs

    func inputFilterDisplay () {
        
        filterInpurD2.isHidden = true
        filterInpurD3.isHidden = true
        
        if (comboLen > 2 ) && (filterInpurD1.text != "") {
            filterInpurD2.isHidden = false
            
            if (filterInpurD2.text != "") {
                filterInpurD3.isHidden = false
            }
            
        } else  if (comboLen > 1 ) && (filterInpurD1.text != "") {
            filterInpurD2.isHidden = false
        }
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
            combListTableview.reloadData()
            updateCounterDisplay()
           
            self.inputFilterDisplay ()
            
            
        } else {
            
            // picker view that affect Immuno
            
            if (pickerView.tag == 1){
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
                
            } else if (pickerView.tag == 4){
                // MMR Deficiency choice
                switch row {
                case 0 :
                    self.mmrDef = .unknown
                    break
                case 1 :
                    self.mmrDef = .yes
                    break
                case 2 :
                    self.mmrDef = .no
                    
                default:
                    break
                }
            }
            
            if ( self.checkImmunoChange() == true ) {
                myGeneDrug.rebuildAll   ( inTargetL: targetL, inDTRelL: dtRelL, allowed: calcMode == CalcMode.auto )
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
                
                comboL[drugNb-1].sort(by: {($0.approvedCount == $1.approvedCount) ? ($0.matchScore > $1.matchScore) : ($0.approvedCount > $1.approvedCount) })
                
            } else {
                comboL[drugNb-1].sort(by: { ($0.matchScore > $1.matchScore) })
                
                comboL[drugNb-1].sort(by: { ($0.matchScore ==  $1.matchScore) ? ($0.diversityScore >  $1.diversityScore) :($0.matchScore >  $1.matchScore) })

            }
            drugNb += 1
        }
 
    }
    
    //------------------------
    // Recount the markers
    func markersCount () ->(Int,Int, Int) {
        
        var prrnaCount  = 0       // protein + rna count
        var genomCount  = 0       // genomic count
        var actionCount = 0       // actionable count
       
        var tList = [Target_C]()
        
        for t in targetL {
            if ( tList.contains( where : { $0.hugoName  == t.hugoName} ) == false ) {
                tList.append (t)
                
                if ( t.actionable == true) {
                    actionCount += 1
                    
                }
                
                if (t.markerType == .genomic) || (t.forceGenomic == true){
                    genomCount += 1
                }else {
                    prrnaCount += 1
                }
            }
        }
        
        
       // do not count ZIMMUNO unless it the only one in TList
       if ( tList.contains( where : { $0.hugoName  == GHOST_TARGET } ) == true ) {
           genomCount  = genomCount  > 1 ? genomCount  - 1 : genomCount
           actionCount = actionCount > 1 ? actionCount - 1 : actionCount
        }
        
        tList.removeAll()
        return ( genomCount, prrnaCount, actionCount )
    }
        
    //------------------------
    // Rebuild the combos

    func buildAllCombos2 () {

        self.indicatorCalc.startAnimating()
        
        DispatchQueue.global(qos:.userInteractive).async {
            self.buildAllCombosBackGround () // takes long Time to respond
            DispatchQueue.main.async {
                self.reArrangeAllCombos ()
                self.updateCounterDisplay()
                self.indicatorCalc.stopAnimating()
            }

        }
        

    }
    //------------------------
    // Rebuild the combos
    func buildAllCombosBackGround () {
        
        // rule 22...
        self.checkEGFR ()
        
        // specific rules
        rules.allRules ()
        
        var prrnaCount  = 0       // protein + rna count
        var genomCount  = 0       // genomic count
        var actionCount = 0       // actionnable count
        
        ( genomCount , prrnaCount, actionCount ) = self.markersCount ()
        
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
        var totoL     = [ [Combination_C](), [Combination_C](), [Combination_C]() ]

        
        var drugNb = 1
        while (drugNb < 4){
            
      //      comboL[drugNb-1].removeAll()
            
            let combosxx =  myCombMaker.combinationsWithoutRepetitionFrom (elements: dtRelLxx, taking: drugNb)
            for elem in combosxx{
                let combElem = Combination_C (dtRelList: elem, filter : (calcMode == .auto),
                                              genomCount : genomCount, prrnaCount: prrnaCount, actionableCount : actionCount, immunoStatus: immunoStatus)
                totoL[drugNb-1].append ( combElem )
            }
            
            // Remove zero scored combos in Auto Mode
            if (calcMode == .auto) {
                totoL[drugNb-1].sort(by: { ($0.strengthScore > $1.strengthScore) })
                var c = totoL[drugNb-1].last
                while ((c != nil) && (c!.strengthScore == 0 ) ) {
                    totoL[drugNb-1].removeLast()
                    c = totoL[drugNb-1].last
                }
            }
            
            // take care of next size combo
            drugNb = drugNb + 1
        }
        
        
        // clean tmp variables
        dtRelLxx.removeAll()
        dtRelLyy.removeAll()
        
        // Sort and Display
        comboL = totoL
        // reArrangeAllCombos ()
        
        
        
    }
    

    
    //------------------------
    // Rebuild the combos
    func buildAllCombos () {
        
        // rule 22...
        self.checkEGFR ()
        rules22added = false // display rules log stuff
        
        // specific rules
        rules.allRules ()
        
        var prrnaCount  = 0       // protein + rna count
        var genomCount  = 0       // genomic count
        var actionCount = 0       // actionnable count

        ( genomCount , prrnaCount, actionCount ) = self.markersCount ()
        
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
                                              genomCount : genomCount, prrnaCount: prrnaCount, actionableCount : actionCount, immunoStatus: immunoStatus)
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
        
        
        // apply user Filters
       // applyUserFilter ()
        
        // Sort and Display
        reArrangeAllCombos ()
     
    }

    func applyUserFilter ( ) {
        
     //   var filterDrug = [ filterDrug1, filterDrug2, filterDrug3]
        
        filterDrug1 = (filterInpurD1.text != nil ) ? filterInpurD1.text! : ""
        filterDrug2 = (filterInpurD2.text != nil ) ? filterInpurD2.text! : ""
        filterDrug3 = (filterInpurD3.text != nil ) ? filterInpurD3.text! : ""

        if (filterDrug1 != "") {
            
         //   comboL[0] = comboL[0].filter(){$0.dtRelL[0].drug.drugName == filterDrug1}
            comboL[0] = comboL[0].filter(){$0.dtRelL[0].drug.drugName.range(of: filterDrug1) != nil}

            
            if (filterDrug2 != "") {
                
                 comboL[1] = comboL[1].filter(){ ( (($0.dtRelL[0].drug.drugName.range(of: filterDrug1) != nil) && ($0.dtRelL[1].drug.drugName.range(of:filterDrug2) != nil)) ||
                                                   (($0.dtRelL[0].drug.drugName.range(of: filterDrug2) != nil) && ($0.dtRelL[1].drug.drugName.range(of:filterDrug1) != nil)) ) }
                if (filterDrug3 != "") {
                    
                    comboL[2] = comboL[2].filter(){
                       ((($0.dtRelL[0].drug.drugName.range(of: filterDrug1) != nil) && ($0.dtRelL[1].drug.drugName.range(of: filterDrug2) != nil) && ($0.dtRelL[2].drug.drugName.range(of: filterDrug3) != nil)) ||
                        (($0.dtRelL[0].drug.drugName.range(of: filterDrug1) != nil) && ($0.dtRelL[1].drug.drugName.range(of: filterDrug3) != nil) && ($0.dtRelL[2].drug.drugName.range(of: filterDrug2) != nil)) ||
                        (($0.dtRelL[0].drug.drugName.range(of: filterDrug2) != nil) && ($0.dtRelL[1].drug.drugName.range(of: filterDrug1) != nil) && ($0.dtRelL[2].drug.drugName.range(of: filterDrug3) != nil)) ||
                        (($0.dtRelL[0].drug.drugName.range(of: filterDrug2) != nil) && ($0.dtRelL[1].drug.drugName.range(of: filterDrug3) != nil) && ($0.dtRelL[2].drug.drugName.range(of: filterDrug1) != nil)) ||
                        (($0.dtRelL[0].drug.drugName.range(of: filterDrug3) != nil) && ($0.dtRelL[1].drug.drugName.range(of: filterDrug1) != nil) && ($0.dtRelL[2].drug.drugName.range(of: filterDrug2) != nil)) ||
                        (($0.dtRelL[0].drug.drugName.range(of: filterDrug3) != nil) && ($0.dtRelL[1].drug.drugName.range(of: filterDrug2) != nil) && ($0.dtRelL[2].drug.drugName.range(of: filterDrug1) != nil)) )}
                } else {
                    
                    comboL[2] = comboL[2].filter(){
                        ((($0.dtRelL[0].drug.drugName.range(of:  filterDrug1) != nil) && ($0.dtRelL[1].drug.drugName.range(of:  filterDrug2) != nil)) ||
                         (($0.dtRelL[0].drug.drugName.range(of:  filterDrug1) != nil) && ($0.dtRelL[2].drug.drugName.range(of:  filterDrug2) != nil)) ||
                         (($0.dtRelL[0].drug.drugName.range(of:  filterDrug2) != nil) && ($0.dtRelL[1].drug.drugName.range(of:  filterDrug1) != nil)) ||
                         (($0.dtRelL[1].drug.drugName.range(of:  filterDrug2) != nil) && ($0.dtRelL[2].drug.drugName.range(of:  filterDrug1) != nil)) ||
                         (($0.dtRelL[1].drug.drugName.range(of:  filterDrug1) != nil) && ($0.dtRelL[2].drug.drugName.range(of:  filterDrug2) != nil)) )}

                }
            } else {
                
                comboL[1] = comboL[1].filter(){  (  ($0.dtRelL[0].drug.drugName.range(of: filterDrug1) != nil) ||
                                                    ($0.dtRelL[1].drug.drugName.range(of: filterDrug1) != nil)) }
                
                comboL[2] = comboL[2].filter(){  (  ($0.dtRelL[0].drug.drugName.range(of: filterDrug1) != nil) ||
                                                    ($0.dtRelL[1].drug.drugName.range(of: filterDrug1) != nil) ||
                                                    ($0.dtRelL[2].drug.drugName.range(of: filterDrug1) != nil))}
            }
        }
        
        
        // redisplay the combo
        combListTableview.reloadData()

    }
    
    
    
    func drugListAdjusted ( outDrugL: [DTRelation_C], actionable: Bool, rebuilt: Bool ){
        
        if ( actionable == true ) || (1==1) {
           
            // free previous Drug Target Relation list
            // and take the new one, and sort it
            
            dtRelL.removeAll()
            dtRelL = outDrugL
            
            dtRelL.sort(by: { $0.drug.allowed  != $1.drug.allowed  ? $0.drug.allowed && !$1.drug.allowed :
                $0.drug.approved != $1.drug.approved ? $0.drug.approved == 1  && $1.drug.approved == 0 :
                ($0.drug.drugName < $1.drug.drugName)  })
            
            
            // generate all combos
            // and update counters
            self.buildAllCombos ()
            self.applyUserFilter()
            self.updateCounterDisplay()
            
            // after buildAll Combos coz rules may delete DTRelations
            drugListTableview.reloadData()

            
        } else {
            
            // mark the Gene as not actionable
            if (targetL.count != 0) {
                targetL.last!.actionable = false  // remember not acctionnable
            }
            
            // refresh display ( gray out unactionables )
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
            if name == "Amelie" {
                loginButton.setImage(UIImage(named: "Amelie Boichard"), for: .normal)

            } else if (name == "Razelle"){
                loginButton.setImage(UIImage(named: "Razelle Kurzrock"), for: .normal)

            } else {
                loginButton.setImage(UIImage(named: "rounded doctor"), for: .normal)
            }
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            
            self.myCaseModel.loadCases()
        
        }else{
            loginButton.setImage(UIImage(named: "person-generic"), for: .normal)
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            
            self.folderImage.isHidden = true
            recordsButton.isEnabled   = false

        }
        
    }
}

//------------------------------------------------------------------------
// CASE Download DELEGATE
extension ViewController: CaseModelProtocol {

    func casesDownloaded(items: [Case_C]) {
        caseL = items
        self.folderImage.isHidden = false
        recordsButton.isEnabled   = true

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
        changePathologyClass(pathoName: theCase.diagnosis)
        
        newMemo.text   = theCase.nickName
        newAge.text    = theCase.age
        newCaseID.text = theCase.caseId
        
        for t in theCase.targetL {
            // self.addTarget (target: t)
            targetL.append (t)
         }
        
        targetL.sort(by: { $0.hugoName < $1.hugoName })
        self.targetInputTableView.reloadData()
        let needRebuild = self.checkImmunoChange()  // look at number of targets
        if (needRebuild == true) || (1 == 1) {
            myGeneDrug.rebuildAll   ( inTargetL: targetL, inDTRelL: dtRelL, allowed: calcMode == CalcMode.auto )
        }
  
        
    }
}



