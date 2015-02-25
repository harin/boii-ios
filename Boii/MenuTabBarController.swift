//
//  MenuTabBarController.swift
//  Boii
//
//  Created by Harin Sanghirun on 21/2/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import UIKit

class MenuTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var rest: Restaurant?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        println("menutab did load")
        
        if let rest = self.rest {
            let drinkVC = self.viewControllers?[0] as DrinkCollectionViewController
            
            drinkVC.restaurant = rest
        }
    }

    
    func tabBarController(tabBarController: UITabBarController,
        didSelectViewController viewController: UIViewController){
        println(viewController)
    }
}
