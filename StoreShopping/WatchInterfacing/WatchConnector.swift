//
//  WatchConnector.swift
//  StoreShopping
//
//  Created by Brian Quick on 2024-07-04.
//

import SwiftUI
import Foundation
import WatchConnectivity
import CloudKit

class WatchConnector: NSObject, WCSessionDelegate, ObservableObject {

   
    var session: WCSession
    var modelitem: ModelItem? = nil
    var modelLocation: ModelLocation? = nil
    
    init(session: WCSession = .default) {
        
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    // user default. what to use when sending data to/from the watch
    @AppStorage(ktransferUserInfoKey)
    private var usetransferUserInfo = ktransferUserInfoDefaultValue
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        print("ios activationDidCompleteWith activationState: \(WCSessionActivationState.RawValue())" )
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("ios sessionDidBecomeInactive activationState: \(WCSessionActivationState.RawValue())" )
        session.activate()
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Activate the new session after having switched to a new watch.
        print("ios sessionDidDeactivate activationState: \(WCSessionActivationState.RawValue())" )
        session.activate()
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("IOS didReceiveMessage: \(message)")
        handleReceived(message: message)
    }
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("IOS - didReceiveUserInfo", userInfo)
        handleReceived(message: userInfo)
    }
    func handleReceived(message: [String : Any]) {
        if let name = message["name"] as? String {
            if let index = modelitem?.items.firstIndex(where: {$0.name == name }) {
                DispatchQueue.main.async {
                    let aRec: CKItemRec = CKItemRec(record: self.modelitem!.items[index].record)!
                    self.modelitem!.setOnListStatus(item: aRec, onlist: false)
                }
            }
                
        }
    }
    // only send the item if it is on the list.  all items pass through here since
    // we need to initialize the watch on the first item in the list whether it is going to
    // be send or not
    func sendItemToWatch(item: CKItemRec, initialize: Bool = false) {
        if initialize {
            let aRec = CKItemRec(shopper: 1, listnumber: 1, locationnumber: 1, onList: true, quantity: 1, isAvailable: true, name: modelitem!.initializeWatch, dateLastPurchased: Date())!
            sendOneItemToWatch(item: aRec)
        }
        if item.onList {
            sendOneItemToWatch(item: item)
        }
        
    }
    func sendOneItemToWatch(item: CKItemRec) {
        print("sendItemToWatch entry with \(item.name)")
        if session.isReachable {
            let data: [String: Any] = [
                "name": item.name,
                "locationnumber": item.locationnumber,
                "locationname": modelLocation?.GetLocationNameByLocationnumber(locationnumber: item.locationnumber) ?? "unKnown",
                "listnumber" :modelLocation?.GetvisitationOrderByLocationnumber(locationnumber: item.locationnumber) ?? 1
            ]
            if usetransferUserInfo {
                session.transferUserInfo(data)
            } else {
                session.sendMessage(data, replyHandler: nil) {error in
                    print(error.localizedDescription)
                }
            }
        } else {
            print("watch session is not reachable")
        }
    }
}
