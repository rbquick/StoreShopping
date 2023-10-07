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

    var isTracing: Bool = false
    func tracing(function: String) {
        if isTracing {
            print("ModelShopList \(function) ")
            Logger.log("ModelShopList \(function)")
        }
    }
    init() {
        MasterShopListName = MyDefaults().myMasterShopListName
        MasterShopListListnumber = MyDefaults().myMasterShopListListnumber
        getAll(shopper: MyDefaults().myMasterShopperShopper)
        tracing(function: "init")
//        previewData()
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
    func addOrUpdate(shoplist: CKShopListRec, _ completion: @escaping (String) -> ()) -> String {
       tracing(function: "addOrUpdate")
        let message = "Adding shoplist"
        print(shoplist.id)
        let index = shoplists.firstIndex(where: { $0.shopper == shoplist.shopper && $0.listnumber == shoplist.listnumber })

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

        return message
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
#warning("condition this when developing delete verses single delete")
                self.shoplists.remove(at: index)
        }
            .store(in: &cancellables)
    }
    func getAll(shopper: Int) {
        tracing(function: "getAll")
        let predicate = NSPredicate(format:"shopper == %@", NSNumber(value: shopper))
        let sort = [NSSortDescriptor(key: "name", ascending: true)]
        CloudKitUtility.fetchAll(predicate: predicate, recordType: myRecordType.ShopList.rawValue, sortDescriptions: sort)
            .receive(on: DispatchQueue.main)
            .sink { c in
                switch c {
                case .finished:
                    self.tracing(function: "getAll .finished")
                case .failure(let error):
                    self.tracing(function: "getAll error = \(error.localizedDescription)")
                }

            } receiveValue: { [weak self] returnedItems in
                self?.shoplists = returnedItems
            }
            .store(in: &cancellables)
        }
    func GetNextlistnumber() -> Int64 {
        tracing(function: "GetNextlistnumber")
        let lastnum = shoplists.map { $0.listnumber }.max()!
        return lastnum + 1
    }
}
