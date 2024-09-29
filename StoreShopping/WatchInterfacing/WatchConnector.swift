//
//  WatchConnector.swift
//  StoreShopping
//
//  Created by Brian Quick on 2024-07-04.
//

import Foundation
import WatchConnectivity

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
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        print("ios activationDidCompleteWith activationState: \(WCSessionActivationState.RawValue())" )
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Activate the new session after having switched to a new watch.
        session.activate()
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("IOS didReceiveMessage: \(message)")
        if let name = message["name"] as? String {
            if let index = modelitem?.items.firstIndex(where: {$0.name == name }) {
                DispatchQueue.main.async {
                    self.modelitem?.items[index].onList = false
                }
            }
                
        }
    }
    
    func sendItemToWatch(item: CKItemRec, initialize: Bool = false) {
        if initialize {
            let aRec = CKItemRec(shopper: 1, listnumber: 1, locationnumber: 1, onList: true, quantity: 1, isAvailable: true, name: modelitem!.initializeWatch, dateLastPurchased: Date())!
            sendOneItemToWatch(item: aRec)
        }
        sendOneItemToWatch(item: item)
        
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
            session.sendMessage(data, replyHandler: nil) {error in
                print(error.localizedDescription)
            }
        } else {
            print("watch session is not reachable")
        }
    }
}
