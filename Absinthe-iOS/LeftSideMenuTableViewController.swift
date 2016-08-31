//
//  LeftSideMenuTableViewController.swift
//  Belashi-iOS
//
//  Created by Noah on 8/2/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit

class LeftSideMenuTableViewController : UITableViewController {
    
    // Give all segues an identifier of 'toItem' (i.e., toAccount)
    let items = [
        "Control",
        "Map",
        "Account"
    ]
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Shove it 20 pixels down because that's the height of the status bar and we don't want our cells behind/above that
        self.tableView.frame = CGRectMake(0.0, 20.0, self.tableView.frame.size.width, self.tableView.frame.size.height - 20.0)
        self.tableView.superview?.backgroundColor = .whiteColor()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        // Switch to new view controller
        let initialViewController = (self.mm_drawerController.centerViewController as! UINavigationController).viewControllers[0]
        initialViewController.performSegueWithIdentifier(String(format: "to%@", items[indexPath.row]), sender: self)
        // Hide left drawer
        self.mm_drawerController.toggleDrawerSide(.Left, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("LeftSideMenuCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = items[indexPath.row]
        
        return cell
        
    }
    
}
