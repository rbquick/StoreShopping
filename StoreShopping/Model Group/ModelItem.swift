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
        getAll(shopper: MyDefaults().myMasterShopperShopper)
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
    func countOfItemsOnList(listnumber: Int64, locationnumber: Int64) -> Int {
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
                    completion("location deleted")
                case .failure(let error):
                    self.tracing(function: "delete error = \(error.localizedDescription)")
                    completion("delete error = \(error.localizedDescription)")
                }
            } receiveValue: { success in
#warning("condition this when developing delete verses single delete")
                self.items.remove(at: index)
        }
            .store(in: &cancellables)
    }
    func getAll(shopper: Int) {
        tracing(function: "getAll")
        let predicate = NSPredicate(format:"shopper == %@", NSNumber(value: shopper))
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
    func moveAllItemsOffShoppingList() {
        for item in items.filter({ $0.onList }) {
            toggleOnListStatus(item: item)
        }
    }
    func toggleOnListStatus(item: CKItemRec) {
        print(item.onList)
        item.record["onList"] = !item.onList
        addOrUpdate(item: item) { _ in
            self.tracing(function: "toggleOnListStatus set to \(!item.onList)")
        }
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
