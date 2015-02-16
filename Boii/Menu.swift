//
//  Menu.swift
//  Boii
//
//  Created by Harin Sanghirun on 15/1/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import Foundation
import UIKit

class Menu: Printable {
    var name: String
    var price: Float
    var thumbnailImage: UIImage?
    var originalImageURL: UIImage?
    
    init(name:String, price:Float){
        self.name = name
        self.price = price
    }
    
    var description: String {
        return "Menu { name: \(name) , price: \(price) }"
    }
    
    
}