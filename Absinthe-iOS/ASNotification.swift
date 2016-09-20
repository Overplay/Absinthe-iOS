//
//  ASNotification.swift
//  OurglassAppSwift
//
//  Created by Alyssa Torres on 3/31/16.
//  Mods by mitch 9/2016
//  Copyright © 2016 App Delegates. All rights reserved.
//


import Foundation

enum ASNotification: String {
    
    case newOPIE
    case droppedOPIE
    case OPIESocketError
    case AsahiLoggedIn
    
    func issue(){
        NSNotificationCenter.defaultCenter().postNotificationName(self.rawValue, object: nil)
    }
    
}
