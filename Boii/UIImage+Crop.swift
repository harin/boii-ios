//
//  UIImage+Crop.swift
//  Boii
//
//  Created by Harin Sanghirun on 16/2/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import Foundation

extension UIImage {
    func crop(var rect: CGRect) -> UIImage{
        if self.scale > 1.0 {
            
            rect = CGRectMake(rect.origin.x * self.scale,
                rect.origin.y * self.scale,
                self.size.width * self.scale,
                self.size.height * self.scale)
        }
        
        let imageRef = CGImageCreateWithImageInRect(self.CGImage, rect)
        let result = UIImage(CGImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
        return result!
    }
}