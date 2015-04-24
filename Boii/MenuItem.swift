//
//  Menu.swift
//  Boii
//
//  Created by Harin Sanghirun on 15/1/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import Foundation
import UIKit

class MenuItem: NSObject, Printable, NSCoding {
//    var name: String
//    var price: Float
    var thumbnailImage: UIImage {
        if image != nil {
            return image!
        } else {
            return defaultImage
        }
    }
    var originalImageURL: UIImage?
    var image: UIImage?
    var defaultImage:UIImage = UIImage(named:"You-Still-Drink-Soda.jpg")!
    var isAvailable: Bool = true
    
    var _id: String
    var price: Double
    var name: String
    var type: String
    
    var pic_url: String?
    var categ: String?
    var promotion: Bool = false
    var restaurant_name: String?
    var valid_until: NSDate?
    
    init(_id: String, name: String, price: Double, type:String){
        self._id = _id
        self.price = price
        self.name = name
        self.type = type
        
        super.init()
    }
    
    override var description: String {
        return "MenuItem { _id: \(_id), name: \(name), price: \(price), pic_url: \(pic_url), categ: \(categ), promotion: \(promotion), restaurant_name: \(restaurant_name), valid_until: \(valid_until) }\n"
    }
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(_id, forKey: "_id")
        aCoder.encodeDouble(price, forKey: "price")
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(type, forKey: "type")
        aCoder.encodeObject(image, forKey: "image")
    }
    required init(coder aDecoder: NSCoder) {

        self._id = aDecoder.decodeObjectForKey("_id") as String!
        self.price = aDecoder.decodeDoubleForKey("price") as Double!
        self.name = aDecoder.decodeObjectForKey("name") as String!
        self.type = aDecoder.decodeObjectForKey("type") as String!
        self.image = aDecoder.decodeObjectForKey("image") as UIImage?
        
        super.init()
    }
    
}