//
//  ViewController.swift
//  aOncology
//
//  Created by Philippe-Faurie on 4/17/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import UIKit

// var myGeneDrug :geneDrugs(igene:"", idrugL: "")
/*
class dgRelation_C {
    
    var geneName : String
    var drugName : String
    var dgIc50   : Float
    
    init (gene: String, drug:String, Ic50: Float){
 
 geneName = gene
        drugName = drug
        dgIc50   = Ic50
    }
    
    
}
 var dgRelationL = [dgRelation_C]()

*/
var targetL  = [Target_C]()
var drugL    = [Drug_C] ()
var comboL   = [[Int]]()



var noDrugNameL = [String]()



//var myCombinations = combinations([1,2,3,4], takenBy: 2)
var myCombo = Combination_C ()

class ViewController: UIViewController , UITableViewDataSource, UITableViewDelegate {
        
  //  var myGeneDrug : geneDrugs = geneDrugs(igene:"EGFR", idrugL: drugl1)
    var myGeneDrug : geneDrugs = geneDrugs(igene:"", idrugL: [""])
    var loggedIn : Bool!
    
    
    @IBOutlet var folderImage: UIImageView!
    
    @IBOutlet var newGeneName: UITextField!
    @IBOutlet var newAberrationName: UITextField!

    @IBOutlet var geneInputTableView: UITableView!
    @IBOutlet var drugListTableview: UITableView!
    
    @IBOutlet var combListTableview: UITableView!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var loggedName: UILabel!
    
    @IBOutlet var drugCount: UILabel!
    @IBOutlet var geneCount: UILabel!
    @IBOutlet var combCount: UILabel!
    
    @IBAction func addGeneTaped(_ sender: Any) {
        let target : Target_C = Target_C (id: 0, hugoName: newGeneName.text!, aberration: newAberrationName.text! )
        if ( target.hugoName.isEmpty == false ) {
            self.addTarget (target: target)
            newGeneName.text! = ""
            newAberrationName.text! = ""
        }
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
                destinationVC.navigationItem.title = drugL[row].drugName
              //  destinationVC.drugName = drugNameL[row]
                destinationVC.drugName = drugL[row].drugName
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == geneInputTableView){
            return targetL.count
        } else if (tableView == drugListTableview){
          //  return drugNameL.count
            return drugL.count
        } else {
            return comboL.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (tableView == geneInputTableView){
           let cell = tableView.dequeueReusableCell(withIdentifier: "cellGeneId")!
           let text = targetL[indexPath.row].hugoName
           cell.textLabel?.text = text

           return cell

         } else if (tableView == drugListTableview){
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellDrugId") as! DrugTableViewCell
            let text = drugL[indexPath.row].drugName
            cell.drugName?.text = text
            cell.delegate = self
            cell.indexPath = indexPath
            
            if (drugL[indexPath.row].allowed == false ) {
                cell.checkMark.image = UIImage(named: "tick_red" )
            } else {
                 cell.checkMark.image = UIImage(named: "Check_mark" )
            }

            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellCombId") as! combTableViewCell
            let text1 = drugL [comboL[indexPath.row][0]].drugName
            let text2 = drugL [comboL[indexPath.row][1]].drugName

            cell.drug1.text = text1
            cell.drug2.text = text2
            return cell
    
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if (tableView == geneInputTableView){
                subGene (target: targetL[indexPath.row])
                targetL.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
           
        }
    }
    
    private func tableView(_ tableView: UITableView, didSelectRowAt indexPath: NSIndexPath) {
        print ("selected row")
    }
        
  
    
    func addTarget (target: Target_C) {

        if targetL.contains(where: {$0.hugoName == target.hugoName}) {
            // nothing to do
        }else{
            targetL.append(target)
            
            self.geneInputTableView.beginUpdates()
            self.geneInputTableView.insertRows(at: [IndexPath.init(row: targetL.count-1, section: 0)], with: .automatic)
            self.geneInputTableView.endUpdates()
            
            myGeneDrug.newGeneDelegate  = self
            myGeneDrug.targetToAdd (theTarget: target,  inDrugL: drugL)
            geneCount.text = String( targetL.count)
            
         }
    }
    
    func subGene (target: Target_C) {
        myGeneDrug.geneToSub   (target: target)
        geneCount.text = String( targetL.count)
        drugCount.text = String( drugL.count)
        combCount.text = String( comboL.count)

    }    
    
}



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

extension ViewController: geneAddedDelegate {
    
    func drugListAdjusted ( outDrugL: [Drug_C] ){
        drugL = outDrugL
        drugListTableview.reloadData()
        var theList = [Int]()
        var i:Int = 0
        for _ in drugL {
            theList.append(i)
            i=i+1
        }
        comboL =  myCombo.combinationsWithoutRepetitionFrom (elements: theList, taking: 2)
        combListTableview.reloadData()
        geneCount.text = String( targetL.count)
        drugCount.text = String( drugL.count)
        combCount.text = String( comboL.count)
    }
}

extension ViewController: loginScreenDelegate {
    func didLogin (hasLogged: Bool, name :String){
        loggedName.text = name
        loggedIn = hasLogged
        
    }
}

extension ViewController: OptionButtonsDelegate {
    func checkMarkTapped(at index:IndexPath){
        
        let cell = drugListTableview.cellForRow(at: index) as! DrugTableViewCell
        if (drugL[index.row].allowed == true ) {
            drugL[index.row].allowed = false
            cell.checkMark.image = UIImage(named: "tick_red" )
            
        } else {
            drugL[index.row].allowed = true
            cell.checkMark.image = UIImage(named: "Check_mark" )

        }
    }
}
