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

class CartViewController: UITableViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let headerView = UIView(frame: CGRectMake(0, 0, self.view.bounds.width, 30.0 ))
        let orderCodeLabel = UILabel(frame: headerView.bounds) as UILabel
        orderCodeLabel.text = "Order Code 857"
        orderCodeLabel.backgroundColor = UIColor.blackColor()
        orderCodeLabel.textColor = UIColor.whiteColor()
        orderCodeLabel.tag = 500
        orderCodeLabel.textAlignment = NSTextAlignment.Center

        headerView.addSubview(orderCodeLabel)
        
        
        
        self.tableView.tableHeaderView = headerView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        var nRow = 0
        
        if section == 0 {
            //Place Order
            nRow = 1
        } else {
            nRow = 5
        }
        
        return nRow
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier(placeOrderCell, forIndexPath: indexPath) as UITableViewCell
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier(orderItemCell, forIndexPath: indexPath) as UITableViewCell
        }


        // Configure the cell...

        return cell
    }


    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            println("have to implement send order")
            
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
            let contentView = NSBundle.mainBundle().loadNibNamed("OrderReadyNotificationView", owner: self, options: nil).first as UIView
            
            let orderIDLabel = contentView.viewWithTag(300) as UILabel
            orderIDLabel.text = "999"
            
            let popup = KLCPopup(contentView: contentView)
            popup.show()
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 70.0
        } else {
            return 100.0
        }
    }
    
    
    
}
