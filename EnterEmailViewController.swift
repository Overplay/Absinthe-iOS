//
//  EnterEmailViewController.swift
//  Absinthe-iOS
//
//  Created by Mitchell Kahn on 9/20/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit

class EnterEmailViewController: RegSceneBaseViewController {

    @IBOutlet var emailLabel: UILabel!
    
    @IBOutlet var emailTextField: UITextField!
    
    @IBOutlet var emailGoodCheck: UIImageView!
    
    @IBOutlet var nextButton: UIButton!
    
    
    var emailOK = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        emailLabel.alpha = 0
        nextButton.alpha = 0
        
        emailGoodCheck.alpha = 0
        
        UIView.animateWithDuration(0.65, animations: {
            self.emailLabel.alpha = 1
        })
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(checkEmail), name: UITextFieldTextDidChangeNotification, object: nil)
        
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
    
    
    func checkEmail(notification: NSNotification){
        
        if let email = emailTextField.text {
            
            if email.isValidEmail() && emailGoodCheck.alpha == 0 {
                fadeIn(emailGoodCheck)
                fadeIn(nextButton)
                emailOK = true
            }
            
            if !email.isValidEmail() {
                fadeOut(emailGoodCheck)
                fadeOut(nextButton)
                emailOK = false
                
            }
        }
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        Settings.sharedInstance.userEmail = emailTextField.text
        
    }
}
