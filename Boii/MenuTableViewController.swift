//
//  MenuTableViewController.swift
//  Boii
//
//  Created by Harin Sanghirun on 15/1/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {
    
    var menus: [Menu]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

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

        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let numberOfRows = menus?.count {
            return numberOfRows
        } else {
            return 0
        }
    }


    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell
        
        if cell == nil {
            
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        }
        
        if let m:[Menu] = menus{
            cell!.textLabel?.text = "\(m[ indexPath.row ].name) \(m[indexPath.row].price)"
        }
        
        return cell!
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let m = menus?[indexPath.row]
        
        if m != nil {
            sendOrderToServer(m!);
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    
    
    func sendOrderToServer(m:Menu) {
        var request = NSMutableURLRequest(URL: NSURL(string:"http://localhost:3000/api/orders")!)
        
        //get data ready
        request.HTTPMethod = "POST"
        let data = "{\"name\":\"\(m.name)\",\"quantity\":1}"
        request.HTTPBody = data.dataUsingEncoding(NSUTF8StringEncoding)
        
        
        var session = NSURLSession.sharedSession()
        var task = session.dataTaskWithRequest(request){
            (data, response, error) -> Void in
            if error != nil {
                println("error=\(error)")
            }
            
            println("response = \(response)")
            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("responseString = \(responseString)")
            println("request= \(NSString(data: request.HTTPBody!, encoding: NSUTF8StringEncoding))")
        }
        
        task.resume()
        
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

    
//    @IBAction func updateMenuAction(sender: AnyObject) {
//        println("update pressed")
//        var request = NSMutableURLRequest(URL: NSURL(string:"http://localhost:3000/api/menus")!)
//        var session = NSURLSession.sharedSession()
//        var task = session.dataTaskWithRequest(request){
//            (data, response, error) -> Void in
//            if error != nil {
//                println(error)
//            } else {
//                self.resultBuffer = NSString(data: data, encoding: NSASCIIStringEncoding)!
//                println(self.resultBuffer!)
//                println(NSThread.mainThread())
//                
//                dispatch_async(dispatch_get_main_queue(), {
//                    println(NSThread.mainThread())
//                })
//            }
//        }
//        
//        task.resume()
//        
//    }
}
