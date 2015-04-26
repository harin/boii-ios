//
//  CartViewController.swift
//  Boii
//
//  Created by Harin Sanghirun on 11/2/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import UIKit

private let placeOrderCell = "PlaceOrderCell"
private let orderItemCell = "OrderItemCell"
private var myContext = 0

class CartViewController: UITableViewController {
    var cartStore: ShoppingCartStore = ShoppingCartStore.sharedInstance
    var orderCodeLabel = UILabel()
        
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.navigationItem.rightBarButtonItem = LogoutBarButtonItem()

        // Initialize the refresh control
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.backgroundColor = UIColor.blackColor()
        self.refreshControl?.tintColor = UIColor.whiteColor()
        self.refreshControl?.addTarget(self, action: "pulledToRefresh:", forControlEvents: UIControlEvents.ValueChanged)

    }
    
    func pulledToRefresh(sender: AnyObject){
        log.debug("Pulled to Refresh")
        //Do something here
        self.cartStore.fetchOrdersWithoutRejected()
//        self.refreshControl?.endRefreshing()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear( animated)
        
        self.addObservers()
        self.cartStore.fetchOrdersWithoutRejected()
        
        
        if let code = self.cartStore.order_code {
            self.orderCodeLabel.text = "Order Code \(code)"
        }
        
    }
    
    func addObservers() {
        // KVO
        cartStore.addObserver(self, forKeyPath: "isFetching", options: .New, context: &myContext)
        AccountManager.sharedInstance.addObserver(self, forKeyPath: "authToken", options: .New, context: &myContext)
        
        // Notification
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cartUpdate:", name: ShoppingCartStore.notifications.cartUpdateNotificationIdentifier, object: nil)
    }
    
    func removeObservers() {
        cartStore.removeObserver(self, forKeyPath: "isFetching")
        AccountManager.sharedInstance.removeObserver(self, forKeyPath: "authToken")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func cartUpdate(noti: NSNotification) {
        
        dispatch_async(dispatch_get_main_queue(), {
            log.debug("Reloading Data")
            self.tableView.reloadData()
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        MBProgressHUD.hideAllHUDsForView(self.view, animated: false)
        self.removeObservers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &myContext {
            log.debug(keyPath)
            
            switch keyPath{
            case "order_code":
                if let code = self.cartStore.order_code {
                    self.tableView.reloadData()
                }
            case "currentOrder":
                self.tableView.reloadData()
            case "ordered":
                self.tableView.reloadData()
            case "authToken":
                self.navigationController?.popViewControllerAnimated(true)
            case "isFetching":
                log.debug("Observed cart isFetching(\(self.cartStore.isFetching))")
                if self.cartStore.isFetching {
//                    self.refreshControl?
                } else {
                    if let rc = self.refreshControl {
                        if rc.refreshing {
                            dispatch_async(dispatch_get_main_queue()){
                                rc.endRefreshing()
                            }
                        }
                    }
                    dispatch_async(dispatch_get_main_queue()){
                        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                    }
                }
            default:
                println("CartView: Unknown keyPath observed")
            }
            
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Int(cartStore.ordered.count) + 2 // order button + current order + past order
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        var nRow = 0
        
        if section == 0 {
            //Place Order Button
            nRow = 1
        } else if section == 1 {
            nRow = self.cartStore.getCurrentOrder().menuItems.count
        } else if section > 1 {
            
            let order = self.cartStore.ordered[orderIdxFromSection(section)]
            if let thisIsAnOrderForSure = order {
                nRow = thisIsAnOrderForSure.menuItems.count
            }
            
        } else {
            // no nothin, unsupported
            log.error("Unsupported section \(section)")
        }
        
        return nRow
    }
    
    func orderIdxFromSection( section: Int) -> Int {
        return self.cartStore.ordered.count - ( section-2 ) - 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier(placeOrderCell, forIndexPath: indexPath) as! UITableViewCell
        } else {

            var order: Order?
            if indexPath.section == 1 {
                //Setup Current Order
                cell = tableView.dequeueReusableCellWithIdentifier("UnorderedItemCell", forIndexPath: indexPath) as! UITableViewCell
                order = self.cartStore.getCurrentOrder()
            } else {
                //Setup for Past Orders
                cell = tableView.dequeueReusableCellWithIdentifier("OrderedItemCell", forIndexPath: indexPath) as! UITableViewCell
                
                var idx = orderIdxFromSection(indexPath.section)
                order = self.cartStore.ordered[idx]
                
            }
            
            // Set order if not nil
            if order != nil {
                let nameLabel = cell.viewWithTag(300) as! UILabel
                let priceLabel = cell.viewWithTag(301) as! UILabel
                
                nameLabel.text = order!.menuItems[indexPath.row].name
                priceLabel.text = "฿ \(order!.menuItems[indexPath.row].price)"
            } else {
                log.error("order is nil for \(indexPath)")
            }
            
            let color = 255 - indexPath.row * 5
            let comp = CGFloat( Float(color) / 255.0 )
            
            cell.backgroundColor = UIColor(red: comp, green: comp, blue: comp, alpha: 1.0)
        }
        return cell
    }

    @IBAction func removeButtonAction(sender: AnyObject) {
        
        if let clickedCell = sender.superview??.superview as? UITableViewCell {
            if let clickedPath = self.tableView.indexPathForCell(clickedCell) {
                cartStore.removeMenuFromCurrentOrder(clickedPath.row)
                self.tableView.reloadData()
            }
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            sendOrder()
        }
    }
    
    func sendOrder() {
        if self.cartStore.getCurrentOrder().menuItems.count > 0 {
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            self.cartStore.sendOrder() {
                (success: Bool, msg: String?) in
                dispatch_async(dispatch_get_main_queue()){
                    log.debug("Send order should've completed with success(\(success)) and msg(\(msg))")
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                    if !success {
                        var message = "Something went wrong."
                        if let unwrappedMsg = msg {
                            message = unwrappedMsg
                        }
                        Utilities.displayOKAlert("Error", msg: message, viewController: self)
                        
                    }
                }
            }
        }
    }
    
    func orderReadyNotification () {
        let contentView = NSBundle.mainBundle().loadNibNamed("OrderReadyNotificationView", owner: self, options: nil).first as! UIView
        
        let orderIDLabel = contentView.viewWithTag(300) as! UILabel
        orderIDLabel.text = "999"
        
        let popup = KLCPopup(contentView: contentView)
        popup.show()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 70.0
        } else {
            return 100.0
        }
    }
    
    // Mark: TableView Delegate
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section < 2 {
            return 0
        }
        return 50.0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: // do nothing should not display header here
            return nil
        case 1: // currentOrder - no order code yet
            return nil
        default: //should have order code
            var order = cartStore.ordered[section-2]
            if let code = order?.orderCode {
                return "Order Code \(code)"
            } else {
                return "Order Code Unknown"
            }
        }
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section < 2 { return nil }

        // Get order for this section
        var order = cartStore.ordered[section-2]
        if order == nil { return nil }
        
//        log.debug("Preparing view for headerInSection\(section)")
        
        let frame = self.view.frame
        
        // view
        var view = UIView(frame: CGRectMake(0, 0, frame.size.width, 100))
        
        if let status = order?.status {
            switch (status) {
            case ShoppingCartStore.orderStatus.accepted:
                view.backgroundColor = UIColor(red: 48.0/255.0, green: 186.0/255.0, blue: 27.0/255.0, alpha: 1.0)
            case ShoppingCartStore.orderStatus.ready:
                view.backgroundColor = UIColor(red: 245.0/255.0, green: 166.0/255.0, blue: 35.0/255.0, alpha: 1.0)
            case ShoppingCartStore.orderStatus.rejected:
                view.backgroundColor = UIColor(red: 208.0/255.0, green: 2.0/255.0, blue: 27.0/255.0, alpha: 1.0)
            default:
                view.backgroundColor = UIColor(red: 255.0/255.0, green: 72.0/255.0, blue: 72.0/255.0, alpha: 1.0)
            }
        }
        
        // Order code description
        var orderCodeDescriptionLabel = UILabel(frame: CGRectZero)
        orderCodeDescriptionLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
        orderCodeDescriptionLabel.font = UIFont.systemFontOfSize(18.0)
        orderCodeDescriptionLabel.text = "order code"

        
        // Order Code
        var orderCodeLabel = UILabel(frame: CGRectZero)
        orderCodeLabel.textColor = UIColor.whiteColor()
        orderCodeLabel.font = UIFont.systemFontOfSize(24)
        if let code = order?.orderCode {
            orderCodeLabel.text = code
        } else {
            orderCodeLabel.text = "Unknown"
        }

        // Status
        var statusLabel = UILabel(frame: CGRectZero)
        statusLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
        statusLabel.font = UIFont.systemFontOfSize(18.0)
        statusLabel.text = order?.status
        
        // Add Subviews
        view.addSubview(orderCodeDescriptionLabel)
        view.addSubview(orderCodeLabel)
        view.addSubview(statusLabel)
        
        orderCodeDescriptionLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        orderCodeLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        statusLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let views = [
            "superview": view,
            "ocd": orderCodeDescriptionLabel,
            "code": orderCodeLabel,
            "status": statusLabel
        ]
        
        var constH = NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[code]-10-[ocd]-(>=0)-[status]-20-|", options: .AlignAllCenterY, metrics: nil, views: views)
        view.addConstraints(constH)
        
        var constV = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[code]-|", options: .AlignAllCenterX, metrics: nil, views: views)
        view.addConstraints(constV)
        var constV2 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[ocd]-|", options: .AlignAllCenterX, metrics: nil, views: views)
        view.addConstraints(constV2)
        var constV3 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[status]-|", options: .AlignAllCenterX, metrics: nil, views: views)
        view.addConstraints(constV3)
        return view
    }

}
