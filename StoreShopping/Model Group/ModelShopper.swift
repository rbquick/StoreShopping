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
    @Published var icloudname = ""
    @Published var icloudPermission = false
    @Published var error = ""

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

        CloudKitUtility.requestApplicationPermission()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.mydiscoverUserIdentity()
                case .failure(let error):
                    self?.error = error.localizedDescription
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] value in
                self?.icloudPermission = value
            }
                .store(in: &cancellables)



//        previewData()
    }
    func mydiscoverUserIdentity() {
        CloudKitUtility.discoverUserIdentity()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error.localizedDescription
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] value in
                self?.icloudname = value
            }
                .store(in: &cancellables)
    }
    func previewData() {
        shoppers.removeAll()
        shoppers.append(CKShopperRec.example1())
    }
    func validName(name: String) -> Bool {
        let index = shoppers.firstIndex(where: { $0.name == name })
        return index != nil 
    }
    func getShopper(name: String) -> CKShopperRec {
        let index = shoppers.firstIndex(where: { $0.name == name })
        if index != nil {
            return shoppers[index!]
        } else {
            return CKShopperRec.UNKNOWN_SHOPPER!
        }

    }
    func addOrUpdate(shopper: CKShopperRec, _ completion: @escaping (String) -> ()) {
       tracing(function: "addOrUpdate")
        let index = shoppers.firstIndex(where: { $0.id == shopper.id })

        CloudKitUtility.update(item: shopper)
            .receive(on: DispatchQueue.main)
            .sink { c in
                switch c {
                case .finished:
                    self.tracing(function: "add .finished")
                    completion("Shopper added")
                case .failure(let error):
                    self.tracing(function: "add error = \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] returnedItems in
                if index != nil {
                    self?.shoppers[index ?? 0] = shopper
                } else {
                    self?.shoppers.append(shopper)
                }
            }
            .store(in: &cancellables)

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

