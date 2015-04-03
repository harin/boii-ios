//
//  myLib.swift
//  Boii
//
//  Created by Harin Sanghirun on 25/2/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import Foundation

let domain = "http://localhost:3000"
let menuPath = "/api/menus"
let restaurantPath = "/api/restaurants"
let orderPath = "/api/orders"
let loginPath = "/api/login"
let logoutPath = "/api/logout"
let userPath = "/api/users"

func getRequest( urlString: String, callback:((NSData!, NSURLResponse!, NSError!, json: AnyObject?) -> Void)?){
    var request = NSMutableURLRequest(URL: NSURL( string: urlString )!)
    var session = NSURLSession.sharedSession()
    var task = session.dataTaskWithRequest(request){
        (data, response, error) -> Void in
        if error != nil {
            println(error)
        } else {
            let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
            callback!(data, response, error, json: json)
        }
    }
    
    task.resume() //send request
}

func postJSONToPath( path: String, params: NSObject, callback:((NSData!, NSURLResponse!, NSError!) -> Void)?){
    
    var request = NSMutableURLRequest( URL: NSURL(string: domain + path)!)
    var session = NSURLSession.sharedSession()
    request.HTTPMethod = "POST"
    
    var jsonData = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: nil)
    request.HTTPBody = jsonData
    
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
//    request.addValue(token, forHTTPHeaderField: "X-Auth-Token")
//    request.addValue(user_id, forHTTPHeaderField: "X-User-Id")
    
    var task = session.dataTaskWithRequest(request) {
        (rawData, response, error) -> Void in
        
        if callback != nil {
            callback!( rawData, response, error )
        }
    }
    
    task.resume()
}

func stringForRestaurantMenuUpdateNotification(rest: Restaurant) -> String{
    return "menuForRestaurantNeedUpdate:\(rest._id)"
}