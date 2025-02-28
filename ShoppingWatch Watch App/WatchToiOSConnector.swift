//
//  watchToiOSConnector.swift
//  StoreShoppingWatch Watch App
//
//  Created by Brian Quick on 2024-07-04.
//
// got most of this code from youtube
//  How to Build Apple Watch Companion App in SwiftUI & Xcode
//  https://youtube.com/watch?v=QzwHU0Xu_EY

import SwiftUI
import Foundation
import WatchConnectivity

class WatchToiOSConnector: NSObject, WCSessionDelegate, ObservableObject {

   
    var session: WCSession
    var modelitem: ModelItem? = nil
    var modelLocation: ModelLocation? = nil
    
    // this determines the colour of the icons on the watch.
    // it is reset true at initialization of the watch load
    @Published var onlistColorSelector: Bool = true
    
    init(session: WCSession = .default) {
        
        self.session = session
        super.init()
        session.delegate = self
        if session.activationState == .notActivated {
            session.activate()
        }
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
        usetransferUserInfoState = false
                handleReceived(message: message)
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
                    self.onlistColorSelector = true
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
        print("activationState: s/b 2 -- \(WCSession.default.activationState.rawValue)") // Should be 2 (activated)
        if session.isReachable {
            let data: [String: Any] = [
                "name": item.name
            ]
            // try the sendMessage and if that fails, do the transferUserInfo ...
            //     still don't know how this works, but it works
            if WCSession.default.isReachable {
                WCSession.default.sendMessage(data, replyHandler: nil, errorHandler: { error in
                    print("Message failed, falling back to transferUserInfo: \(error.localizedDescription)")
                    WCSession.default.transferUserInfo(data)
                })
            } else {
                print("iPhone not reachable, using transferUserInfo")
                WCSession.default.transferUserInfo(data)
            }
        } else {
            print("session is not reachable")
        }
    }
    
}
