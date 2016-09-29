//
//  LoginOrRegViewController.swift
//  Absinthe-iOS
//
//  Created by Mitchell Kahn on 9/20/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit

class LoginOrRegViewController: UIViewController {
    

    @IBOutlet var ogLogoView: UIImageView!
    @IBOutlet var createAccountButton: UIButton!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var loginWithFBButton: UIButton!
    @IBOutlet var logoToTop: NSLayoutConstraint!
    
    @IBAction func loginPressed(sender: UIButton) {
        
    }
    
    
    @IBAction func createAccountPressed(sender: UIButton) {
        
    }
    
    
    @IBAction func loginWithFBPressed(sender: UIButton) {
        
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check user authorization
        Asahi.sharedInstance.checkAuthorized().then {authorized -> Void in
            if authorized {
                self.performSegueWithIdentifier("fromLRToMainTabs", sender: nil)
            }
        }
        
        let logoRestPosition = logoToTop.constant
        logoToTop.constant = -200
        createAccountButton.alpha = 0
        loginWithFBButton.alpha = 0
        self.view.layoutIfNeeded()

        UIView.animateWithDuration(1.5, delay: 0, usingSpringWithDamping: 0.14, initialSpringVelocity: 3.0, options: .CurveLinear, animations: {
            self.logoToTop.constant = logoRestPosition
            self.view.layoutIfNeeded()
            }, completion: { _ in
                
                // Bring in buttons
                UIView.animateWithDuration(0.35, animations: { 
                    self.createAccountButton.alpha = 1
                    }, completion: { (_) in
                        UIView.animateWithDuration(0.35, animations: { 
                            self.loginWithFBButton.alpha = 1
                        })
                })
        })
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
