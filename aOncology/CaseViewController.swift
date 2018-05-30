//
//  CaseViewController.swift
//  aOncology
//
//  Created by Philippe-Faurie on 5/29/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import UIKit


protocol caseSelectionDelegate {
    func didSelectCase (caseRow: Int)
}

class CaseViewController: UIViewController {

    @IBOutlet var caseViewTableView: UITableView!
    var caseSelectDelegate : caseSelectionDelegate!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
}

//------------------------------------------------------------------------
// TABLEVIEW DELEGATE
extension CaseViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return caseL.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellCaseId")
        let nickName = caseL[indexPath.row].nickName
        let caseId   = caseL[indexPath.row].caseId
        
        cell?.textLabel?.text = caseId
        cell?.detailTextLabel?.text = nickName
        
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
                caseL.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath , animated: true)
        dismiss(animated: true, completion: nil)
        caseSelectDelegate.didSelectCase(caseRow: indexPath.row)
    }
    
}

