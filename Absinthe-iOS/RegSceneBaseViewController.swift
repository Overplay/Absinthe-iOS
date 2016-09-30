//
//  RegSceneBaseViewController.swift
//  Absinthe-iOS
//
//  Created by Mitchell Kahn on 9/21/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit

class RegSceneBaseViewController: UIViewController {
    
    @IBAction func onBack(sender: UIButton) {
        self.navigationController!.popViewControllerAnimated(true)
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
