//
//  DrugDetailViewController.swift
//  aOncology
//
//  Created by Philippe-Faurie on 4/22/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import UIKit
import WebKit

class DrugDetailViewController: UIViewController {
    var baseUrl = "https://www.drugs.com/search.php?searchterm="
    var drugName : String = String("drug")

    @IBOutlet var webView: WKWebView!
  

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let address = baseUrl + drugName
        let webURL = URL(string: address)
        let urlRequest = URLRequest(url: webURL!)
        webView.load(urlRequest)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let address = baseUrl + drugName
        let webURL = URL(string: address)
        let urlRequest = URLRequest(url: webURL!)
        webView.load(urlRequest)
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
