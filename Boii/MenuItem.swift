//
//  Menu.swift
//  Boii
//
//  Created by Harin Sanghirun on 15/1/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import Foundation
import UIKit

class MenuItem: Printable {
    var name: String
    var price: Float
    var thumbnailImage: UIImage?
    var originalImageURL: UIImage?
    var isAvailable: Bool
    var isPromotion: Bool
    var validUntil: NSDate?
    var category: String?
    var ingredient: [String]?
    
    init(name:String, price:Float){
        self.name = name
        self.price = price
        self.isAvailable = true
        self.isPromotion = false
        self.thumbnailImage = UIImage(named:"starbuck_coffee.jpg")
    }
    
    var description: String {
        return "Menu { name: \(name) , price: \(price) }"
    }
    
    
}