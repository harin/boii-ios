//
//  RegisterViewController.swift
//  Boii
//
//  Created by Harin Sanghirun on 11/2/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var gesture = UITapGestureRecognizer(target: self, action: "tapBackground:")
        self.view.addGestureRecognizer(gesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tapBackground(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    @IBAction func signUpAction(sender: AnyObject) {
    
        //Check password and verify password
        var password = passwordTextField.text
        var verify = confirmPasswordTextField.text
        if password != verify {
            
            var alert = UIAlertController(title: "Error", message: "confirm password does not match", preferredStyle: .Alert)
            
            var OKAction = UIAlertAction(title: "OK", style: .Default){
                (action) in
                
            }
            
            alert.addAction(OKAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
            
            return
        }
        
        var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)

        AccountManager.sharedInstance.signup(emailTextField.text, password: passwordTextField.text) {
            (success, msg) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                
                if success {
                    log.info("Login Successful")
                    
                    hud.hide(true)
                    self.navigationController?.popViewControllerAnimated(true);
                    
                } else {
                    log.info("Login failed")
                    hud.hide(true)
                    
                    var alertMsg = ""
                    if msg != nil {
                        alertMsg = msg!
                    } else {
                        alertMsg = "Something went wrong."
                    }
                    
                    var alert = UIAlertController(title: "Error", message: alertMsg, preferredStyle: .Alert)
                    var OKAction = UIAlertAction(title: "OK", style: .Default, handler: {(action) in})
                    alert.addAction(OKAction)
                    
                    self.presentViewController(alert, animated: true, completion: {return})
                    
                }

                            
                hud.hide(true);
                self.navigationController?.popToRootViewControllerAnimated(true);
            });
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
