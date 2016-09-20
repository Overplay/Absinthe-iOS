//
//  StringExtensions.swift
//  Absinthe-iOS
//
//  Created by Mitchell Kahn on 9/20/16.
//  Copyright © 2016 Ourglass. All rights reserved.
//

import Foundation


extension String {
    
    func blank() -> Bool {
        let trimmed = self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        return trimmed.isEmpty
    }
    
    func isValidEmail() -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(self)
        
    }
    
    func isValidPwd() -> Bool {
        
        // OK, this should be a RegEx, but I fucking hate RegEx...
        
        if self.characters.count < 8 {
            return false
        }
               
        return true
    }
    
    // This is really shitty!
    func munge() -> String {
        
        var bytes = Array<UInt8>()
        
        for c in self.utf8 {
            bytes.append(c+1)
        }
        
        let munged = String(bytes)
        
        return munged
        
    }
    
    func trunc(length: Int, trailing: String? = "") -> String {
        if self.characters.count > length {
            return self.substringToIndex(self.startIndex.advancedBy(length)) + (trailing ?? "")
        } else {
            return self
        }
    }
    
}