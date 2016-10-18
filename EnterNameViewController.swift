//
//  EnterNameViewController.swift
//  Absinthe-iOS
//
//  Created by Mitchell Kahn on 9/20/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit

class EnterNameViewController: RegSceneBaseViewController, UITextFieldDelegate {
    
    
    @IBOutlet var fnameLabel: UILabel!
    @IBOutlet var lnameLabel: UILabel!
    
    @IBOutlet var fnameTextField: UITextField!
    @IBOutlet var lnameTextField: UITextField!
    
    @IBOutlet var fnameGoodCheck: UIImageView!
    @IBOutlet var lnameGoodCheck: UIImageView!
    
    @IBOutlet var nextButton: UIButton!
    
    
    var fnameOK = false
    var lnameOK = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        fnameLabel.alpha = 0
        lnameLabel.alpha = 0
        nextButton.alpha = 0
        
        fnameGoodCheck.alpha = 0
        lnameGoodCheck.alpha = 0
        
        UIView.animateWithDuration(0.65, animations: {
            self.fnameLabel.alpha = 1
            }) { _ in
                UIView.animateWithDuration(0.35, animations: {
                    self.lnameLabel.alpha = 1
                })
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(checkNames), name: UITextFieldTextDidChangeNotification, object: nil)
        
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
    
    
    func checkNames(notification: NSNotification){
        
        if let firstName = fnameTextField.text {
            
            if !firstName.isEmpty && fnameGoodCheck.alpha == 0 {
                fadeIn(fnameGoodCheck)
                fnameOK = true
            }
            
            if firstName.isEmpty {
                fadeOut(fnameGoodCheck)
                fnameOK = false

            }
        }
        
        if let lastName = lnameTextField.text {
            
            if !lastName.isEmpty && lnameGoodCheck.alpha == 0 {
                fadeIn(lnameGoodCheck)
                lnameOK = true
            }
            
            if lastName.isEmpty {
                fadeOut(lnameGoodCheck)
                lnameOK = false
            }

        }

        if lnameOK && fnameOK {
            fadeIn(nextButton)
        } else {
            fadeOut(nextButton)
        }
        
        
        
    }

   
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        Settings.sharedInstance.userFirstName = fnameTextField.text
        Settings.sharedInstance.userLastName = lnameTextField.text
    }
    
    

}
