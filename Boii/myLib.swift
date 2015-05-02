//
//  myLib.swift
//  Boii
//
//  Created by Harin Sanghirun on 25/2/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import Foundation
//let domain = "http://192.168.10.41:3000"
let domain = "http://boiitest.meteor.com"
let menuPath = "/api/menus"
let restaurantPath = "/api/restaurants"
let orderPath = "/api/orders"
let loginPath = "/api/login"
let logoutPath = "/api/logout"
let userPath = "/api/users"

var redLabelColor = UIColor(red: 235.0/255.0, green: 41.0/255.0, blue: 41.0/255.0, alpha: 1)
var randomRedColorComps = [
    [235/255.0, 41.0/255.0, 41.0/255.0, 1.0],
    [1.0, 121.0/255.0, 121.0/255.0, 1.0],
    [1.0, 44.0/255.0, 44.0/255.0],
    [204.0/255.0, 36.0/255.0, 36.0/255.0],
    [238.0/255.0, 68.0/255.0, 68.0/255.0],
    [241.0/255.0, 106.0/255.0, 106.0/255.0],
    [239.0/255.0, 87.0/255.0, 87.0/255.0]
//    UIColor(red: 1.0, green: 121.0/255.0, blue: 121.0/255.0, alpha: 1.0),
//    UIColor(red: 1.0, green: 44.0/255.0, blue: 44.0/255.0, alpha: 1.0),
//    UIColor(red: 204.0/255.0, green: 36.0/255.0, blue: 36.0/255.0, alpha: 1.0)
]




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

class Utilities {
    class func displayUpdateAlert(title:String, msg: String) {
        if let nav = UIApplication.sharedApplication().keyWindow?.rootViewController {
            if nav is UINavigationController {
                var alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
                var OKAction = UIAlertAction(title: "OK", style: .Default, handler: {(action) in})
                alert.addAction(OKAction)
                nav.presentViewController(alert, animated: true, completion: {return})
            } else {
                log.debug("Expected a Navigation Controller, got \(nav)")
            }
        } else {
            log.error("Enable to retrieve rootViewController, sry")
        }
    }
    
    class func displayOKAlert(title:String, msg: String, viewController: UIViewController) {
        var alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        var OKAction = UIAlertAction(title: "OK", style: .Default, handler: {(action) in})
        alert.addAction(OKAction)
        viewController.presentViewController(alert, animated: true, completion: {return})
    }

    class func defaultImageWithSize(size: CGSize) -> UIImage {

        UIGraphicsBeginImageContext(size)
        var context = UIGraphicsGetCurrentContext()
        
//        img.drawAtPoint(CGPointMake(0, 0))
        
        var frame = CGRectMake(0, 0, size.width, size.height)
        
        let randomNumber = Int(arc4random_uniform(UInt32(randomRedColorComps.count)))
        let randComp = randomRedColorComps[randomNumber]
        let red = CGFloat(randComp[0])
        let green = CGFloat(randComp[1])
        let blue = CGFloat(randComp[2])
        
        CGContextSetRGBFillColor(context, red, green, blue, 1.0)
//        log.debug("\(comp[0])")
        CGContextFillRect(context, frame)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    class func getRequest( urlString: String, callback:((NSData!, NSURLResponse!, NSError!, json: AnyObject?) -> Void)?){
        var request = NSMutableURLRequest(URL: NSURL( string: urlString )!)
        var session = NSURLSession.sharedSession()
        var task = session.dataTaskWithRequest(request){
            (data, response, error) -> Void in
            
            let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
            callback!(data, response, error, json: json)
            
        }
        
        task.resume() //send request
    }
}

