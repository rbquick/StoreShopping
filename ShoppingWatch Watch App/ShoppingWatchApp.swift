//
//  ShoppingWatchApp.swift
//  ShoppingWatch Watch App
//
//  Created by Brian Quick on 2024-07-14.
//
/*
 some things to check out for making the watch app work
 
 Yep, check out the WatchConnectivity WWDC 2015 sesison or have a look at the docmumentation:
 https://developer.apple.com/library/prerelease/ios/documentation/WatchConnectivity/Reference/WatchConnectivity_framework/index.html
 Basically If you use sendMessage() on the WatchKit extension that will wake the iPhone app straight away to receive the data
 Or you could use transferCurrentUserInfo() to queue data on the phone ready to be received as soon as the iPhone app is next launched.
 Finally I also recommend this tutorial and other WatchConnectivity ones on the site:
 http://www.kristinathai.com/watchos-2-how-to-communicate-between-devices-using-watch-connectivity/
 Their very easy to follow and have code examples too.
 */

import SwiftUI

@main
struct ShoppingWatch_Watch_AppApp: App {
    @StateObject var modelitem = ModelItem()
    @StateObject var modelLocation = ModelLocation()
    @StateObject var watchToiOSConnector = WatchToiOSConnector()
    var body: some Scene {
        WindowGroup {
            WatchContentView()
                .environmentObject(modelitem)
                .environmentObject(modelLocation)
                .environmentObject(watchToiOSConnector)
        }
    }
}
