//
//  csvHeading.swift
//  GameTrackerrbq
//
//  Created by Brian Quick on 2023-12-01.
//

import Foundation

///  csvHeading Create a CSV heading line with the name in an enum
/// - Parameter enumType: any enum
/// - Returns: String
///             like \("fieldname1"),\("fieldname2")/n
func csvHeading<T: RawRepresentable & CaseIterable>(for enumType: T.Type) -> String where T.RawValue == String {
        var names = ""
    for (index, name)  in enumType.allCases.enumerated() {
            if index != 0 {
                names += ","
            }
            names += name.rawValue
        }
        names += "\n"
    return names
}
func csvHeading(fieldNames: [String]) -> String  {
    let names = fieldNames.joined(separator: ",") + "\n"
    return names
}
