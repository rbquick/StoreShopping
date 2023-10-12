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
        self.record = record
    }
    init?(shopper: Int64, listnumber: Int64, locationnumber: Int64, onList: Bool, quantity: Int, isAvailable: Bool, name: String) {
        let record = CKRecord(recordType: myRecordType.Item.rawValue)
        record["shopper"] = shopper
        record["listnumber"] = listnumber
        record["locationnumber"] = locationnumber
        record["onList"] = onList
        record["quantity"] = quantity
        record["isAvailable"] = isAvailable
        record["name"] = name
        self.init(record: record)
    }

    // the color of its association location
    // FIXME: this is the old struct within a struct...this location color is in the cklocationrec struct
    var color: Color {
        return Color(uiColor: UIColor(displayP3Red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5))
//        location_?.color ?? Color(uiColor: UIColor(displayP3Red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5))
    }

    func update(shopper: Int64, listnumber: Int64, locationnumber: Int64, onList: Bool, quantity: Int, isAvailable: Bool, name: String) -> CKItemRec? {
        let record = record
        record["shopper"] = shopper
        record["listnumber"] = listnumber
        record["locationnumber"] = locationnumber
        record["onList"] = onList
        record["quantity"] = quantity
        record["isAvailable"] = isAvailable
        record["name"] = name
        return CKItemRec(record: record)!
    }
    var canBeSaved: Bool { name.count > 0 }

    static func example1() -> CKItemRec {
        return CKItemRec(shopper: 1, listnumber: 1, locationnumber: 1, onList: false, quantity: 1, isAvailable: true, name: "New Item")!
    }
}
