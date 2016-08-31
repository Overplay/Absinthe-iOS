//
//  IntroViewController.swift
//  Belashi-iOS
//
//  Created by Noah on 8/1/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit
import EAIntroView

class IntroViewController : UIViewController {
    
    let pageCount = 2
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        let pages = NSMutableArray()
        for i in 1...pageCount {
            pages.addObject(EAIntroPage(customViewFromNibNamed: String(format: "IntroPage%d", i)))
        }
        
        let introView = EAIntroView(frame: self.view.bounds)
        
        introView.pages = pages as [AnyObject]
        introView.showInView(self.view)
        
        xcglog.info("Shown")
        
    }
    
}
