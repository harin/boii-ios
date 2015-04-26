//
//  CartBarButtonItem.swift
//  Boii
//
//  Created by Harin Sanghirun on 9/2/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import UIKit

private var myContext = 0

class CartBarButtonItem: UIBarButtonItem {
    var viewController: UIViewController?
    let cartButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
    let cartStore: ShoppingCartStore = ShoppingCartStore.sharedInstance
    let accountManager: AccountManager = AccountManager.sharedInstance
    var titleLabel = UILabel(frame: CGRectMake(0, 0, 80, 25))

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
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.font = UIFont.systemFontOfSize(17.0)
        titleLabel.textColor = redLabelColor
        titleLabel.text = "Login"
        titleLabel.textAlignment = NSTextAlignment.Right
        titleLabel.font = UIFont(name: "Courier", size: 17.0)
        cartButton.addSubview(titleLabel)
        
        cartButton.frame = CGRectMake(0, 0, 80, 25)
        cartButton.addTarget(self, action: "cartButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.customView = cartButton
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cartUpdate:", name: ShoppingCartStore.notifications.cartUpdateNotificationIdentifier, object: nil)
        
        //Observe authToken of accountManager
        accountManager.addObserver(self, forKeyPath: "isLoggedIn", options: .New, context: &myContext)
    }
    
    deinit{
        accountManager.removeObserver(self, forKeyPath: "isLoggedIn", context: &myContext)
    }
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    func cartButtonAction(sender: AnyObject) {
        if AccountManager.sharedInstance.isLoggedIn {
            // show cart
            let storyboard = UIStoryboard(name: "CartStoryboard", bundle: nil) as UIStoryboard
            let loginController = storyboard.instantiateViewControllerWithIdentifier("CartViewController") as! CartViewController
            
            self.viewController?.navigationController?.pushViewController(loginController, animated: true)
        } else {
            // show login page
            
            let storyboard = UIStoryboard(name: "LoginStoryboard", bundle: nil) as UIStoryboard
            let loginController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            self.viewController?.navigationController?.pushViewController(loginController, animated: true)
        }
    }
    
    func cartUpdate( sender: AnyObject? ) {
        self.setCustomTitle("cart(\(cartStore.getCurrentOrder().menuItems.count))")
    }
    
    func setCustomTitle( title: String) {
        self.titleLabel.text = title
    }
    
    // MARK: KVO
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        println("CartBarButtonItem: ObserveValueForKey:\(keyPath)")
        if context == &myContext {
            dispatch_async(dispatch_get_main_queue()){
                if self.accountManager.isLoggedIn {
                    self.setCustomTitle("cart(\(self.cartStore.getCurrentOrder().menuItems.count))")
                } else {
                    self.setCustomTitle("Login")
                }
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
}
