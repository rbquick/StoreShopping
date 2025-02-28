//
//  LocationsView.swift
//  ShoppingList
//
//  Created by Jerry on 5/6/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

struct LocationsView: View {

    @EnvironmentObject var modellocation: ModelLocation
    @EnvironmentObject var mastervalues: MasterValues
    @EnvironmentObject var watchConnector: WatchConnector
    @Environment(\.editMode) private var editMode

		// MARK: - @State and @StateObject Properties

    @State var editLocationRec = CKLocationRec.example1()

	var body: some View {
		VStack(spacing: 0) {
			
			Rectangle()
				.frame(height: 1)
			
			List {
                Section(header: Text("Locations Listed: \(modellocation.locations.count)")) {
                    ForEach(modellocation.locations) { location in
                            LocationRowView(location: location) { setChangeLocation(location: location) }
					} // end of ForEach
					.onMove(perform: moveLocations)
				} // end of Section
			} // end of List
			.listStyle(InsetGroupedListStyle())
			
			Divider() // keeps list from running through tab bar (!)
		} // end of VStack
        .navigationBarTitle("\(MyDefaults().myMasterShopListName) Locations")

		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing, content: addNewButton)
			ToolbarItem(placement: .navigationBarLeading) { EditButton() }
		}
        .sheet(isPresented: $mastervalues.isAddNewLocationSheetPresented) {
            UpdateLocationView(draftLocation: CKLocationRec(shopper: Int64(MyDefaults().myMasterShopperShopper), listnumber: Int64(MyDefaults().myMasterShopListListnumber), locationnumber: 9999, name: "New Location", visitationOrder: 1, red: 0.5, green: 0.5, blue: 0.5, opacity: 0.5)!)
		}
        .sheet(isPresented: $mastervalues.isChangeLocationSheetPresented) {
            // FIXed:  have to find the location that is selected in the list
            //          the editLocationRec is set when a location is selected
            UpdateLocationView(draftLocation: editLocationRec)
        }
		.onAppear { handleOnAppear() }
        .onDisappear { editMode?.wrappedValue = .inactive}
		
	} // end of var body: some View
                    func setChangeLocation(location: CKLocationRec) {
                                editLocationRec = location
                                mastervalues.isChangeLocationSheetPresented = true
                            }
		// this is new to SL16: allowing you to reorder Locations by dragging.
		// we make a copy of the current ordering of the locations array (some
		// type coercion in necessary) and then rewrite all the visitationOrders
		// after the move (except for the unknown location).
	func moveLocations(at offsets: IndexSet, destination: Int) {
//        print(modellocation.locations[0].name)
        var oldLocations = modellocation.locations.compactMap({ $0 }) as! [CKLocationRec]
		oldLocations.move(fromOffsets: offsets, toOffset: destination)
        modellocation.locations = oldLocations
        modellocation.updateVisitationOrder()
//		var position = 0
//		for location in oldLocations where !location.isUnknownLocation {
//			location.visitationOrder_ = position
//			position += 1
//		}
	}
	
	func handleOnAppear() {
			// because the unknown location is created lazily, this will
			// make sure that we'll not be left with an empty screen.
			// however, this could introduce a subtle problem: if you
			// are using NSPersistentCloudKitContainer, you might
			// have a "late delivery" from the cloud of an unknown
			// location from another device (if this is the first time you're
			// using the app) ... but i will ignore that here and leave any
			// fixes to the Location class for later resolution.
        if modellocation.locations.count == 0 {
            modellocation.locations.append(CKLocationRec.example1())
		}
	}
	
	// defines the usual "+" button to add a Location
	func addNewButton() -> some View {
		Button {
            mastervalues.isAddNewLocationSheetPresented = true
		} label: {
            HStack {
                Text("Add ")
                Image(systemName: "plus")
            }
		}
	}
	
}
