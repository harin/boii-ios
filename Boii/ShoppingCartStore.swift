//
//  ShoppingCartStore.swift
//  Boii
//
//  Created by Harin Sanghirun on 16/2/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import Foundation

class ShoppingCartStore: NSObject {
    var restaurant: Restaurant? // current restaurant
    var accountManager: AccountManager = AccountManager.sharedInstance
    dynamic var order_code: String?
    dynamic var isFetching: Bool = false
    
    struct orderStatus {
        static var accepted = "accepted"
        static var rejected = "rejected"
        static var billed = "billed"
        static var ready = "ready"
    }
    
    private var currentOrder: Order
    
    var ordered: OrderedDictionary<String, Order>
    
    struct notifications {
        static let cartUpdateNotificationIdentifier = "cartUpdateNotification"
    }

    func notifyCartUpdate() {
        log.debug("cart updated")
        let note = NSNotification(name: ShoppingCartStore.notifications.cartUpdateNotificationIdentifier, object: self)
        NSNotificationCenter.defaultCenter().postNotification(note)
    }
    
    //singleton
    class var sharedInstance: ShoppingCartStore {
        struct Static {
            static var instance: ShoppingCartStore?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            Static.instance = ShoppingCartStore()
        }
        return Static.instance!
    }
    
    //init
    
    override init(){
        currentOrder = Order()
        ordered = OrderedDictionary()
        
        super.init()
    }
    
//    func orderedArchivePath() -> String {
//        let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
//        return documentDirectory.stringByAppendingPathComponent("ordered.archive")
//    }
//    
//    func currentOrderArchivePath() -> String {
//        let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
//        return documentDirectory.stringByAppendingPathComponent("currentOrder.archive")
//    }
//    
//    func saveChanges() -> Bool {
//        var success1 = NSKeyedArchiver.archiveRootObject(ordered, toFile: self.orderedArchivePath())
//        var success2 = NSKeyedArchiver.archiveRootObject(currentOrder, toFile: self.currentOrderArchivePath())
//        return success1 && success2
//    }
    
    // MARK: Setter and Getter
    
    func addMenuToCurrentOrder(_menu: MenuItem){
        log.debug("adding menu(\(_menu.name)) to current order")
        self.currentOrder.menuItems.append(_menu)
        notifyCartUpdate()
    }
    
    func removeMenuFromCurrentOrder( menuIdx: Int ) {
        self.currentOrder.menuItems.removeAtIndex(menuIdx)
        notifyCartUpdate()
    }
    
    func getCurrentOrder() -> Order {
        return self.currentOrder
    }
    
    // MARK: Others
    
    private func initOrders() {
        self.currentOrder = Order()
        self.ordered = OrderedDictionary()
    }
    
    
    func receivePushForOrderWithId(_order_id: String, status:String) {
        // Find the Order
        let orderToUpdate = ordered[_order_id]
        
        if let order = orderToUpdate {
            // Update order status accordingly
            order.status = status
            if let code = order.orderCode {
                let message = "Order with code \(code) was \(status)"
                let title = "Order Status Update"
                Utilities.displayUpdateAlert(title, msg: message)
            }
            
            switch (status) {
            case ShoppingCartStore.orderStatus.accepted:
                println("Order accepted")
                // alert
                
                // update ui
                
            case ShoppingCartStore.orderStatus.rejected:
                println("Order rejected")
                // alert
                
                // remove from list
                removeOrderWithId(_order_id)
                
            case ShoppingCartStore.orderStatus.billed:
                println("Order billed")
                // alert
                
                //remove from list
                removeOrderWithId(_order_id)

            case ShoppingCartStore.orderStatus.ready:
                println("Order Ready")
                //alert user to go pickup
//                log.debug("\(UIApplication.sharedApplication().keyWindow)")
//                log.debug("\(UIApplication.sharedApplication().keyWindow?.rootViewController)")
                
                
            default:
                println("Unsupported order status case")
            }
            
            self.notifyCartUpdate()
        }
    }
    
    func removeOrderWithId(id: String){
        //dispatch_sync(dispatch_get_main_queue()){
            log.debug("Removing Order with id \(id)")
            log.debug("\(self.ordered[id])")
            self.ordered[id] = nil
        //}
    }
    
    func switchToRestaurant(rest: Restaurant){
        
        if restaurant != nil {
            //ask whether want to switch restaurant
            self.restaurant = rest
            initOrders()
            
            notifyCartUpdate()
            
        } else {
            //initialize
            self.restaurant = rest
        }
    }
    
    func askToSwitch(rest: Restaurant, viewController:UIViewController){
        let alertController = UIAlertController(title: "", message: "Would you like to switch to \(rest.name)", preferredStyle: UIAlertControllerStyle.Alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) { (action) in
            
            self.restaurant = rest
            self.initOrders()
            self.notifyCartUpdate()
        }
        
        let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel) {
            (action) in
            
        }
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        viewController.presentViewController(alertController, animated: true) {}
    }
    
    
    private func dataForOrder(user_id: String) -> AnyObject{
        var orderItems: [AnyObject] = []
        
        for menu in currentOrder.menuItems{
            var orderItem = [
                "menu_id": menu._id,
                "quantity": 1
            ]
            orderItems.append(orderItem)
        }
        
        var data: AnyObject = [
            "customer_id": "\(user_id)",
            "restaurant_id": "\(self.restaurant!._id)",
            "orderItems": orderItems
        ]
        println("Cart: data to post= \(data)")
        return data
    }
    func fetchOrdersIncludingRejected() {
        self.fetchOrders(true)
    }
    
    func fetchOrdersWithoutRejected() {
        self.fetchOrders(false)
    }

    private func fetchOrders(includeRejected:Bool){
        if accountManager.isLoggedIn && self.restaurant != nil {
            
            log.debug("Updating orders")
            
            var url = domain + orderPath + "?restaurant_id=\(self.restaurant!._id)"
            
            if includeRejected {
                url += "&includeRejected=true"
            }
            
            var request = NSMutableURLRequest(URL: NSURL( string: url )!)
            
            request.setValue(accountManager.userId, forHTTPHeaderField: "x-user-id")
            request.setValue(accountManager.authToken, forHTTPHeaderField: "x-auth-token")
            
            var session = NSURLSession.sharedSession()
            var task = session.dataTaskWithRequest(request){
                (data, response, error) -> Void in
                
                let rawJson: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
                
//                log.debug("\(rawJson)")
                
                self.parseOrder(rawJson)
                self.isFetching = false

            }
            
            self.isFetching = true
            task.resume()
            
        } else {
            if !accountManager.isLoggedIn {
                log.error("Not loggedIn")
            }
            
            if self.restaurant == nil {
                log.error("self.restaurant not initialized")
            }
        }
    }
    
    func parseOrder( rawJson: AnyObject? ){
        var cartUpdated = false // Use to check whether there is an update to the cart
        
        if rawJson != nil {
            let json = JSON(rawJson!)
            if json != nil {
                //parse
                let status = json["status"].string
                if status == "success" {
                    let data = json["data"]
                    if data != nil  {
                        var newOrdered = OrderedDictionary<String, Order>()
                        for (key: String, orderJson: JSON) in data {
                            // Create Empty Order
                            var order = Order()
                            
                            order.order_id = orderJson["_id"].string
                            
                            if order.order_id != nil {
                                order.orderCode = orderJson["confirm_code"].string
                                
                                if let status = orderJson["order_status"].string {
                                    order.status = status
                                }
                                
                                let menuItems = orderJson["orderItems"]
                                if menuItems != nil {
                                    for(index: String, menus: JSON) in menuItems {
                                        //find menu item with id
                                        if let menuId = menus.string {
                                            if let menu = self.restaurant?.menuWithId(menuId) {
                                                //If menu exist => add to order
                                                order.menuItems.append( menu)
                                            } else {
                                                log.error("Menu with id(\(menuId)) not found")
                                            }
                                        } else {
                                            log.error("menuId is \(menus.string)")
                                        }
                                    }
                                } else {
                                    log.error("orderJson['orderItems'] is \(menuItems)")
                                }
                                // Put order into cart
                                newOrdered[order.order_id!] = order
                                
                            } else {
                                log.error("order_id is \(order.order_id)")
                            }
                        }
                        
                        
                        // Update the cartUpdate Flag
                        if !cartUpdated {
                            cartUpdated = true
                        }
                        
                        // set ordered to newOrdered
                        self.ordered = newOrdered

                    } else {
                        log.error("data=\(data)")
                    }
                } else {
                    log.error("status=\(status)")
                }
            }
        } else {
            log.error("rawJson is \(rawJson)")
        }
        
        // If updated, send notification
        if cartUpdated {
            self.notifyCartUpdate()
        }
    }
    
    func sendOrder() {
        if let token = accountManager.authToken {
            if let user_id = accountManager.userId {
                if let rest_id = restaurant?._id {
                    var request = NSMutableURLRequest( URL: NSURL(string: domain + orderPath)!)
                    var session = NSURLSession.sharedSession()
                    request.HTTPMethod = "POST"
                    let authToken = AccountManager.sharedInstance.authToken
                    
                    var params: AnyObject = dataForOrder(user_id)
                    var jsonData = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: nil)
                    request.HTTPBody = jsonData
                    
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.addValue("application/json", forHTTPHeaderField: "Accept")
                    request.addValue(token, forHTTPHeaderField: "X-Auth-Token")
                    request.addValue(user_id, forHTTPHeaderField: "X-User-Id")
                    
                    var task = session.dataTaskWithRequest(request) { (rawData, response, error) -> Void in
                        
                        if(error == nil) {
                            //Handle successful request
                            log.verbose("Response: \(response)")
                            log.verbose("Data: \(NSString(data: rawData, encoding: NSUTF8StringEncoding))")
                            //Set Order Code
                            if let data = rawData {
                                var json = JSON(data: data)
                                
                                let order_code = json["order_code"].string
                                let order_id = json["order_id"].string
                                
                                if order_code != nil && order_id != nil {
                                    
                                    //update currentOrder and put in ordered
                                    self.currentOrder.order_id = order_id!
                                    self.currentOrder.orderCode = order_code!
                                    self.ordered[order_id!] = self.currentOrder
                                    
                                    log.debug("\(self.ordered[order_id!])")
                                    
                                    //initialize new order
                                    self.currentOrder = Order()
                                    
                                    self.notifyCartUpdate()
                                    
                                } else {
                                    if order_code == nil { log.error("order_code is nil") }
                                    if order_id   == nil { log.error("order_id is nil") }
                                }
                            }
                        } else {
                            //Handle request failure
                            log.error("send order request failed: \(error)")
                            
                        }
                    }
                    task.resume()
                }
            }
        }
        
    }
    

    
}
