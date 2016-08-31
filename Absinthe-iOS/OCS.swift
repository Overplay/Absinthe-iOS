//
//  OCS.swift
//  OurglassAppSwift
//  Ourglass Cloud System
//
//  Created by Alyssa Torres on 3/30/16.
//  Copyright © 2016 App Delegates. All rights reserved.
//

import Foundation

class OCS {
    
    static let sharedInstance = OCS()
    
    func signIn(username: String, password: String) -> Bool {
        xcglog.debug("OCS signing in")
        return true
    }
    
    func signUp(username: String, password: String) {
        xcglog.debug("OCS signing up for \(username)")
    }
}