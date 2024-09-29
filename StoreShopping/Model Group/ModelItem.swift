//
//  ModelItem.swift
//  StoreShopping
//
//  Created by Brian Quick on 2023-10-07.
//

import Foundation
import CloudKit
import Combine
import SwiftUI

class ModelItem: ObservableObject {
    @Published var items = [CKItemRec]()
    @Published var groupedItems = [Int64: [CKItemRec]]()    // grouped items for the watch view
    @Published var itemsFinishedCount = 0


    var cancellables = Set<AnyCancellable>()
    let initializeWatch = "initializeWatch"

    var isTracing: Bool = true
    func tracing(function: String) {
        if isTracing {
            print("ModelItem \(function) ")
            Logger.log("ModelItem \(function)")
        }
    }

    init() {
        #if os(iOS)
        createItems()
        #endif
    }
    func createItems() {
        items.removeAll()
        getAll(shopper: MyDefaults().myMasterShopperShopper, listnumber: MyDefaults().myMasterShopListListnumber)
    }
    
    // count the items in the list that have been selected for the watch display
    var onListItemCount: Int {
        return items.filter { $0.onList }.count
    }
    
    func addOrUpdate(item: CKItemRec, _ completion: @escaping (String) -> ()) {
       tracing(function: "addOrUpdate")
        let index = items.firstIndex(where: { $0.id == item.id } )
        var message = "Adding item"
        if index != nil {
             message = "Changing item index: \(index ?? 0)"
        }
        CloudKitUtility.update(item: item)
            .receive(on: DispatchQueue.main)
            .sink { c in
                switch c {
                case .finished:
                    self.tracing(function: message)
                    completion(message)
                case .failure(let error):
                    self.tracing(function: "addOrUpdate error = \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] returnedItems in
                if index != nil {
                    self?.items[index ?? 1] = item
                } else {
                    self?.items.append(item)
                }
            }
            .store(in: &cancellables)

    }
    func countOfItemsAtLocation(listnumber: Int64, locationnumber: Int64) -> Int {
        let cou = items.reduce(0) { $0 + Int((($1.listnumber == listnumber) && ($1.locationnumber == locationnumber)) ? 1 : 0)  }
        return cou
    }
    func delete(item: CKItemRec, completion: @escaping (String) -> ()) {
        tracing(function: "delete")
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        CloudKitUtility.delete(item: item)
            .receive(on: DispatchQueue.main)
            .sink { c in
                switch c {
                case .finished:
                    self.tracing(function: "delete .finished")
                    completion("Item deleted")
                case .failure(let error):
                    self.tracing(function: "delete error = \(error.localizedDescription)")
                    completion("delete error = \(error.localizedDescription)")
                }
            } receiveValue: { success in
#warning("RBQ:condition this when developing delete verses single delete")
                if !MyDefaults().developmentDeleting {
                    self.items.remove(at: index)
                }
        }
            .store(in: &cancellables)
    }
    // this get EVERYTHING...only use this in the development phase when loading data
    func getAll() {
        tracing(function: "getAll()")
        let predicate = NSPredicate(value: true)
        let sort = [NSSortDescriptor(key: "name", ascending: true)]
        CloudKitUtility.fetchAll(predicate: predicate, recordType: myRecordType.Item.rawValue, sortDescriptions: sort)
            .receive(on: DispatchQueue.main)
            .sink { _ in

            } receiveValue: { [weak self] returnedItems in
                self?.items = returnedItems
            }
            .store(in: &cancellables)
        }
    func getAll(shopper: Int, listnumber: Int) {
        tracing(function: "getAll(shopper:\(shopper), listnumber:\(listnumber)")
        getAllItemsByListnumber(shopper: shopper, listnumber: listnumber) { completion in
            self.items = completion
        }
    }
    func getAllItemsByListnumber(shopper: Int, listnumber: Int, _ completion: @escaping ([CKItemRec]) -> ()) {
        tracing(function: "getAllItemByListnumber(shopper: \(shopper), listnumber: \(listnumber))")
//        let predicate = NSPredicate(format:"shopper == %@ AND listnumber == %@", NSNumber(value: shopper), NSNumber(value: listnumber))
        let predicate = NSPredicate(format:"shopper == %@ AND listnumber == %@", NSNumber(value: shopper), NSNumber(value: listnumber))
        let sort = [NSSortDescriptor(key: "name", ascending: true)]
        var myItems = [CKItemRec]()
        CloudKitUtility.fetchAll(predicate: predicate, recordType: myRecordType.Item.rawValue, sortDescriptions: sort)
            .receive(on: DispatchQueue.main)
            .sink { c in
                switch c {
                case .finished:
                    self.tracing(function: "getAllItemsByListnumber .finished")
                    self.itemsFinishedCount = myItems.count
                    completion(myItems)
                case .failure(let error):
                    self.tracing(function: "getAllItemsByListnumber error = \(error.localizedDescription)")
                }

            } receiveValue: { returnedItems in
                myItems = returnedItems
            }
            .store(in: &cancellables)
        }
    func getACountOnList(shopper: Int, listnumber: Int, _ competion: @escaping (Int) -> ()) {
        tracing(function: "getACountOnList shopper: \(shopper) listnumber: \(listnumber)")
        var myRecs = [CKItemRec]()
        let predicate = NSPredicate(format:"shopper == %@ AND listnumber == %@", NSNumber(value: shopper), NSNumber(value: listnumber))
//        let predicate = NSPredicate(format:"shopper == %@ AND listnumber == %@", NSNumber(value: shopper), NSNumber(value: listnumber))
        let sort = [NSSortDescriptor(key: "name", ascending: true)]
        CloudKitUtility.fetchAll(predicate: predicate, recordType: myRecordType.Item.rawValue, sortDescriptions: sort)
            .receive(on: DispatchQueue.main)
            .sink { c in
                switch c {
                case .finished:
                    self.tracing(function: "getACountOnList .finished")
//                    modelitem.items.reduce(0) { $1.onList == true ? $0 + 1 : $0 }
                    competion(myRecs.reduce(0) { $1.onList == true ? $0 + 1 : $0 })
                case .failure(let error):
                    self.tracing(function: "getACountOnList error = \(error.localizedDescription)")
                }

            } receiveValue: { returnedItems in
                myRecs = returnedItems
            }
            .store(in: &cancellables)
        }
    //
    // if the item is in the items array, it is on the data base
    //
    func isOnFile(item: CKItemRec) -> Bool {
        let index = items.firstIndex(where: { $0.id == item.id } )
        return index != nil
    }
    func moveAllItemsOffShoppingList() {
        for item in items.filter({ $0.onList }) {
            toggleOnListStatus(item: item) { completion in
                print("moveAllItemsOffShoppingList \(completion)")
            }
        }
    }
    // The only difference between set and toggle is the .onlist is set to false.
    // this should only be used on the receive data from the watch
    // since there is no UI at this time, setting it to not be on the list should cause no problems
    //  if you are in ios, update the actual item in the table and the database.
    // if you are on the watch, only change the table of items since that is really the database for the watch
    // use the name to find the record since that is the only thing identifying it on the watch

    func setOnListStatus(item: CKItemRec, onlist: Bool) {
        let onlist = !item.onList
        var dateLastPurchased: Date? = item.dateLastPurchased
        if !onlist {
            dateLastPurchased = Date()
        }
        var thisOS = ""
#if !os(iOS)
        thisOS = "WatchOS"
    guard let index = items.firstIndex(where: { $0.name == item.name } ) else { return }
    let changerec = CKItemRec(shopper: item.shopper, listnumber: item.listnumber, locationnumber: item.locationnumber, onList: onlist, quantity: item.quantity, isAvailable: item.isAvailable, name: item.name, dateLastPurchased: item.dateLastPurchased)!
        items[index] = changerec
#endif

#if os(iOS)
        thisOS = "iOS"
        let changerec = item.update(shopper: item.shopper, listnumber: item.listnumber, locationnumber: item.locationnumber, onList: onlist, quantity: item.quantity, isAvailable: item.isAvailable, name: item.name, dateLastPurchased: dateLastPurchased)!
        addOrUpdate(item: changerec) { _ in
            self.tracing(function: "\(thisOS) toggleOnListStatus set to \(item.onList)")
        }
#endif

    }
    func toggleOnListStatus(item: CKItemRec, _ completion: @escaping (String) -> ())  {
        tracing(function: "StringtoggleOnListStatus item status: \(item.onList)")
        let onlist = !item.onList
        var dateLastPurchased: Date? = item.dateLastPurchased
        if !onlist {
            dateLastPurchased = Date()
        }
        let changerec = item.update(shopper: item.shopper, listnumber: item.listnumber, locationnumber: item.locationnumber, onList: !item.onList, quantity: item.quantity, isAvailable: item.isAvailable, name: item.name, dateLastPurchased: dateLastPurchased)!

        addOrUpdate(item: changerec) { _ in
            self.tracing(function: "toggleOnListStatus set to \(item.onList)")
            completion("toggleOnListStatus set to \(item.onList)")
        }
//        return "toggleOnListStatus returned"
//        item.record["onList"] = !item.record["onList"]
//        Self.persistentStore.save()
    }
    func markAvailable(item: CKItemRec) {
        item.record["isAvailable"] = true
        addOrUpdate(item: item) { _ in
            self.tracing(function: "toggleAvailableStatus set to \(!item.isAvailable)")
        }
    }
    func toggleAvailableStatus(item: CKItemRec) {
        item.record["isAvailable"] = !item.isAvailable
        addOrUpdate(item: item) { _ in
            self.tracing(function: "toggleAvailableStatus set to \(!item.isAvailable)")
        }
    }
    // grouping for the watch view
    func groupItemsByLocation() {
        groupedItems = Dictionary(grouping: items.filter { $0.onList }, by: { $0.listnumber })

        tracing(function: "groupItemsByLocation")
    }
}
