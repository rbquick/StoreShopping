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

    var isTracing: Bool = true
    func tracing(function: String) {
        if isTracing {
            print("ModelShopper \(function) ")
            Logger.log("ModelShopper \(function)")
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
                if !MyDefaults().developmentDeleting {
                    self.shoppers.remove(at: index)
                }
        }
            .store(in: &cancellables)
    }
    // this get EVERYTHING...only use this in the development phase when loading data
    // this getAll only exists since as of 2023-10-18, i'm not using these shoppers
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

