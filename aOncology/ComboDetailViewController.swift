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
    
    @IBOutlet var cureMatchScore: UILabel!
    @IBOutlet var matchScore: UILabel!
    @IBOutlet var totalScored: UILabel!
    
    @IBOutlet var warningImage: UIImageView!
    @IBOutlet var warningLabel: UILabel!
    
    @IBOutlet var pointImage: UIImageView!
    
    @IBOutlet var ComboDetailTableView: UITableView!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var graphView: GraphView!
    
    @IBOutlet var graphSlider: UISlider!
    
    
    // Slider Change
    @IBAction func sliderChangeValue(_ sender: UISlider) {
        
        self.graphView.thePoint = Int(sender.value)
        graphView.displayPoint (imageView : pointImage)
        row = self.graphView.thePoint
        self.setAll()
        self.checkWarning()
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
        self.checkWarning()
        
    }
    
    func checkWarning () {
        warningImage.isHidden = comboL[drugCount-1][row].redundancy == false
        warningLabel.isHidden = comboL[drugCount-1][row].redundancy == false
    }
    
    func setAll () {
        
        var comboToGraph = [Combination_C]()
        var pointToGraph = 0
        
        self.matchScore.text     = String (format:"%.2f",comboL[drugCount-1][row].matchScore)
        self.cureMatchScore.text = String (format:"%.2f",comboL[drugCount-1][row].strengthScore)
        
        comboToGraph = comboL[drugCount-1]
        pointToGraph = self.row              // where the sepcic combo is
        /*
        if ( 0 != 1 /*reducedCombo == false*/){
            // use the combo as is
          
            
        } else {
            // im manual mode, the list of drugs is reduced
            // recalculate the combolist based on teh complete drug list
            // and find the position of the combo in this combolist
            
            let combosxx =  myCombMaker.combinationsWithoutRepetitionFrom (elements: dtRelL, taking: drugCount)
            for elem in combosxx{
                let combElem = Combination_C (dtRelList: elem, filter : calcMode == .auto
                                              actionableCount: self.actionableTargetCount, pathogenicCount : targetL.count )
                comboToGraph.append ( combElem )
            }
            comboToGraph.sort(by: { ($0.strengthScore > $1.strengthScore) })
            
            // find the psoition of row(ie score) of teh reduced combo in the new combolist
            let score = comboL[drugCount-1][row].strengthScore
            var r = 0
            while  ( (comboToGraph[r].strengthScore > score ) && (r < comboToGraph.count )){
                r = r + 1
            }
            
            pointToGraph = r < comboToGraph.count ? r : r-1
            
        }
        */
        
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
                
                
                destinationVC.row = self.row
                destinationVC.drugCount = self.drugCount
                
                destinationVC.navigationItem.title = "DEBUG SCREEN"
                
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
        let geneName = comboL[drugCount-1][row].dtRelL[indexPath.section].targetHitL[indexPath.row].target.hugoName
        let hitScore = comboL[drugCount-1][row].dtRelL[indexPath.section].targetHitL[indexPath.row].hitScore
        
        cell.gene.text = geneName
        cell.hitScore.text = String(format:"%.2f", hitScore)
 
        return cell
    }
    
}




