//
//  UserDefaultDefinitions.swift
//  StoreShopping
//
//  Created by Brian Quick on 2023-09-29.
//

import Foundation

// @AppStorage keys
// FIXME: check that all of these are being used
let kShoppingListIsMultiSectionKey = "kShoppingListIsMultiSectionKey"
let kPurchasedListIsMultiSectionKey = "kPurchasedListIsMultiSectionKey"
let kPurchasedMostRecentlyKey = "kPurchasedMostRecentlyKey"
let kDisableTimerWhenInBackgroundKey = "kDisableTimerWhenInBackgroundKey"
let kMasterShopperKey = "kMasterShopperKey"
let kMasterShopListNameKey = "kMasterShopListNameKey"

// @AppStorage default values
// FIXME: check that all of these are being used
let kShoppingListIsMultiSectionDefaultValue = false
let kPurchasedListIsMultiSectionDefaultValue = false
let kPurchasedMostRecentlyDefaultValue = 3
let kDisableTimerWhenInBackgroundDefaultValue = false
let kMasterShopListListnumberDefaultValue = 1
let kMasterShopListNameDefaultValue = "Costco"




class MasterValues: ObservableObject {
    // booleans to show various sheets
    // state to trigger a sheet to appear to add a new location
    @Published var isAddNewShopListSheetPresented: Bool
    @Published var isChangeShopListSheetPresented: Bool

    @Published var isAddNewLocationSheetPresented = false
    @Published var isChangeLocationSheetPresented = false


    @Published var MasterShopperShopper: Int {
        willSet {
            MyDefaults().myMasterShopperShopper = newValue
            objectWillChange.send()
        }
    }
    init() {
        isAddNewShopListSheetPresented = false
        isChangeShopListSheetPresented = false
        MasterShopperShopper = MyDefaults().myMasterShopperShopper
    }

}
class MyDefaults {
    let defaults = UserDefaults.standard
    var myMasterShopperName: String {
        get { return defaults.string(forKey: "myMasterShopperName") ?? "Sandra" }
        set { defaults.setValue(newValue, forKey: myMasterShopperName) }
    }
    var myMasterShopListListnumber: Int {
        get { let thisdefault = defaults.integer(forKey: "myMasterShopListListnumber")
            if thisdefault == 0 {
                return 1
            } else {
                return thisdefault
            }
        }
        set { defaults.setValue(newValue, forKey: "myMasterShopListListnumber") }
    }
    var myMasterShopListName: String {
        get { return defaults.string(forKey: kMasterShopListNameKey) ?? kMasterShopListNameDefaultValue }
        set { defaults.setValue(newValue, forKey: kMasterShopListNameKey) }
    }
    var myMasterShopperShopper: Int {
        get { let thisdefault = defaults.integer(forKey: "myMasterShopperShopper")
            if thisdefault == 0 {
                return 1
            } else {
                return thisdefault
            }
        }
        set { defaults.setValue(newValue, forKey: "myMasterShopperShopper") }
    }
}
