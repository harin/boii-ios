//
//  Restaurant.swift
//  Boii
//
//  Created by Harin Sanghirun on 16/2/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import Foundation
import UIKit

struct tel {
    var type: String
    var number: String
}

class Restaurant: Printable {
    
    var _id: String
    var name: String
    
    var address: String?
    var beaconID: String?
    var email: String?
    var phone: [tel] = []
    
    var drinks: [MenuItem]?
    var foods: [MenuItem]?
    var thumbnailImage: UIImage = UIImage(named:"toofast-375w.jpg")!
    
    
    init(_id: String, name:String){
        self._id = _id
        self.name = name
    }
    
    
    var description: String {
        return "Restaurant { _id: \(_id), name: \(name), address: \(address), beaconID: \(beaconID), email: \(email), phone: \(phone)\n"
    }
    
}