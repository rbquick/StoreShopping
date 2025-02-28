//
//  WatchConnector.swift
//  StoreShopping
//
//  Created by Brian Quick on 2024-07-04.
//
//
/*
 ✅ 3. Use Background Execution Mode

 If the iPhone app is in the background, it may not receive data immediately. Enable background execution for Watch Connectivity in your iPhone's Info.plist:

 Open Xcode → Select your iPhone app target.
 Go to Signing & Capabilities → Click + Capability → Add Background Modes.
 Enable "Uses Bluetooth LE Accessories" and "Acts as a Bluetooth LE Accessory".
 */

import SwiftUI
import Foundation
import WatchConnectivity
import CloudKit

class WatchConnector: NSObject, WCSessionDelegate, ObservableObject {

//   static let shared = WatchConnector()
    var session: WCSession
    var modelitem: ModelItem? = nil
    var modelLocation: ModelLocation? = nil
    
    @Published var sendMessageSucceedded: Bool = false
    
    init(session: WCSession = .default) {
        
        self.session = session
        super.init()
        session.delegate = self
        if session.activationState == .notActivated {
            print("WatchConnector: activating session")
            session.activate()
        }
    }
    
    // user default. what to use when sending data to/from the watch
    @AppStorage(ktransferUserInfoKey)
    private var usetransferUserInfo = ktransferUserInfoDefaultValue
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        print("ios activationDidCompleteWith activationState: \(WCSessionActivationState.RawValue())" )
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("ios sessionDidBecomeInactive activationState: \(WCSessionActivationState.RawValue())" )
        if session.activationState == .notActivated {
            session.activate()
        }
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Activate the new session after having switched to a new watch.
        print("ios sessionDidDeactivate activationState: \(WCSessionActivationState.RawValue())" )
        if session.activationState == .notActivated {
            session.activate()
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("IOS didReceiveMessage: \(message)")
        handleReceived(message: message)
    }
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("IOS - didReceiveUserInfo", userInfo)
        handleReceived(message: userInfo)
    }
    // take the item off the watch's list
    //  only if it is onList ... we do not want it to reappear
    func handleReceived(message: [String : Any]) {
        if let name = message["name"] as? String {
            if let index = modelitem?.items.firstIndex(where: {$0.name == name }) {
                DispatchQueue.main.async {
                    let aRec: CKItemRec = CKItemRec(record: self.modelitem!.items[index].record)!
                    if aRec.onList {
                        self.modelitem!.setOnListStatus(item: aRec, onlist: false)
                    }
                }
            }
                
        }
    }
    // only send the item if it is on the list.  all items pass through here since
    // we need to initialize the watch on the first item in the list whether it is going to
    // be send or not
    func sendItemToWatch(item: CKItemRec, initialize: Bool = false) {
        if initialize {
            print("WCSession activated: \(WCSession.default.activationState == .activated)")
            print("isPaired: \(WCSession.default.isPaired)")
            print("isWatchAppInstalled: \(WCSession.default.isWatchAppInstalled)")
            print("activationState: s/b 2 -- \(WCSession.default.activationState.rawValue)") // Should be 2 (activated)
            let aRec = CKItemRec(shopper: 1, listnumber: 1, locationnumber: 1, onList: true, quantity: 1, isAvailable: true, name: modelitem!.initializeWatch, dateLastPurchased: Date())!
            sendOneItemToWatch(item: aRec)
        }
        if item.onList {
            sendOneItemToWatch(item: item)
        }
        
    }
    func sendOneItemToWatch(item: CKItemRec) {
        print("sendItemToWatch entry with \(item.name)")
        sendMessageSucceedded = true
//        if session.isReachable {
            let data: [String: Any] = [
                "name": item.name,
                "locationnumber": item.locationnumber,
                "locationname": modelLocation?.GetLocationNameByLocationnumber(locationnumber: item.locationnumber) ?? "unKnown",
                "listnumber" :modelLocation?.GetvisitationOrderByLocationnumber(locationnumber: item.locationnumber) ?? 1
            ]
        session.sendMessage(data, replyHandler: { response in
            // ✅ Message was received successfully on the Watch
            DispatchQueue.main.async {
                self.sendMessageSucceedded = true
                print("✅ sendMessage succeeded")
            }
        }, errorHandler: { error in
            // ❌ Message failed
            DispatchQueue.main.async {
                self.sendMessageSucceedded = false
                print("❌ sendMessage failed: \(error.localizedDescription)")

                // 🔄 Use transferUserInfo as a backup
                print("🔄 Trying transferUserInfo as a fallback")
                self.session.transferUserInfo(data)
            }
        })
//              this is supposed to wake up the app on the watch ... it does not
//                print("trying transferUserInfo")
//                self.session.transferUserInfo(data)
                            }
//        } else {
//            print("watch session is not reachable")
//        }
    }

