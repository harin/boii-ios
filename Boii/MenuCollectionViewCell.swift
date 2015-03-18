//
//  MenuCollectionViewCell.swift
//  Boii
//
//  Created by Harin Sanghirun on 4/2/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import UIKit

class MenuCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
//    required init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        if let imageView = self.imageView? {
//            var layer = CAGradientLayer()
//            layer.frame = imageView.bounds
//            
//            var endColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.9).CGColor //clear
//            var startColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.1).CGColor // black
//            layer.colors = [startColor, endColor]
//            layer.startPoint = CGPointMake(0.5, 1.0)
//            layer.endPoint   = CGPointMake(0.5, 0.5)
//            
//            imageView.layer.mask = layer
//            
//            imageView.contentMode = .ScaleAspectFill
//        }
    }
    
    func initImage(image: UIImage){
        //only set image if it does not exist.
        if self.imageView.image == nil {
            
            self.imageView.image = imageWithGradient(image)
        }
    }
    
    func imageWithGradient(img:UIImage!) -> UIImage{
        
        
        UIGraphicsBeginImageContext(img.size)
        var context = UIGraphicsGetCurrentContext()
        
        img.drawAtPoint(CGPointMake(0, 0))
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locations:[CGFloat] = [0.25, 1.0]
        //1 = opaque
        //0 = transparent
        let bottom = UIColor(red: 0, green: 0, blue: 0, alpha: 1).CGColor
        let top = UIColor(red: 0, green: 0, blue: 0, alpha: 0).CGColor
        
        let gradient = CGGradientCreateWithColors(colorSpace,
            [top, bottom], locations)
        
        //coordinate inverted
        //bottom of image
        let startPoint = CGPointMake(img.size.width/2, -img.size.height)
        //top of image
        let endPoint = CGPointMake(img.size.width/2, img.size.height * 2)
        
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }

    
    
    
}
