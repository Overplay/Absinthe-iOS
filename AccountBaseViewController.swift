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
    
}
