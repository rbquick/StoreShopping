//
//  View+Extensions.swift
//  ShoppingList
//

import SwiftUI

extension View {
	
	func myCentered() -> some View {
		HStack {
			Spacer()
			self
			Spacer()
		}
	}
}
