//
//  CompactMainView.swift
//  StoreShopping
//

import SwiftUI

struct CompactMainView: View {

    // what screen do you want to show 1st
    @State private var selection: NavigationItem = .shoppingList
    @State private var navPath = NavigationPath()

    var body: some View {
                NavigationStack {
            switch selection {
            case .shopListList:
                ShopListsView()
            case .shoppingList:
                ShoppingListView()
            case .purchasedList:
                PurchasedItemsView()
            case .locationList:
                LocationsView()
            case .inStoreTimer:
                TimerView()
            case .preferences:
                PreferencesView()
            }
        }

        Spacer()
        Text("Selected Tag: \(selection.rawValue)")
            .foregroundColor(.clear)
            .frame(width: 0, height: 0)
        TabView(selection: $selection) {
            Rectangle()
                .tabItem { Label("Lists", systemImage: "list.bullet.rectangle.portrait") }
                .tag(NavigationItem.shopListList)
            Rectangle()
                .tabItem { Label("Shopping List", systemImage: "cart") }
                .tag(NavigationItem.shoppingList)
            Rectangle()
                .tabItem { Label("Selection", systemImage: "purchased") }
                .tag(NavigationItem.purchasedList)
            Rectangle()
                .tabItem { Label("Locations", systemImage: "map") }
                .tag(NavigationItem.locationList)
            Rectangle()
                .tabItem { Label("Preferences", systemImage: "gear") }
                .tag(NavigationItem.preferences)
        } // end of TabView
        // This frame works on an iphone8
        // There s/b be a better was to put the tabview at
        //   the bottom of the screen.
        .frame(height: 40)

        .onAppear(perform: myOnAppear)
        

    } // end of var body: some View
    func myOnAppear() {
        navPath.removeLast(navPath.count)
        if let storedSelection = UserDefaults.standard.value(forKey: "SelectedNavigationItem") as? Int,
           let retrievedSelection = NavigationItem(rawValue: storedSelection) {
            selection = retrievedSelection
        }
    }
}

