//
//  Settings.swift
//  Belashi-iOS
//
//  Created by Mitchell Kahn on 7/13/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import Foundation


// NSUserDefaults settings are wrapped here for cleanliness

class Settings {
    
    static let sharedInstance = Settings()

    
    var isDevelopmentMode: Bool {
        get {
            // Temporary defaults -- if nil, return true
            let userDefaults = NSUserDefaults.standardUserDefaults()
            return userDefaults.objectForKey("devMode") == nil ? true : userDefaults.boolForKey("devMode")
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "devMode")
        }
    }

    // MARK:Defaults
    
    // For some odd reason, the defaults block below is not working even though it was lifted from A8PoO
    // Found all over the internet too, still doesn't work
    
    func registerDefaults() {
        NSUserDefaults.standardUserDefaults().registerDefaults(["devMode": true])
    }

}