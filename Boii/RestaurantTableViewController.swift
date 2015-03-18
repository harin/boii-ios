//
//  RestaurantTableViewController.swift
//  Boii
//
//  Created by Harin Sanghirun on 29/1/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

/*
จ่ายเงินก่อน
connect to facebook
QR code
*/
import UIKit

class RestaurantTableViewController: UITableViewController {
    var defaultImg: UIImage?
    var restaurantStore: RestaurantStore?
    var restaurants: [Restaurant]?
    var shoppingCart: ShoppingCartStore = ShoppingCartStore.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.topItem?.title = "Boii"
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        

        self.restaurantStore = RestaurantStore.sharedInstance
        self.restaurants = RestaurantStore.sharedInstance.restaurants
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateRestaurant:", name: "restaurantsNeedUpdateNotification", object: nil)
        
        // Set right bar button
        let barButton = CartBarButtonItem.sharedInstance

        self.navigationItem.rightBarButtonItem = barButton
        
        // Set left bar button
        let leftBarButton = RestaurantShortcutBarButtonItem()
        leftBarButton.viewController = self
        self.navigationItem.leftBarButtonItem = leftBarButton
        
    }
    
    override func viewDidAppear(animated: Bool) {
        // Need to re-set viewcontroller of barbutton when view appear.
        let barButton = self.navigationItem.rightBarButtonItem as CartBarButtonItem?
        if barButton != nil {
            barButton?.viewController = self
        }

    }
    
    func updateRestaurant(sender: AnyObject?){
        dispatch_async(dispatch_get_main_queue(), {
            // DO SOMETHING ON THE MAINTHREAD
            self.tableView.reloadData()
            println("RestaurantTVC: updating restaurants \(NSThread.currentThread())")
            self.restaurants = RestaurantStore.sharedInstance.restaurants
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        let barButton = self.navigationItem.rightBarButtonItem as CartBarButtonItem
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
        
        if let store = restaurantStore {
            return store.restaurants.count
        }
        
        return 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("restaurantCell", forIndexPath: indexPath) as UITableViewCell
        
        var backgroundImgView = tableView.viewWithTag(200) as UIImageView
        var titleLabel = tableView.viewWithTag(100) as UILabel
        
        if let restaurant = restaurants?[indexPath.row] {
            
            titleLabel.text = restaurant.name
            titleLabel.textColor = UIColor.whiteColor()
            
            //apply filter to image
            var newImg = restaurant.thumbnailImage
            var inputImage = CIImage(CGImage: newImg.CGImage)
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "selectRestaurantSegue" {
            
            if let cell = sender as UITableViewCell? {
                if let index = self.tableView.indexPathForCell(cell) as NSIndexPath? {
                    let dest = segue.destinationViewController as MenuTabBarController
                    
                    if let targetRest = self.restaurants?[index.row] {
                        dest.rest = targetRest
                    }
                }
            }
        }
    }
    


}
