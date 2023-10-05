//
//  CKLocation.swift
//  StoreShopping
//
//  Created by Brian Quick on 2023-09-30.
//

import Foundation
import SwiftUI
import CloudKit

struct ShopListCodable: Codable, Identifiable {
    enum CodingKeys: CodingKey {
        case shopper
        case listnumber
        case name
    }

    var id = UUID()
    var shopper: Int64
    var listnumber: Int64
    var name: String

    init(from shoplist: CKShopListRec) {
        shopper = shoplist.shopper
        listnumber = shoplist.listnumber
        name = shoplist.name
    }
}

struct CKShopListRec: Identifiable, Hashable, CloudKitableProtocol {

    let id: CKRecord.ID
    let shopper: Int64
    let listnumber: Int64
    let name: String
    let record: CKRecord

    init?(record: CKRecord) {
        self.id = record.recordID
        self.shopper = record["shopper"] as? Int64 ?? 99
        self.listnumber = record["listnumber"] as? Int64 ?? 99
        self.name = record["name"] as? String ?? kMasterShopListNameDefaultValue
        self.record = record
    }
    init?(shopper: Int64, listnumber: Int64, name: String) {
        let record = CKRecord(recordType: myRecordType.ShopList.rawValue)
        record["shopper"] = shopper
        record["listnumber"] = listnumber
        record["name"] = name
        self.init(record: record)
    }

    func update(shopper: Int64, listnumber: Int64, name: String) -> CKShopListRec? {
        let record = record
        record["shopper"] = shopper
        record["listnumber"] = listnumber
        record["name"] = name
        return CKShopListRec(record: record)!
    }
    // to do a save/update of an Item, it must have a non-empty name
    var canBeSaved: Bool { name.count > 0 }
    
    static func example1() -> CKShopListRec {
        return CKShopListRec(shopper: 1, listnumber: 1, name: kMasterShopListNameDefaultValue)!
    }
}
