//
//  ViewController.swift
//  OurglassAppSwift
//
//  Created by Alyssa Torres on 3/1/16.
//  Copyright © 2016 App Delegates. All rights reserved.
//

import UIKit
import PKHUD
import PromiseKit

class ChooseOurglasserViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
 
    @IBOutlet var mainStatusLabel: UILabel!
    @IBOutlet var ourglasserCollection : UICollectionView!
    
    let SEARCHING_TIMEOUT_INTERVAL = 30.0
    
    // TODO this will be replaced with a call into Settings eventually. 
    let isDevelopment = Settings.sharedInstance.isDevelopmentMode
    
    let nc = NSNotificationCenter.defaultCenter()
    var refreshControl : UIRefreshControl!
    var refreshing = true
    
    var availableOPIEs = [OPIE]()
    var iphoneIPAddress = String()
    
    var shouldFindAfterAppear = true
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register for OPIE notifications
        nc.addObserver(self, selector: #selector(newOPIE), name: ASNotification.newOPIE.rawValue, object: nil)
        nc.addObserver(self, selector: #selector(OPIESocketError), name: ASNotification.OPIESocketError.rawValue, object: nil)
        nc.addObserver(self, selector: #selector(droppedOPIE), name: ASNotification.droppedOPIE.rawValue, object: nil)

        // Setup collection view
        self.ourglasserCollection.dataSource = self
        self.ourglasserCollection.delegate = self
        self.ourglasserCollection.allowsMultipleSelection = false
        
        // Setup refresh control and add
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(findOurglassers), forControlEvents: UIControlEvents.ValueChanged)
        self.ourglasserCollection.addSubview(self.refreshControl)
        self.ourglasserCollection.alwaysBounceVertical = true
        
        setNeedsStatusBarAppearanceUpdate()
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        log.info(NetUtils.getWifiInfo()!.description)
        
        self.navigationController?.navigationBarHidden = true

        
        if shouldFindAfterAppear {
            shouldFindAfterAppear = false
            self.findOurglassers()
        }
    }
    
    // Delegate method to start finding after intro is finished
//    func introDidFinish(introView: EAIntroView!, wasSkipped: Bool) {
//        // Begin searching
//        self.findOurglassers()
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func newOPIE() {
        log.debug("New OPIE")
        self.availableOPIEs = OPIEBeaconListener.sharedInstance.opies
        self.stopRefresh()
    }
    
    func droppedOPIE() {
        log.debug("Dropped OPIE")
        self.availableOPIEs = OPIEBeaconListener.sharedInstance.opies
        self.stopRefresh()
    }
    
    func OPIESocketError() {
        self.refreshControl.endRefreshing()
        
        HUD.hide()
        
        let alertController = UIAlertController(title: "OPIE Locator", message: "There was an error locating OPIEs.", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    

    func findOurglassers() {
        
        // Run a sweep...
        OPIEBeaconListener.sharedInstance.broadcastPacket()
        
        self.refreshing = true
        
        // Show HUD, hide drag down
        
        HUD.show(.LabeledProgress(title: "Is there anybody", subtitle: "out there?"))
        
        self.refreshControl.endRefreshing()
        
        if let ssid = NetUtils.getWifiSSID() {
            if ssid.characters.count < 1 {
                self.mainStatusLabel.text = "Not connected!"
            }else {
                self.mainStatusLabel.text = String(format: "\(ssid)")
            }
            
        } else {
            self.mainStatusLabel.text = "Not connected!"
            self.refreshControl.endRefreshing()
        }
        
        self.availableOPIEs = OPIEBeaconListener.sharedInstance.opies
        
        // Stops the spinner if we have seen no added/dropped OPIEs in 5s
        NSTimer.scheduledTimerWithTimeInterval(SEARCHING_TIMEOUT_INTERVAL, target: self, selector: #selector(stopRefresh), userInfo: nil, repeats: false)
    }
    
    func stopRefresh() {
        self.refreshing = false
        HUD.hide()
        self.refreshControl.endRefreshing()
        self.sortByIPAndReload()
    }
    
    func sortByIPAndReload() {
        if self.availableOPIEs.count > 1 {
            self.availableOPIEs.sortInPlace {
                (a : OPIE, b : OPIE) -> Bool in
                let comp = a.ipAddress.compare(b.ipAddress, options: NSStringCompareOptions.NumericSearch)
                if comp == NSComparisonResult.OrderedAscending {
                    return true
                } else {
                    return false
                }
            }
        }
        self.ourglasserCollection.reloadData()
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.availableOPIEs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell : OurglasserCell = collectionView.dequeueReusableCellWithReuseIdentifier("DefaultOurglasserCell", forIndexPath: indexPath) as! OurglasserCell
        
//        cell.image.image = self.availableOPIEs[indexPath.row].icon
        cell.name.text = self.availableOPIEs[indexPath.row].systemName
        cell.location.text = self.availableOPIEs[indexPath.row].location
        //cell.ipAddress.text = (isDevelopment ? self.availableOPIEs[indexPath.row].ipAddress : "")
        cell.ipAddress.text = self.availableOPIEs[indexPath.row].ipAddress
        cell.systemNumberLabel.text = "\(indexPath.row+1)"
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("toOPControl", sender: indexPath)
    }
    
    // Set header view height low if we're not showing the error message, why would we want a huge blank space?
    // Set the '' to however tall it is in the storyboard
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return self.availableOPIEs.count < 1 && !self.refreshing ? CGSizeMake(330, 100) : CGSizeMake(330, 20)
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
//        switch kind {
//            
//        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "headerView", forIndexPath: indexPath)
            
            if self.availableOPIEs.count < 1 && !self.refreshing {
                headerView.hidden = false
            } else {
                headerView.hidden = true
            }
            return headerView
//            
//        default:
//            assert(false, "Unexpected element kind in OPIE collection view.")
//        }
//        
    
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.refreshControl.endRefreshing()
        
        if segue.identifier == "toOPControl" && sender != nil {
            let indexPath: NSIndexPath = sender as! NSIndexPath
            let op = self.availableOPIEs[indexPath.row]
            let ovc : OurglasserViewController = segue.destinationViewController as! OurglasserViewController
            ovc.goToUrl = op.getDecachedUrl()
            ovc.navTitle = op.location
            ovc.op = op
            ovc.chooseViewController = self
        }
    }

}

