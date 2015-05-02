//
//  DrinkCollectionViewController.swift
//  Boii
//
//  Created by Harin Sanghirun on 4/2/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import UIKit

private let reuseIdentifier = "drinkMenuCell"
private let reusePromoIdentifier = "drinkPromotionMenuCell"
private var myContext = 0

class DrinkCollectionViewController:
    UICollectionViewController,
    UICollectionViewDelegateFlowLayout
    {
    
    let defaultThumbnail : UIImage? = UIImage(named: "starbuck_coffee.jpg")
    var selectedMenu: MenuItem?
    var restaurant: Restaurant?
    var isObservingRestaurant: Bool = false
    let refreshControl = UIRefreshControl()
    

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.tabBarController?.title = restaurant?.name
//        if let name = restaurant?.name {
//            self.setTitle(name)
//        }

        // Do any additional setup after loading the view.
        
        let barButton = CartBarButtonItem.sharedInstance
        
        self.tabBarController?.navigationItem.rightBarButtonItem = barButton
        
        if let rest = self.restaurant {
            let notiName = stringForRestaurantMenuUpdateNotification(rest)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCollection:", name: notiName, object: nil)
            
            if ShoppingCartStore.sharedInstance.restaurant == nil {
                ShoppingCartStore.sharedInstance.switchToRestaurant(rest)
            }
        } else {
            log.error("no restaurant set")
        }
        
        self.refreshControl.tintColor = redLabelColor
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
    
    func updateCollection(sender: AnyObject?){
        dispatch_async(dispatch_get_main_queue(), {
            self.collectionView?.reloadData()
            self.refreshControl.endRefreshing()
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let barButton = self.tabBarController?.navigationItem.rightBarButtonItem as! CartBarButtonItem
        barButton.viewController = self
        
        
        if let rest = restaurant {
            rest.addObserver(self, forKeyPath: "isFetching", options: .New, context: &myContext)
            self.isObservingRestaurant = true
            
            if rest.isFetching == true {
                log.debug("showing HUD")
                MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if self.restaurant != nil && self.isObservingRestaurant == true{
            self.restaurant!.removeObserver(self, forKeyPath: "isFetching")
        }
        
        MBProgressHUD.hideAllHUDsForView(self.view, animated: false)
    }
    
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &myContext {
            log.debug(keyPath)
            switch keyPath{
            case "isFetching":
                var isFetching = self.restaurant?.isFetching
                if isFetching == nil { return }
                
                if isFetching == true {
                    //display hud
                    dispatch_async(dispatch_get_main_queue()){
                        log.debug("Displaying ProgressHUD")
                        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                        return
                    }
                } else {
                    //turn hud off
                    dispatch_async(dispatch_get_main_queue()){
                        log.debug("Hiding ProgressHUD")
                        MBProgressHUD.hideHUDForView(self.view, animated: true)
                        return
                    }
                }
            default:
                println("CartView: Unknown keyPath observed")
            }
            
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
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
        
        if let menu = self.restaurant?.drinks {
            return menu.count
        }
        return 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: MenuCollectionViewCell
        let index = indexPath.row
        if let menu = self.restaurant?.drinks[index] {
            
            if menu.promotion {
                cell = collectionView.dequeueReusableCellWithReuseIdentifier(reusePromoIdentifier, forIndexPath: indexPath) as! MenuCollectionViewCell
            } else {
                cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MenuCollectionViewCell
            }

            cell.priceLabel.text = "฿ \(menu.price)"
            cell.titleLabel.text = menu.name
            
            var url: NSURL?
            log.debug("\(menu.pic_url)")
            if let urlString = menu.pic_url {
                url = NSURL(string: domain + urlString)
            } else {
                url = NSURL(string: "")
            }
//            if let image = menu.image {
//                cell.imageView.image = image
//            } else {
                var frame = cell.frame
                cell.imageView.sd_setImageWithURL(url, placeholderImage: Utilities.defaultImageWithSize(frame.size), completed: { (image, error, cacheType, url) in
                    if image != nil {
                        menu.image = image
                    }
                })
//            }
        } else {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MenuCollectionViewCell
        }

        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let contentView = NSBundle.mainBundle().loadNibNamed("MenuDetailView", owner: self, options: nil).first as! UIView
        
        if let menu = self.restaurant?.drinks {
            let imageView = contentView.viewWithTag(301) as! UIImageView
            
            self.selectedMenu = menu[indexPath.row]

            // Setup Image
            
            imageView.image = selectedMenu!.thumbnailImage
            imageView.clipsToBounds = true
            
            // Whatever
            let addToCartButton = contentView.viewWithTag(401) as! UIButton
            addToCartButton.addTarget(self, action: "addButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            let cancelButton = contentView.viewWithTag(402) as! UIButton
            cancelButton.addTarget(self, action: "cancelButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            
            
            let popup = KLCPopup(contentView: contentView)
            popup.show()
        } else {
            println("drinkCVC: Error: drinks not found in restaurant")
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
            log.info("Initializing cartStore restaurant")
            
            if let rest = self.restaurant {
                ShoppingCartStore.sharedInstance.switchToRestaurant(rest)
            }
        }
        
        if let ID = self.restaurant?._id {
            // Check if current cart is for current restaurant
            if ShoppingCartStore.sharedInstance.restaurant?._id == ID {
                
                //Check if in region, if not disallow ordering
                if BeaconManager.sharedInstance.closestBeacon != nil || self.restaurant!.require_beacon == false {
                    if let order = selectedMenu {
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
                        (action) -> Void in
                    })
                    
                    alert.addAction(cancel)
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }

            } else {
                //ask to change restaurant
                
                if let rest = self.restaurant {
                    ShoppingCartStore.sharedInstance.switchToRestaurant(rest)
                }
                
                KLCPopup.dismissAllPopups()
            }
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    private let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 48,right: 0)
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
