//
//  UIDevice.extention.swift
//  StoreShopping
//
//  Created by Brian Quick on 2024-07-15.
//

import Foundation
import UIKit

extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}
