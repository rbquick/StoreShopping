//
//  ModelLocation.swift
//  StoreShopping
//
//  Created by Brian Quick on 2023-10-05.
//

import Foundation
import SwiftUI
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
        #if os(iOS)
        createLocations()
        #endif
    }
    func createLocations() {
        locations.removeAll()
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

            } receiveValue: { returnedItems in
                myRecs = returnedItems
            }
            .store(in: &cancellables)
        }
    // this get EVERYTHING...only use this in the development phase when loading data
    func getAll() {
        tracing(function: "getAll")
        let predicate = NSPredicate(value: true)
        let sort = [NSSortDescriptor(key: "name", ascending: true)]
        CloudKitUtility.fetchAll(predicate: predicate, recordType: myRecordType.Location.rawValue, sortDescriptions: sort)
            .receive(on: DispatchQueue.main)
            .sink { _ in

            } receiveValue: { [weak self] returnedItems in
                self?.locations = returnedItems
            }
            .store(in: &cancellables)
        }
    func getAll(shopper: Int, listnumber: Int) {
        tracing(function: "getAll")
        getAllLocationsByListNumber(shopper: shopper, listnumber: listnumber) { completion in
            self.locations = completion
        }
//        let predicate = NSPredicate(format:"shopper == %@ AND listnumber == %@", NSNumber(value: shopper), NSNumber(value: listnumber))
//        let sort = [NSSortDescriptor(key: "visitationOrder", ascending: true)]
//        CloudKitUtility.fetchAll(predicate: predicate, recordType: myRecordType.Location.rawValue, sortDescriptions: sort)
//            .receive(on: DispatchQueue.main)
//            .sink { c in
//                switch c {
//                case .finished:
//                    self.tracing(function: "getAll .finished")
//                case .failure(let error):
//                    self.tracing(function: "getAll error = \(error.localizedDescription)")
//                }
//
//            } receiveValue: { [weak self] returnedItems in
//                self?.locations = returnedItems
//            }
//            .store(in: &cancellables)
        }
    func getAllLocationsByListNumber(shopper: Int, listnumber: Int, _ completion: @escaping ([CKLocationRec]) -> ()) {
        tracing(function: "getLocationsByListNumber")
        let predicate = NSPredicate(format:"shopper == %@ AND listnumber == %@", NSNumber(value: shopper), NSNumber(value: listnumber))
        let sort = [NSSortDescriptor(key: "visitationOrder", ascending: true)]
        var myLocations = [CKLocationRec]()
        CloudKitUtility.fetchAll(predicate: predicate, recordType: myRecordType.Location.rawValue, sortDescriptions: sort)
            .receive(on: DispatchQueue.main)
            .sink { c in
                switch c {
                case .finished:
                    self.tracing(function: "getAll .finished")
                    completion(myLocations)
                case .failure(let error):
                    self.tracing(function: "getAll error = \(error.localizedDescription)")
                }

            } receiveValue: { returnedItems in
                myLocations = returnedItems
            }
            .store(in: &cancellables)
        }
    func updateVisitationOrder() {
        var position = 0
        for location in locations {
            location.record["visitationOrder"] = position
            addOrUpdate(location: location) { completion in
                print("\(location.visitationOrder) - \(location.name)")
            }
            position += 1
        }
    }
    func addOrUpdate(location: CKLocationRec, _ completion: @escaping (String) -> ()) {
       tracing(function: "addOrUpdate")
        let message = "Adding location"
        let index = locations.firstIndex(where: { $0.id == location.id })

        CloudKitUtility.update(item: location)
            .receive(on: DispatchQueue.main)
            .sink { c in
                switch c {
                case .finished:
                    self.tracing(function: "addOrUpdate .finished")
                    completion("Location added")
                case .failure(let error):
                    self.tracing(function: "addOfUpdate error = \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] returnedItems in
                if index != nil {
                    self?.locations[index ?? 0] = location
                } else {
                    self?.locations.append(location)
                }
            }
            .store(in: &cancellables)

    }
    func delete(location: CKLocationRec, completion: @escaping (String) -> ()) {
        tracing(function: "delete")
        guard let index = locations.firstIndex(where: { $0.id == location.id }) else { return }
        CloudKitUtility.delete(item: location)
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
#warning("RBQ:condition this when developing delete verses single delete")
                if !MyDefaults().developmentDeleting {
                    self.locations.remove(at: index)
                }
        }
            .store(in: &cancellables)
    }
    func getColorByLocation(listnumber: Int64, locationNumber: Int64) -> Color {
        let index = locations.firstIndex(where: { $0.listnumber == listnumber && $0.locationnumber == locationNumber })
        if index == nil {
            return Color.red
        }
        return locations[index!].color
    }
    func GetNextLocationNumber(completion: @escaping (Int64) -> ()) {
        tracing(function: "GetNextLocationNumber")
        var lastLocationNumber = [CKLocationRec]()
        let shopper = MyDefaults().myMasterShopperShopper
        let listnumber = MyDefaults().myMasterShopListListnumber
        let predicate = NSPredicate(format:"shopper == %@ AND listnumber == %@", NSNumber(value: shopper), NSNumber(value: listnumber))
        let sort = [NSSortDescriptor(key: "locationnumber", ascending: false)]
        CloudKitUtility.fetchOne(predicate: predicate, recordType: myRecordType.Location.rawValue, sortDescriptions: sort, resultsLimit: 1)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tracing(function: "GetNextLocationNumber returned \(lastLocationNumber.count)")
                if lastLocationNumber.count == 0 {
                   // self?.nextGameID = 0
                    completion(1)
                } else {
                   // self?.nextGameID = lastGames[0].GameID + 1
                    completion(lastLocationNumber[0].locationnumber + 1)
                }
            } receiveValue: { returnedItems in
                lastLocationNumber = returnedItems
            }
            .store(in: &cancellables)
    }
    func GetLocationByName(for name: String) -> CKLocationRec {
        let trimmedString = name.trimmingCharacters(in: .whitespaces)
        print(trimmedString)
        let index = locations.firstIndex(where: { $0.name.trimmingCharacters(in: .whitespaces) == trimmedString })
        if index != nil {
            return locations[index!]
        } else {
            return CKLocationRec.unKnown()
        }
    }
    func AddLocationToLocations(listnumber: Int, locationnumber: Int64, name: String) {
        let index = locations.firstIndex(where: { $0.locationnumber == locationnumber })
        if index == nil {
            let aRec = CKLocationRec(shopper: 1, listnumber: Int64(listnumber), locationnumber: locationnumber, name: name, visitationOrder: listnumber, red: 0.5, green: 0.5, blue: 0.5, opacity: 0.5)!
            locations.append(aRec)
        }
    }
    func GetvisitationOrderByLocationnumber(locationnumber: Int64) -> Int {
        let index = locations.firstIndex(where: { $0.locationnumber == locationnumber })
        if index != nil {
            return locations[index!].visitationOrder
        } else {
            return 1
        }
    }
    func GetLocationNameByLocationnumber(locationnumber: Int64) -> String {
        let index = locations.firstIndex(where: { $0.locationnumber == locationnumber })
        if index != nil {
            return locations[index!].name
        } else {
            return "unKnown"
        }
    }
    func GetLocationNameByListNumber(listnumber: Int64) -> String {
        let index = locations.firstIndex(where: { $0.listnumber == listnumber })
        if index != nil {
            return locations[index!].name
        } else {
            return "unKnown"
        }
    }
}
