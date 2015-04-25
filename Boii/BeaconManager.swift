//
//  BeaconManager.swift
//  iBacon
//
//  Created by Harin Sanghirun on 9/3/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class BeaconManager: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    let boiiRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"), identifier: "BoiiRegion")
    var currentRestaurant: Restaurant?
    var closestBeacon: CLBeacon? {
        didSet {
            postBeaconUpdateNotification()
        }
    }
    
    class var beaconUpdateNotificationString:String {
        return "BeaconNeedUpdateNotification"
    }
    class var enterBeaconRegionNotificationString:String {
        return "enterBeaconRegionNotification"
    }
    class var exitBeaconRegionNotificationString:String {
        return "exitBeaconRegionNotification"
    }
    
    class var sharedInstance: BeaconManager {

        struct Static {
            static var instance: BeaconManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = BeaconManager()
        }
        
        return Static.instance!
    }
    
    override init(){
        super.init()
        println("Initializing BeaconManager")
        locationManager.delegate = self
        
        if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedAlways {
            locationManager.requestAlwaysAuthorization()
        }
        
        if(UIApplication.instancesRespondToSelector(Selector("registerUserNotificationSettings:")))
        {
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Sound | .Alert | .Badge, categories: nil))
        }
        else
        {
            //do iOS 7 stuff, which is pretty much nothing for local notifications.
        }
        
        println("Is Location Services Enabled? \(CLLocationManager.locationServicesEnabled())")
        
        boiiRegion.notifyEntryStateOnDisplay = true
        boiiRegion.notifyOnEntry = true
        boiiRegion.notifyOnExit = true
        start()
        
    }
    
    func start(){
//        println("BeaconManager: Starting")
        startRanging()
        startMonitoring()
    }
    
    func startRanging(){
        locationManager.startRangingBeaconsInRegion(boiiRegion)
    }
    
    func startMonitoring(){
        locationManager.startMonitoringForRegion(boiiRegion)

    }
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
//        println("Entered: didRangeBeacons: \(beacons)")

        if beacons.count > 0 {
        } else {
            if self.closestBeacon != nil {
                self.closestBeacon = nil
            }
        }
        
        let knownBeacons = beacons.filter{ $0.proximity != CLProximity.Unknown }
        
        if knownBeacons.count > 0 {
            let closestBeacon = knownBeacons[0] as! CLBeacon
            
            if closestBeacon.minor != self.closestBeacon?.minor &&
                closestBeacon.major != self.closestBeacon?.major {
                    
                self.closestBeacon = closestBeacon
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didStartMonitoringForRegion region: CLRegion!) {
        println("Entered: didStartMonitoringForRegion")
        self.locationManager.requestStateForRegion(boiiRegion)
        println("calling requestingStateForRegion")
    }
    
    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        println("Entered: didDetermineState")
        
        if state == CLRegionState.Inside {
            println("I'm Inside \(region)")
        } else {
            println("I'm not Inside")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        println("didEnterRegion")
//        postBeaconUpdateNotification()
        postEnterBeaconRegionNotification()
        
        let noti = UILocalNotification()
        noti.alertBody = "You just entered this restaurant"
        noti.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().presentLocalNotificationNow(noti)
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        println("didExitRegion")
//        postBeaconUpdateNotification()
        postExitBeaconRegionNotification()
    }
    
    // MARK: Notifcation Helpers
    func postEnterBeaconRegionNotification(){
        let noti = NSNotification(name: BeaconManager.enterBeaconRegionNotificationString, object: self.closestBeacon)
        NSNotificationCenter.defaultCenter().postNotification(noti)
    }
    
    func postExitBeaconRegionNotification(){
        let noti = NSNotification(name: BeaconManager.exitBeaconRegionNotificationString, object: self.closestBeacon)
        NSNotificationCenter.defaultCenter().postNotification(noti)
    }
    
    func postBeaconUpdateNotification(){
        let noti = NSNotification(name: BeaconManager.beaconUpdateNotificationString, object: self.closestBeacon)
        NSNotificationCenter.defaultCenter().postNotification(noti)
    }
    
    
}