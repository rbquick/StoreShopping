//
//  CKItemRec.swift
//  StoreShopping
//
//  Created by Brian Quick on 2023-10-07.
//

import Foundation
import SwiftUI
import CloudKit

struct ItemsCodable: Decodable {
    let ItemCodables: [ItemCodable]
}
struct ItemCodable: Decodable {

    var onList: Bool
    var quantity: Int
    var isAvailable: Bool
    var locationName: String
    var name: String

}

struct CKItemRec: Identifiable, Hashable,  CloudKitableProtocol {

    let id: CKRecord.ID
    let shopper: Int64
    let listnumber: Int64
    let locationnumber: Int64
    let onList: Bool
    let quantity: Int
    let isAvailable: Bool
    let name: String
    let dateLastPurchased: Date?
    let record: CKRecord

    init?(record: CKRecord) {
        self.id = record.recordID
        self.shopper = record["shopper"] as? Int64 ?? 99
        self.listnumber = record["listnumber"] as? Int64 ?? 99
        self.locationnumber = record["locationnumber"] as? Int64 ?? 99
        self.onList = record["onList"] as? Bool ?? false
        self.quantity = record["quantity"] as? Int ?? 1
        self.isAvailable = record["isAvailable"] as? Bool ?? true
        self.name = record["name"] as? String ?? "UnKnown"
        self.dateLastPurchased = record["dateLastPurchased"] as? Date? ?? nil
        self.record = record
    }
    init?(shopper: Int64, listnumber: Int64, locationnumber: Int64, onList: Bool, quantity: Int, isAvailable: Bool, name: String, dateLastPurchased: Date?) {
        let record = CKRecord(recordType: myRecordType.Item.rawValue)
        record["shopper"] = shopper
        record["listnumber"] = listnumber
        record["locationnumber"] = locationnumber
        record["onList"] = onList
        record["quantity"] = quantity
        record["isAvailable"] = isAvailable
        record["name"] = name
        record["dateLastPurchased"] = dateLastPurchased
        self.init(record: record)
    }

    func update(shopper: Int64, listnumber: Int64, locationnumber: Int64, onList: Bool, quantity: Int, isAvailable: Bool, name: String, dateLastPurchased: Date?) -> CKItemRec? {
        let record = record
        record["shopper"] = shopper
        record["listnumber"] = listnumber
        record["locationnumber"] = locationnumber
        record["onList"] = onList
        record["quantity"] = quantity
        record["isAvailable"] = isAvailable
        record["name"] = name
        record["dateLastPurchased"] = dateLastPurchased
        return CKItemRec(record: record)!
    }
    var canBeSaved: Bool { name.count > 0 }

    static func example1() -> CKItemRec {
        return CKItemRec(shopper: 1, listnumber: 1, locationnumber: 1, onList: false, quantity: 1, isAvailable: true, name: "1st Example", dateLastPurchased: Date())!
    }
    static func example2() -> CKItemRec {
        return CKItemRec(shopper: 1, listnumber: 1, locationnumber: 1, onList: false, quantity: 1, isAvailable: true, name: "2nd Example", dateLastPurchased: Date())!
    }
}
