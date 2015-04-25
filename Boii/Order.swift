//
//  Order.swift
//  Boii
//
//  Created by Harin Sanghirun on 2/4/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import Foundation

class Order: NSObject, Printable, NSCoding {
    var menuItems: [MenuItem] = []
    var order_id: String?
    var status: String = "approving"
    var orderCode: String?
    
    override var description: String {
        return "Order(\(order_id), \(menuItems), \(status), \(orderCode)"
    }
    
    override init() {
        super.init()
    }
    
    // MARK: NSCoding
    required init(coder aDecoder: NSCoder) {
        self.menuItems = aDecoder.decodeObjectForKey("menuItems") as! [MenuItem]
        self.order_id = aDecoder.decodeObjectForKey("order_id") as! String?
        self.status = aDecoder.decodeObjectForKey("status") as! String
        self.orderCode = aDecoder.decodeObjectForKey("orderCode") as! String?
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(menuItems, forKey: "menuItems")
        aCoder.encodeObject(order_id, forKey: "order_id")
        aCoder.encodeObject(status, forKey: "status")
        aCoder.encodeObject(orderCode, forKey: "orderCode")
    }
}