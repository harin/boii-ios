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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpAction(sender: AnyObject) {
        
        
        var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)

        AccountManager.sharedInstance.signup(emailTextField.text, password: passwordTextField.text) {
            (status) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                println("register status = \(status)");

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
