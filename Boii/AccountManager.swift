//
//  AccountManager.swift
//  Boii
//
//  Created by Harin Sanghirun on 23/2/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import Foundation

class AccountManager: NSObject {
    dynamic var authToken: String? {
        didSet {
            println("AM: authToken setted to:\(authToken)")
        }
    }
    var userId: String?
    var isLoggedIn: Bool {
        return authToken != nil;
    }
    
    //Singleton
    class var sharedInstance: AccountManager {
        struct Static {
            static var instance: AccountManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = AccountManager()
        }
        
        return Static.instance!
    }
    
    func login(email: String, password: String, callback: ((Bool) -> Void)? ){

        var url = domain + "/api/login/"
        var request = NSMutableURLRequest( URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var data = "user=\(email)&password=\(password)"
        request.HTTPBody = data.dataUsingEncoding(NSUTF8StringEncoding)
        
        var task = session.dataTaskWithRequest(request) { (rawData, response, error) -> Void in
            println("Response: \(response)")
            var status: String?
            if let data = rawData {
                var json = JSON(data: data)
                println("Json=: \(json)")
                status = json["status"].string
                println("Status = \(status)")
                
                
                if status == "success" {
                    println("AM: Setting authToken")
                    var data = json["data"]
                        
                    self.authToken = data["authToken"].string
                    self.userId = data["userId"].string
                    
                } else {
                    println("AccountManager: Response status = \(status)")
                    println(NSString(data: rawData, encoding: NSUTF8StringEncoding));
                }
            }
            
            if callback != nil {
                callback!( status == "success" )
            }
        }
        
        task.resume()
    }
    
    
    
}