//
//  MenuStore.swift
//  Boii
//
//  Created by Harin Sanghirun on 15/1/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

/*

api needed




*/

import Foundation

class MenuStore {
    //singleton
    class var sharedInstance: MenuStore {
        struct Static {
            static var instance: MenuStore?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = MenuStore()
        }
        
        return Static.instance!
    }
    //properties
    
    var drinks: [MenuItem]
    var foods: [MenuItem]
    
    //methods
    init(){

//        var drink1 = MenuItem(name: "Ice Cream Punch",price: 50)
//        var drink2 = MenuItem(name:"Chocolate Shake",price: 100)
//        var drink3 = MenuItem(name:"Cappucino",price: 80.53)
//        var drink4 = MenuItem(name:"Mocha",price: 80.2)
//        var drink5 = MenuItem(name:"Mochachinno",price: 334)
//        var drink6 = MenuItem(name:"Coke",price: 20)
//        var drink7 = MenuItem(name:"Water", price:8)
//        var drink8 = MenuItem(name:"Orange Juice",price: 60)
        
//        drinks = [drink1, drink2, drink3, drink4, drink5, drink6, drink7, drink8]
        foods = []
        drinks = []
    }
    
    func menuForRestaurant(ID: String) {
        
    }
}




//class Singleton {
//    class var sharedInstance: Singleton {
//        struct Static {
//            static var instance: Singleton?
//            static var token: dispatch_once_t = 0
//        }
//        
//        dispatch_once(&Static.token) {
//            Static.instance = Singleton()
//        }
//        
//        return Static.instance!
//    }
//}
// http://code.martinrue.com/posts/the-singleton-pattern-in-swift