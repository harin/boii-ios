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


*/

import Foundation

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
        
        self.ordered += self.toOrder
        self.toOrder = []
        
        //send order to server
        
    }
    
}

/*
Handing Cart when user want to switch restaurant they're in.




*/