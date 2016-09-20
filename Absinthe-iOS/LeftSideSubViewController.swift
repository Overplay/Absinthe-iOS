//
//  LeftSideSubViewController.swift
//  Belashi-iOS
//
//  Created by Noah on 8/9/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit
import MMDrawerController

class LeftSideSubViewController : UIViewController {
    
    func openLeftSideView() {
        log.info("Opening left side view")
        self.mm_drawerController.toggleDrawerSide(.Left, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Have to set top left button as drawer button to override back button
        // It's currently setup that these are all segues and there's one root view (navigation controller)
        // so you can easily switch between them all. You need this so it doesn't say back though.
        let leftDrawerButton = MMDrawerBarButtonItem(target: self, action: #selector(openLeftSideView))
        self.navigationItem.leftBarButtonItem = leftDrawerButton
    }
    
}
