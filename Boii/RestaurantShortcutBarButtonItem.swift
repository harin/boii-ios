//
//  RestaurantShortcutBarButtonItem.swift
//  Boii
//
//  Created by Harin Sanghirun on 11/3/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import UIKit

private var myContext = 0

class RestaurantShortcutBarButtonItem: UIBarButtonItem {
    var shortcutButton: UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
    var titleLabel = UILabel(frame: CGRectMake(0,0,100,25))
    var beaconManager = BeaconManager.sharedInstance
    var viewController: UIViewController?
    var currentRestaurant: Restaurant?
    
    override init() {
        super.init()
        
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.font = UIFont(name: "Courier", size: 17)
        titleLabel.textColor = redLabelColor
        titleLabel.text = ""
        titleLabel.textAlignment = NSTextAlignment.Left
        shortcutButton.addSubview(titleLabel)
        
        shortcutButton.frame = CGRectMake(0, 0, 100, 25)
        shortcutButton.addTarget(self, action: "shortcutButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.customView = shortcutButton
        
        BeaconManager.sharedInstance.addObserver(self, forKeyPath: "currentRestaurant", options: .New, context: &myContext)
    }
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    deinit {
        BeaconManager.sharedInstance.removeObserver(self, forKeyPath: "currentRestaurant")
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &myContext {
            log.debug(keyPath)
            
            if keyPath == "currentRestaurant" {
                dispatch_async(dispatch_get_main_queue()) {
                    if let rest = BeaconManager.sharedInstance.currentRestaurant {
                        self.titleLabel.text = "\(rest.name)"
                        self.currentRestaurant = rest
                    } else {
                        self.titleLabel.text = ""
                    }
                }
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    func shortcutButtonAction(sender: AnyObject){
        println("RestaurantShortcut: shortcut pressed")
        
        if let vc = viewController {
            if let rest = currentRestaurant {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let dest = storyboard.instantiateViewControllerWithIdentifier("MenuTabBarController") as! MenuTabBarController!
                dest.rest = rest
                vc.navigationController?.pushViewController(dest, animated: true)
            }
        }
    }
    
}
