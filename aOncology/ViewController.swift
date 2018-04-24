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
var geneNameL = [String]()
var drugNameL = [String]()
var comboL    = [[Int]]()

var noDrugNameL = [String]()



//var myCombinations = combinations([1,2,3,4], takenBy: 2)
var myCombo = Combination_C ()

class ViewController: UIViewController , UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
        
  //  var myGeneDrug : geneDrugs = geneDrugs(igene:"EGFR", idrugL: drugl1)
    var myGeneDrug : geneDrugs = geneDrugs(igene:"", idrugL: [""])
    var loggedIn : Bool!
    
    
    @IBOutlet var folderImage: UIImageView!
    
    @IBOutlet var newGeneName: UITextField!
    @IBOutlet var geneInputTableView: UITableView!
    @IBOutlet var drugListTableview: UITableView!
    
    @IBOutlet var combListTableview: UITableView!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var loggedName: UILabel!
    
    @IBOutlet var drugCount: UILabel!
    @IBOutlet var geneCount: UILabel!
    @IBOutlet var combCount: UILabel!
    
    @IBAction func addGeneTaped(_ sender: Any) {
        self.addGene (gene: newGeneName.text!)
        newGeneName.text! = ""
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
                destinationVC.navigationItem.title = drugNameL[row]
                destinationVC.drugName = drugNameL[row]
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
            return geneNameL.count
        } else if (tableView == drugListTableview){
            return drugNameL.count
        } else {
            return comboL.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (tableView == geneInputTableView){
           let cell = tableView.dequeueReusableCell(withIdentifier: "cellGeneId")!
           let text = geneNameL[indexPath.row]
           cell.textLabel?.text = text

           return cell

         } else if (tableView == drugListTableview){
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellDrugId") as! DrugTableViewCell
            let text = drugNameL[indexPath.row]
            cell.drugName?.text = text
            cell.delegate = self
            cell.indexPath = indexPath
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellCombId") as! combTableViewCell
            let text1 = drugNameL [comboL[indexPath.row][0]]
            let text2 = drugNameL [comboL[indexPath.row][1]]

            cell.drug1.text = text1
            cell.drug2.text = text2
            return cell
    
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if (tableView == geneInputTableView){
               geneNameL.remove(at: indexPath.row)
               subGene ()
               tableView.deleteRows(at: [indexPath], with: .fade)
            }
           
        }
    }
    
    private func tableView(_ tableView: UITableView, didSelectRowAt indexPath: NSIndexPath) {
        print ("selected row")
    }
        
  
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("TextField should return method called")
        textField.resignFirstResponder();
        self.newGeneName = textField
        
        return true;
    }
    
    func addGene (gene: String) {
        if geneNameL.contains(gene) {
            // nothing to do
        }else{
            geneNameL.append(gene)
            
            self.geneInputTableView.beginUpdates()
            self.geneInputTableView.insertRows(at: [IndexPath.init(row: geneNameL.count-1, section: 0)], with: .automatic)
            self.geneInputTableView.endUpdates()
            
            myGeneDrug.newGeneDelegate  = self
            myGeneDrug.geneToAdd (name: gene,  inDrugL: drugNameL)
            geneCount.text = String( geneNameL.count)
            
         }
    }
    
    func subGene () {
        myGeneDrug.genesToRebuild (geneL: geneNameL)
        geneCount.text = String( geneNameL.count)
        drugCount.text = String( drugNameL.count)
        combCount.text = String( comboL.count)

    }    
    
}

extension ViewController: geneAddedDelegate {
    
    func drugListAdjusted ( outDrugL: [String] ){
        drugNameL = outDrugL
        drugListTableview.reloadData()
        var theList = [Int]()
        var i:Int = 0
        for _ in drugNameL {
            theList.append(i)
            i=i+1
        }
        comboL =  myCombo.combinationsWithoutRepetitionFrom (elements: theList, taking: 2)
        combListTableview.reloadData()
        geneCount.text = String( geneNameL.count)
        drugCount.text = String( drugNameL.count)
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
        if (cell.drugAllowed) {
            cell.drugAllowed = false
            cell.checkMark.image = UIImage(named: "tick_red" )
            
        } else {
            cell.drugAllowed = true
            cell.checkMark.image = UIImage(named: "Check_mark" )

        }
    }
}
