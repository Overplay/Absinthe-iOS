//
//  Asahi.swift
//  Belashi-iOS
//
//  Created by Noah on 7/19/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

public class Asahi: NSObject {
    
    static let sharedInstance = Asahi()
    
    var currentToken = String()
    
    var loggedIn = false
    var currentEmail = String()
    
    var _postNotification = false
    
    func createApiEndpoint(endpoint: String) -> String {
        return "http://104.131.145.36".stringByAppendingString(endpoint)
    }
    
    // Auto sign in on app startup, but this is if we're saving the username/password in plain text so this is only temporary
    // Eventually move to JWTs so we can uncomment this when that is setup and migrate over to using those
//    override init() {
//        super.init()
//        let email = NSUserDefaults.standardUserDefaults().valueForKey("Email") as? String
//        let password = NSUserDefaults.standardUserDefaults().valueForKey("Password") as? String
//        if email != nil && password != nil {
//            _postNotification = true
//            self.login(email!, password: password!)
//        }
//    }
    
    func register(email: String, password: String, user: NSDictionary) -> Promise<[String]> {
        var jsonUser = String()
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(user, options: [])
            jsonUser = String(data: jsonData, encoding: NSUTF8StringEncoding)!
        } catch let error as NSError {
            print(error)
        }
        return Promise<[String]> { fulfill, reject in
            Alamofire.request(.POST, createApiEndpoint("/auth/addUser"), parameters:["email":email,"password":password,"user":jsonUser,"type":"local"], encoding: .JSON)
                .responseString(completionHandler: { response in switch response.result {
                case .Success(let data):
                    // 200..<300 is range of good HTTP codes, anything above that is bad for this case
                    if 200..<300 ~= (response.response?.statusCode)! {
                        fulfill([String((response.response?.statusCode)!), "true", "Registered successfully."])
                    }else {
                        fulfill([String((response.response?.statusCode)!), "false", data])
                    }
                case .Failure(let error):
                    reject(error)
                    }
                })
        }
    }
    
    func login(email: String, password: String) -> Promise<[String]> {
        return Promise<[String]> { fulfill, reject in
        Alamofire.request(.POST, createApiEndpoint("/auth/login"), parameters:["email":email, "password":password,"type":"local"], encoding: .JSON)
            .responseString(completionHandler: { response in switch response.result {
            case .Success(let data):
                // 200..<300 is range of good HTTP codes, anything above that is bad for this case
                if 200..<300 ~= (response.response?.statusCode)! {
                    self.loggedIn = true
                    self.currentEmail = email
                    NSUserDefaults.standardUserDefaults().setValue(email, forKey: "Email")
                    NSUserDefaults.standardUserDefaults().setValue(password, forKey: "Password")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    if self._postNotification {
                        self._postNotification = false
                        NSNotificationCenter.defaultCenter().postNotificationName("AsahiLoggedIn", object: nil)
                    }
                    fulfill([String((response.response?.statusCode)!), "true", "Logged in successfully."])
                }else {
                    fulfill([String((response.response?.statusCode)!), "false", data])
                }
            case .Failure(let error):
                reject(error)
                }
            })
        }
    }
    
    func logout() -> Promise<[String]> {
        return Promise<[String]> { fulfill, reject in
        Alamofire.request(.POST, createApiEndpoint("/auth/logout"), parameters: nil, encoding: .URL)
            .responseString(completionHandler: { response in switch response.result {
            case .Success(let data):
                // 200..<300 is range of good HTTP codes, anything above that is bad for this case
                if 200..<300 ~= (response.response?.statusCode)! {
                    self.loggedIn = false
                    fulfill([String((response.response?.statusCode)!), "true", "Logged out successfully."])
                }else {
                    fulfill([String((response.response?.statusCode)!), "false", data])
                }
            case .Failure(let error):
                reject(error)
                }
            })
        }
    }
    
    func changePassword(email: String, newPassword: String) -> Promise<[String]> {
        return Promise<[String]> { fulfill, reject in
            Alamofire.request(.POST, createApiEndpoint("/auth/changePwd"), parameters: ["email":email,"newpass":newPassword], encoding: .JSON)
                .responseString(completionHandler: { response in switch response.result {
                case .Success(let data):
                    // 200..<300 is range of good HTTP codes, anything above that is bad for this case
                    if 200..<300 ~= (response.response?.statusCode)! {
                        fulfill([String((response.response?.statusCode)!), "true", data])
                    }else {
                        fulfill([String((response.response?.statusCode)!), "false", data])
                    }
                case .Failure(let error):
                    reject(error)
                    }
                })
        }
    }
    
    func getVenues() -> Promise<[AnyObject]> {
        return Promise<[AnyObject]> { fulfill, reject in
            Alamofire.request(.GET, createApiEndpoint("/api/v1/venue"))
                .responseJSON(completionHandler: { response in switch response.result {
                case .Success(let data):
                    // 200..<300 is range of good HTTP codes, anything above that is bad for this case
                    if 200..<300 ~= (response.response?.statusCode)! {
                        fulfill([String((response.response?.statusCode)!), "true", data])
                    }else {
                        fulfill([String((response.response?.statusCode)!), "false", data])
                    }
                case .Failure(let error):
                    reject(error)
                    }
                })
        }
    }

}
