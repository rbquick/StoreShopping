//
//  OperationTabView.swift
//  ShoppingList
//
//  Created by Jerry on 6/11/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI
import CloudKit

struct PreferencesView: View {

    // this view is a restructured version of the older DevToolTab to now handle
    // user preferences.  for the moment, the only preference we have is for
    // setting the number of days back in time to section out the item in the
    // PurchasedItemsView:
    // -- first section: items purchased within the last N days
    // -- second section: all other items purchased.
    // we'll allow N here to be 0 ... 10

    // in SL16, i have added a preference for whether to disable a running timer
    // when in the background; and i have cleaned up the view code so i can really
    // read and understand some of what was written three years ago (!)

    @State private var confirmDataHasBeenAdded = false
    @State private var shoplistsAdded: Int = 0
    @State private var locationsAdded: Int = 0
    @State private var itemsAdded: Int = 0
    @State private var returnedMessage: String = ""




    // user default. 0 = purchased today; 3 = purchased up to 3 days ago, ...
    @AppStorage(kPurchasedMostRecentlyKey)
    private var historyMarker = kPurchasedMostRecentlyDefaultValue

    // user default.  true ==> turn of timer (counting) when in the background.
    @AppStorage(kDisableTimerWhenInBackgroundKey)
    private var suspendTimerWhenInBackground = kDisableTimerWhenInBackgroundDefaultValue

    // rbq added 2023-03-30
    // this is the @FetchRequest that ties this view to CoreData Locations
    @EnvironmentObject var modelshopper: ModelShopper
    @EnvironmentObject var modelshoplist: ModelShopList
    @EnvironmentObject var modellocation: ModelLocation
    @EnvironmentObject var modelitem: ModelItem
    // FIXME: remove these as they get replaced
    //    @FetchRequest(fetchRequest: Location.allLocationsPreferences())
    //    private var locations: FetchedResults<Location>
    //    @FetchRequest(fetchRequest: Item.allItemsPreferences())
    //    private var items: FetchedResults<Item>
    var body: some View {
        Form {
            Section(header: Text("Purchased Items History Mark"),
                    footer: Text("Sets the number of days to look backwards in time to separate out items purchased recently.")) {
                Stepper(value: $historyMarker, in: 0...10) {
                    HStack {
                        SLFormLabelText(labelText: "History mark: ")
                        Text("\(historyMarker)")
                    }
                }
            }

            Section(header: Text("Timer Preference"),
                    footer: Text("Turn this on if you want the timer to pause, say, while you are on a phone call")) {
                Toggle(isOn: $suspendTimerWhenInBackground) {
                    Text("Suspend when in background")
                }
            }

            if kShowDevTools {
                Section("Developer Actions") {
                    List {
                        // 1.  load sample data
                        Button("Load Sample Data") {
                              loadSampleData()
                        }
                        .myCentered()
//                        .disabled(modelshoplist.shoplists.count > 0)

                        // 2. offload data as JSON
                        Button("Write database as JSON") {
                            deleteAllData()
                            //  writeDatabase()
                        }
                        .myCentered()
                        // rbq added 2023-03-30
                        // 3.  Delete sample data
                        Button("Delete All Data") {
                            deleteAllData()
                        }
                        .myCentered()
                        .disabled(modelshoplist.shoplists.count == 0)
                        // 4.  refresh the data
                        Button("Refresh All Data") {
                            modelshoplist.getAll(shopper: MyDefaults().myMasterShopperShopper)
                            modelshopper.getAll()
                            modelitem.getAll(shopper: MyDefaults().myMasterShopperShopper, listnumber: MyDefaults().myMasterShopListListnumber)
                        }
                        .myCentered()
                    } // end of List
                    .listRowSeparator(.automatic)
                    VStack {
                        List {
                            ForEach(modelitem.items) { item in
                                Text("\(item.shopper) - \(item.listnumber) - \(item.name)")
                            }
                        }
                    }
                } // end of Section
                            } // end of if kShowDevTools
            } // end of Form
                .navigationBarTitle("Preferences")
                .alert("Data Added", isPresented: $confirmDataHasBeenAdded) {
                    Button("OK", role: .none) { }
                } message: {
                    Text("Sample data for the app (\(shoplistsAdded) shopping lists \(locationsAdded) locations and \(itemsAdded) shopping items) have been added.")
                }
        } // end of var body: some View

            func loadSampleData() {
                let currentShopListCount = modelshoplist.shoplists.count // rbq added 2023-03-31
//                let currentLocationCount = Location.count() // what it is now
//                let currentItemCount = Item.count() // what it is now
//                populateDatabaseFromJSON(persistentStore: persistentStore)
//                loadShopingLists()
//                loadShoppers()
//                loadLocations()
                loadItems()
                shoplistsAdded = modelshoplist.shoplists.count - currentShopListCount // rbq added 2023-03-31
//                locationsAdded = Location.count() - currentLocationCount // now the differential
//                itemsAdded = Item.count() - currentItemCount // now the differential
                confirmDataHasBeenAdded = true
            }

    func loadItems() {
        guard let url = Bundle.main.url(forResource: "items", withExtension: "json")
        else {
            print("Json file not found")
            return
        }
        let data = try? Data(contentsOf: url)
        do {
            let decoder = JSONDecoder()
            let jsonData  = try decoder.decode(ItemsCodable.self, from: data!)
            var myrecords = [CKRecord]()
            for item in jsonData.ItemCodables { let location = modellocation.GetLocationByName(for: item.locationName)
                let myrecord = CKRecord(recordType: myRecordType.Item.rawValue)
                myrecord["shopper"] = location.shopper
                myrecord["listnumber"] = location.listnumber
                myrecord["locationnumber"] = location.locationnumber
                myrecord["onList"] = item.onList
                myrecord["quantity"] = item.quantity
                myrecord["isAvailable"] = item.isAvailable
                myrecord["name"] = item.name
                myrecords.append(myrecord)
                print(item.name)
            }

            if myrecords.count > 0 {
                CloudKitUtility.saveAllRecords(myrecords)
            }
        } catch {
            print(error.localizedDescription)
            return
        }


    }
    func loadLocations() {
        var mylists = [LocationCodable]()
        guard let url = Bundle.main.url(forResource: "locations", withExtension: "json")
                   else {
                       print("Json file not found")
                       return
                   }

               let data = try? Data(contentsOf: url)
        do {
            let decoder = JSONDecoder()
            let shoplists = try decoder.decode([LocationCodable].self, from: data!)
            mylists = shoplists

            var myrecords = [CKRecord]()
            for mylist in mylists {
                let myrecord = CKRecord(recordType: myRecordType.Location.rawValue)
                myrecord["shopper"] = mylist.shopper
                myrecord["listnumber"] = mylist.listnumber
                myrecord["locationnumber"] = mylist.locationnumber
                myrecord["name"] = mylist.name
                myrecord["visitationOrder"] = mylist.visitationOrder
                myrecord["red"] = mylist.red
                myrecord["green"] = mylist.green
                myrecord["blue"] = mylist.blue
                myrecord["opacity"] = mylist.opacity
                myrecords.append(myrecord)
            }
            if myrecords.count > 0 {
                CloudKitUtility.saveAllRecords(myrecords)
            }
        } catch {
            print(error.localizedDescription)
        }
        return
    }

    func loadShopingLists() {
        var mylists = [ShopListCodable]()
        guard let url = Bundle.main.url(forResource: "shoplists", withExtension: "json")
                   else {
                       print("Json file not found")
                       return
                   }

               let data = try? Data(contentsOf: url)
        do {
            let decoder = JSONDecoder()
            let shoplists = try decoder.decode([ShopListCodable].self, from: data!)
            mylists = shoplists

            var myrecords = [CKRecord]()
            for mylist in mylists {
                let myrecord = CKRecord(recordType: myRecordType.ShopList.rawValue)
                myrecord["shopper"] = mylist.shopper
                myrecord["listnumber"] = mylist.listnumber
                myrecord["name"] = mylist.name
                myrecords.append(myrecord)
            }
            if myrecords.count > 0 {
                CloudKitUtility.saveAllRecords(myrecords)
            }
        } catch {
            print(error.localizedDescription)
        }
        return
    }

    func loadShoppers() {
        var mylists = [ShopperCodable]()
        guard let url = Bundle.main.url(forResource: "shoppers", withExtension: "json")
                   else {
                       print("Json file not found")
                       return
                   }

               let data = try? Data(contentsOf: url)
        do {
            let decoder = JSONDecoder()
            let shoppers = try decoder.decode([ShopperCodable].self, from: data!)
            mylists = shoppers

            var myrecords = [CKRecord]()
            for mylist in mylists {
                let myrecord = CKRecord(recordType: myRecordType.Shopper.rawValue)
                myrecord["shopper"] = mylist.shopper
                myrecord["name"] = mylist.name
                myrecords.append(myrecord)
            }
            if myrecords.count > 0 {
                CloudKitUtility.saveAllRecords(myrecords)
            }
        } catch {
            print(error.localizedDescription)
        }
        return
    }


    // delete all the items on and off the list before the locations
    func deleteAllData() {
        //        print("Items On:  \(items.count)")
        //        for item in items {
        //            Item.delete(item)
        //        }
        //        print("Locations: \(locations.count)")
        //        for location in locations {
        //            Location.delete(location)
        //        }
//        print("Shoppers: \(modelshopper.shoppers.count)")
//        for shopper in modelshopper.shoppers  {
//
//            modelshopper.delete(shopper: shopper) { rtnMessage in
//                returnedMessage = rtnMessage
//                print(returnedMessage)
//            }
//        }
//        modelshopper.shoppers.removeAll()
//        print("ShopLists: \(modelshoplist.shoplists.count)")
//        for shoplist in modelshoplist.shoplists  {
//
//            modelshoplist.delete(shoplist: shoplist) { rtnMessage in
//                returnedMessage = rtnMessage
//                print(returnedMessage)
//            }
//        }
//        modelshoplist.shoplists.removeAll()
        for item in modelitem.items  {

            modelitem.delete(item: item) { rtnMessage in
                returnedMessage = rtnMessage
                print(returnedMessage)
            }
        }
        modelitem.items.removeAll()
    }
} // end of struct
struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
            .environmentObject(ModelLocation())
            .environmentObject(MasterValues())
            .environmentObject(InStoreTimer())
            .environmentObject(ModelShopper())
            .environmentObject(ModelShopList())
            .environmentObject(ModelLocation())
            .environmentObject(ModelItem())
    }
}
