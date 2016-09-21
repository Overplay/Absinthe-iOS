//
//  EnterPasswordViewController.swift
//  Absinthe-iOS
//
//  Created by Mitchell Kahn on 9/20/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit
import PKHUD

// A lot of this VCs functionality is in the Base VC
class EnterPasswordViewController: LoginBaseViewController {

    
    @IBAction func nextPressed(sender: UIButton) {
        
        HUD.show(.LabeledProgress(title: "Creating Account", subtitle: "Please Wait"))
        
        Asahi.sharedInstance.register(Settings.sharedInstance.userEmail!,
                                      password: pwdTextField.text!,
                                      user: [ "firstName": Settings.sharedInstance.userFirstName!,
                                            "lastName": Settings.sharedInstance.userLastName! ])
            .then{ response in
                HUD.flash(.LabeledSuccess(title: "All Set!", subtitle: "Welcome to Ourglass"), delay: 1.0, completion: { (_) in
                    log.debug("Do something!")
                })
            }
            .error{ err -> Void in
                // On the off chance an account already exists
                self.login()
        }
        
    }
    
    override func recoverFromLoginFailure() {
        super.recoverFromLoginFailure()
        recoverFromRegFailure()
    }
    
    func recoverFromRegFailure(){
        
        HUD.hide()
        
        let alertController = UIAlertController(title: "Uh Oh", message: "There was a problem registering. Do you already have an account with that email?", preferredStyle: .Alert)
        
        
        let cancelAction = UIAlertAction(title: "Try Again", style: .Cancel) { (action) in
            self.navigationController!.popToRootViewControllerAnimated(true)
        }
        
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    

    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
//        Settings.sharedInstance.userEmail = emailTextField.text
        
    }

}
