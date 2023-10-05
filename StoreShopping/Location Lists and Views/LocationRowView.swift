//
//  LocationRowView.swift
//  ShoppingList
//
//  Created by Jerry on 6/1/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

// MARK: - LocationRowView

struct LocationRowView: View {
	
	let location: CKLocationRec
	
	 //var rowData: LocationRowData

	var body: some View {
		HStack {
			// color bar at left (new in this code)
            // FIXME: this color is on the DraftLocation which I am not using
			location.color
                .frame(width: 10, height: 36)
			
			VStack(alignment: .leading) {
				Text(location.name)
					.font(.headline)
				Text(subtitle())
					.font(.caption)
			}
			// we do not show the location index in SL16
//			if !location.isUnknownLocation {
//				Spacer()
//				Text(String(location.visitationOrder))
//			}
		} // end of HStack
	} // end of body: some View
	
	func subtitle() -> String {
        return "Items not available yet"
        // FIXME: get this count once items are on file
//		if location.itemCount == 1 {
//			return "1 item"
//		} else {
//			return "\(location.itemCount) items"
//		}
	}
	
}
