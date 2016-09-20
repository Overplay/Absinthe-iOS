//
//  Settings.swift
//  Absinthe-iOS
//
//  Created by Mitchell Kahn on 7/13/16.
//  Copyright © 2016 Ourglass TV. All rights reserved.
//

import Foundation


// NSUserDefaults settings are wrapped here for cleanliness

class Settings {
    
    let userDefaults = NSUserDefaults.standardUserDefaults()

    static let sharedInstance = Settings()

    // MARK App Modes
    
    var isDevelopmentMode: Bool {
        get {
            return userDefaults.boolForKey("devMode")
        }
        set {
            userDefaults.setBool(newValue, forKey: "devMode")
        }
    }
    
    var appleReviewMode: Bool {
        get {
            return userDefaults.boolForKey("appleReviewMode")
        }
        set {
            userDefaults.setBool(newValue, forKey: "appleReviewMode")
        }
    }
    
    // MARK Asahi Cloud Services
    
    var ourglassCloudBase: String {
        get {
            return userDefaults.stringForKey("asahiBase") ?? "whoopsie"
        }
        set {
            userDefaults.setObject(newValue, forKey: "asahiBase")
        }
    }
    
    var ourglassCloudScheme: String {
        get {
            return userDefaults.stringForKey("asahiScheme") ?? "http://"
        }
        set {
            userDefaults.setObject(newValue, forKey: "asahiScheme")
        }
    }
    
    var ourglassCloudBaseUrl: String {
        return ourglassCloudScheme + ourglassCloudBase
    }
    
    // MARK: User info
    
    
    var userFirstName: String? {
        get {
            return userDefaults.stringForKey("userFirstName")
        }
        set {
            userDefaults.setObject(newValue, forKey: "userFirstName")
        }
    }
    
    var userLastName: String? {
        get {
            return userDefaults.stringForKey("userLastName")
        }
        set {
            userDefaults.setObject(newValue, forKey: "userLastName")
        }
    }

    
    var userEmail: String? {
        get {
            return userDefaults.stringForKey("userEmail")
        }
        set {
            userDefaults.setObject(newValue, forKey: "userEmail")
        }
    }

    var userAsahiJWT: String? {
        get {
            return userDefaults.stringForKey("userAsahiJWT")
        }
        set {
            userDefaults.setObject(newValue, forKey: "userAsahiJWT")
        }
    }
    
    // TODO: This absolutely should never be used plaintext after release!!!
    var userPassword: String? {
        get {
            return userDefaults.stringForKey("userPwd")
        }
        set {
            userDefaults.setObject(newValue, forKey: "userPwd")
        }
    }


    // MARK:Defaults
    
    func registerDefaults() {
        
        userDefaults.registerDefaults([
            
            "devMode" :  true,
            "asahiScheme" : "http://",
            "asahiBase" : "107.170.209.248",
            "appleReviewMode" : false
        ])
    }

}