//
//  ModelShopper.swift
//  StoreShopping
//
//  Created by Brian Quick on 2023-10-02.
//

import SwiftUI
import CloudKit
import Combine

class ModelShopper: ObservableObject {
    @Published var shoppers = [CKShopperRec]()

    var cancellables = Set<AnyCancellable>()

    var isTracing: Bool = false
    func tracing(function: String) {
        if isTracing {
            print("ModelCourse \(function) ")
            Logger.log("ModelCourse \(function)")
        }
    }
    init() {
        tracing(function: "init")
        getAll()
//        previewData()
    }
    func previewData() {
        shoppers.removeAll()
        shoppers.append(CKShopperRec.example1())
    }

    func delete(shopper: CKShopperRec, completion: @escaping (String) -> ()) {
        tracing(function: "delete")
        guard let index = shoppers.firstIndex(where: { $0.id == shopper.id }) else { return }
        // FIXME: implement when connected to db
        CloudKitUtility.delete(item: shopper)
            .receive(on: DispatchQueue.main)
            .sink { c in
                switch c {
                case .finished:
                    self.tracing(function: "delete .finished")
                    completion("shopper deleted")
                case .failure(let error):
                    self.tracing(function: "delete error = \(error.localizedDescription)")
                    completion("delete error = \(error.localizedDescription)")
                }
            } receiveValue: { success in
//                self.shoppers.remove(at: index)
        }
            .store(in: &cancellables)
    }
    func getAll() {
        tracing(function: "ModelShopper.getAll")
        let predicate = NSPredicate(value: true)
        let sort = [NSSortDescriptor(key: "name", ascending: true)]
        CloudKitUtility.fetchAll(predicate: predicate, recordType: myRecordType.Shopper.rawValue, sortDescriptions: sort)
            .receive(on: DispatchQueue.main)
            .sink { _ in

            } receiveValue: { [weak self] returnedItems in
                self?.shoppers = returnedItems
            }
            .store(in: &cancellables)
        }
}

