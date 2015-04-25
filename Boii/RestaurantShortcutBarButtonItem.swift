//
//  RestaurantShortcutBarButtonItem.swift
//  Boii
//
//  Created by Harin Sanghirun on 11/3/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import UIKit

class RestaurantShortcutBarButtonItem: UIBarButtonItem {
    var shortcutButton: UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
    var titleLabel = UILabel(frame: CGRectMake(0,0,100,25))
    var beaconManager = BeaconManager.sharedInstance
    var viewController: UIViewController?
    var currentRestaurant: Restaurant? {
        didSet {
            println("RestaurantShortcut: setting barbutton title")
            if currentRestaurant != nil {
                println("\t restaurant not nil yeah!")
                shortcutButton.setTitle("\(currentRestaurant?.name)", forState: UIControlState.Normal)
            } else {
                shortcutButton.setTitle("", forState: UIControlState.Normal)
            }
        }
    }
    
    override init() {
        super.init()
        
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.font = UIFont(name: "Courier", size: 17)
        titleLabel.textColor = redLabelColor
        titleLabel.text = ""
        titleLabel.textAlignment = NSTextAlignment.Left
        
//        shortcutButton.setTitle("", forState: UIControlState.Normal)
        
        
        shortcutButton.addSubview(titleLabel)
        
        shortcutButton.frame = CGRectMake(0, 0, 100, 25)
//        shortcutButton.setTitleColor(redLabelColor, forState: UIControlState.Normal)
//        shortcutButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Highlighted)
        shortcutButton.addTarget(self, action: "shortcutButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.customView = shortcutButton
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "beaconUpdate:", name: BeaconManager.beaconUpdateNotificationString, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "restaurantUpdate:", name: RestaurantStore.restaurantNeedUpdateNotificationIdentifier, object: nil)
        
        
        currentRestaurant = RestaurantStore.sharedInstance.restaurantWithBeacon(1, minor: 1)
        
        self.titleLabel.text = "W&W"
    }
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    // Respond to beaconUpdateNotification sent by Beacon Manager
    // Update currentRestaurant and the button title
    func beaconUpdate(notification: NSNotification) {
        if let beacon = beaconManager.closestBeacon {
            let major = beacon.major.integerValue
            let minor = beacon.minor.integerValue
            
            let restaurant = RestaurantStore.sharedInstance.restaurantWithBeacon(major, minor: minor)
            if let rest = restaurant {
                self.shortcutButton.setTitle("\(rest.name)", forState: .Normal)
                currentRestaurant = rest
            } else {
                self.shortcutButton.setTitle("", forState: .Normal)
                currentRestaurant = nil
            }
            
        } else {
            self.shortcutButton.setTitle("", forState: .Normal)
            currentRestaurant = nil
        }
    }
    
    // When restaurant in RestaurantStore is updated
    // Update the currentRestaurant if it is nil otherwise, skip
    func restaurantUpdate(notification: NSNotification){
        dispatch_async(dispatch_get_main_queue(), {
            println("RestaurantShortcut: Updating restaurant")
        })
        if currentRestaurant == nil {
            
//            // For Testing
//            
//            currentRestaurant = RestaurantStore.sharedInstance.restaurantWithBeacon(1, minor: 1)?
//            dispatch_async(dispatch_get_main_queue(), {
//                println("RestaurantShortcut: currentRest = \(self.currentRestaurant)")
//            })
//            
//            
//            // Resume normal Code
//            
            
            if let beacon = beaconManager.closestBeacon {
                
                let major = beacon.major.integerValue
                let minor = beacon.minor.integerValue
                
                if let restaurant = RestaurantStore.sharedInstance.restaurantWithBeacon(major, minor: minor) {

                    currentRestaurant = restaurant
                    dispatch_async(dispatch_get_main_queue(), {
                        println("RestaurantShortcut: currentRest = \(self.currentRestaurant)")
                    })
                }
            }
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
