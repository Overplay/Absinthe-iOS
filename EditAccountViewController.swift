//
//  EditAccountViewController.swift
//  Absinthe-iOS
//
//  Created by Alyssa Torres on 10/14/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit
import SwiftyJSON
import PKHUD

class EditAccountViewController: AccountBaseViewController {

    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var emailGoodCheck: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBAction func closeEditAccount(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func save(sender: AnyObject) {
        
        guard let first = self.firstName.text
            else {
                showAlert("Oops!", message: "The information you put in is not valid.")
                return
        }
        
        guard let last = self.lastName.text
            else {
                showAlert("Oops!", message: "The information you put in is not valid.")
                return
        }
        
        guard let email = self.email.text
            else {
                showAlert("Oops!", message: "The information you put in is not valid.")
                return
        }
        
        let alertController = UIAlertController(title: "Save Changes", message: "Are you sure you want to save changes to your account information?", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "No", style: .Cancel) { (action) in }
        
        alertController.addAction(cancelAction)
        
        // TODO: change account information with call to Asahi and store new info in Settings
        let okAction = UIAlertAction(title: "Yes", style: .Default) { (action) in
            
            HUD.show(.Progress)
            
            if let uid = Settings.sharedInstance.userId {
                Asahi.sharedInstance.changeAccountInfo(first, lastName: last, email: email, userId: uid)
            
                    .then{ response -> Void in
                        Settings.sharedInstance.userEmail = email
                        Settings.sharedInstance.userFirstName = first
                        Settings.sharedInstance.userLastName = last
                        
                        HUD.flash(.Success, delay:0.7)
                    }
                
                    .error{ err -> Void in
                        HUD.hide()
                        self.showAlert("Unable to change account info", message: "")
                    }
            } else {
                HUD.hide()
                self.showAlert("Unable to change account info", message: "")
            }
        }
        
        alertController.addAction(okAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailGoodCheck.alpha = 0
        self.saveButton.alpha = 0

        self.firstName.text = Settings.sharedInstance.userFirstName
        self.lastName.text = Settings.sharedInstance.userLastName
        self.email.text = Settings.sharedInstance.userEmail
        checkEmail()
        
        Asahi.sharedInstance.checkAuthStatus()
            
            .then{ response -> Void in
                log.debug("Successfully checked auth")
                if let first = response["firstName"].string {
                    Settings.sharedInstance.userFirstName = first
                    self.firstName.text = first
                }
                
                if let last = response["lastName"].string {
                    Settings.sharedInstance.userLastName = last
                    self.lastName.text = last
                }
                
                if let email = response["auth"]["email"].string {
                    Settings.sharedInstance.userEmail = email
                    self.email.text = email
                    self.checkEmail()
                }
                
                if let userId = response["id"].string {
                    Settings.sharedInstance.userId = userId
                }
            }
            
            // TODO: how do we want to handle this error?
            .error{ err -> Void in
                log.error("Error checking auth")
                print(err)
                
                let alertController = UIAlertController(title: "Error loading account information", message: "There was an issue loading your account information.", preferredStyle: .Alert)
                
                let okAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                }
                
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(checkEmail), name: UITextFieldTextDidChangeNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkEmail() {
        
        if let email = self.email.text {
            
            if email.isValidEmail() && self.emailGoodCheck.alpha == 0 {
                fadeIn(self.emailGoodCheck)
                fadeIn(self.saveButton)
            }
            
            if !email.isValidEmail() {
                fadeOut(self.emailGoodCheck)
                fadeOut(self.saveButton)
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
