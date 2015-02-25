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
    let cartButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
    let cartStore: ShoppingCartStore = ShoppingCartStore.sharedInstance

    class var sharedInstance: CartBarButtonItem {
        struct Static {
            static var instance: CartBarButtonItem?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = CartBarButtonItem()
        }
        
        return Static.instance!
    }
    
    override init() {
        super.init()
        
        cartButton.setTitle("(\(cartStore.totalOrder))", forState: UIControlState.Normal)
        cartButton.frame = CGRectMake(0, 0, 20, 20)
        cartButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        cartButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Highlighted)
        cartButton.addTarget(self, action: "cartButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
//        self.viewController = vc
        
        self.customView = cartButton
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cartUpdate:", name: "cartUpdateNotification", object: nil)
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
    
    func cartUpdate( sender: AnyObject? ){
        cartButton.setTitle("(\(cartStore.totalOrder))", forState: UIControlState.Normal)
    }
    
}
