//
//  FirstViewController.swift
//  OurglassAppSwift
//
//  Created by Alyssa Torres on 3/1/16.
//  Copyright © 2016 App Delegates. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class OurglasserViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet var webView: UIWebView!
    @IBAction func disme(sender: UIButton) {
        self.timer.invalidate()
        self.hud.hide()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // Set in initialization
    var op: OPIE!
    // Use to tell it to refresh when we go back to it
    var chooseViewController: ChooseOurglasserViewController!
    var goToUrl = String()
    var navTitle = String()
    
    var timer = NSTimer() // check for device still alive
    var timeoutTimer = NSTimer() // check for web page slow load
    var interval = 10  // seconds
    var alamofireManager : Alamofire.Manager!
    var requestTimeout = 5  // seconds for device disappear
    var timeoutTime = 30 // seconds for web page timeout (slow load)
    var hud: PKHUD!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup HUD
        self.hud = PKHUD()
        self.hud.dimsBackground = true
        self.hud.userInteractionOnUnderlyingViewsEnabled = true
        self.hud.contentView = PKHUDProgressView()
        
        if self.respondsToSelector(Selector("automaticallyAdjustsScrollViewInsets")) {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        self.webView.delegate = self
        self.webView.scrollView.scrollEnabled = false
        self.webView.scrollView.bounces = false
        goToApps()
        
        self.navigationController?.topViewController?.title = self.navTitle
        
        // Configure request timeout
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.timeoutIntervalForResource = NSTimeInterval(self.requestTimeout)
        self.alamofireManager = Alamofire.Manager(configuration: config)
        
        startPageLoadTimeout()
    }
    
    func startPageLoadTimeout() {
        // Show HUD
        self.hud.show()
        
        if(self.timeoutTimer.valid) {
            self.timeoutTimer.invalidate()
        }
        // Wait 30 seconds for slow page load
        self.timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(self.timeoutTime), target: self, selector: #selector(webViewDidTimeOut), userInfo: nil, repeats: false)
    }
    
    func webViewDidTimeOut() {
        self.hud.hide()
        
        let alertController = UIAlertController(title: "Network Error", message: "There appears to be an issue communicating with the Ourglass device.", preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: {(alert:UIAlertAction!) in
            // If main controller
            if self.goToUrl.rangeOfString("/www/control/index.html") != nil {
                let opIndex = OPIEBeaconListener.sharedInstance.opies.indexOf({
                    $0.ipAddress == self.op.ipAddress
                })
                OPIEBeaconListener.sharedInstance.opies.removeAtIndex(opIndex!)
                NSNotificationCenter.defaultCenter().postNotificationName(Notifications.droppedOPIE, object: nil, userInfo: ["OPIE": self.op])
                self.chooseViewController.shouldFindAfterAppear = true
            }
            self.navigationController?.popViewControllerAnimated(true)
        }))
        alertController.addAction(UIAlertAction(title: "Try Again", style: .Default, handler: {(alert: UIAlertAction!) in
            self.goToApps()
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.hud.hide()
        if self.timeoutTimer.valid {
            self.timeoutTimer.invalidate()
        }
    }
    
    func goToApps() {
        self.startPageLoadTimeout()
        let url = NSURL(string: self.goToUrl)
        self.webView.loadRequest(NSURLRequest(URL: url!))
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        let requestUrlString = request.URL?.absoluteString
        
        // If is loading url that it is supposed to load in view controller initially, allow through
        // Use rangeOfString and not checking exact match because some app controllers have subpages with ui-router
        // i.e., index.html#/home instead of just index.html
        if requestUrlString?.rangeOfString(self.goToUrl) != nil {
            return true
        }
        
        // If is not main url, go to new controller
        self.performSegueWithIdentifier("toAppControl", sender: [requestUrlString!, self.navTitle])
        
        return false
        
    }
    
    // MARK: - Navigation
    
    override func viewWillDisappear(animated: Bool) {
        self.hud.hide()
        super.viewWillDisappear(animated)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toAppControl" && sender != nil {
            let ovc : OurglasserViewController = segue.destinationViewController as! OurglasserViewController
            var args = sender as! [String]
            ovc.goToUrl = args[0]
            ovc.navTitle = args[1]
            // Modify back button BEFORE pushing because the object actually belongs to previous/current view controller (self), not the one being currently shown/pushed (ovc)
            let backButton = UIBarButtonItem(title: "Control Panel", style: .Plain, target: nil, action: nil)
            self.navigationItem.backBarButtonItem = backButton
        }
    }
}
