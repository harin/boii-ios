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

private let estimoteUUID = "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"
private let beaconUUID =   "B9407F30-F5F8-466E-AFF9-25556B57FE6D"

class BeaconManager: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    let boiiRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: estimoteUUID), identifier: "BoiiRegion")
    dynamic var currentRestaurant: Restaurant? {
        didSet {
            log.debug("Current Restaurant changed to \(self.currentRestaurant)")
        }
    }
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCurrentRestaurant:", name: RestaurantStore.notificationNames.requestedBeaconFound, object: nil)
        
    }
    
    func updateCurrentRestaurant( sender: AnyObject ) {
        if let beacon = self.closestBeacon {
            self.currentRestaurant = RestaurantStore.sharedInstance.restaurantWithBeacon(beacon.major.stringValue, minor: beacon.minor.stringValue)
            postWelcomeLocalNotification()
        }
    }
    
    func start(){
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
        
        if beacons.count > 0 {
            log.debug("beaconcount = \(beacons)")
        } else {
            log.debug("beaconcount(0) = \(beacons)")
            if self.closestBeacon != nil {
                self.closestBeacon = nil
                log.debug("set closest beacon to \(self.closestBeacon)")
            }
        }
        
        let knownBeacons = beacons.filter{ $0.proximity != CLProximity.Unknown }
        
        if knownBeacons.count > 0 {
            let closestBeacon = knownBeacons[0] as! CLBeacon
//            log.debug("closestBeacon = \(closestBeacon)")
            
            if closestBeacon.minor != self.closestBeacon?.minor ||
                closestBeacon.major != self.closestBeacon?.major {
                
                //New Region
                self.closestBeacon = closestBeacon
                getCurrentRestaurant()
                log.debug("Update Beacon to \(self.closestBeacon)")
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didStartMonitoringForRegion region: CLRegion!) {
        println("Entered: didStartMonitoringForRegion")
        self.locationManager.requestStateForRegion(boiiRegion)
        println("calling requestingStateForRegion")
    }
    
    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        log.debug("")
        
        if state == CLRegionState.Inside {
            log.debug("I'm Inside \(region)")
        } else {
            log.debug("I'm not Inside")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        log.debug("")
        locationManager.startRangingBeaconsInRegion(boiiRegion)
        
//        postBeaconUpdateNotification()
        postEnterBeaconRegionNotification()
        
        // Find restaurant with major and minor
//        getCurrentRestaurant()
    }
    

    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        log.debug("")
        self.currentRestaurant = nil
        self.closestBeacon = nil
//        postBeaconUpdateNotification()
        postExitBeaconRegionNotification()
    }
    
    private func getCurrentRestaurant() {
        log.debug("Getting current Restaurant")
        if let beacon = self.closestBeacon {
            if let rest = RestaurantStore.sharedInstance.restaurantWithBeacon(beacon.major.stringValue, minor: beacon.minor.stringValue) {
                self.currentRestaurant = rest
                self.postWelcomeLocalNotification()
            } else {
                log.error("Receive nil for restaurant with beacon(\(beacon.major):\(beacon.minor))")
            }
        }
    }
    
    // MARK: Notifcation Helpers
    
    func postWelcomeLocalNotification() {
        if let rest = currentRestaurant {
            let noti = UILocalNotification()
            noti.alertBody = "Welcome to \(rest.name)"
            noti.soundName = UILocalNotificationDefaultSoundName
            UIApplication.sharedApplication().presentLocalNotificationNow(noti)
        }
    }
    
    func postPromotionAdvertisementLocalNotification() {
        
    }
    
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