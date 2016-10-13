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
        
        switch elements[indexPath.row] {
        case "Invite Friends:btn":
            print("Inviting friends")
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
            self.performSegueWithIdentifier("fromAccountToRegistration", sender: nil)
        }
        
        alertController.addAction(okAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)

    }
    
    func widthOfString(str: String, forHeight: CGFloat, withFont: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.max, height: forHeight)
        let boundingBox = str.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: withFont], context: nil)
        return boundingBox.width
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("settingsCell", forIndexPath: indexPath) as! SettingsCell
        cell.userInteractionEnabled = true
        
        let val = elements[indexPath.row] as String
        let labelText = val.componentsSeparatedByString(":")[0]
        //let type = val.componentsSeparatedByString(":")[1]
        
        /*cell.textLabel?.text = labelText
        cell.backgroundColor = UIColor(white: 51/255, alpha: 1.0)
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.textColor = UIColor( white: 1.0, alpha: 0.7)
        cell.textLabel?.font = UIFont(name: Style.regularFont, size: 20.0)*/
        
        cell.label.text = labelText
        
        cell.icon.image = UIImage(named: "AppIcon")
        
        // TODO: what does this do?
        /*if let existingTextField = cell.contentView.viewWithTag(TEXT_FIELD_TAG) {
            existingTextField.removeFromSuperview()
        }
        
        if type.rangeOfString("tf") != nil {
            cell.textLabel!.text = String(format: "%@:", cell.textLabel!.text!)
            
            let labelWidth = widthOfString(cell.textLabel!.text!, forHeight: cell.contentView.bounds.size.height, withFont: cell.textLabel!.font)
            
            let textField = UITextField(frame: CGRectMake(labelWidth + 40, 0, cell.contentView.bounds.size.width - labelWidth - 40 - 15, cell.contentView.bounds.size.height))
            
            textField.tag = TEXT_FIELD_TAG
            textField.adjustsFontSizeToFitWidth = true
            textField.returnKeyType = .Done
            textField.delegate = self
            textField.autocorrectionType = .No
            textField.autocapitalizationType = .None
            textField.secureTextEntry = false
            textField.textColor = .blackColor()
            
            if indexPath.section == 0 {
                textField.enabled = !Asahi.sharedInstance.loggedIn
                cell.userInteractionEnabled = textField.enabled
                if labelText == "Email" {
                    if !textField.enabled {
                        textField.text = Asahi.sharedInstance.currentEmail
                        textField.textColor = .grayColor()
                    }else {
                        textField.text = (lastEmail != "" ? lastEmail : Asahi.sharedInstance.currentEmail)
                    }
                }
            }else {
                textField.enabled = true
                cell.userInteractionEnabled = true
            }
            // Different types of text field
            switch(type) {
                case "stf":
                    textField.secureTextEntry = true
                    break
                case "ntf":
                    textField.autocapitalizationType = .Words
                    break
                default:
                    break
            }
            cell.contentView.addSubview(textField)
            // Add pointers to an array so we can easily grab the text later. Combination of section index + label (for two similarly named text fields, i.e. Email)
            elementTextFields[String(indexPath.section).stringByAppendingString(cell.textLabel!.text!)] = textField
        } else if type == "btn" {
            cell.userInteractionEnabled = true
        }*/
        
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
