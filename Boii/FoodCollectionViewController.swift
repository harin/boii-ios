//
//  FoodCollectionViewController.swift
//  Boii
//
//  Created by Harin Sanghirun on 19/3/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import UIKit

private let reuseIdentifier = "foodMenuCell"

class FoodCollectionViewController:
    UICollectionViewController,
    UICollectionViewDelegateFlowLayout
{
    
    let defaultThumbnail : UIImage? = UIImage(named: "starbuck_coffee.jpg")
    var selectedMenu: MenuItem?
    var restaurant: Restaurant?
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.title = restaurant?.name
        
        // Do any additional setup after loading the view.
        
        let barButton = CartBarButtonItem.sharedInstance
        
        self.tabBarController?.navigationItem.rightBarButtonItem = barButton
        
        if let rest = self.restaurant {
            let notiName = stringForRestaurantMenuUpdateNotification(rest)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateMenu:", name: notiName, object: nil)
        } else {
            println("DrinkCVC: Error: no restaurant set")
        }
        
        self.refreshControl.addTarget(self, action: "startRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView?.addSubview(refreshControl)
    }
    
    func startRefresh( sender: AnyObject ){
        log.debug("Refreshing")
        if self.restaurant != nil {
            if !self.restaurant!.fetchMenu() {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func updateMenu(sender: AnyObject?){
        
        dispatch_async(dispatch_get_main_queue(), {
            println("DrinkCVC: updating Menu \(NSThread.currentThread())")
            self.collectionView?.reloadData()
        })
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let barButton = self.tabBarController?.navigationItem.rightBarButtonItem as CartBarButtonItem
        barButton.viewController = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let menu = self.restaurant?.foods {
            return menu.count
        }
        return 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as MenuCollectionViewCell
        
        let index = indexPath.row
        if let menu = self.restaurant?.foods[index] {
            cell.priceLabel.text = "฿ \(menu.price)"
            cell.titleLabel.text = menu.name
            
            var url: NSURL?
            log.debug("\(menu.pic_url)")
            if let urlString = menu.pic_url {
                url = NSURL(string: domain + urlString)
            } else {
                url = NSURL(string: "")
            }
            
            cell.imageView.sd_setImageWithURL(url, placeholderImage: menu.thumbnailImage, completed: { (image, error, cacheType, url) in
                log.debug("Done loading image for path \(indexPath)")
                
                if image != nil {
                    menu.image = image
                }
            })
            
            
            //            cell.initImage(menu[index].thumbnailImage)
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let contentView = NSBundle.mainBundle().loadNibNamed("MenuDetailView", owner: self, options: nil).first as UIView
        
        if let menu = self.restaurant?.foods {
            let imageView = contentView.viewWithTag(301) as UIImageView
            
            self.selectedMenu = menu[indexPath.row]
            
            imageView.image = selectedMenu!.thumbnailImage
            imageView.clipsToBounds = true
            
            let addToCartButton = contentView.viewWithTag(401) as UIButton
            addToCartButton.addTarget(self, action: "addButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            let cancelButton = contentView.viewWithTag(402) as UIButton
            cancelButton.addTarget(self, action: "cancelButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            
            
            let popup = KLCPopup(contentView: contentView)
            popup.show()
        } else {
            println("foodCVC: Error: drinks not found in restaurant")
        }
    }
    
    func cancelButtonPressed(sender: AnyObject) {
        if sender is UIView {
            sender.dismissPresentingPopup()
        }
    }
    
    func addButtonPressed(sender: AnyObject) {
        println("addButtonPressed")
        
        // Check and Initialize Shopping Cart
        if ShoppingCartStore.sharedInstance.restaurant == nil {
            println("\(_stdlib_getTypeName(self)): Initializing CartStore's restaurant")
            ShoppingCartStore.sharedInstance.restaurant = self.restaurant
        }
        
        if let ID = self.restaurant?._id {
            // Check if current cart is for current restaurant
            if ShoppingCartStore.sharedInstance.restaurant?._id == ID {
                
                //Check if in region, if not disallow ordering
                if BeaconManager.sharedInstance.closestBeacon != nil || self.restaurant!.requireIBeacon == false {
                    if let order = selectedMenu? {
                        ShoppingCartStore.sharedInstance.addMenuToCurrentOrder(order)
                    } else {
                        println("failed to add to cart")
                    }
                    
                    if sender is UIView {
                        sender.dismissPresentingPopup()
                    }
                } else {
                    if sender is UIView {
                        sender.dismissPresentingPopup()
                    }
                    
                    var alert = UIAlertController(title: "Cannot Order", message: "You must be in the restaurant to order", preferredStyle: .Alert)
                    
                    
                    var cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                        (aciton) -> Void in
                    })
                    
                    alert.addAction(cancel)
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
            } else {
                //ask to change restaurant
                
                let msg = "Would you like to change your current restaurant to \(self.restaurant!.name)"
                let alert = UIAlertController(title: "This is a different restaurant", message: msg, preferredStyle: UIAlertControllerStyle.Alert);
                let YESAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {
                    (action) in
                    
                    ShoppingCartStore.sharedInstance.switchToRestaurant(self.restaurant!)
                }
                
                let NOAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel) { (action) in
                    
                }
                alert.addAction(YESAction)
                alert.addAction(NOAction)
                
                KLCPopup.dismissAllPopups()
                
                self.presentViewController(alert, animated: true){}
            }
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    private let sectionInsets = UIEdgeInsets(top: 64.0, left: 0, bottom: 0,right: 0)
    private let interitemSpacing: CGFloat = 0.0
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = self.view.frame.width / 2 -  interitemSpacing
        let height = (4 * width) / 3
        
        return CGSize(width: width, height: height)
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return interitemSpacing
    }
    
    
    
    
}
