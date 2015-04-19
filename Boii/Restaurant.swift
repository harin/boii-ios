//
//  Restaurant.swift
//  Boii
//
//  Created by Harin Sanghirun on 16/2/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import Foundation
import UIKit

struct tel {
    var type: String
    var number: String
}

class Restaurant: NSObject, NSCoding, Printable  {
    
    var _id: String
    var name: String
    
    var address: String?
    var beaconID: String?
    var beaconMajor: Int?
    var beaconMinor: Int?
    var email: String?
    var phone: [tel] = []
    var thumbnailImage: UIImage = UIImage(named:"toofast-375w.jpg")!
    var pic_url: String?
    dynamic var isFetching: Bool = false

    private var drinkList: [MenuItem]
    private var foodList: [MenuItem]
    
    var requireIBeacon: Bool = false;
    var lastFetch: NSDate = NSDate(timeIntervalSince1970: 0);
    var sinceLastFetch: Double {
        return  NSDate().timeIntervalSinceDate(self.lastFetch);
    }
    
    var drinks: [MenuItem] {
        get {
            if drinkList.count == 0 && self.sinceLastFetch > 300{
                fetchMenu()
            }
            return drinkList
        }
    }
    var foods: [MenuItem] {
        get {
            return foodList
        }
    }
    
    
    init(_id: String, name:String){
        self._id = _id
        self.name = name
        drinkList = []
        foodList = []
        
        super.init()
    }
    override var description: String {
        return "Restaurant { _id: \(_id), name: \(name), address: \(address), beaconMajor: \(beaconMajor), beaconMinor: \(beaconMinor),email: \(email), phone: \(phone)\n"
    }
    
    
    // MARK: NSCoding
    required init(coder aDecoder: NSCoder) {
        //        self.myCourses  = aDecoder.decodeObjectForKey("myCourses") as? Dictionary
        
        self._id = aDecoder.decodeObjectForKey("_id") as String!
        self.name = aDecoder.decodeObjectForKey("name") as String!
        self.drinkList = aDecoder.decodeObjectForKey("drinkList") as [MenuItem]
        self.foodList = aDecoder.decodeObjectForKey("foodList") as [MenuItem]
        
        super.init()
        
    }
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(_id, forKey: "_id")
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(drinkList, forKey: "drinkList")
        aCoder.encodeObject(foodList, forKey: "foodList")
    }

    // MARK: Helper methods
    
    func menuWithId(menu_id: String) -> MenuItem? {
        for menu in drinkList {
            if menu._id == menu_id {
                return menu
            }
        }
        for menu in foodList {
            if menu._id == menu_id {
                return menu
            }
        }
        
        return nil
    }
    
    
    // MARK: API accessing methods
    
    func fetchMenu() {
        
        //Only fetch if more than 5 minutes since last fetch;
        if (self.sinceLastFetch > 300) {
            self.lastFetch = NSDate();
            log.debug("Restaurant (\(self.name)): fetching menus")
            let path = domain + restaurantPath + "/\(self._id)/menus"
            log.verbose("Restaurant: Fetching Menu from path = \(path)")
            
            self.isFetching = true
            getRequest(path) {
                (data, session, error, json) -> Void in
                
                if json != nil {
                    self.parseMenuJson(json!)
                }
                
                self.isFetching = false
            }
        }
    }
    
    func parseMenuJson( jsonObject: AnyObject){
        
        let json = JSON( jsonObject )
        
        let data = json["data"] // array of menu
        log.verbose("\(data)")
        
        var result: [MenuItem] = []
        
        var drinkResult: [MenuItem] = []
        var foodResult: [MenuItem] = []
        
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS'Z'"
        
        //parse each menu
        for (index: String, menu: JSON) in data {
            println(menu);
            let _id         = menu["_id"].string
            let name        = menu["name"].string
            let price       = menu["price"].number?.doubleValue
            let type        = menu["type"].string
            
            if _id != nil && name != nil && price != nil && type != nil {
                let m = MenuItem(_id: _id!, name: name!, price: price!, type: type!)
                
                if let categ = menu["categ"].string {
                    m.categ = categ
                }
                
                if let pic_url = menu["pic_url"].string {
                    m.pic_url = pic_url
                    log.debug("url for \(self.name)=\(m.pic_url)")
                } else {
                    log.error("no picture for \(self.name)");
                }
                
                if let promotion = menu["promotion"].bool {
                    m.promotion = promotion
                }
                
                if let restaurant_name = menu["restaurant_name"].string {
                    m.restaurant_name = restaurant_name
                }
                
                if let valid_until = menu["valid_until"].string {
                    //"2015-02-23T14:38:26.357Z"
                    let date = dateFormat.dateFromString(valid_until)
                    
                    m.valid_until = date
                }

                switch type! {
                case "drink":
                    drinkResult.append(m)
                case "food":
                    foodResult.append(m)
                default:
                    log.error("Restaurant: Error menu type: \(type)")
                }
                
            } else {
                if _id == nil {
                    log.error("ParseMenuError: _id is \(_id)")
                }
                if name == nil {
                    log.error("ParseMenuError: name is \(name)")
                }
                if price == nil {
                    log.error("ParseMenuError: price is \(price)")
                }
            }
        }
        log.verbose("Done Parsing \(result.count)items\n Result =\n \(result)")
        
        self.drinkList = drinkResult
        self.foodList = foodResult
        
        log.verbose("Restaurant: Updated drink = \(self.drinkList)")
        log.verbose("Restaurant: Updated food = \(self.foodList)")

        menuForRestaurantNeedUpdate()
    }
    
    func menuForRestaurantNeedUpdate(){
        log.debug("Restaurant: Menu need update notification Sent")
        
        let notiName = stringForRestaurantMenuUpdateNotification(self)
        let note = NSNotification(name: notiName, object: self)
        
        NSNotificationCenter.defaultCenter().postNotification(note)
    }

}