//
//  CKLocationRec.swift
//  StoreShopping
//
//  Created by Brian Quick on 2023-10-05.
//

import Foundation
import SwiftUI
import CloudKit

// this is a simple struct to extract only the fields of a Location
// that we would import or export in such a way that the result is Codable.
struct LocationCodable: Codable {
    var shopper: Int64
    var listnumber: Int64
    var locationnumber: Int64
    var name: String
    var visitationOrder: Int
    var red: Double
    var green: Double
    var blue: Double
    var opacity: Double

    init(from location: CKLocationRec) {
        shopper = location.shopper
        listnumber = location.listnumber
        locationnumber = location.locationnumber
        name = location.name
        visitationOrder = location.visitationOrder
        red = location.red
        green = location.green
        blue = location.blue
        opacity = location.opacity
    }
}

// constants
let kUnknownLocationName = "Unknown Location"
let kUnknownLocationVisitationOrder: Int32 = INT32_MAX

struct CKLocationRec: Identifiable, Hashable, CloudKitableProtocol {

    let id: CKRecord.ID
    let shopper: Int64
    let listnumber: Int64
    let locationnumber: Int64
    let name: String
    let visitationOrder: Int
    let red: Double
    let green: Double
    let blue: Double
    let opacity: Double
    let record: CKRecord

    init?(record: CKRecord) {
        self.id = record.recordID
        self.shopper = record["shopper"] as? Int64 ?? 99
        self.listnumber = record["listnumber"] as? Int64 ?? 99
        self.locationnumber = record["locationnumber"] as? Int64 ?? 99
        self.name = record["name"] as? String ?? kUnknownLocationName
        self.visitationOrder = record["visitationOrder"] as? Int ?? 1
        self.red = record["red"] as? Double ?? 0.5
        self.green = record["green"] as? Double ?? 0.5
        self.blue = record["blue"] as? Double ?? 0.5
        self.opacity = record["opacity"] as? Double ?? 0.5
        self.record = record
    }

    init?(shopper: Int64, listnumber: Int64, locationnumber: Int64, name: String, visitationOrder: Int, red: Double, green: Double, blue: Double, opacity: Double) {
        let record = CKRecord(recordType: myRecordType.Location.rawValue)
        record["shopper"] = shopper
        record["listnumber"] = listnumber
        record["locationnumber"] = locationnumber
        record["name"] = name
        record["visitationOrder"] = visitationOrder
        record["red"] = red
        record["green"] = green
        record["blue"] = blue
        record["opacity"] = opacity
        self.init(record: record)
    }

    enum StructNames: String, CaseIterable {
        case shopper = "shopper"
        case listnumber = "listnumber"
        case locationnumber = "locationnumber"
        case name = "name"
        case visitationOrder = "visitationOrder"
        case red = "red"
        case green = "green"
        case blue = "blue"
        case opacity = "opacity"
    }





    // simplified test of "is the unknown location"
    var isUnknownLocation: Bool { visitationOrder == kUnknownLocationVisitationOrder }

    var visitationOrder_: Int {
        get {
            return record["visitationOrder"] as? Int ?? 1
        }
        set {
            record["visitationOrder"] = newValue
        }
    }

    func update(shopper: Int64, listnumber: Int64, locationnumber: Int64, name: String, visitationOrder: Int, red: Double, green: Double, blue: Double, opacity: Double) -> CKLocationRec? {
        let record = record
        record["shopper"] = shopper
        record["listnumber"] = listnumber
        record["locationnumber"] = locationnumber
        record["name"] = name
        record["visitationOrder"] = visitationOrder
        record["red"] = red
        record["green"] = green
        record["blue"] = blue
        record["opacity"] = opacity
        return CKLocationRec(record: record)!
    }

    var color: Color {
        get {
            Color(red: red, green: green, blue: blue, opacity: opacity)
        }
        set {
            if let components = newValue.cgColor?.components {
                //items.forEach({ $0.objectWillChange.send() })
                let doubles = components.map { Double($0) }
                record["red"] = doubles[0]
                record["green"] = doubles[1]
                record["blue"] = doubles[2]
                record["opacity"] = doubles[3]
            }
        }
    }
    var canBeSaved: Bool { name.count > 0 }

    static func example1() -> CKLocationRec {
        return CKLocationRec(shopper: 1, listnumber: 1, locationnumber: 1, name: "Loc 1", visitationOrder: 2, red: 0.5, green: 0.5, blue: 0.5, opacity: 0.5)!
    }
    static func unKnown() -> CKLocationRec {
        return CKLocationRec(shopper: 1, listnumber: 1, locationnumber: 2, name: "Loc 2", visitationOrder: 1, red: 0.5, green: 0.5, blue: 0.5, opacity: 0.5)!
    }
    static func mustHave2() -> CKLocationRec {
        return CKLocationRec(shopper: 1, listnumber: 3, locationnumber: 3, name: "Loc 3", visitationOrder: 1, red: 0.5, green: 0.5, blue: 0.5, opacity: 0.5)!
    }
}
