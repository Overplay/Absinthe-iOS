//
//  Asahi.swift
//  Absinthe-iOS
//
//  Created by Noah on 7/19/16.
//  Edits by Mitch Sept 2016
//  Copyright © 2016 Ourglass TV. All rights reserved.
//

//  This is the interface to the Ourglass Cloud Server aka Asahi aka Applejack


import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON

public class Asahi: NSObject {
    
    enum AsahiError: ErrorType {
        case MissingOrMalformedParams
        case ResponseWasNotValidJson
    }
    
    static let sharedInstance = Asahi()
    
    var currentToken = String()
    
    var loggedIn = false
    var currentEmail: String?
    
    var _postNotification = false
    
    
    func createApiEndpoint(endpoint: String) -> String {
        return Settings.sharedInstance.ourglassCloudBaseUrl + endpoint
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
    
    func register(email: String, password: String, user: NSDictionary) -> Promise<JSON> {
        
        return Promise<JSON> { resolve, reject in
            
            let params: Dictionary = [
                "email":email,
                "password":password,
                "user": user,
                "type":"local"]

            Alamofire.request(RequestRouter.Register(params))
                .validate()
                .responseJSON { response in
                
                    switch response.result {
                    
                    case .Success:
                    
                        guard let value = response.result.value else {
                            reject(AsahiError.ResponseWasNotValidJson)
                            return
                        }
                    
                        self.currentEmail = params["email"] as? String
                        let json = JSON(value)
                        resolve(json)
                    
                    case .Failure(let error):
                        log.debug(error.localizedDescription)
                        reject(error)
                    
                }
            }
        }
    }
    
    // We need a JSON login endpoint. Keep this here until it is done
    func loginJSON(email: String, password: String) -> Promise<JSON> {
        
        return Promise<JSON> { resolve, reject in
            
            let parameters = ["email":email,
                            "password":password,
                            "type":"local"]
            
            Alamofire.request(RequestRouter.Login(parameters))
                .validate()
                .responseJSON { response in
                    
                    switch response.result {
                        
                    case .Success:
                        
                        guard let value = response.result.value else {
                            reject(AsahiError.ResponseWasNotValidJson)
                            return
                        }
                        
                        self.loggedIn = true
                        self.currentEmail = email
                        
                        Settings.sharedInstance.userEmail = email
                        if (Settings.sharedInstance.isDevelopmentMode){
                            Settings.sharedInstance.userPassword = password
                        }
                        
                        ASNotification.AsahiLoggedIn.issue()
                        resolve(JSON(value))
                        
                    case .Failure(let error):
                        log.debug(error.localizedDescription)
                        reject(error)
                        
                    }
            }
        }
    }


    
    // TODO: MAK This should be replaced with a proper JSON login endpoint (see above)
    func loginOnly(email: String, password: String) -> Promise<Bool> {
        
        return Promise<Bool> { resolve, reject in
            
            let parameters = ["email":email,
                "password":password,
                "type":"local"]
            
            Alamofire.request(RequestRouter.Login(parameters))
                .validate()
                .responseString { response in
                    
                    switch response.result {
                        
                    case .Success:
                        
                        self.loggedIn = true
                        self.currentEmail = email
                        
                        Settings.sharedInstance.userEmail = email
                        if (Settings.sharedInstance.isDevelopmentMode){
                            Settings.sharedInstance.userPassword = password
                        }
                        
                        ASNotification.AsahiLoggedIn.issue()
                        resolve(true)
                        
                    case .Failure(let error):
                        log.debug(error.localizedDescription)
                        reject(error)
                        
                    }
            }
        }
    }
    
    func login(email: String, password: String) -> Promise<String> {
        
        return loginOnly(email, password: password)
            .then{ _ -> Promise<String> in
                self.getToken()
        }
    }
    
    func getToken() -> Promise<String> {
        
        return Promise<String> { fulfill, reject in
            
            Alamofire.request(RequestRouter.GetToken())
                .validate()
                .responseJSON { response in
                    
                    switch response.result {
                    
                        case .Success:
                            
                            guard let value = response.result.value else {
                                reject(AsahiError.ResponseWasNotValidJson)
                                return
                            }
                            
                            Settings.sharedInstance.userAsahiJWT = (value["token"] as! String)
                            Settings.sharedInstance.userAsahiJWTExpiry = (value["expires"] as! Int)
                            fulfill(Settings.sharedInstance.userAsahiJWT!)
                    
                        case .Failure(let error):
                            reject(error)
                        
                    }
                }
            }
    }
    
    // TODO: This should also be replaced with JSON endpoint
    func changePassword(email: String, newPassword: String) -> Promise<Bool> {
        
        return Promise<Bool> { resolve, reject in
            
            let params = ["email": email, "newpass": newPassword]
            
            Alamofire.request(RequestRouter.ChangePwd(params))
                .validate()
                .responseString(completionHandler: { response in switch response.result {
                case .Success:
                    resolve(true)
                case .Failure(let error):
                    reject(error)
                    }
                })
        }
    }
    
    func getVenues() -> Promise<JSON> {
        
        return Promise<JSON> { resolve, reject in
            
            Alamofire.request(RequestRouter.GetVenues())
                .validate()
                .responseJSON(completionHandler: { response in
                    
                    switch response.result {
                
                    case .Success:
                    
                        guard let value = response.result.value else {
                            reject(AsahiError.ResponseWasNotValidJson)
                            return
                        }
                        
                        let json = JSON(value)
                        resolve(json)
                        
                    case .Failure(let err):
                        reject (err)

                    }
                })
        }
    }
    
    func checkAuthorized() -> Promise<Bool> {
        
        return Promise<Bool> { resolve, reject in
            
            if let _ = Settings.sharedInstance.userAsahiJWT {
                resolve(true)
            } else {
                resolve(false)
            }
        }
    }
    
    func checkAuthStatus() -> Promise<JSON> {
        return Promise<JSON> { resolve, reject in
            
            Alamofire.request(RequestRouter.GetAuthStatus())
                
                .validate()
                
                .responseJSON(completionHandler: { response in
                    
                    guard let value = response.result.value else {
                        reject(AsahiError.ResponseWasNotValidJson)
                        return
                    }
                    
                    switch response.result {
                        
                    case .Success:
                        resolve(JSON(value))
                        
                    case .Failure(let error):
                        reject(error)
                    }
                })
        }
    }
    
    func logout() -> Promise<Bool> {
        return Promise<Bool> { resolve, reject in
            Alamofire.request(RequestRouter.Logout())
            
                .validate()
            
                .responseString(completionHandler: { response in
                    switch response.result {
                    case .Success:
                        resolve(true)
                    case .Failure(let error):
                        reject(error)
                    }
            })
        }
    }
    
    
    // MARK Test Methods
    
    func testRegistration(){
        
        // Create unique email
        let email = "absinthe-\(NSDate().timeIntervalSince1970)@test.com"
        
        register(email, password: "yah00die", user: [ "firstName":"Dick", "lastName":"Yahoodie"])
            .then { response -> Void in
                log.debug("Well, I got a response regging: \(response)")
            }
            .error { ( err: ErrorType ) -> Void in
                log.debug("hmm, that sucks")
                let fuck = err as NSError
                log.error("\(fuck.localizedDescription)")
        }
    }
    
    // MARK Assumes "absinthetest@ourglass.tv/ab5inth3" exists in the system
    func testLogin(){
        
        login("absinthetest@ourglass.tv", password: "ab5inth3")
            .then { response -> Void in
                log.debug("Well, I got a response logging in: \(response)")
            }
            .error { ( err: ErrorType ) -> Void in
                log.debug("hmm, that sucks")
                let fuck = err as NSError
                log.error("\(fuck.localizedDescription)")
        }

    }
    
    func testGetVenues(){
        
        getVenues()
            .then { response -> Void in
                log.debug("Well, I got a response logging in: \(response)")
            }
            .error { ( err: ErrorType ) -> Void in
                log.debug("hmm, that sucks")
                let fuck = err as NSError
                log.error("\(fuck.localizedDescription)")
        }

    }
}
