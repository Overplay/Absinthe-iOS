//
//  LoginBaseViewController.swift
//  Absinthe-iOS
//
//  Created by Mitchell Kahn on 9/21/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit
import PKHUD

class LoginBaseViewController: RegSceneBaseViewController {
    
    @IBOutlet var pwdLabel: UILabel!
    @IBOutlet var pwdTextField: UITextField!
    @IBOutlet var pwdGoodCheck: UIImageView!
    @IBOutlet var nextButton: UIButton!
    
    var pwdOK = false
    var password: String?

    
    @IBAction func showPwdPressed(sender: UIButton) {
        
        pwdTextField.secureTextEntry = !pwdTextField.secureTextEntry
        
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        pwdLabel.alpha = 0
        nextButton.alpha = 0
        
        pwdGoodCheck.alpha = 0
        
        UIView.animateWithDuration(0.65, animations: {
            self.pwdLabel.alpha = 1
        })
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(checkFields), name: UITextFieldTextDidChangeNotification, object: nil)

    }
    

    func checkFields(notification: NSNotification){
        
        if let pwd = pwdTextField.text {
            
            if pwd.isValidPwd() && pwdGoodCheck.alpha == 0 {
                fadeIn(pwdGoodCheck)
                fadeIn(nextButton)
                pwdOK = true
                password = pwd
            }
            
            if !pwd.isValidPwd() {
                fadeOut(pwdGoodCheck)
                fadeOut(nextButton)
                pwdOK = false
                password = nil
            }
        }
        
    }
    
    func login(email: String, pwd: String){
        
        Asahi.sharedInstance.login(email, password: pwd)
            .then{ response -> Void in
                HUD.flash(.LabeledSuccess(title: "Logged In!", subtitle: nil ))
                log.debug("OK, let's do this!")
                self.handleLogin()
            }
            .error{ err in
                self.recoverFromLoginFailure()
                
        }
        
    }
    
    // This is normally handled in the child class
    func recoverFromLoginFailure(){
        log.debug("Login failed")
    }
    
    
    func handleLogin(){
        log.debug("Heading to main UI...")
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
