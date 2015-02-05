//
//  ViewController.swift
//  Boii
//
//  Created by Harin Sanghirun on 12/1/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import UIKit
import Foundation


class ViewController: UIViewController {
    
    var resultBuffer: String?
    var JSONBuffer: JSON?
    var menus: [Menu]?

    @IBOutlet weak var menuTextView: UITextView!
    @IBOutlet weak var updateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        updateMenuAction(self);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func updateMenuAction(sender: AnyObject) {
        println("update pressed")
        var request = NSMutableURLRequest(URL: NSURL(string:"http://localhost:3000/api/menus")!)
        var session = NSURLSession.sharedSession()
        var task = session.dataTaskWithRequest(request){
            (data, response, error) -> Void in
            if error != nil {
                println(error)
            } else {
                self.resultBuffer = NSString(data: data, encoding: NSASCIIStringEncoding)
                self.JSONBuffer = JSON(data: data)
                println(self.JSONBuffer!)
                self.parseMenuJson(self.JSONBuffer)
                
                
                
                dispatch_async(dispatch_get_main_queue(), {
                    println(NSThread.mainThread())
                    self.refreshTextView()
                })
            }
        }
        
        task.resume()
        
    }
    
    func parseMenuJson(var jsonData:JSON?){
        
        menus = []
        if let json = jsonData {
            for (index: String, menu: JSON) in json {
                //Do something you want
                var name = menu["name"].string
                var price = menu["price"].double
                
                if name == nil {
                    name = "unnamed"
                }
                
                if price == nil {
                    price = -1
                }
                
                var newMenu = Menu(name: name!, price: Float(price!)) //found nil when unwrapping an Optional value (price)
                menus?.append(newMenu)
                
            }
            
            println(menus)
        }
    }
    
    func refreshTextView() {
        menuTextView.text = resultBuffer?
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMenuTable" {
            var dest = segue.destinationViewController as MenuTableViewController;
                dest.menus = self.menus
        }
    }
}



