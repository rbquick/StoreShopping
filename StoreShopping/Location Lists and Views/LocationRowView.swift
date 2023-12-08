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

    @EnvironmentObject var modelitem: ModelItem
	
    var tapAction: () -> ()

	var body: some View {
		HStack {
			// color bar at left (new in this code)
			location.color
                .frame(width: 10, height: 36)
			
			VStack(alignment: .leading) {
				Text(location.name)
					.font(.headline)
                // put this line in if you are having a problem in developmen
//                Text("List: \(location.listnumber) Location: \(location.locationnumber)")
				Text(subtitle())
					.font(.caption)
			}
			// we do not show the location index in SL16
//			if !location.isUnknownLocation {
//				Spacer()
//				Text(String(location.visitationOrder))
//			}
		} // end of HStack
        .onTapGesture(perform: tapAction)
	} // end of body: some View
	
	func subtitle() -> String {
        return "\(modelitem.countOfItemsAtLocation(listnumber: location.listnumber, locationnumber: location.locationnumber )) Total items"
	}
	
}
