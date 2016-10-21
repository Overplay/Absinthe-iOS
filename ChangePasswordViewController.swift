//
//  ChangePasswordViewController.swift
//  Absinthe-iOS
//
//  Created by Alyssa Torres on 10/17/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit
import PKHUD

class ChangePasswordViewController: AccountBaseViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var repeatNewPassword: UITextField!
   
    @IBOutlet weak var emailCheck: UIImageView!
    @IBOutlet weak var passwordCheck: UIImageView!
    @IBOutlet weak var newPasswordCheck: UIImageView!
    @IBOutlet weak var repeatNewPasswordCheck: UIImageView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBAction func goBack(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func saveNewPassword(sender: AnyObject) {
        
        if checkInputs() && checkRepeatPassword() {
            let alertController = UIAlertController(title: "Change Password", message: "Are you sure you want to change your password?", preferredStyle: .Alert)
        
            let cancelAction = UIAlertAction(title: "No", style: .Cancel) { (action) in }
        
            alertController.addAction(cancelAction)
        
            // TODO: change password with call to Asahi and store new info in Settings
            let okAction = UIAlertAction(title: "Yes", style: .Default) { (action) in }
        
            alertController.addAction(okAction)
        
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        else if !checkRepeatPassword() {
            let alertController = UIAlertController(title: "New Password", message: "Your passwords do not match.", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            }
            
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        else {
            let alertController = UIAlertController(title: "Oops!", message: "The information you provided is not valid.", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            }
            
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        // TODO: check that given password matches account?
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.emailCheck.alpha = 0
        self.passwordCheck.alpha = 0
        self.newPasswordCheck.alpha = 0
        self.repeatNewPasswordCheck.alpha = 0
        self.saveButton.alpha = 0
        
        
        self.email.text = Settings.sharedInstance.userEmail
        
        checkInputs()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(checkInputs), name: UITextFieldTextDidChangeNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkInputs() -> Bool {
        let emailValid = checkEmail()
        let currentPasswordValid = checkPassword(self.currentPassword, checkImage: self.passwordCheck)
        let newPasswordValid = checkPassword(self.newPassword, checkImage: self.newPasswordCheck)
        let repeatPasswordValid = checkRepeatPassword()
        
        if emailValid && currentPasswordValid && newPasswordValid && repeatPasswordValid {
            fadeIn(self.saveButton)
            return true
        }
        
        else {
            fadeOut(self.saveButton)
            return false
        }
    }
    
    func checkEmail() -> Bool {
        if let email = self.email.text {
            
            if email.isValidEmail() && self.emailCheck.alpha == 0 {
                fadeIn(self.emailCheck)
                return true
            }
            
            if !email.isValidEmail() {
                fadeOut(self.emailCheck)
                return false
            }
            
            else {
                return true
            }
        }
        
        return false
    }
    
    func checkPassword(textField: UITextField, checkImage: UIImageView) -> Bool {
        if let pwd = textField.text {
            
            if pwd.isValidPwd() && checkImage.alpha == 0 {
                fadeIn(checkImage)
                return true
            }
            
            if !pwd.isValidPwd() {
                fadeOut(checkImage)
                return false
            }
            
            else {
                return true
            }
        }
        
        return false
    }
    
    func checkRepeatPassword() -> Bool {
        if let pwd = self.newPassword.text {
            if let rpwd = self.repeatNewPassword.text {
                
                if !pwd.isValidPwd() || pwd != rpwd {
                    fadeOut(self.repeatNewPasswordCheck)
                    return false
                }
            
                else {
                    fadeIn(self.repeatNewPasswordCheck)
                    return true
                }
            }
        }
        return false
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
