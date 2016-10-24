//
//  RequestRouter.swift
//  Absinthe-iOS
//
//  Created by Alyssa Torres on 9/30/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON

enum RequestRouter: URLRequestConvertible {
    
    static let baseURLString: String = Settings.sharedInstance.ourglassCloudBaseUrl
    
    case GetToken()
    case Register([String: AnyObject])
    case Login([String: AnyObject])
    case ChangePwd([String: AnyObject])
    case GetVenues()
    case GetAuthStatus()
    case Logout()
    case ChangeAccountInfo([String: AnyObject])
    case InviteNewUser([String: AnyObject])
    
    var URLRequest: NSMutableURLRequest {
        var method: Alamofire.Method {
            switch self {
            case .GetToken, .GetVenues, .GetAuthStatus, .Logout:
                return .GET
            case .Register, .Login, .ChangePwd, .InviteNewUser:
                return .POST
            case .ChangeAccountInfo:
                return .PUT
            }
        }
        
        let params: ([String: AnyObject]?) = {
            switch self {
            case .GetToken, .GetVenues, .GetAuthStatus, .Logout:
                return (nil)
            case .Register(let newUser):
                return (newUser)
            case .Login(let user):
                return (user)
            case .ChangePwd(let newPass):
                return (newPass)
            case .ChangeAccountInfo(let info):
                return (info)
            case .InviteNewUser(let email):
                return (email)
            }
        }()
        
        let url: NSURL = {
            let relativePath: String?
            switch self {
            case .GetToken:
                relativePath = "/user/jwt"
            case .Register:
                relativePath = "/auth/addUser"
            case .Login:
                relativePath = "/auth/login"
            case .ChangePwd:
                relativePath = "/auth/changePwd"
            case .GetVenues:
                relativePath = "/api/v1/venue"
            case .GetAuthStatus:
                relativePath = "/auth/status"
            case .Logout:
                relativePath = "/auth/logoutPage"
            case .ChangeAccountInfo:
                relativePath = "/user/\(Settings.sharedInstance.userId)"   // TODO: this might crash
            case .InviteNewUser:
                relativePath = "/user/inviteNewUser"
            }
            
            var URL = NSURL(string: RequestRouter.baseURLString)!
            if let relativePath = relativePath {
                URL = URL.URLByAppendingPathComponent(relativePath)
            }
            
            return URL
        }()
        
        let URLRequest = NSMutableURLRequest(URL: url)
        
        if let _ = Settings.sharedInstance.userAsahiJWT {
            URLRequest.setValue("Bearer: \(Settings.sharedInstance.userAsahiJWT)", forHTTPHeaderField: "Authorization")
        }
        
        let encoding: Alamofire.ParameterEncoding
        
        switch self {
        case .GetToken, .GetVenues, .GetAuthStatus, .Logout:
            encoding = Alamofire.ParameterEncoding.URL
        case .Register, .Login, .ChangePwd, .ChangeAccountInfo, .InviteNewUser:
            encoding = Alamofire.ParameterEncoding.JSON
        }
        
        let (encodedRequest, _) = encoding.encode(URLRequest, parameters: params)
        
        encodedRequest.HTTPMethod = method.rawValue
        
        return encodedRequest
    }
}

