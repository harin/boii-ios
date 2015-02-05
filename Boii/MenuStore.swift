//
//  MenuStore.swift
//  Boii
//
//  Created by Harin Sanghirun on 15/1/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

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
    
    var menus: [Menu]
    
    //methods
    init(){
        menus = []
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