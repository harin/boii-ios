//
//  AppDelegate.swift
//  Boii
//
//  Created by Harin Sanghirun on 12/1/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import UIKit
import CoreData
import XCGLogger

let log = XCGLogger.defaultInstance()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let accountManager: AccountManager = AccountManager.sharedInstance


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        log.setup(logLevel: .Debug, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil)
        // Override point for customization after application launch.
        
        RestaurantStore.sharedInstance.fetchRestaurant()
        BeaconManager.sharedInstance.start()
        
        var setting = UIUserNotificationSettings(forTypes: .Sound | .Alert, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(setting)
        
        if( AccountManager.sharedInstance.isLoggedIn) {
            UIApplication.sharedApplication().registerForRemoteNotifications()
        }
        
        //Option contains push notification if app is not running when it came
        
        if let launchOpts: NSDictionary = launchOptions {
            var notificationPayload: NSDictionary = launchOpts.objectForKey(UIApplicationLaunchOptionsRemoteNotificationKey) as NSDictionary
            println(notificationPayload);
        }
        
        return true
    }
    
//    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
//        println("Did Receive Remote Notification with Content Available to fetch");
//    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        log.info("Did Received LocalNotification: \(notification)")
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        let success = RestaurantStore.sharedInstance.saveChanges()
        if success {
            println("Saved all Restaurants")
        } else {
            println("Could not save Restaurants")
        }
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        log.debug("AppDelegate didRegisterForRemoteNotificationsWithDeviceToken");
        var tokenString = deviceToken.description
        tokenString = tokenString.stringByReplacingOccurrencesOfString(" ", withString: "")
        tokenString = tokenString.stringByReplacingOccurrencesOfString("<", withString: "")
        tokenString = tokenString.stringByReplacingOccurrencesOfString(">", withString: "")
        println("token = \(tokenString)")
        
        accountManager.deviceToken = tokenString;
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        log.error("FailedToRegesterRemoteNotificationsWithError: \(error)")
    }

    
    // MARK: Push Notification
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        println("Did Receive Remote Notification");
        let dictionary: Dictionary = userInfo
        
        println("dictionary = \(dictionary)")
        
        let order_id = dictionary["order_id"] as? String
        let order_status = dictionary["order_status"] as? String
        println("order_id = \(order_id))")
        println("order_statas = \(order_status)")
        if order_id != nil && order_status != nil {
            ShoppingCartStore.sharedInstance.receivePushForOrderWithId(order_id!, status: order_status!)
        } else {
            if order_id     == nil { log.error("order_id is nil") }
            if order_status == nil { log.error("order_status is nil") }
        }
    }
}

