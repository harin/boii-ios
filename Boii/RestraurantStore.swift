//
//  RestraurantStore.swift
//  Boii
//
//  Created by Harin Sanghirun on 19/2/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import Foundation

class RestaurantStore: NSObject {
    //singleton
    class var sharedInstance: RestaurantStore {
        struct Static {
            static var instance: RestaurantStore?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = RestaurantStore()
        }
        
        return Static.instance!
    }
    
    class var restaurantNeedUpdateNotificationIdentifier: String {
        return "restaurantsNeedUpdateNotification"
    }
    
    //properties
    
    var restaurants: [Restaurant] = []
    dynamic var isFetching: Bool = false
    
    struct notificationNames {
        static var requestedBeaconFound = "restaurantWithRequestedBeaconFound"
    }
    
    //methods
    override init(){
        super.init()
        let path = restArchivePath()
        var rest = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as! [Restaurant]?
        if let r = rest {
            restaurants = r
        }
    }
    
    func restArchivePath() -> String {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        return documentDirectory.stringByAppendingPathComponent("items.archive")
    }
    
    func saveChanges() -> Bool {
        let path = self.restArchivePath()
        return NSKeyedArchiver.archiveRootObject(restaurants, toFile: path)
    }

    // Return restaurant with the specify major and minor, return nil is non is found
    func restaurantWithBeacon(major: String, minor: String) -> Restaurant?{
        
        // search locally
        for rest: Restaurant in restaurants {
            log.debug("\(rest.beaconMajor):\(rest.beaconMinor) = \(major):\(minor)")
            if rest.beaconMajor != nil && rest.beaconMinor != nil {
                if rest.beaconMajor == major && rest.beaconMinor == minor {
                    log.debug("\n\n\n\nResutant found = \(rest.name)\n\n\n\n")
                    return rest
                }
            }
        }
        log.debug("Resutant not found, fetching (\(major):\(minor)) from server")

        // None found, request from server
        
        var urlString = domain + restaurantPath + "?beacon_minor=\(minor)&beacon_major=\(major)"
        
        Utilities.getRequest(urlString) { (rawData, response, error, jsonObject) in
            if let _jsonObject: AnyObject = jsonObject {
                var restaurants = self.parseRestaurantJson(_jsonObject)
                if restaurants.count > 0 {
                    self.restaurants += restaurants
                    self.restaurantsNeedUpdate()
                    self.restaurantWithRequestedBeaconFound()
                } else {
                    log.error("No restaurant with beacon(\(major):\(minor)) found")
                }
            } else {
                log.error("jsonObject is \(jsonObject)")
            }
        }
        
        return nil
    }
    
    // MARK: helper methods
    
    func getRestaurantWithId(rest_id: String) -> Restaurant?{
        for rest in restaurants {
            if rest._id == rest_id {
                return rest
            }
        }
        return nil
    }
    
    // MARK: API methods
    
    func fetchRestaurant(){
        log.debug("RestaurantStore: fetching restaurant")
        
        self.isFetching = true
        Utilities.getRequest(domain+restaurantPath) {
            (data, session, error, json) -> Void in
            
            if error == nil {
//                log.debug("\(json)")
                
                if json != nil {
                    let restaurants = self.parseRestaurantJson(json!)
                    if restaurants.count > 0 {
                        self.restaurants = restaurants
                        self.restaurantsNeedUpdate()
                    }
                    
                } else {
                    log.error("json=\(json)")
                }
            } else {
                log.error("error=\(error)")
            }
            
            log.debug("Done fetching")
            self.isFetching = false
        }
    }
    
    func parseRestaurantJson( jsonObject: AnyObject) -> [Restaurant]{
        log.debug("Parsing restaurant json")
        /*
        _id: String
        address: String
        beaconID: String
        email: String
        name: String
        phone: {"type":String, "number": String}
        
        */
        
        let json = JSON( jsonObject )
        
        let data = json["data"] // array of restaurant
        log.debug("data = \n\(data)")
        
        var result: [Restaurant] = []
        
        //parse each menu
        for (index: String, rest: JSON) in data {
            
            let _id         = rest["_id"].string
            let name        = rest["name"].string
            
            if _id != nil && name != nil{
                let r = Restaurant(_id: _id!, name: name!)
                
                if let address = rest["address"].string {
                    r.address = address
                }
                
                if let beaconMajor = rest["beacon_major"].string {
                    r.beaconMajor = beaconMajor
                }
                
                if let beaconMinor = rest["beacon_minor"].string {
                    r.beaconMinor = beaconMinor
                } else {
                    log.error("failed to parse beacon minor for \(name)")
                }
                
                if let pic_url = rest["pic_url"].string {
                    r.pic_url = pic_url
                }
                
                if let email = rest["email"].string {
                    r.email = email
                }
                let phone = rest["phone"].arrayValue
                
                if let require_beacon = rest["require_beacon"].bool {
                    r.require_beacon = require_beacon
                }
                
                if let ad_phrase = rest["ad_phrase"].string {
                    r.ad_phrase = ad_phrase
                } else {
                    log.error("\n\n\nAd phrase not found\n\n")
                }
                
                for num in phone {
                    let type = num["type"].string
                    let number = num["type"].string
                    
                    if type != nil && number != nil {
                        r.phone.append(tel(type: type!, number: number!))
                    }
                }
                result.append(r)
            } else {
                if _id == nil {
                    log.error("Error: _id is \(_id)")
                }
                if name == nil {
                    log.error("Error: name is \(name)")
                }
            }
        }
        
        log.verbose("Done Parsing \(result.count)items\n Result =\n \(result)")
        

        return result

    }
    
    func restaurantsNeedUpdate() {
        
//        log.debug("")
        let note = NSNotification(name: "restaurantsNeedUpdateNotification", object: self)
        
        NSNotificationCenter.defaultCenter().postNotification(note)
    }
    
    func restaurantWithRequestedBeaconFound() {
        
        let note = NSNotification(name: "restaurantWithRequestedBeaconFound", object: self)
        
        NSNotificationCenter.defaultCenter().postNotification(note)
    }
    
    func menuForRestaurantNeedUpdate(rest: Restaurant){
        log.debug("")
        
        let notiName = stringForRestaurantMenuUpdateNotification(rest)
        let note = NSNotification(name: notiName, object: self)
        
        NSNotificationCenter.defaultCenter().postNotification(note)
    }

}
