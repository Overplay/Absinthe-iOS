//
//  LoginViewController.swift
//  Absinthe-iOS
//
//  Created by Mitchell Kahn on 9/20/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit

class LoginViewController: LoginBaseViewController {
    
    let segueId = "fromLoginToMainTabs"
    
    @IBOutlet var emailTextField: UITextField!    
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var emailGoodCheck: UIImageView!
    
    var emailOK = false;
    
    @IBAction func goPressed(sender: UIButton){
        loginWithSegue(emailTextField.text!, pwd: pwdTextField.text!, segueId: segueId)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIView.animate(duration: 0.35, delay: 0.65, options: .CurveEaseInOut) {
            self.emailLabel.alpha = 1
        }
        
        emailGoodCheck.alpha = 0

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func checkFields(notification: NSNotification) {
        super.checkFields(notification)
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
