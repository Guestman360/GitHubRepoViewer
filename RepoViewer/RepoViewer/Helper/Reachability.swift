//
//  Reachability.swift
//  RepoViewer
//
//  Created by Matt Guest on 3/18/18.
//  Copyright © 2018 AlphaApplications. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration

class NetworkConnection {
    
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == false {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    class func checkConnection(sender: UIViewController){
        if NetworkConnection.isConnectedToNetwork() == true {
            print("Connected to the internet")
            //  Do something
        } else {
            print("No internet connection")
            let alertController = UIAlertController(title: "No Internet Available", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default){(result:UIAlertAction) -> Void in
                return
            }
            alertController.addAction(okAction)
            sender.present(alertController, animated: true, completion: nil)
            //  Do something
        }
    }
    
}
