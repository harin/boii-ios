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
        
    }
    
    func menuForRestaurant(ID: String) {
        
    }
    
    
    
}
