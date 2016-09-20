//
//  OPIEBeaconListener.swift
//  OurglassAppSwift
//
//  Created by Alyssa Torres on 3/31/16.
//  Copyright © 2016 App Delegates. All rights reserved.
//

import CocoaAsyncSocket
import SwiftyJSON

class OPIEBeaconListener: NSObject, GCDAsyncUdpSocketDelegate {
    
    static let sharedInstance = OPIEBeaconListener()
    
    // This is the subnet mask for the current network, all IPs on local Wi-Fi
    let BROADCAST_HOST = "255.255.255.255"
    let PORT: UInt16 = 9091
    // max time (in seconds) that can elapse between OPIE broadcasts before the OPIE is dropped
    let timeBeforeDrop: Double = 10
    
    let netInfo = NetUtils.getWifiInfo()! as [String:String]
    
    // For identifying different UDP packets sent to different hosts or whatever
    // This doesn't really matter for our usecase
    let TAG = 1
    
    private var socket: GCDAsyncUdpSocket!
    let nc = NSNotificationCenter.defaultCenter()
    var opies = [OPIE]()
    
    private override init() {
        super.init()
    }
    
    func startListening() {
        
        opies = [OPIE]()
        
        self.socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())

        do {
            try self.socket.bindToPort(PORT)
        } catch {
            log.error(String("ERROR: OPIE socket failed to bind to port %d", self.PORT))
            //ASNotification.OPIEScoketError.issue()
            nc.postNotificationName(ASNotification.OPIESocketError.rawValue, object: nil)
        }
        
        do {
            try self.socket.enableBroadcast(true)
        } catch {
            self.socket.close()
            log.error("ERROR: OPIE socket failed to enable broadcast.")
            nc.postNotificationName(ASNotification.OPIESocketError.rawValue, object: nil)
        }
        
        do {
            try self.socket.beginReceiving()
        } catch {
            self.socket.close()
            log.error("ERROR: OPIE socket failed to begin receiving.")
            nc.postNotificationName(ASNotification.OPIESocketError.rawValue, object: nil)
        }
        
        broadcastPacket()
        
    }
    
    func stopListening() {
        self.socket.close()
    }
    
    // MARK: - GCDAsyncUdpSocket
    
    func broadcastPacket() {
        log.info("Broadcasting packet...")
        do {
            // JSON object to broadcast to the LAN
            let jsonPacket = JSON([
                "ip": netInfo["ip"]!
                ])
            try self.socket.sendData(jsonPacket.rawData(), toHost: BROADCAST_HOST, port: PORT, withTimeout: -1, tag: TAG)
            try self.socket.sendData(jsonPacket.rawData(), toHost: BROADCAST_HOST, port: PORT, withTimeout: -1, tag: TAG)
            try self.socket.sendData(jsonPacket.rawData(), toHost: BROADCAST_HOST, port: PORT, withTimeout: -1, tag: TAG)
        } catch {
            log.error("ERROR: OPIE socket failed to send packet.")
            nc.postNotificationName(ASNotification.OPIESocketError.rawValue, object: nil)
        }
    }
    
    @objc func udpSocket(sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        log.info("Sent packet into nothingness... hoping for response.")
    }
    
    @objc func udpSocket(sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: NSError) {
        log.error(String(format: "ERROR: OPIE socket failed to send packet. %@", error.description))
        nc.postNotificationName(ASNotification.OPIESocketError.rawValue, object: nil)
    }
    
    @objc func udpSocket(sock: GCDAsyncUdpSocket, didReceiveData data: NSData, fromAddress address: NSData, withFilterContext filterContext: AnyObject?) {
        
        let ipAddress = NetUtils.getIPAddress(address)
        if ipAddress != nil && ipAddress == netInfo["ip"]! {
            log.info("Got own packet. Working!")
            return
        }
        
        let toAdd = OPIE()
        
        do {
            let OurglasserJson = try NSJSONSerialization.JSONObjectWithData(data, options:[])
            if let name = OurglasserJson["name"] as? String {
                toAdd.systemName = name != "undefined" && name != "" ? name : "Ourglass Device"
            }
            if let location = OurglasserJson["location"] as? String {
                toAdd.location = location != "undefined" && location != "" ? location : ""
            }
            toAdd.lastHeardFrom = NSDate()
            
        } catch {
            log.error("Error reading UDP JSON.")
            return
        }
        
        if ipAddress != nil {
            
            // Verify unique-ness of OPIE box. Use name when testing so we can simulate multiple OPIEs from the same computer, but eventually we'll use the IP address as the unique identifier.
            for op in self.opies {
                
                // I think we have enough boxes that we don't need to simulate a ton of boxes from the same IP.
                // comment out when testing
                if op.ipAddress == ipAddress {
                    op.systemName = toAdd.systemName
                    op.location = toAdd.location
                    op.lastHeardFrom = NSDate()
                    nc.postNotificationName(ASNotification.newOPIE.rawValue, object: nil, userInfo: ["OPIE": op])
                    return
                }
                
                // comment out when not testing
                /*
                if op.systemName == toAdd.systemName {
                    op.systemName = toAdd.systemName
                    op.location = toAdd.location
                    op.lastHeardFrom = NSDate()
                    nc.postNotificationName(Notifications.newOPIE, object: nil, userInfo: ["OPIE": op])
                    return
                }
                */
            }
            
            toAdd.ipAddress = ipAddress!
            self.opies.append(toAdd)
            nc.postNotificationName(ASNotification.newOPIE.rawValue, object: nil, userInfo: ["OPIE": toAdd])
        }
    }
}
