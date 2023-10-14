//
//  RegularMainView.swift
//  StoreShopping
//

import SwiftUI

// the RegularMainView is a two-column NavigationSplitView, where
// the first column has the same role that the TabView has in the
// CompactMainView.

struct RegularMainView: View {
	
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
			
			Label("Stopwatch", systemImage: "stopwatch")
				.tag(NavigationItem.inStoreTimer)
			
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
					case .shoppingList:
						ShoppingListView()
					case .purchasedList:
                    PurchasedItemsView()
                    // rbq added 2023-04-01
                    case .shopListList:
                        ShopListsView()
					case .locationList:
						LocationsView()
					case .inStoreTimer:
						TimerView()
					case .preferences:
						PreferencesView()
					case .none:	// selection is an optional type, but will never be nil
						Text(".none")
				}
			}
		}
		.navigationSplitViewStyle(.balanced)
			// note: this modifier comes from Stewart Lynch.  see NavAppearanceModifier.swift
		.navigationAppearance(backgroundColor: .systemGray6,
													foregroundColor: .systemBlue,
													tintColor: .systemBlue)
	}
}
