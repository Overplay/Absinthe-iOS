//
//  ABNetworking.swift
//  Absinthe-iOS
//
//  Interface to AmstelBright APIs
//
//  Created by Mitchell Kahn on 8/31/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import Alamofire
import SwiftyJSON
import PromiseKit

class ABNetworking {
    
    var ipAddress: String = ""
    var useHttps = false
    
    var apiPath: String  {
        return ( self.useHttps ? "https://" : "http://" ) + self.ipAddress + "api/"
    }
    
    enum ABErrors: ErrorType {
        case BadUrl
        case NotAuthorized
        case Weird
    }
    
    func getJSON( endpoint: String, parameters: [String:AnyObject]? = nil ) -> Promise<JSON> {
        
        return Promise{ resolve, reject in
            
            Alamofire.request(.GET, endpoint,
                //headers: [ "X-CSRF-Token" : self.token ],
                parameters: parameters )
                .validate()
                .responseJSON { response in
                    
                    switch response.result {
                        
                    case .Success:
                        
                        //TODO a single guard statement
                        guard let value = response.result.value else {
                            reject(ABErrors.Weird)
                            return
                        }
                        
                        let json = JSON(value)
                        resolve(json)
                        
                    case .Failure(let error):
                        log.debug(error.localizedDescription)
                        reject(error)
                        
                    }
            }

            
            
        }
        
    }
    
    func getSystemInfo() -> Promise<JSON> {
        
        return getJSON(apiPath+"/system/device")
        
    }
    
}
