//
//  EnterPasswordViewController.swift
//  Absinthe-iOS
//
//  Created by Mitchell Kahn on 9/20/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit

class EnterPasswordViewController: UIViewController {

    @IBOutlet var pwdLabel: UILabel!
    
    @IBOutlet var pwdTextField: UITextField!
    
    @IBOutlet var pwdGoodCheck: UIImageView!
    
    @IBOutlet var nextButton: UIButton!
    
    
    var pwdOK = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        pwdLabel.alpha = 0
        nextButton.alpha = 0
        
        pwdGoodCheck.alpha = 0
        
        UIView.animateWithDuration(0.65, animations: {
            self.pwdLabel.alpha = 1
        })
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(checkPwd), name: UITextFieldTextDidChangeNotification, object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITextField Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        log.debug("Delegate: should return")
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        log.debug("Delegate: did end editing")
        //checkNames()
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        return true
    }
    
    func fadeIn(view: UIView){
        UIView.animateWithDuration(0.35) {
            view.alpha = 1
        }
    }
    
    func fadeOut(view: UIView){
        UIView.animateWithDuration(0.35) {
            view.alpha = 0
        }
    }
    
    
    func checkPwd(notification: NSNotification){
        
//        if let pwd = pwdTextField.text {
//            
//            if email.isValidEmail() && emailGoodCheck.alpha == 0 {
//                fadeIn(emailGoodCheck)
//                fadeIn(nextButton)
//                emailOK = true
//            }
//            
//            if !email.isValidEmail() {
//                fadeOut(emailGoodCheck)
//                fadeOut(nextButton)
//                emailOK = false
//                
//            }
//        }
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
//        Settings.sharedInstance.userEmail = emailTextField.text
        
    }

}
