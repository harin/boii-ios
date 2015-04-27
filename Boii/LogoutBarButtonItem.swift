//
//  LogoutBarButtonItem.swift
//  Boii
//
//  Created by Harin Sanghirun on 18/3/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import UIKit

class LogoutBarButtonItem: UIBarButtonItem {
    var button: UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
    var accountManager: AccountManager = AccountManager.sharedInstance
    var titleLabel = UILabel(frame: CGRectMake(0, 0, 80, 25))
    override init() {
        super.init()
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.font = UIFont.systemFontOfSize(17.0)
        titleLabel.textColor = redLabelColor
        titleLabel.text = "Logout"
        titleLabel.textAlignment = NSTextAlignment.Right
        
        button.frame = CGRectMake(0, 0, 80, 25)
        button.addSubview(titleLabel)
        
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
