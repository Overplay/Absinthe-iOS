//
//  NoAnimationSegue.swift
//  Belashi-iOS
//
//  Created by Noah on 8/2/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit

class NoAnimationSegue : UIStoryboardSegue {
    
    // This is for the hamburger menu. We want the views to segue instantly, we don't want to see a white screen pushing a new view
    // because it looks like the flow is all messed up. When you click on an item in the hamburger menu and segue, it shows up right away.
    override func perform() {
        self.sourceViewController.navigationController?.pushViewController(self.destinationViewController, animated: false)
    }
    
}
