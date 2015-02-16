//
//  CartBarButtonItem.swift
//  Boii
//
//  Created by Harin Sanghirun on 9/2/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import UIKit

class CartBarButtonItem: UIBarButtonItem {
    var isLoggedIn: Bool = false
    var viewController: UIViewController?

    override init() {
        super.init()
        
        let cartButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        cartButton.setTitle("(2)", forState: UIControlState.Normal)
        cartButton.frame = CGRectMake(0, 0, 20, 20)
        cartButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        cartButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Highlighted)
        cartButton.addTarget(self, action: "cartButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
//        self.viewController = vc
        
        self.customView = cartButton
    }
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    func cartButtonAction(sender: AnyObject){
        if isLoggedIn {
            // show cart
            let storyboard = UIStoryboard(name: "CartStoryboard", bundle: nil) as UIStoryboard
            let loginController = storyboard.instantiateViewControllerWithIdentifier("CartViewController") as CartViewController
            
            self.viewController?.navigationController?.pushViewController(loginController, animated: true)
        } else {
            // show login page
            
            let storyboard = UIStoryboard(name: "LoginStoryboard", bundle: nil) as UIStoryboard
            let loginController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as LoginViewController
            self.viewController?.navigationController?.pushViewController(loginController, animated: true)
            
        }
        
        
    }
    
}
