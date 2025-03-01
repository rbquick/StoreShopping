//
//  ModelShopList.swift
//  StoreShopping
//
//  Created by Brian Quick on 2023-09-30.
//

import SwiftUI
import CloudKit
import Combine

class ModelShopList: ObservableObject {
    @Published var shoplists = [CKShopListRec]()
    @Published var getAllResultsMsg: String = ""

    @Published var MasterShopListName: String {
        willSet {
            MyDefaults().myMasterShopListName = newValue
            objectWillChange.send()
        }
    }
    @Published var MasterShopListListnumber: Int {
        willSet {
            MyDefaults().myMasterShopListListnumber = newValue
            objectWillChange.send()
        }
    }

   

    var cancellables = Set<AnyCancellable>()

    var isTracing: Bool = true
    func tracing(function: String) {
        if isTracing {
            print("ModelShopList \(function) ")
            Logger.log("ModelShopList \(function)")
        }
    }
    init() {
        MasterShopListName = MyDefaults().myMasterShopListName
        MasterShopListListnumber = MyDefaults().myMasterShopListListnumber
        createShoplists()

        tracing(function: "init")
//        previewData()
    }
    func createShoplists() {

        shoplists.removeAll()
        getAll(shopper: MyDefaults().myMasterShopperShopper)
    }
    func previewData() {
        shoplists.removeAll()
        shoplists.append(CKShopListRec.example1())
    }
    func getMaster() -> CKShopListRec {
        if let index = shoplists.firstIndex(where: { $0.shopper == MyDefaults().myMasterShopperShopper && $0.listnumber == MyDefaults().myMasterShopListListnumber }) {
            print("getMaster is \(shoplists[index].listnumber) - \(shoplists[index].name)")
            return shoplists[index]
        } else {
            return CKShopListRec(shopper: Int64(MyDefaults().myMasterShopperShopper), listnumber: Int64(MyDefaults().myMasterShopListListnumber), name: "UnKnown")!
        }
    }
    func onFile(shopper: Int64, listnumber: Int64) -> Bool {
        let index = shoplists.firstIndex(where: { $0.shopper == shopper && $0.listnumber == listnumber })
        return index != nil
    }
    func addOrUpdate(shoplist: CKShopListRec, _ completion: @escaping (String) -> ()) {
       tracing(function: "addOrUpdate")
        print(shoplist.id)
        let index = shoplists.firstIndex(where: { $0.id == shoplist.id })

        CloudKitUtility.update(item: shoplist)
            .receive(on: DispatchQueue.main)
            .sink { c in
                switch c {
                case .finished:
                    self.tracing(function: "add .finished")
                    completion("Course added")
                case .failure(let error):
                    self.tracing(function: "add error = \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] returnedItems in
                if index != nil {
                    self?.shoplists[index ?? 0] = shoplist
                } else {
                    self?.shoplists.append(shoplist)
                }
            }
            .store(in: &cancellables)

    }
    func delete(shoplist: CKShopListRec, completion: @escaping (String) -> ()) {
        tracing(function: "delete")
        guard let index = shoplists.firstIndex(where: { $0.id == shoplist.id }) else { return }
        CloudKitUtility.delete(item: shoplist)
            .receive(on: DispatchQueue.main)
            .sink { c in
                switch c {
                case .finished:
                    self.tracing(function: "delete .finished")
                    completion("shoplist deleted")
                case .failure(let error):
                    self.tracing(function: "delete error = \(error.localizedDescription)")
                    completion("delete error = \(error.localizedDescription)")
                }
            } receiveValue: { success in
// ("RBQ:condition this when developing delete verses single delete")
                if !MyDefaults().developmentDeleting {
                    self.shoplists.remove(at: index)
                }
        }
            .store(in: &cancellables)
    }
    func getShopListName(listnumber: Int64) -> String {
        guard let index = shoplists.firstIndex(where: { $0.listnumber == listnumber }) else { return "Unknown"}
        return shoplists[index].name
    }
    func getAll() {
        tracing(function: "getAll")
        let predicate = NSPredicate(value: true)
        let sort = [NSSortDescriptor(key: "name", ascending: true)]
        CloudKitUtility.fetchAll(predicate: predicate, recordType: myRecordType.ShopList.rawValue, sortDescriptions: sort)
            .receive(on: DispatchQueue.main)
            .sink { _ in

            } receiveValue: { [weak self] returnedItems in
                self?.shoplists = returnedItems
            }
            .store(in: &cancellables)
        }
    func getAll(shopper: Int) {
        tracing(function: "getAll shopper: \(shopper)")
        shoplists.removeAll()   // empty the lists so you can report an error in nothing comes back from fetchAll
        let predicate = NSPredicate(format:"shopper == %@", NSNumber(value: shopper))
        let sort = [NSSortDescriptor(key: "name", ascending: true)]
        CloudKitUtility.fetchAll(predicate: predicate, recordType: myRecordType.ShopList.rawValue, sortDescriptions: sort)
            .timeout(.seconds(5), scheduler: DispatchQueue.main) // Set your desired timeout duration here
            .receive(on: DispatchQueue.main)
            .sink { c in
                switch c {
                case .finished:
                    self.tracing(function: "getAll .finished")
                    // allow the caller to report an error to retry
                    self.getAllResultsMsg = self.shoplists.count == 0 ? "Error:Pull down to refresh" :  "Lists Available"
                case .failure(let error):
                        if let urlError = error as? URLError {
                             self.tracing(function: "getAll URLError: \(urlError.localizedDescription)")
                         } else {
                             self.tracing(function: "getAll error: \(error.localizedDescription)")
                         }
                }

            } receiveValue: { [weak self] returnedItems in
                self?.shoplists = returnedItems
                                self?.tracing(function: "getAll returnedItems: \(returnedItems.count)")
            }
            .store(in: &cancellables)
        }

    func GetNextlistnumber(completion: @escaping (Int64) -> ())  {
        tracing(function: "GetNextlistnumber")
        var lastListNumber = [CKShopListRec]()
        let shopper = MyDefaults().myMasterShopperShopper
        let predicate = NSPredicate(format:"shopper == %@", NSNumber(value: shopper))
        let sort = [NSSortDescriptor(key: "listnumber", ascending: false)]
        CloudKitUtility.fetchOne(predicate: predicate, recordType: myRecordType.ShopList.rawValue, sortDescriptions: sort, resultsLimit: 1)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tracing(function: "GetNextGameID returned \(lastListNumber.count)")
                if lastListNumber.count == 0 {
                   // self?.nextGameID = 0
                    completion(1)
                } else {
                   // self?.nextGameID = lastGames[0].GameID + 1
                    completion(lastListNumber[0].listnumber + 1)
                }
            } receiveValue: { returnedItems in
                lastListNumber = returnedItems
            }
            .store(in: &cancellables)
    }
}
