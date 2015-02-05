//
//  Menu.swift
//  Boii
//
//  Created by Harin Sanghirun on 15/1/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import Foundation

class Menu: Printable {
    var name: String
    var price: Float
    
    init(name:String, price:Float){
        self.name = name
        self.price = price
    }
    
    var description: String {
        return "Menu { name: \(name) , price: \(price) }"
    }
    
    
}