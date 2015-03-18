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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let headerView = UIView(frame: CGRectMake(0, 0, self.view.bounds.width, 30.0 ))
        orderCodeLabel.frame = headerView.frame
        orderCodeLabel.text = ""
        orderCodeLabel.backgroundColor = UIColor.blackColor()
        orderCodeLabel.textColor = UIColor.whiteColor()
        orderCodeLabel.tag = 500
        orderCodeLabel.textAlignment = NSTextAlignment.Center

        headerView.addSubview(orderCodeLabel)
        self.tableView.tableHeaderView = headerView
        
        self.navigationItem.rightBarButtonItem = LogoutBarButtonItem()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear( animated)
        cartStore.addObserver(self, forKeyPath: "order_code", options: .New, context: &myContext)
        AccountManager.sharedInstance.addObserver(self, forKeyPath: "authToken", options: .New, context: &myContext)
        if let code = self.cartStore.order_code {
            self.orderCodeLabel.text = "Order Code \(code)"
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        cartStore.removeObserver(self, forKeyPath: "order_code")
        AccountManager.sharedInstance.removeObserver(self, forKeyPath: "authToken")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &myContext {
            switch keyPath{
            case "order_code":
                if let code = self.cartStore.order_code {
                    dispatch_async(dispatch_get_main_queue()){
                        if code != "" {
                            self.orderCodeLabel.text = "Order Code \(code)"
                        } else {
                            self.orderCodeLabel.text = ""
                        }
                    }
                }
            case "authToken":
                self.navigationController?.popViewControllerAnimated(true)
            default:
                println("CartView: Unknown keyPath observed")
            }
            
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        var nRow = 0
        
        if section == 0 {
            //Place Order
            nRow = 1
        } else if section == 1 {
            nRow = self.cartStore.ordered.count

        } else {
            nRow = self.cartStore.toOrder.count
        }
        
        return nRow
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier(placeOrderCell, forIndexPath: indexPath) as UITableViewCell
        } else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCellWithIdentifier("OrderedItemCell", forIndexPath: indexPath) as UITableViewCell
            
            let nameLabel = cell.viewWithTag(300) as UILabel
            let priceLabel = cell.viewWithTag(301) as UILabel
            
            let ordered = self.cartStore.ordered
                nameLabel.text = ordered[indexPath.row].name
                priceLabel.text = "$ \(ordered[indexPath.row].price)"
            
            
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("UnorderedItemCell", forIndexPath: indexPath) as UITableViewCell
            
            let nameLabel = cell.viewWithTag(300) as UILabel
            let priceLabel = cell.viewWithTag(301) as UILabel
            
            let toOrder = self.cartStore.toOrder
                nameLabel.text = toOrder[indexPath.row].name
                priceLabel.text = "$ \(toOrder[indexPath.row].price)"
            
        }

        return cell
    }

    @IBAction func removeButtonAction(sender: AnyObject) {
        
        if let clickedCell = sender.superview??.superview as? UITableViewCell {
            if let clickedPath = self.tableView.indexPathForCell(clickedCell) {
                cartStore.toOrder.removeAtIndex(clickedPath.row)
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
        if self.cartStore.toOrder.count > 0 {
            self.cartStore.sendOrder()
            self.tableView.reloadData()
        }
        
    }
    
    func orderReadyNotification () {
        let contentView = NSBundle.mainBundle().loadNibNamed("OrderReadyNotificationView", owner: self, options: nil).first as UIView
        
        let orderIDLabel = contentView.viewWithTag(300) as UILabel
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
    
    
    
}
