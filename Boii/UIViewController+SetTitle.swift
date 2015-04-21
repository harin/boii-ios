//
//  UIViewController+SetTitle.swift
//  Boii
//
//  Created by Harin Sanghirun on 20/4/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import Foundation

extension UIViewController {
    func setTitle( title:String) {
        
        if let titleView = self.navigationItem.titleView as? UILabel {
            titleView.text = title
            titleView.sizeToFit()
        } else {
            var titleView = UILabel(frame: CGRect.zeroRect)
            titleView.backgroundColor = UIColor.clearColor()
            titleView.font = UIFont.boldSystemFontOfSize(17.0)
//            titleView.shadowColor = UIColor(white: 0.0, alpha: 0.5)
            
            titleView.textColor = UIColor(red: 235.0/255.0, green: 41.0/255.0, blue: 41.0/255.0, alpha: 1)
            self.navigationItem.titleView = titleView
            
            titleView.text = title
            titleView.sizeToFit()
        }
    }
}