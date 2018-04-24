//
//  loginViewController.swift
//  aOncology
//
//  Created by Philippe-Faurie on 4/20/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import UIKit

protocol loginScreenDelegate {
    func didLogin (hasLogged: Bool, name :String)
}


class loginViewController: UIViewController, UITextFieldDelegate {

    var loginDelegate : loginScreenDelegate!
    var isLogged :Bool!
    var theColor: UIColor!
    
    @IBOutlet var upInputView: UIView!
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    
    @IBOutlet var logInOutButton: UIButton!
    
    @IBAction func loginTapped(_ sender: Any) {
        if isLogged == false {
            if ((self.username.text == "") && (self.password.text == "")){
                return
            }

            isLogged = true
            loginDelegate.didLogin(hasLogged: true, name: self.username.text!)

        } else {
            isLogged = false
            loginDelegate.didLogin(hasLogged: false, name: "Sign In")
        }
        self.dismiss (animated :false, completion: nil)
    }
    
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss (animated :false, completion: nil)

    }
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        theColor = logInOutButton.backgroundColor!
        logInOutButton.setTitleColor(UIColor.gray, for: .disabled)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isLogged == false {
            upInputView.isHidden = false
            logInOutButton.setTitle("Login", for: .normal)
            self.checkLoginButtonEnable()
            
        } else {
            upInputView.isHidden = true
            logInOutButton.setTitle("Logout", for: .normal)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    func checkLoginButtonEnable () {
        if ((self.username.text != "") && (self.password.text != "")){
            logInOutButton.isEnabled = true

        } else {
            logInOutButton.isEnabled = false

        }
    }
    
    func lookAtEntry (_ textField: UITextField){
        if (textField == username ) {
            self.username.text = textField.text
        }else{
            self.password.text = textField.text
        }
        self.checkLoginButtonEnable()
    }
   
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.lookAtEntry(textField)
    }
 
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.lookAtEntry(textField)
        textField.resignFirstResponder();
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.lookAtEntry(textField)
        textField.resignFirstResponder();
        return true
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
