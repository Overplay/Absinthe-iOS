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
    
    // Stupid swift doesn't like to keep stupid elements in their stupid order
    // So let's do it manually with a dictionary!
    // tf = text field -- no autocapitalization or autocorrection
    // stf = secure text field -- hides characters
    // ntf = name text field -- capitalizes every word
    // bn = button -- user interaction enabled and color changed
    let elements = [
        "Log In": [
            "Email:tf",
            "Password:stf",
            "Log:bn"
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
    ]
    
    var elementTextFields = [String:UITextField]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView = self.view as! UITableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadTableView), name: "AsahiLoggedIn", object: nil)
    }
    
    func reloadTableView() {
        self.tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Array(elements.keys).count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements[Array(elements.keys)[section]]!.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(elements.keys)[section]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 {
            // This is either log in or log out
            if indexPath.row == LOG_IN_ROW_INDEX {
                if Asahi.sharedInstance.loggedIn {
                    log.info("Hit log out button")
                    logOut()
                }else {
                    log.info("Hit log in button")
                    logIn(elementTextFields["0Email:"]!.text!, password: elementTextFields["0Password:"]!.text!)
                }
            }
        }else if indexPath.section == 1 {
            if indexPath.row == REGISTER_ROW_INDEX {
                log.info("Hit register")
                register(elementTextFields["1Email:"]!.text!, password: elementTextFields["1Password:"]!.text!, confirmPassword: elementTextFields["1Confirm Password:"]!.text!, firstName: elementTextFields["1First Name:"]!.text!, lastName: elementTextFields["1Last Name:"]!.text!, phone: elementTextFields["1Phone:"]!.text!)
            }
        }
    }
    
    func widthOfString(str: String, forHeight: CGFloat, withFont: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.max, height: forHeight)
        let boundingBox = str.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: withFont], context: nil)
        return boundingBox.width
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AccountCell", forIndexPath: indexPath)
        cell.userInteractionEnabled = true
        
        var dict = elements[Array(elements.keys)[indexPath.section]]!
        
        let val = dict[indexPath.row] as String
        var labelText = val.componentsSeparatedByString(":")[0]
        let type = val.componentsSeparatedByString(":")[1]
        
        // Keep only one log in/out button
        if labelText == "Log" {
            labelText = String(format: "%@ %@", labelText, (Asahi.sharedInstance.loggedIn ? "Out" : "In"))
        }
        
        cell.textLabel?.text = labelText
        cell.textLabel?.textColor = .blackColor()
        
        if let existingTextField = cell.contentView.viewWithTag(TEXT_FIELD_TAG) {
            existingTextField.removeFromSuperview()
        }
        
        // If a text field at all
        if type.rangeOfString("tf") != nil {
            // Add colon to end of label
            cell.textLabel!.text = String(format: "%@:", cell.textLabel!.text!)
            let labelWidth = widthOfString(cell.textLabel!.text!, forHeight: cell.contentView.bounds.size.height, withFont: cell.textLabel!.font)
            // Set the width of the text field based on the label width + 40 pixels
            // - 15 pixels for spacing on the right side
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
        } else if type == "bn" {
            cell.userInteractionEnabled = true
            cell.textLabel?.textColor = UIColor(red: (14.0/255.0), green: (122.0/255.0), blue: (254.0/255.0), alpha: 1.0)
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
    
    func logOut() {
        
//        Asahi.sharedInstance.logout().then { loggedOut -> Void in
//
//            if loggedOut {
//                self.tableView.reloadData()
//            }else {
////                self.showAlertWithTitle("Error!", andMessage: response[2])
//            }
//            // For testing
//            
//            self.showAlertWithTitle("Message", andMessage: "Logged out")
//        }
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
