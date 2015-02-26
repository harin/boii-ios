//
//  ShoppingCartStore.swift
//  Boii
//
//  Created by Harin Sanghirun on 16/2/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//


/*

api needed

POST /orders
/*
{
customer_id: String ,
payed: Boolean ,
status: String,
order_datetime: ,
orderItems: [
{
menu_id: ,
quantity:
},
{
menu_id: ,
quantity:
},
{
menu_id: ,
quantity:
}
]
}

Should return

{
success: Boolean,
orderCode: String
}
*/

*/

import Foundation

struct orderItem{
    var menu_id: String
    var quantity: Int
}

struct order{
    var customer_id: String
    var payed: Bool
    var status: String
    var order_datetime: NSDate
    var orderItems: [orderItem]
}



class ShoppingCartStore {

    var restaurant: Restaurant? // current restaurant
    var ordered: [MenuItem] {
        didSet {
            notifyCartUpdate()
        }
    }
    var toOrder: [MenuItem] {
        didSet {
            notifyCartUpdate()
        }
    }
    var totalOrder: Int {
        get {
            return ordered.count + toOrder.count
        }
    }
    
    func notifyCartUpdate(){
        
        println("cartStore: cart updated")
        let note = NSNotification(name: "cartUpdateNotification", object: self)
        
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
    
    
    //properties

    //methods
    init(){
        self.ordered = []
        self.toOrder = []
    }
    
    func switchToRestaurant(rest: Restaurant){
        
        if restaurant != nil {
            //ask whether want to switch restaurant
            self.restaurant = rest
            self.ordered.removeAll(keepCapacity: false)
            self.toOrder.removeAll(keepCapacity: false)
        
        } else {
            //initialize
            self.restaurant = rest
            
        }
    }
    
    
    
    func askToSwitch(rest: Restaurant, viewController:UIViewController){
        let alertController = UIAlertController(title: "", message: "Would you like to switch to \(rest.name)", preferredStyle: UIAlertControllerStyle.Alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) { (action) in
            
            self.restaurant = rest
            self.ordered = []
            self.toOrder = []
            
        }
        
        let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel) {
            (action) in
            
        }
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        viewController.presentViewController(alertController, animated: true) {
            
        }

    }
    
    func sendOrder(){
        //send order to server

        postOrder()
        
        //update local data
//        self.ordered += self.toOrder
//        self.toOrder = []
        
        
    }
    
    func dataForOrder() -> AnyObject{
        var orderItems: [AnyObject] = []
        
        for menu in toOrder{
            var orderItem = [
                "menu_id": menu._id,
                "quantity": 1
            ]
            orderItems.append(orderItem)
        }
        
        var data: AnyObject = [
            "customer_id": "1234",
            "restaurant_id": "1234",
            "orderItems": orderItems
        ]
        println("Cart: data to post= \(data)")
        return data
    }
    
    func postOrder() {
        var request = NSMutableURLRequest( URL: NSURL(string: domain + orderPath)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var params: AnyObject = dataForOrder()
        var jsonData = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: nil)
        request.HTTPBody = jsonData
        
//        println(jsonData)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            println("Response: \(response)")
        }
        
        task.resume()
    }
    
}

/*
Handing Cart when user want to switch restaurant they're in.




*/