//
//  NetUtils.swift
//  OurglassAppSwift
//
//  Created by Alyssa Torres on 3/10/16.
//  Copyright © 2016 App Delegates. All rights reserved.
//

import Foundation
import SystemConfiguration.CaptiveNetwork
import PromiseKit

class NetUtils : NSObject, SimplePingDelegate, NSStreamDelegate {
    
    // MARK: PING
    
    var sema: dispatch_semaphore_t!
    var isError = false
    var response: AnyObject!
    
    func ping(address: String) -> Promise<AnyObject>! {
        let simpPing = SimplePing(hostName: address)
        simpPing.delegate = self
        simpPing.start()
        
        xcglog.debug("Starting ping")
        
        return Promise<AnyObject> { fulfill, reject in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                self.sema = dispatch_semaphore_create(0)
                dispatch_semaphore_wait(self.sema, DISPATCH_TIME_FOREVER)
                if self.isError {
                    reject(self.response as! ErrorType)
                } else {
                    fulfill(self.response)
                }
            }
        }
    }
    
    // Stop and signal promise
    func stopPing(pinger: SimplePing, isError: Bool, response: AnyObject) {
        self.isError = isError
        self.response = response
        pinger.stop()
        dispatch_semaphore_signal(sema)
    }
    
    // Send ping immediately
    func simplePing(pinger: SimplePing, didStartWithAddress address: NSData) {
        xcglog.debug("Sent ping with data")
        pinger.sendPingWithData(nil)
    }
    
    // Failed so reject promise
    func simplePing(pinger: SimplePing, didFailWithError error: NSError) {
        self.isError = true
        self.response = error.description
        xcglog.debug(String("Ping failed with error: %@", error.description))
        stopPing(pinger, isError: true, response: error.description)
    }
    
    // Failed so reject promise
    func simplePing(pinger: SimplePing, didFailToSendPacket packet: NSData, sequenceNumber: UInt16, error: NSError) {
        xcglog.debug(String("Ping packed failed to send with error: %@", error.description))
        stopPing(pinger, isError: true, response: error.description)
    }
    
    // Got data back so fulfill promise
    func simplePing(pinger: SimplePing, didReceivePingResponsePacket packet: NSData, sequenceNumber: UInt16) {
        xcglog.debug(String("Received ping response with data: %@", packet))
        stopPing(pinger, isError: false, response: packet)
    }
    
    // MARK: WIFI ADDRESS
    
    // Get mobile device IP and netmask of connected Wi-Fi
    static func getWifiInfo() -> [String:String]? {
        var address : String!
        var netmask : String!
        var ifaddr : UnsafeMutablePointer<ifaddrs> = nil
        
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                let interface = ptr.memory
                if interface.ifa_addr.memory.sa_family == UInt8(AF_INET) {
                    if let name = String.fromCString(interface.ifa_name) where name == "en0" {
                        var hostname = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
                        getnameinfo(&interface.ifa_addr.memory, socklen_t(interface.ifa_addr.memory.sa_len), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST)
                        address = String.fromCString(hostname)
                        getnameinfo(&interface.ifa_netmask.memory, socklen_t(interface.ifa_netmask.memory.sa_len), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST)
                        netmask = String.fromCString(hostname)
                    }
                }
                
                ptr = ptr.memory.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        if address == nil {
            address = "Not connected to Wi-Fi"
        }
        if netmask == nil {
            netmask = "Not connected to Wi-Fi"
        }
        var base: String!
        let baseComps = address.componentsSeparatedByString(".")
        if baseComps.count == 4 {
            base = baseComps[3]
        }
        if base == nil {
            base = "Not connected to Wi-Fi"
        }
        return ["ip": address, "subnet": netmask, "base": base]
    }
    
    // Get name (SSID) of connected Wi-Fi
    static func getWifiSSID() ->  String? {
        #if arch(i386) || arch(x86_64)
            return "SimulatedSSID"
        #endif
        var currentSSID = ""
        if let interfaces:CFArray! = CNCopySupportedInterfaces() {
            for i in 0..<CFArrayGetCount(interfaces){
                let interfaceName: UnsafePointer<Void> = CFArrayGetValueAtIndex(interfaces, i)
                let rec = unsafeBitCast(interfaceName, AnyObject.self)
                let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)")
                if unsafeInterfaceData != nil {
                    let interfaceData = unsafeInterfaceData! as Dictionary!
                    currentSSID = interfaceData["SSID"] as! String
                }
            }
        }
        return currentSSID
    }
    
    // Get IP address of OPIE from data
    static func getIPAddress(address: NSData) -> String? {
        var ipAddress : String?
        var sa = sockaddr()
        
        address.getBytes(&sa, length: sizeof(sockaddr))
        
        if Int32(sa.sa_family) == AF_INET {
            var ip4 = sockaddr_in()
            address.getBytes(&ip4, length: sizeof(sockaddr_in))
            ipAddress = String(format: "%s", inet_ntoa(ip4.sin_addr))
        }
        
        return ipAddress
    }
    
}
