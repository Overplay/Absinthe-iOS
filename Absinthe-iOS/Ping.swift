//
//  Ping.swift
//  Belashi-iOS
//
//  Created by Noah on 7/20/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import Foundation

class Ping : NSObject, NSURLSessionDelegate {
    
    var connection: NSURLConnection!
    
    func connect(address: String) {
        
        xcglog.info("connecting...")
        
        let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var dataTask: NSURLSessionDataTask?
        let url = NSURL(string: address)
        dataTask = defaultSession.dataTaskWithURL(url!) {
            data, response, error in
            if let error = error {
                xcglog.error(error.localizedDescription)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                xcglog.debug(httpResponse.description)
            }
        }
        dataTask?.resume()
        
    }
}
