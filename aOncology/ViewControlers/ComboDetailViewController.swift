//
//  ComboDetailViewController.swift
//  aOncology
//
//  Created by Philippe-Faurie on 5/2/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import UIKit

class ComboDetailViewController: UIViewController {
    
    var drugCount = 0         // number of drug in teh combo
    var row = 0               // what combo is that
    var reducedCombo = false  // in manual mode a sublist of drugs might have been used
    
    var caseID = String ()
    var memo   = String ()
    var diag   = String ()
    
    @IBOutlet var cureMatchScore: UILabel!
    @IBOutlet var matchScore: UILabel!
    @IBOutlet var totalScored: UILabel!
    
    @IBOutlet var warningImage: UIImageView!
    @IBOutlet var warningLabel: UILabel!
    
    @IBOutlet var immunoImage: UIImageView!
    @IBOutlet var pointImage: UIImageView!
    
    @IBOutlet var ComboDetailTableView: UITableView!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var graphView: GraphView!
    
    @IBOutlet var graphSlider: UISlider!
    
    @IBOutlet var communityImage: UIImageView!
    @IBOutlet var communityButton: UIButton!
    // Slider Change
    @IBAction func sliderChangeValue(_ sender: UISlider) {
        
        self.graphView.thePoint = Int(sender.value)
        graphView.displayPoint (imageView : pointImage)
        row = self.graphView.thePoint
        
        self.setAll()
        self.checkIndicators()
        ComboDetailTableView.reloadData()
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.setAll()
        self.checkIndicators()
    }
    
    func checkIndicators () {
        
        warningImage.isHidden = comboL[drugCount-1][row].redundancy    == false
        warningLabel.isHidden = comboL[drugCount-1][row].redundancy    == false
        immunoImage.isHidden  = comboL[drugCount-1][row].immunoStatus  == .noImmuno
        
        if (loggedIn == false) {
            communityImage.isHidden = true
            communityButton.isEnabled = false
            
        } else {
            communityImage.isHidden   = false
            communityButton.isEnabled = true

        }

    }
    
    func setAll () {
        
        var comboToGraph = [Combination_C]()
        var pointToGraph = 0
        
        self.matchScore.text     = String (format:"%.2f",comboL[drugCount-1][row].matchScore)
        self.cureMatchScore.text = String (format:"%.2f",comboL[drugCount-1][row].strengthScore)
        
        comboToGraph = comboL[drugCount-1]
        pointToGraph = self.row              // where the sepcic combo is

        
        // send the data to the graph
        var r = 0
        self.graphView.graphPoints.removeAll()
        while ( (r < comboToGraph.count) && (comboToGraph[r].strengthScore > 0) ) {
            self.graphView.graphPoints.append( Int (comboToGraph[r].strengthScore) )
            r = r + 1
        }
        if ( r == 0) {
            self.graphView.graphPoints.append(0)
        }
        
        // what combo exactly it is
        // so we can draw a point
        self.graphView.thePoint = pointToGraph
        self.totalScored.text = String(graphView.graphPoints.count)
        
        // clean useless variables
        comboToGraph.removeAll()
        self.graphSlider.maximumValue = Float (self.graphView.graphPoints.count-1)

        self.graphSlider.value = Float (pointToGraph)
         graphView.displayPoint (imageView : pointImage)

        
        
    }
    
    //------------------------------------
    // Segue stuff
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDebug" {
            if let destinationVC = segue.destination as? DebugViewController{
                
                destinationVC.row       = self.row
                destinationVC.drugCount = self.drugCount
                
                destinationVC.navigationItem.title = "DEBUG SCREEN"
            }
            
        } else if segue.identifier == "toReview" {
            if let destinationVC = segue.destination as? ReviewViewController{
                
                destinationVC.row       = self.row
                destinationVC.drugCount = self.drugCount
                
                destinationVC.caseID     = self.caseID
                destinationVC.memo       = self.memo
                destinationVC.diagnostic = self.diag


                destinationVC.navigationItem.title = "Review"
                
            }
        }
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
extension ComboDetailViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var title = comboL[drugCount-1][row].dtRelL[section].drug.drugName
        
        if (comboL[drugCount-1][row].dtRelL[section].drug.approved == 1) {
            title = title  +  " (*)"
        }
        return title
//        return comboL[drugCount-1][row].dtRelL[section].drug.drugName

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        return self.drugCount
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return comboL[drugCount-1][row].dtRelL[section].targetHitL.count
       // return items[section].count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellComboDetailId") as! ComboDetailTableViewCell
        var geneName = comboL[drugCount-1][row].dtRelL[indexPath.section].targetHitL[indexPath.row].target.hugoName
        geneName = geneName == GHOST_TARGET ? "(IMMUNO)" : geneName
        
        let hitScore = comboL[drugCount-1][row].dtRelL[indexPath.section].targetHitL[indexPath.row].hitScore
        
        cell.gene.text = geneName
        cell.hitScore.text = String(format:"%.2f", hitScore)
        
        cell.TSub1.text = ""
        cell.TSub2.text = ""
        cell.TSub3.text = ""
        
        let tHit = comboL[drugCount-1][row].dtRelL[indexPath.section].targetHitL[indexPath.row]
        
        var i = 0
        for s in tHit.targetSubsL {
            i += 1
            
            var str = "via " + s.target.hugoName
            
            if (s.mode == SubsMode.indirect){
                str = str + " pathway"
            }
            
            if (i==1) {
                cell.TSub1.text = str
            } else if (i==2) {
                cell.TSub2.text = str
            } else if (i==3) {
                cell.TSub3.text = str
            }
            
        }
        
 
        return cell
    }
    
}




