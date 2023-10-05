//
//  NavigationItem.swift
//  ShoppingList
//
//  Created by Brian Quick on 2023-04-05.
//  Copyright © 2023 Jerry. All rights reserved.
//


import SwiftUI

enum NavigationItem: Int {
    case shoppingList
    case purchasedList
    case shopListList           // rbq added 2023-04-01
    case locationList
    case inStoreTimer
    case preferences
    var tag: Int {
        return self.rawValue
    }
}
