//
//  AccountBaseViewController.swift
//  Absinthe-iOS
//
//  Created by Alyssa Torres on 10/18/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit

class AccountBaseViewController: UIViewController {
    
    @IBAction func onBack(sender: UIButton) {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
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
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: .Default) { (action) in
        }
        
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
