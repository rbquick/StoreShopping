//
//  ShoppingListApp.swift
//  StoreShopping
//

import Foundation
import SwiftUI

/*
 the app will hold an object of type Today, which keeps track of the "start of today."
 the PurchasedItemsView needs to know what "today" means to properly section out
 its data, and it might seem to you that the PurchasedItemsView could handle that by
 itself.  however, if you push the app into the background when the PurchasedItemsView
 is showing and then bring it back a few days later, the PurchasedItemsView will show
 the same display as when it went into the background and not know about the change;
 so its view will need to be updated.  that's why this is here: the app certainly
 knows when it becomes active, can update what "today" means, and the
 PurchasedItemsView will pick up on that in its environment
 */

class Today: ObservableObject {
	@Published var start: Date = Calendar.current.startOfDay(for: Date())
	
	func update() {
		let newStart = Calendar.current.startOfDay(for: Date())
		if newStart != start {
			start = newStart
		}
	}
}

/*
the App creates both the (global, singleton) PersistentStore and a Today object
as @StateObjects and pushes the managedObjectContext of the PersistentStore
and the Today object into the SwiftUI environment.
new in this version is that we have the App create the InStoreTimer as well and
push that into the environment, for use with the TimerTabView.
we also attach .onReceive modifiers to the MainView to watch being moved into
and out of the background.
*/

@main
struct StoreShoppingApp: App {
	
//	@StateObject var persistentStore: PersistentStore
    @StateObject var mastervalues = MasterValues()
    @StateObject var modelshopper = ModelShopper()
    @StateObject var modelshoplist = ModelShopList()
    @StateObject var modellocation = ModelLocation()
    @StateObject var modelitem = ModelItem()
	@StateObject var today = Today()
	@StateObject var inStoreTimer = InStoreTimer()
	
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
			MainView()
             //   .environmentObject(today)
                .environmentObject(inStoreTimer)
                .environmentObject(mastervalues)
                .environmentObject(modelshopper)
                .environmentObject(modelshoplist)
                .environmentObject(modellocation)
                .environmentObject(modelitem)
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
		if inStoreTimer.isSuspended {
			inStoreTimer.start()
		}
		today.update()
	}

}
