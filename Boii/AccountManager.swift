//
//  AccountManager.swift
//  Boii
//
//  Created by Harin Sanghirun on 23/2/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

class AccountManager: NSObject {
    var authToken: String? {
//        set(token) {
//            if let _token = token {
//                if (!KeychainWrapper.setString(_token, forKey:"authtoken")){
//                    log.error("Failed to save authtoken to keychain")
//                }
//            }
//        }
        get {
            return KeychainWrapper.stringForKey("authtoken")
        }
    }
    var userId: String? {
        get {
            return KeychainWrapper.stringForKey("userId")
        }
    }
    dynamic var isLoggedIn: Bool = false
    var deviceToken: String = "" {
        didSet {
            updateDeviceToken()
        }
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
    
    override init(){
        super.init()
//        KeychainWrapper.accessGroup = "group.myAccessGroup"
        if let _authToken = self.authToken, let _userId = self.userId {
            self.isLoggedIn = true
        }
    }
    
    // MARK: helpers
    
    func setCredentials(authtoken: String, userId: String) {
        if KeychainWrapper.setString(authtoken, forKey: "authtoken") &&
            KeychainWrapper.setString(userId, forKey: "userId") {
            
                isLoggedIn = true
                log.debug("credential=\(self.authToken):\(self.userId)")
                
        } else {
            log.error("Setting credential failed")
            log.debug("credential=\(self.authToken):\(self.userId)")
        }
    }
    
    func removeCredentials(){
        if KeychainWrapper.removeObjectForKey("authtoken") &&
            KeychainWrapper.removeObjectForKey("userId") {
                isLoggedIn = false
        } else {
            log.error("Remove credential failed")
        }
    }
    
    // MARK: API
    
    func signup(email: String, password: String, callback: ((success: Bool, msg: String?) -> Void)? ){
        
        var url = domain + "/api/users/"
        var request = NSMutableURLRequest( URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var data = "email=\(email)&password=\(password)"
        request.HTTPBody = data.dataUsingEncoding(NSUTF8StringEncoding)
        
        var task = session.dataTaskWithRequest(request) { (rawData, response, error) -> Void in
            println("Response: \(response)")
            var status: String?
            var message: String?
            if let data = rawData {
                var json = JSON(data: data)
                println("Json=: \(json)")
                status = json["status"].string
                message = json["message"].string

                println("Status = \(status)")
                
                
                if status == "success" {
                    println("AM: Setting authToken")

                    var authToken = json["authToken"]["token"].string
                    var userId = json["userId"].string
                    if let _authToken = authToken, let _userId = userId {
                        self.setCredentials(_authToken, userId: _userId)
                    } else {
                        if authToken == nil { log.error("authToken is \(authToken)") }
                        if userId == nil { log.error("userId is \(userId)") }
                    }
                    self.updateDeviceToken()
                    
                } else {
                    println("AccountManager: Response status = \(status)")
                    println(NSString(data: rawData, encoding: NSUTF8StringEncoding));
                }
            }
            if callback != nil {
                callback!(success: status == "success" ,msg: message)
            }
        }
        task.resume()
    }
    
    func login(email: String, password: String, callback: ((Bool, String?) -> Void)? ){

        var url = domain + "/api/login/"
        var request = NSMutableURLRequest( URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var data = "user=\(email)&password=\(password)"
        request.HTTPBody = data.dataUsingEncoding(NSUTF8StringEncoding)
        
        var task = session.dataTaskWithRequest(request) { (rawData, response, error) -> Void in
            println("Response: \(response)")
            var status: String?
            var message: String? = nil
            if let data = rawData {
                var json = JSON(data: data)
                println("Json=: \(json)")
                status = json["status"].string
                message = json["message"].string
                println("Status = \(status)")
                
                if status == "success" {
                    println("AM: Setting authToken")
                    var data = json["data"]
                        
                    var authToken = data["authToken"].string
                    var userId = data["userId"].string
                    
                    log.debug("auth:id=\(authToken):\(userId)")

                    if let _authToken = authToken, let _userId = userId {
                        self.setCredentials(_authToken, userId: _userId)
                    } else {
                        if authToken == nil { log.error("authToken is \(authToken)") }
                        if userId == nil { log.error("userId is \(userId)") }
                    }
                    self.updateDeviceToken()
                    
                    ShoppingCartStore.sharedInstance.fetchOrdersWithoutRejected()
                    
                    
                } else {
                    println("AccountManager: Response status = \(status)")
                    println(NSString(data: rawData, encoding: NSUTF8StringEncoding));
                }
            }
            
            if callback != nil {
                callback!( status == "success" , message)
                    UIApplication.sharedApplication().registerForRemoteNotifications()
            }
        }
        
        task.resume()
    }
    
    func logout(){

        if let token = self.authToken{
            if let user_id = self.userId{
                var request = NSMutableURLRequest( URL: NSURL(string: domain + logoutPath)!)
                var session = NSURLSession.sharedSession()
                request.HTTPMethod = "GET"
            
                request.addValue(token, forHTTPHeaderField: "X-Auth-Token")
                request.addValue(user_id, forHTTPHeaderField: "X-User-Id")
                
                var task = session.dataTaskWithRequest(request) { (rawData, response, error) -> Void in
                    println("Response: \(response)")
                    println("Data: \(NSString(data: rawData, encoding: NSUTF8StringEncoding))")
                    //Set Order Code
                    if let data = rawData {
                        var json = JSON(data: data)
                        if let status = json["status"].string {
                            if status == "success" {
                                log.debug("You are logged out")

                            } else {
                                log.error("\(status)")
                            }
                        } else {
                            log.error("\(json)")
                        }
                    }
                }
                task.resume()
            }
        }
        self.removeCredentials()
    }
    
    private func updateDeviceToken(){
        if self.isLoggedIn {
            var request = NSMutableURLRequest( URL: NSURL(string: domain + userPath)!)
            var session = NSURLSession.sharedSession()
            request.HTTPMethod = "PUT"
            
            var params = ["deviceToken": self.deviceToken]
            
            var jsonData = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: nil)
            request.HTTPBody = jsonData
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue(self.authToken, forHTTPHeaderField: "X-Auth-Token")
            request.addValue(self.userId, forHTTPHeaderField: "X-User-Id")
            
            var task = session.dataTaskWithRequest(request) {
                (rawData, response, error) -> Void in
                if (error != nil) {
                    //handle error
                    log.error("\(error)")
                    
                } else {
                    let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(rawData, options: NSJSONReadingOptions.MutableContainers, error: nil)
                    log.verbose("\(json)")
                }
            }
            
            log.debug("AM: updating deviceToken(\(params))" )
            task.resume()
        }
    }
    
    
}