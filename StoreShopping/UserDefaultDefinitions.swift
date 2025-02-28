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
let ktransferUserInfoKey = "ktransferUserInfoKey"

// @AppStorage default values
// FIXME: check that all of these are being used
let kShoppingListIsMultiSectionDefaultValue = false
let kPurchasedListIsMultiSectionDefaultValue = false
let kPurchasedMostRecentlyDefaultValue = 3
let kDisableTimerWhenInBackgroundDefaultValue = false
let kMasterShopListListnumberDefaultValue = 1
let kMasterShopListNameDefaultValue = "Costco"
let ktransferUserInfoDefaultValue = true




class MasterValues: ObservableObject {
    // booleans to show various sheets
    // state to trigger a sheet to appear to add a new location
    @Published var isAddNewShopListSheetPresented: Bool
    @Published var isChangeShopListSheetPresented: Bool

    @Published var isAddNewLocationSheetPresented = false
    @Published var isChangeLocationSheetPresented = false

    // control to bring up a sheet used to add a new item
    @Published var isAddNewItemSheetPresented = false
    @Published var isChangeNewItemSheetPresented = false

    @Published var MasterShopperShopper: Int {
        willSet {
            MyDefaults().myMasterShopperShopper = newValue
            objectWillChange.send()
        }
    }
    
    @Published var isWatchAvailable: Bool = false
    
    init() {
        isAddNewShopListSheetPresented = false
        isChangeShopListSheetPresented = false
        MasterShopperShopper = MyDefaults().myMasterShopperShopper
    }

}
class MyDefaults {
    let defaults = UserDefaults.standard
    var developmentDeleting: Bool {
        get { return defaults.bool(forKey: "developmentDeleting") }
        set { defaults.setValue(newValue, forKey: "developmentDeleting") }
    }
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
        get {
            let thisdefault = aShopperRec
            return Int(thisdefault.shopper)
        }
        set {
            var ShopperRec = aShopperRec
            ShopperRec.shopper = Int64(newValue)
            aShopperRec = ShopperRec
        }

//        get { let thisdefault = defaults.integer(forKey: "myMasterShopperShopper")
//            if thisdefault == 0 {
//                return 1
//            } else {
//                return thisdefault
//            }
//        }
//        set { defaults.setValue(newValue, forKey: "myMasterShopperShopper") }
    }
    func removemyMasterShopperShopper() {
        defaults.removeObject(forKey: kMasterShopperKey)
    }
    var aShopperRec: ShopperCodable {
        get {
            guard let savedData = defaults.data(forKey: kMasterShopperKey) else  {
                print("error from guard aUser get")
                return ShopperCodable.UNKNOWN_SHOPPER
            }
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode(ShopperCodable.self, from: savedData) {
                return decoded
            }
            print("error from decoded aUser get")
            return ShopperCodable.UNKNOWN_SHOPPER
        }
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                let UserJson = encoded
                defaults.setValue(UserJson, forKey: kMasterShopperKey)
            }

        }
    }
}
