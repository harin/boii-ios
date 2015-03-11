//
//  RestraurantStore.swift
//  Boii
//
//  Created by Harin Sanghirun on 19/2/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

/*

api needed

GET /restaurants

GET /restaurants/:id/menus?type=drink
GET /restaurants/:id/menus?type=food

*/



import Foundation


let domain = "http://localhost:3000"
let menuPath = "/api/menus"
let restaurantPath = "/api/restaurants"
let orderPath = "/api/orders"

class RestaurantStore {
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
    //properties
    
    var restaurants: [Restaurant] = []
    
    //methods
    init(){
        let path = self.restArchivePath()
        var rest = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as [Restaurant]?
        if let r = rest {
            restaurants = r
        }
        
        /*
        var res1 = Restaurant(_id: "1", name: "Too Fast To Sleep")
        var res2 = Restaurant(_id: "2", name: "Think Tank")
        var res3 = Restaurant(_id: "3", name: "NE8T")
        var res4 = Restaurant(_id: "4", name: "Think Tank")
        var res5 = Restaurant(_id: "5", name: "Something long name very much")
        var res6 = Restaurant(_id: "6", name: "Short")
        
        var drink1 = MenuItem(name: "Ice Cream Punch",price: 50)
        var drink2 = MenuItem(name:"Chocolate Shake",price: 100)
        var drink3 = MenuItem(name:"Cappucino",price: 80.53)
        var drink4 = MenuItem(name:"Mocha",price: 80.2)
        var drink5 = MenuItem(name:"Mochachinno",price: 334)
        var drink6 = MenuItem(name:"Coke",price: 20)
        var drink7 = MenuItem(name:"Water", price:8)
        var drink8 = MenuItem(name:"Orange Juice",price: 60)
    
        restaurants = [res1,res2,res3,res4,res5,res6]

        for res in restaurants {
            let drink1 = MenuItem(name: "Ice Cream Punch",price: 50)
            let drink2 = MenuItem(name:"Chocolate Shake",price: 100)
            let drink3 = MenuItem(name:"Cappucino",price: 80.53)
            let drink4 = MenuItem(name:"Mocha",price: 80.2)
            let drink5 = MenuItem(name:"Mochachinno",price: 334)
            let drink6 = MenuItem(name:"Coke",price: 20)
            let drink7 = MenuItem(name:"Water", price:8)
            let drink8 = MenuItem(name:"Orange Juice",price: 60)
            
            let drinks = [drink1, drink2, drink3, drink4, drink5, drink6, drink7, drink8]
            
            res.drinks = drinks
            
            let food1 = MenuItem(name: "Ice Cream Punch",price: 50)
            let food2 = MenuItem(name:"Chocolate Shake",price: 100)
            let food3 = MenuItem(name:"Cappucino",price: 80.53)
            let food4 = MenuItem(name:"Mocha",price: 80.2)
            
            let foods = [food1,food2,food3,food4]
            
            res.foods = foods
        }
        
        */
    }
    
    func restArchivePath() -> String {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        return documentDirectory.stringByAppendingPathComponent("items.archive")
    }
    
    func saveChanges() -> Bool {
        let path = self.restArchivePath()
        return NSKeyedArchiver.archiveRootObject(restaurants, toFile: path)
    }
    
    func fetchMenuForRestaurant(rest: Restaurant) {
        println("RestaurantStore: fetching menus for \(rest.name)")
        
        
        let path = domain + restaurantPath + "/\(rest._id)/menus"
        
        getRequest(path) {
            (data, session, error, json) -> Void in
            
            if json != nil {
                
            }
            
        }
        
    }
    
    func fetchRestaurant(){
        println("RestaurantStore: fetching restaurant")
        
        getRequest(domain+restaurantPath) {
            (data, session, error, json) -> Void in
            
            if json != nil {
                self.parseRestaurantJson(json!)
            }
            
        }
        
//        var request = NSMutableURLRequest(URL: NSURL(string:domain + restaurantPath )!)
//        var session = NSURLSession.sharedSession()
//        var task = session.dataTaskWithRequest(request){
//            (data, response, error) -> Void in
//            if error != nil {
//                println(error)
//            } else {
//                let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
//                
//                if json != nil {
//                    self.parseRestaurantJson(json!)
//                }
//                
//            }
//        }
//        
//        task.resume() //send request
    }
    
    
    
    
    func parseRestaurantJson( jsonObject: AnyObject){
        /*
        _id: String
        address: String
        beaconID: String
        email: String
        name: String
        phone: {"type":String, "number": String}
        
        */
        
        let json = JSON( jsonObject )
        
        println(json)
        
        let data = json["data"] // array of restaurant
        println(data)
        
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
                
                if let beaconID = rest["beaconID"].string {
                    r.beaconID = beaconID
                }
                
                if let email = rest["email"].string {
                    r.email = email
                }
                let phone = rest["phone"].arrayValue
                
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
                    println("Error: _id is \(_id)")
                }
                if name == nil {
                    println("Error: name is \(name)")
                }
            }
        }
        
        println("Done Parsing \(result.count)items\n Result =\n \(result)")
        restaurants = result
        
        restaurantsNeedUpdate()
        
    }
    
    
    func restaurantsNeedUpdate() {
        
        println("restaurantStore: restaurant need update notification")
        let note = NSNotification(name: "restaurantsNeedUpdateNotification", object: self)
        
        NSNotificationCenter.defaultCenter().postNotification(note)
    }
    
    func menuForRestaurantNeedUpdate(rest: Restaurant){
        println("restaurant: restaurant need update notification")
        
        let notiName = stringForRestaurantMenuUpdateNotification(rest)
        let note = NSNotification(name: notiName, object: self)
        
        NSNotificationCenter.defaultCenter().postNotification(note)
    }

    
    
}
