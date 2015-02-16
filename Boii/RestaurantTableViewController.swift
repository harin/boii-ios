//
//  RestaurantTableViewController.swift
//  Boii
//
//  Created by Harin Sanghirun on 29/1/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import UIKit

class RestaurantTableViewController: UITableViewController {
    var defaultImg: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.topItem?.title = "Boii"
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        let barButton = CartBarButtonItem() as CartBarButtonItem
        barButton.viewController = self
        
        self.navigationItem.rightBarButtonItem = barButton
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 5
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("restaurantCell", forIndexPath: indexPath) as UITableViewCell
        
        var backgroundImgView = tableView.viewWithTag(200) as UIImageView
        var titleLabel = tableView.viewWithTag(100) as UILabel
        
        titleLabel.text = "Hello World!"
        titleLabel.textColor = UIColor.whiteColor()
        
        
        //set image
        backgroundImgView.image = UIImage(named: "toofast-375w.jpg")
        backgroundImgView.contentMode = .ScaleAspectFill
       

        
        //add filter to image
        if let img = defaultImg? {
            
            backgroundImgView.image = img
            
        } else {
            
            var newImg: UIImage? = UIImage(named: "toofast-375w.jpg")
            var inputImage = CIImage(CGImage: newImg?.CGImage)
            var context = CIContext(options: nil)
            
            var filter = CIFilter(name: "CIVignette")
            filter.setValue(inputImage, forKey: kCIInputImageKey)
            
            filter.setValue(0.9, forKey: "inputRadius")
            filter.setValue(1, forKey: "inputIntensity")
            
            var outputImage = filter.outputImage
            var cgImg = context.createCGImage(outputImage, fromRect: outputImage.extent())
            defaultImg = UIImage(CGImage: cgImg)
            
            backgroundImgView.image = defaultImg

        }
        
        // Configure the cell...

        return cell
    }
    


}
