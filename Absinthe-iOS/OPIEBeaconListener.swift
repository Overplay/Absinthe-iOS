//
//  OPIEBeaconListener.swift
//  OurglassAppSwift
//
//  Created by Alyssa Torres on 3/31/16.
//  Mods by Noah August 2016
//  Modes by Mitch Sept 2016
//  Copyright © 2016 Ourglass. All rights reserved.
//

import CocoaAsyncSocket
import SwiftyJSON

class OPIEBeaconListener: NSObject, GCDAsyncUdpSocketDelegate {
    
    static let sharedInstance = OPIEBeaconListener()
    
    // This is the subnet mask for the current network, all IPs on local Wi-Fi
    let BROADCAST_HOST = "255.255.255.255"
    
    // 9091 for now
    let PORT = Settings.sharedInstance.udpDiscoveryPort
    
    // max time (in seconds) that can elapse between OPIE broadcasts before the OPIE is dropped
    let timeBeforeDrop: Double = 10
    
    // time between pseudo upnp broadcast
    let broadcastInterval: Double = 5
    
    
    // TODO: [mak] are their situations where this could fail (!)?
    let netInfo = NetUtils.getWifiInfo()! as [String:String]
    
    // For identifying different UDP packets sent to different hosts or whatever
    // This doesn't really matter for our usecase
    let TAG = 1
    
    var socket: GCDAsyncUdpSocket!
    let nc = NSNotificationCenter.defaultCenter()
    
    // Array of Ourglass Players
    var opies = [OPIE]()
    
    func startListening() {
        
        opies = [OPIE]()
        
        self.socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())

        do {
            try self.socket.bindToPort(PORT)
        } catch {
            log.error(String("ERROR: OPIE socket failed to bind to port %d", self.PORT))
            ASNotification.OPIESocketError.issue()
            return
        }
        
        do {
            try self.socket.enableBroadcast(true)
        } catch {
            self.socket.close()
            log.error("ERROR: OPIE socket failed to enable broadcast.")
            ASNotification.OPIESocketError.issue()
            return
        }
        
        do {
            try self.socket.beginReceiving()
        } catch {
            self.socket.close()
            log.error("ERROR: OPIE socket failed to begin receiving.")
            ASNotification.OPIESocketError.issue()
            return
        }
        
        // Fire off the psuedo upnp "anyone there?" packet to send on an interval
        NSTimer.scheduledTimerWithTimeInterval(broadcastInterval, target: self, selector: #selector (broadcastPacket),userInfo: nil, repeats: true)
        
        // Check devices are online
        // TODO: remove algo broken?
        //NSTimer.scheduledTimerWithTimeInterval(timeBeforeDrop, target: self, selector: #selector (checkOPIEs), userInfo: nil, repeats: true)
        
    }
    
    func stopListening() {
        self.socket.close()
    }
    
    // MARK: - GCDAsyncUdpSocket
    
    func broadcastPacket() {
        
        log.info("Broadcasting pseudo upnp discovery packet...")
        
        do {
            // JSON object to broadcast to the LAN
            let jsonPacket = JSON([
                "ip": netInfo["ip"]!
                ])
            
            try self.socket.sendData(jsonPacket.rawData(), toHost: BROADCAST_HOST, port: PORT, withTimeout: -1, tag: TAG)
            
            // On the simulator, toss a second packet to port 9092 in case we're running local ogUdpSimulator
            #if (arch(i386) || arch(x86_64)) && os(iOS)
                try self.socket.sendData(jsonPacket.rawData(), toHost: BROADCAST_HOST, port: PORT+1, withTimeout: -1, tag: TAG)
            #endif
            
            //try self.socket.sendData(jsonPacket.rawData(), toHost: BROADCAST_HOST, port: bport, withTimeout: -1, tag: TAG)
            //try self.socket.sendData(jsonPacket.rawData(), toHost: BROADCAST_HOST, port: bport, withTimeout: -1, tag: TAG)
        } catch {
            log.error("ERROR: OPIE socket failed to send packet.")
            ASNotification.OPIESocketError.issue()
        }
    }
    
    // These funcs are marked as @objc so that this swift class can act as a delegate
    
    @objc func udpSocket(sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        log.info("Sent packet into nothingness... hoping for response.")
    }
    
    @objc func udpSocket(sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: NSError) {
        log.error(String(format: "ERROR: OPIE socket failed to send packet. %@", error.description))
        ASNotification.OPIESocketError.issue()
    }
    
    @objc func udpSocket(sock: GCDAsyncUdpSocket, didReceiveData data: NSData, fromAddress address: NSData, withFilterContext filterContext: AnyObject?) {
        
        let ipAddress = NetUtils.getIPAddress(address)
        
        guard ipAddress != nil else {
            log.error("Got nil IP address as source of UDP packet, bailing!")
            return
        }
        
        guard ipAddress != netInfo["ip"] else {
            log.debug("Got my own address as source of UDP packet, skipping!")
            return
        }
        
        let receivedOp = OPIE()
        
        do {
            let OurglasserJson = try NSJSONSerialization.JSONObjectWithData(data, options:[])
            if let name = OurglasserJson["name"] as? String {
                receivedOp.systemName = name != "undefined" && name != "" ? name : "Ourglass Device"
            }
            if let location = OurglasserJson["location"] as? String {
                receivedOp.location = location != "undefined" && location != "" ? location : ""
            }
            receivedOp.lastHeardFrom = NSDate()
            
        } catch {
            log.error("Error reading UDP JSON.")
            return
        }
        
        receivedOp.ipAddress = ipAddress!
        processOPIE(receivedOp)
    }
    
    func processOPIE(receivedOp: OPIE) {
        
        for op in self.opies {
            
            if op.ipAddress == receivedOp.ipAddress {
                op.systemName = receivedOp.systemName
                op.location = receivedOp.location
                op.lastHeardFrom = NSDate()
                nc.postNotificationName(ASNotification.newOPIE.rawValue, object: nil, userInfo: ["OPIE": op])
                return
            }
        }
        
        self.opies.append(receivedOp);
        nc.postNotificationName(ASNotification.newOPIE.rawValue, object: nil, userInfo: ["OPIE": receivedOp])
    }
    
    func checkOPIEs() {
        log.info("Checking devices online...")
        
        var online = [OPIE]()
        var dropped = false
        
        for op in self.opies {
            if let lastHeard = op.lastHeardFrom {
                let elapsedTime = NSDate().timeIntervalSinceDate(lastHeard)
                if elapsedTime <= timeBeforeDrop {
                    online.append(op)
                } else {
                    dropped = true
                }
            }
        }
        
        self.opies = online
        if dropped == true {
            nc.postNotificationName(ASNotification.droppedOPIE.rawValue, object: nil)
        }
    }
}
