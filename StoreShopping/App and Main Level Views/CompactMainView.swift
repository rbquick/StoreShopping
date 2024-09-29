//
//  CompactMainView.swift
//  StoreShopping
//

import SwiftUI
import UIKit

struct CompactMainView: View {

    @EnvironmentObject var mastervalues: MasterValues
    @EnvironmentObject var modelitem: ModelItem
    @StateObject var watchConnector = WatchConnector()
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
            case .watch:
                WatchConnectorView()
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
            if UIDevice.isIPhone {
                if mastervalues.isWatchAvailable {
                    Rectangle()
                        .tabItem { Label("Watch", systemImage: "applewatch.and.arrow.forward") }
                        .tag(NavigationItem.watch)
                } else {
                    Rectangle()
                        .tabItem { Label("Preferences", systemImage: "gear") }
                        .tag(NavigationItem.preferences)
                }
            }
            
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

