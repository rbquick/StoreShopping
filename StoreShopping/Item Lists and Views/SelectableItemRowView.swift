	//
	//  SelectableItemRowView.swift
	//  ShoppingList
	//
	//  Created by Jerry on 11/28/20.
	//  Copyright © 2020 Jerry. All rights reserved.
	//

import SwiftUI

	// MARK: - SelectableItemRowView

struct SelectableItemRowView: View {
	
		// incoming are an item description, whether that item is selected or not, what symbol
		// to use for animation, and what to do if the selector is tapped.  we treat
		// the item as an @ObservedObject: we want to get redrawn if any property changes.
        //rbq changed from Observableobject to state ... should do the same thing
	@State var item: CKItemRec

    @EnvironmentObject var mastervalues: MasterValues
    @EnvironmentObject var modellocation: ModelLocation
	var selected: Bool
	var sfSymbolName: String
	var tapAction: () -> ()
	
	var body: some View {
		HStack {
			
				// --- build the little circle to tap on the left
			ZStack {
					// not sure if i want to have at least a visible circle here at the bottom layer or not.  for
					// some color choices (e.g., Dairy = white) nothing appears to be shown as tappable
					//				Circle()
					//					.stroke(Color(.systemGray6))
					//					.frame(width: 28.5, height: 28.5)
				if selected {
					Image(systemName: "circle.fill")
						.foregroundColor(.blue)
						.font(.title)
				}
				Image(systemName: "circle")
					//					.foregroundColor(Color(item.uiColor))
					.foregroundColor(item.color)
					.font(.title)
				if selected {
					Image(systemName: sfSymbolName)
						.foregroundColor(.white)
						.font(.subheadline)
				}
			} // end of ZStack
			.animation(.easeInOut, value: selected)
			.frame(width: 24, height: 24)
			.onTapGesture(perform: tapAction)
			
			item.color
				.frame(width: 10, height: 36)
			
				// name and location
			VStack(alignment: .leading) {
				
				if item.isAvailable {
					Text(item.name)
				} else {
					Text(item.name)
						.italic()
						.strikethrough()
				}

                // rbq changed 2023-04-01
                // added the HStack to put a shopping cart on the line if the item
                //       is on the shopping list
                HStack {
                    Text("\(modellocation.GetLocationNameByLocationnumber(locationnumber: item.locationnumber))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if item.onList {
                        Spacer()
                        Image(systemName: "cart")
                            .foregroundColor(.green)
                            .font(.subheadline)
                    }
                }
			}

			Spacer()
			
				// quantity at the right
			Text("\(item.quantity)")
				.font(.headline)
				.foregroundColor(Color.blue)
			
		} // end of HStack
	}
}
