//
//  ShoppingWatchApp.swift
//  ShoppingWatch Watch App
//
//  Created by Brian Quick on 2024-07-14.
//

import SwiftUI

@main
struct ShoppingWatch_Watch_AppApp: App {
    @StateObject var modelitem = ModelItem()
    @StateObject var modelLocation = ModelLocation()
    var body: some Scene {
        WindowGroup {
            WatchContentView()
                .environmentObject(modelitem)
                .environmentObject(modelLocation)
        }
    }
}
