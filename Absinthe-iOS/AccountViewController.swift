//
//  AccountViewController.swift
//  Belashi-iOS
//
//  Created by Noah on 8/1/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit
import MMDrawerController

class AccountViewController : LeftSideSubViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    let LOG_IN_ROW_INDEX = 2
    let REGISTER_ROW_INDEX = 6
    
    let TEXT_FIELD_TAG = 1
    
    var lastEmail = String()
    
    var tableView: UITableView!
    
    // tf = text field -- no autocapitalization or autocorrection
    // stf = secure text field -- hides characters
    // ntf = name text field -- capitalizes every word
    // bn = button -- user interaction enabled and color changed
    /*let elements = [
        "Log In": [
            "Email:tf",
            "Password:stf",
            "Log Out:bn"
        ],
        "Register": [
            "First Name:ntf",
            "Last Name:ntf",
            "Phone:tf",
            "Email:tf",
            "Password:stf",
            "Confirm Password:stf",
            "Register:bn"
        ]
    ]*/
    
    let elements = ["Invite Friends:btn", "Edit Account:btn", "Add New Ourglass Device:btn", "Add/Manage Venues:btn", "Log Out:btn"]
    
    var elementTextFields = [String:UITextField]()
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView = self.view as! UITableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // not necessary?
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadTableView), name: "AsahiLoggedIn", object: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // TODO: clean this
        switch elements[indexPath.row] {
        case "Invite Friends:btn":
            print("Inviting friends")
        case "Edit Account:btn":
            self.performSegueWithIdentifier("fromAccountToEdit", sender: nil)
        case "Log Out:btn":
            logout()
        default:
            print("Other setting")
        }
    }
    
    func logout() {
        let alertController = UIAlertController(title: "Log out", message: "Are you sure you want to log out?", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "No", style: .Cancel) { (action) in
            
        }
        
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "Yes", style: .Default) { (action) in
            Settings.sharedInstance.userAsahiJWT = nil
            self.performSegueWithIdentifier("fromAccountToRegistration", sender: nil)
        }
        
        alertController.addAction(okAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("settingsCell", forIndexPath: indexPath) as! SettingsCell
        cell.userInteractionEnabled = true
        
        let val = elements[indexPath.row] as String
        let labelText = val.componentsSeparatedByString(":")[0]
        
        cell.label.text = labelText
        
        switch labelText {
        case "Invite Friends":
            cell.icon.image = UIImage(named: "ic_card_giftcard_white_18pt")
        case "Edit Account":
            cell.icon.image = UIImage(named: "ic_perm_identity_white_18pt")
        case "Add New Ourglass Device":
            cell.icon.image = UIImage(named: "ic_queue_play_next_white_18pt")
        case "Add/Manage Venues":
            cell.icon.image = UIImage(named: "ic_add_location_white_18pt")
        default:
            break
        }
        
        return cell
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // If auto logged in, stick email in text field
        if Asahi.sharedInstance.loggedIn && Asahi.sharedInstance.currentEmail != "" {
            self.lastEmail = Asahi.sharedInstance.currentEmail!
        }
    }
    
    func logIn(email: String, password: String) {
        self.lastEmail = email
        Asahi.sharedInstance.login(email, password: password).then { response -> Void in
            
                self.tableView.reloadData()
        }
    }
    
    
    func register(email: String, password: String, confirmPassword: String, firstName: String, lastName: String, phone: String) {
        self.lastEmail = email
        if password == confirmPassword {
            Asahi.sharedInstance.register(
                email,
                password: password,
                user: [
                    "firstName": firstName,
                    "lastName": lastName,
                    "mobilePhone": phone
                ]).then { response -> Void in
                    log.info(response.description)
                    if(response[1] == "true") {
                        self.tableView.reloadData()
                    }else {
//                        self.showAlertWithTitle("Error!", andMessage: response[2])
                    }
                    // For testing
                    //self.showAlertWithTitle("Message", andMessage: response[2])
            }
        }
    }

    func showAlertWithTitle(title: String, andMessage: String) {
        let message = andMessage.stringByReplacingOccurrencesOfString("\\n", withString: "\n")
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okButtonAction = UIAlertAction(title: "Ok", style: .Default) { (action) in
            log.info("Pressed ok")
        }
        alertController.addAction(okButtonAction)
        self.presentViewController(alertController, animated: true) {}
    }
    
}
