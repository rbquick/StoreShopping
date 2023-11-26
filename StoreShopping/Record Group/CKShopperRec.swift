//
//  CKShopperRec.swift
//  StoreShopping
//
//  Created by Brian Quick on 2023-10-02.
//


import Foundation
import SwiftUI
import CloudKit

// this Codable is ONLY for importing data and not used elsewhere in the app
struct ShopperCodable: Codable, Identifiable {
    enum CodingKeys: CodingKey {
        case shopper
        case name
    }

    var id = UUID()
    var shopper: Int64
    var name: String

    init(from shoplist: CKShopperRec) {
        shopper = shoplist.shopper
        name = shoplist.name
    }
}

struct CKShopperRec: Identifiable, Hashable, CloudKitableProtocol {

    let id: CKRecord.ID
    let shopper: Int64
    let name: String
    let record: CKRecord

    init?(record: CKRecord) {
        self.id = record.recordID
        self.shopper = record["shopper"] as? Int64 ?? 99
        self.name = record["name"] as? String ?? kMasterShopListNameDefaultValue
        self.record = record
    }
    init?(shopper: Int64, name: String) {
        let record = CKRecord(recordType: myRecordType.ShopList.rawValue)
        record["shopper"] = shopper
        record["name"] = name
        self.init(record: record)
    }
    static func example1() -> CKShopperRec {
        return CKShopperRec(shopper: 1, name: kMasterShopListNameDefaultValue)!
    }
}

