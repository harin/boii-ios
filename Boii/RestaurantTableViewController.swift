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

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
       
        //resize Image
//        var rowHeight = self.tableView.rowHeight
//        var imgHeight = backgroundImgView.bounds.height
//        var imgWidth = backgroundImgView.bounds.width
//        
//        var newWidth = (imgHeight/imgWidth) / rowHeight
//        
//        var newSize = CGSize(width: newWidth, height: rowHeight)
//        
//        UIGraphicsBeginImageContext(newSize)
//        backgroundImgView.image?.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
//        var resizedImg = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        backgroundImgView.image = resizedImg

        
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
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
