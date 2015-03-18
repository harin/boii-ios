//
//  LogoutBarButtonItem.swift
//  Boii
//
//  Created by Harin Sanghirun on 18/3/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import UIKit

class LogoutBarButtonItem: UIBarButtonItem {
    var button: UIButton = UIButton()
    var accountManager: AccountManager = AccountManager.sharedInstance
    
    override init() {
        super.init()
        
        button.setTitle("Logout", forState: UIControlState.Normal)
        button.frame = CGRectMake(0, 0, 60, 20)
        button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        button.setTitleColor(UIColor.redColor(), forState: UIControlState.Highlighted)
        button.addTarget(self, action: "logoutButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.customView = button
    }
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    func logoutButtonAction(sender: AnyObject){
        self.accountManager.logout()
    }
    
}
