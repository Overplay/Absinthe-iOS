//
//  AccountViewController.swift
//  Belashi-iOS
//
//  Created by Noah on 8/1/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit
import PKHUD

struct SettingsOption {
    let label: String
    let image: String?
    
    init(label: String) {
        self.label = label
        self.image = nil
    }
    
    init(label: String, image: String) {
        self.label = label
        self.image = image
    }
}

class AccountViewController : LeftSideSubViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var tableView: UITableView!
    
    let options = [
        SettingsOption(label: "Invite Friends", image: "ic_card_giftcard_white_18pt"),
        SettingsOption(label: "Edit Account", image: "ic_perm_identity_white_18pt"),
        SettingsOption(label: "Add New Ourglass Device", image: "ic_queue_play_next_white_18pt"),
        SettingsOption(label: "Add/Manage Venues", image: "ic_add_location_white_18pt"),
        SettingsOption(label: "Log Out")]
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView = self.view as! UITableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch options[indexPath.row].label {
        case "Invite Friends":
            log.debug("Inviting friends...")
        case "Edit Account":
            self.performSegueWithIdentifier("fromAccountToEdit", sender: nil)
        case "Log Out":
            logout()
        default:
            break
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("settingsCell", forIndexPath: indexPath) as! SettingsCell
        
        cell.userInteractionEnabled = true
        
        cell.label.text = options[indexPath.row].label
        
        if let image = options[indexPath.row].image {
            cell.icon.image = UIImage(named: image)
        }
        
        return cell
    }
    
    func logout() {
        let alertController = UIAlertController(title: "Log out", message: "Are you sure you want to log out?", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "No", style: .Cancel) { (action) in
            
        }
        
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "Yes", style: .Default) { (action) in
            
            Asahi.sharedInstance.logout()
                .then{ response -> Void in
                    Settings.sharedInstance.userAsahiJWT = nil
                    HUD.flash(.LabeledSuccess(title: "Logged out!", subtitle: ""), delay: 1.0, completion: { (_) in
                        self.performSegueWithIdentifier("fromAccountToRegistration", sender: nil)
                    })
                }
                
                // TODO: is this how we should handle errors?
                .error{ err -> Void in
                    log.error("Error logging out")
                    Settings.sharedInstance.userAsahiJWT = nil
                    HUD.flash(.LabeledSuccess(title: "Logged out!", subtitle: ""), delay: 1.0, completion: { (_) in
                        self.performSegueWithIdentifier("fromAccountToRegistration", sender: nil)
                    })
            }
            
        }
        
        alertController.addAction(okAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
}
