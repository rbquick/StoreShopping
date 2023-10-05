//
//  ModelLocation.swift
//  StoreShopping
//
//  Created by Brian Quick on 2023-10-05.
//

import Foundation
import CloudKit
import Combine

class ModelLocation: ObservableObject {
    @Published var locations = [CKLocationRec]()

    var cancellables = Set<AnyCancellable>()

    var isTracing: Bool = true
    func tracing(function: String) {
        if isTracing {
            print("ModelLocation \(function) ")
            Logger.log("ModelLocation \(function)")
        }
    }

    init() {
        getAll(shopper: MyDefaults().myMasterShopperShopper, listnumber: MyDefaults().myMasterShopListListnumber)
    }

    func getACount(shopper: Int, listnumber: Int, _ competion: @escaping (Int) -> ()) {
        tracing(function: "getACount")
        var myRecs = [CKLocationRec]()
        let predicate = NSPredicate(format:"shopper == %@ AND listnumber == %@", NSNumber(value: shopper), NSNumber(value: listnumber))
        let sort = [NSSortDescriptor(key: "shopper", ascending: true)]
        CloudKitUtility.fetchAll(predicate: predicate, recordType: myRecordType.Location.rawValue, sortDescriptions: sort)
            .receive(on: DispatchQueue.main)
            .sink { c in
                switch c {
                case .finished:
                    self.tracing(function: "getACount .finished")
                    competion(myRecs.count)
                case .failure(let error):
                    self.tracing(function: "getACount error = \(error.localizedDescription)")
                }

            } receiveValue: { [weak self] returnedItems in
                myRecs = returnedItems
            }
            .store(in: &cancellables)
        }

    func getAll(shopper: Int, listnumber: Int) {
        tracing(function: "getAll")
        let predicate = NSPredicate(format:"shopper == %@ AND listnumber == %@", NSNumber(value: shopper), NSNumber(value: listnumber))
        let sort = [NSSortDescriptor(key: "name", ascending: true)]
        CloudKitUtility.fetchAll(predicate: predicate, recordType: myRecordType.Location.rawValue, sortDescriptions: sort)
            .receive(on: DispatchQueue.main)
            .sink { c in
                switch c {
                case .finished:
                    self.tracing(function: "getAll .finished")
                case .failure(let error):
                    self.tracing(function: "getAll error = \(error.localizedDescription)")
                }

            } receiveValue: { [weak self] returnedItems in
                self?.locations = returnedItems
            }
            .store(in: &cancellables)
        }
}
