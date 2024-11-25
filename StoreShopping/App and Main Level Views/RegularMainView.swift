//
//  RegularMainView.swift
//  StoreShopping
//

import SwiftUI
import UIKit

// the RegularMainView is a two-column NavigationSplitView, where
// the first column has the same role that the TabView has in the
// CompactMainView.

struct RegularMainView: View {
    @EnvironmentObject var mastervalues: MasterValues
    @StateObject var watchConnector = WatchConnector()
    @State private var selection: NavigationItem? = .shoppingList
	
	var sidebarView: some View {
		List(selection: $selection) {
			
            // rbq added 2023-04-01
            Label("Lists", systemImage: "list.bullet.rectangle.portrait")
                .tag(NavigationItem.shopListList)

			Label("Shopping List", systemImage: "cart")
				.tag(NavigationItem.shoppingList)
			
			Label("Selection", systemImage: "purchased")
				.tag(NavigationItem.purchasedList)
			
			Label("Locations", systemImage: "map")
				.tag(NavigationItem.locationList)
            if UIDevice.isIPhone {
//                if mastervalues.isWatchAvailable {
                    Label("Watch", systemImage: "applewatch.and.arrow.forward")
                        .tag(NavigationItem.watch)
//                }
            }
//			Label("Stopwatch", systemImage: "stopwatch")
//				.tag(NavigationItem.inStoreTimer)
			
			Label("Preferences", systemImage: "gear")
				.tag(NavigationItem.preferences)
			
		}
	}
	
	var body: some View {
		NavigationSplitView(columnVisibility: .constant(.automatic)) {
			sidebarView
				.navigationSplitViewColumnWidth(250)
		} detail: {
			NavigationStack {
				switch selection {
                    case .purchasedList:
                    PurchasedItemsView()
                case .shoppingList:
                    ShoppingListView()
                    // rbq added 2023-04-01
                    case .shopListList:
                        ShopListsView()
					case .locationList:
						LocationsView()
                    case .watch:
                        WatchConnectorView()
					case .inStoreTimer:
						TimerView()
					case .preferences:
						PreferencesView()
					case .none:	// selection is an optional type, but will never be nil
						Text(".none")
				}
			}
		}
        .onAppear(perform: myOnAppear)
		.navigationSplitViewStyle(.balanced)
			// note: this modifier comes from Stewart Lynch.  see NavAppearanceModifier.swift
		.navigationAppearance(backgroundColor: .systemGray6,
													foregroundColor: .systemBlue,
													tintColor: .systemBlue)
	}
    func myOnAppear() {
        if let storedSelection = UserDefaults.standard.value(forKey: "SelectedNavigationItem") as? Int,
           let retrievedSelection = NavigationItem(rawValue: storedSelection) {
            selection = retrievedSelection
        }
        activateWatch()
    }
    func activateWatch() {
        if watchConnector.session.isReachable {
            mastervalues.isWatchAvailable = true
        } else {
            mastervalues.isWatchAvailable = false
        }
    }
}
