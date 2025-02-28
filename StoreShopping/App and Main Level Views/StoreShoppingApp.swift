//
//  ShoppingListApp.swift
//  StoreShopping
//

import Foundation
import SwiftUI

/*
the App creates both the (global, singleton) PersistentStore and a Today object
as @StateObjects
new in this version is that we have the App create the InStoreTimer as well and
push that into the environment, for use with the TimerTabView.
we also attach .onReceive modifiers to the MainView to watch being moved into
and out of the background.
*/

@main
struct StoreShoppingApp: App {
	
//	@StateObject var persistentStore: PersistentStore
    // since adding the login, the AuthViewModel HAS to be first to initialize
    // it is setting things that are required on the initial screen presentation
    @StateObject var authviewModel = AuthViewModel()
    @StateObject var mastervalues = MasterValues()
    @StateObject var modelshopper = ModelShopper()
    @StateObject var modelshoplist = ModelShopList()
    @StateObject var modellocation = ModelLocation()
    @StateObject var modelitem = ModelItem()
    @StateObject var modelitemsection = ModelItemSection()
    @StateObject var inStoreTimer = InStoreTimer()
    @StateObject var watchConnector = WatchConnector()

    @Environment(\.scenePhase) var scenePhase
	let resignActivePublisher =
		NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
	let enterForegroundPublisher =
		NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
	
	init() {
		// this is done in an init so we can create the persistentStore, set up
		// the App's @StateObject for it, and also set the static (class) variables
		// for Item and Location classes so they can access the store
		//and its context.
//		let store = PersistentStore()
//		Item.persistentStore = store
//		Location.persistentStore = store
//        ShopList.persistentStore = store
//		_persistentStore = StateObject(wrappedValue: store)
        whereIsMySQLite()
	}
	
	var body: some Scene {
		WindowGroup {
            Group {
                    MainView()
                    .environmentObject(authviewModel)
                    .environmentObject(inStoreTimer)
                    .environmentObject(mastervalues)
                    .environmentObject(modelshopper)
                    .environmentObject(modelshoplist)
                    .environmentObject(modellocation)
                    .environmentObject(modelitem)
                    .environmentObject(modelitemsection)
                    .environmentObject(watchConnector)
                
            }

//                .onChange(of: scenePhase) { newPhase in
//                    if modelitem.items.count > 0 {
//                        if newPhase == .active {
//                            print("Active")
//                            // refresh all the tables on active
//                            // use the items array since it will have the proper
//                            //   shopper / list for the refresh
//                            modelshoplist.getAll(shopper: Int(modelitem.items[0].shopper))
//                            modellocation.getAll(shopper: Int(modelitem.items[0].shopper), listnumber: Int(modelitem.items[0].listnumber))
//                            modelitem.getAll(shopper: Int(modelitem.items[0].shopper), listnumber: Int(modelitem.items[0].listnumber))
//                        } else if newPhase == .inactive {
//                            print("Inactive")
//                        } else if newPhase == .background {
//                            print("Background")
//                        }
//                    }
//                }
		}
	}
    // rbq added 2023-03-31
    // got this from from a stackoverflow answer for where is my core data database
    // https://stackoverflow.com/questions/10239634/how-can-i-check-what-is-stored-in-my-core-data-database
    func whereIsMySQLite() {
        let path = FileManager
            .default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .last?
            .absoluteString
            .replacingOccurrences(of: "file://", with: "")
            .removingPercentEncoding

        print(path ?? "Not found")
    }


    // TODO
	func handleResignActive(_ note: Notification) {
			// when going into background, save Core Data and shut down timer
	//	persistentStore.save()
		inStoreTimer.suspendForBackground()
	}

	func handleBecomeActive(_ note: Notification) {
			// when app becomes active, restart timer if it was running previously.
			// also update the meaning of Today because we may be transitioning to
			// active on a different day than when we were pushed into the background
        // don't have to do the Today thing from the original code since the date
        //    will be recalc's at app coming into view
		if inStoreTimer.isSuspended {
			inStoreTimer.start()
		}
	}

}
