//
//  ReviewViewController.swift
//  aOncology
//
//  Created by Philippe-Faurie on 8/19/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import UIKit

var revTargetL = [String] ()
var revDrugL   = [String] ()
var reviewL    = [review_C]()

class review_C {
    
    var caseId    : String
    var memo      : String
    var date      : String
    var rate      : Double
    
    
    init (caseId:String, memo: String, date : String, rate: Double){
        
        self.caseId = caseId
        self.memo   = memo
        self.date   = date
        self.rate   = rate
        
    }
}



class ReviewViewController: UIViewController {
    
    var row       = 0
    var drugCount = 0
    
    var caseID = String()
    var memo   = String()
    var diagnostic = String()
    
    
    @IBOutlet var ratingView:      CosmosView!
    @IBOutlet var caseIDLabel:     UILabel!
    @IBOutlet var memoLabel:       UILabel!
    @IBOutlet var diagnosticLabel: UILabel!
    
    @IBOutlet var reviewTextView:  UITextView!

    
    @IBOutlet var targetTableView: UITableView!
    @IBOutlet var drugTableview:   UITableView!
    @IBOutlet var reviewTableview: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {

       caseIDLabel.text     = caseID
       memoLabel.text    = memo
       diagnosticLabel.text = diagnostic

        
        
        revDrugL.removeAll()
        revTargetL.removeAll()

        let relList  = comboL[drugCount-1][row].dtRelL
        for rel in relList {
            let targetList = rel.targetHitL!
            for t in  targetList {
                revTargetL.append ( t.target.hugoName )
            }
            revDrugL.append (rel.drug.drugName)
            
        }
        drugTableview.reloadData()
        targetTableView.reloadData()
        
    }
    
    @IBAction func ReviewSubmitted(_ sender: Any) {
        
        if (self.reviewTextView.text.utf8.count != 0 ) {
            reviewL.append (review_C (caseId:"12.34", memo: self.reviewTextView.text!, date:"Oct-4-2017",rate: self.ratingView.rating))
            reviewTableview.reloadData()
        }
        
        self.reviewTextView.text = ""
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
extension ReviewViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == targetTableView){
            return revTargetL.count
            
        } else if (tableView == drugTableview){
            return revDrugL.count
            
        } else if (tableView == reviewTableview){
            return reviewL.count
            
        } else {
            return 0
        
        }
    }
   
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (tableView == targetTableView){
            let cell = tableView.dequeueReusableCell(withIdentifier: "revTargetCellId")
            cell?.textLabel?.text = revTargetL [indexPath.row]
            
            return cell!
            
        } else if (tableView == drugTableview){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "revDrugCellId")
            cell?.textLabel?.text = revDrugL [indexPath.row]
            
            return cell!
            
        } else /*if (tableView == reviewTableview)*/ {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCellId") as! ReviewTableViewCell
            cell.date.text = reviewL [indexPath.row].date
            cell.memo.text = reviewL [indexPath.row].memo
            cell.ratingCosmosView.rating = reviewL [indexPath.row].rate
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if (tableView == reviewTableview) {
               reviewL.remove(at: indexPath.row)  // trick used to add Immuno
               tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath , animated: true)
    }
    
    
}




