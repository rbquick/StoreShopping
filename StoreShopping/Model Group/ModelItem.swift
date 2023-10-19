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


    var cancellables = Set<AnyCancellable>()

    var isTracing: Bool = true
    func tracing(function: String) {
        if isTracing {
            print("ModelItem \(function) ")
            Logger.log("ModelItem \(function)")
        }
    }

    init() {
        getAll(shopper: MyDefaults().myMasterShopperShopper, listnumber: MyDefaults().myMasterShopListListnumber)
    }


    func addOrUpdate(item: CKItemRec, _ completion: @escaping (String) -> ()) -> String {
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

        return message
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
#warning("condition this when developing delete verses single delete")
                if !MyDefaults().developmentDeleting {
                    self.items.remove(at: index)
                }
        }
            .store(in: &cancellables)
    }
    // this get EVERYTHING...only use this in the development phase when loading data
    func getAll() {
        tracing(function: "getAll")
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
        tracing(function: "getAll")
//        let predicate = NSPredicate(format:"shopper == %@ AND listnumber == %@", NSNumber(value: shopper), NSNumber(value: listnumber))
        let predicate = NSPredicate(format:"shopper == %@ AND listnumber == %@", NSNumber(value: shopper), NSNumber(value: listnumber))
        let sort = [NSSortDescriptor(key: "name", ascending: true)]
        CloudKitUtility.fetchAll(predicate: predicate, recordType: myRecordType.Item.rawValue, sortDescriptions: sort)
            .receive(on: DispatchQueue.main)
            .sink { c in
                switch c {
                case .finished:
                    self.tracing(function: "getAll .finished")
                case .failure(let error):
                    self.tracing(function: "getAll error = \(error.localizedDescription)")
                }

            } receiveValue: { [weak self] returnedItems in
                self?.items = returnedItems
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
                print("moveAllItemsOffShoppingList")
            }
        }
    }
    func toggleOnListStatus(item: CKItemRec, _ completion: @escaping (String) -> ()) -> String {
        print(item.onList)
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
        return "toggleOnListStatus returned"
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
}
