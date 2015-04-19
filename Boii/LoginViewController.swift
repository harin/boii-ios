//
//  LoginViewController.swift
//  Boii
//
//  Created by Harin Sanghirun on 11/2/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signupLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        AccountManager.sharedInstance.login("a@a.com", password: "123456", callback: nil)
        
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
    
    @IBAction func loginAction(sender: AnyObject) {
        let email = "a@a.com" //self.emailTextField.text
        let password = "password"// self.passwordTextField.text
        
        println("LoginVC: Logging user in");
        //perform some format check here
        
        var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        AccountManager.sharedInstance.login(email , password: password) {
            (success) in
            
            println("callback called");
            
            dispatch_async(dispatch_get_main_queue(), {
                hud.hide(true);
                self.navigationController?.popViewControllerAnimated(true);
            });
        }
        
        //show some loading action.
        
        
        //dismiss view controller if successful
        
        //else show why failed
        
    }

    @IBAction func signUpAction(sender: AnyObject) {
        
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
