//
//  watchToiOSConnector.swift
//  StoreShoppingWatch Watch App
//
//  Created by Brian Quick on 2024-07-04.
//

import SwiftUI
import Foundation
import WatchConnectivity

class WatchToiOSConnector: NSObject, WCSessionDelegate, ObservableObject {

   
    var session: WCSession
    var modelitem: ModelItem? = nil
    var modelLocation: ModelLocation? = nil
    
    init(session: WCSession = .default) {
        
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    // update this on receive of message so the usetransferUserInfo can be set on the main thread
    @State var usetransferUserInfoState = false
    // user default. what to use when sending data to/from the watch
    @AppStorage(ktransferUserInfoKey)
    private var usetransferUserInfo = ktransferUserInfoDefaultValue
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        print("watch activationDidCompleteWith activationState: \(activationState)" )
     
        print("watch activationDidCompleteWith error: \(String(describing: error))")
        
    }
    // WCSessionDelegate method
//       func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
//           print("watch didReceiveMessage: \(message)")
//           if let name = message["name"] as? String,
//              let aRec = CKItemRec(shopper: 1, listnumber: 1, locationnumber: 1, onList: true, quantity: 1, isAvailable: true, name: name, dateLastPurchased: Date()) {
//               DispatchQueue.main.async {
//                   self.modelitem?.items.append(aRec)
//               }
//               replyHandler(["name": name, "status": "success"])
//           } else {
//               replyHandler(["status": "error", "message": "Invalid name"])
//           }
//       }
    func session(_ session: WCSession,
                 didReceiveMessage message: [String : Any],
                 replyHandler: @escaping ([String : Any]) -> Void) {
        print("watch didReceivMessage with replyHandler \(message)")
    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("watch didReceiveMessage: \(message)")
        usetransferUserInfoState = false
        handleReceived(message: message)
//        if let aRec = CKItemRec(shopper: 1, listnumber: Int64(message["listnumber"] as! Int), locationnumber: message["locationnumber"] as! Int64, onList: true, quantity: 1, isAvailable: true, name: message["name"] as! String, dateLastPurchased: Date()) {
//            DispatchQueue.main.async {
//                if (message["name"] as! String) == self.modelitem?.initializeWatch {
//                    self.modelitem?.items.removeAll()
//                    self.modelLocation?.locations.removeAll()
//                } else {
//                    self.modelLocation?.AddLocationToLocations(listnumber: message["listnumber"] as! Int, locationnumber: message["locationnumber"] as! Int64, name: message["locationname"] as! String)
//                    self.modelitem?.items.append(aRec)
//                    self.modelitem?.groupItemsByLocation()
//                }
//            }
//        }
    }
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("watch - didReceiveUserInfo", userInfo)
        usetransferUserInfoState = true
        handleReceived(message: userInfo)
    }
    func handleReceived(message: [String : Any]) {
        if let aRec = CKItemRec(shopper: 1, listnumber: Int64(message["listnumber"] as! Int), locationnumber: message["locationnumber"] as! Int64, onList: true, quantity: 1, isAvailable: true, name: message["name"] as! String, dateLastPurchased: Date()) {
            DispatchQueue.main.async {
                if (message["name"] as! String) == self.modelitem?.initializeWatch {
                    self.modelitem?.items.removeAll()
                    self.modelLocation?.locations.removeAll()
                    self.usetransferUserInfo = self.usetransferUserInfoState
                } else {
                    self.modelLocation?.AddLocationToLocations(listnumber: message["listnumber"] as! Int, locationnumber: message["locationnumber"] as! Int64, name: message["locationname"] as! String)
                    self.modelitem?.items.append(aRec)
                    self.modelitem?.groupItemsByLocation()
                }
            }
        }
    }
    func sendItemToiOS(item: CKItemRec) {
        print("sendItemToiOS entry with \(item.name)")
        if session.isReachable {
            let data: [String: Any] = [
                "name": item.name
            ]
            if usetransferUserInfo {
                session.transferUserInfo(data)
            } else {
                // Sending a message with a errorHandler only
                session.sendMessage(data, replyHandler: nil, errorHandler: { error in
                    print("Error sending message: \(error.localizedDescription)")
                })
            }
        } else {
            print("session is not reachable")
        }
    }
    
}
