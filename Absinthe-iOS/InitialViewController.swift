//
//  InitialTabBarViewController.swift
//  Belashi-iOS
//
//  Created by Noah on 8/1/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit
import EAIntroView
import MMDrawerController

class InitialViewController : UIViewController {
    
    // We can't exactly list the files because these are all compiled, but we can do it at compile time, yay!
    // Take the number of IntroPages we want, and use this number to loop through them, all titled "IntroPage"
    // with a number afterwards (STARTING WITH 1, ALL THE WAY UP TO INCLUDING THIS NUMBER).
    // You can find these .xibs in the Intro folder, just create as many as you want, name them according to
    // the pattern, and up this variable right here
    // i.e., If this is 3, it will use IntroPage1.xib, IntroPage2.xib, and IntroPage3.xib
    let PAGE_COUNT = 2
    
    var introView: EAIntroView!
    
    // Means are we gonna show the intro this application run, not is currently showing
    var isShowingIntro = false
    
    override func loadView() {
        super.loadView()
        
        // REMOVE 'FALSE' WHEN TESTING INTRO BUT ITS ANNOYING EVERYTIME
        if     false &&       !NSUserDefaults.standardUserDefaults().boolForKey("NotFirstLaunch") {
            
            log.info("Showing intro")
            // Set bool true so it doesn't run again
            // UNCOMMENT THIS WHEN NOT TESTING OR ELSE IT WILL SHOW EVERYTIME AND THATS BAD
//            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "NotFirstLaunch")
//            NSUserDefaults.standardUserDefaults().synchronize()
            
            // Show intro
            
            isShowingIntro = true
            
            let pages = NSMutableArray()
            for i in 1...PAGE_COUNT {
                pages.addObject(EAIntroPage(customViewFromNibNamed: String(format: "IntroPage%d", i)))
            }
            
            introView = EAIntroView(frame: CGRectMake(0, 0, self.navigationController!.view.frame.width, self.navigationController!.view.frame.height), andPages: pages as [AnyObject])
            
            // Setting static title view. You can change this but you have to reflect the open space in the IntroPages.
            // If you look in those xib files, you'll see there's room left for this intro view on top.
            let titleImageView = UIImageView(image: UIImage(named: "OPLogo"))
            titleImageView.contentScaleFactor = 1.25
            introView.titleView = titleImageView
            introView.titleViewY = 90
            
            // Show over main window being shown currently I'm actually not sure if Apple allows
            let window = UIApplication.sharedApplication().keyWindow
            introView.showInView(window)
            
            log.info("Shown")
            
        }
        
        // WHATEVER THIS SEGUE IS WILL BE THE DEFAULT VIEW
        self.performSegueWithIdentifier("toControl", sender: self)
//        self.performSegueWithIdentifier("toAccount", sender: self)
//        self.performSegueWithIdentifier("toMap", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toControl" {
            // If clicked on in hamburger menu, start finding when it appears
            if sender!.isKindOfClass(LeftSideMenuTableViewController) {
                (segue.destinationViewController as! ChooseOurglasserViewController).shouldFindAfterAppear = true
            // If seguing from another class (THIS ONE), set as delegate so it knows when to start finding (gets callback and starts when intro is dismissed)
            }else {
                // Only set as delegate if is being shown so we don't crash, for obvious reasons
                if isShowingIntro {
                    isShowingIntro = false
                    introView.delegate = segue.destinationViewController as! ChooseOurglasserViewController
                }else {
                    (segue.destinationViewController as! ChooseOurglasserViewController).shouldFindAfterAppear = true
                }
            }
        }
    }
    
}
