//
//  LoginOrRegViewController.swift
//  Absinthe-iOS
//
//  Created by Mitchell Kahn on 9/20/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit

class LoginOrRegViewController: RegSceneBaseViewController {
    

    @IBOutlet var ogLogoView: UIImageView!
    @IBOutlet var createAccountButton: UIButton!
    @IBOutlet var loginWithFBButton: UIButton!
    @IBOutlet var logoToTop: NSLayoutConstraint!
    
    @IBOutlet weak var welcomeToTop: NSLayoutConstraint!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var orLabel: UILabel!
    
    @IBAction func loginPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("fromLRToLogin", sender: nil)
    }
    
    @IBAction func signupPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("fromLRToEnterName", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Move the check for logged in somewhere else so reg scene doesn't flash
        
        // For now, log in using Settings, then check Auth status
        
        let welcomeRestPosition = welcomeToTop.constant
        self.welcomeToTop.constant = -200
        
        self.loginButton.alpha = 0
        self.signUpButton.alpha = 0
        self.orLabel.alpha = 0
        
        self.view.layoutIfNeeded()

        UIView.animateWithDuration(1.5, delay: 0, usingSpringWithDamping: 0.14, initialSpringVelocity: 3.0, options: .CurveLinear, animations: {
            self.welcomeToTop.constant = welcomeRestPosition
            self.view.layoutIfNeeded()
            }, completion: { _ in
                
                // Bring in buttons
                UIView.animateWithDuration(0.35, animations: { 
                    self.loginButton.alpha = 1
                    }, completion: { _ in
                        UIView.animateWithDuration(0.35, animations: {
                            self.orLabel.alpha = 1
                        }, completion: { _ in
                        UIView.animateWithDuration(0.35, animations: { 
                            self.signUpButton.alpha = 1
                        })
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
