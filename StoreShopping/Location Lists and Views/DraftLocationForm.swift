	//
	//  DraftLocationForm.swift
	//  ShoppingList
	//
	//  Created by Jerry on 12/10/21.
	//  Copyright © 2021 Jerry. All rights reserved.
	//

import SwiftUI

struct DraftLocationForm: View {
	
		// incoming data:
		// -- a DraftLocation (editable values for a Location)
		// -- an optional action to execute if the user decides to delete
		//      a draft in the case that it represents an existing Location
	@State var draftLocation: CKLocationRec
    @EnvironmentObject var modellocation: ModelLocation
    @EnvironmentObject var modelitem: ModelItem
    @EnvironmentObject var mastervalues: MasterValues
    @Binding public var name: String
    @Binding public var red: Double
    @Binding public var green: Double
    @Binding public var blue: Double
    @Binding public var opacity: Double

    @State private var color = Color.red

		// trigger for confirming deletion of the associated Location (if the
		// draft represents an existing Location that is not the Unknown Location)
	@State private var isConfirmDeleteLocationPresented = false

		// definition of whether we can offer a deletion option in this view
		// (it's a real location that's not the unknown location)
	private var locationCanBeDeleted: Bool {
        return true
        // FIXed: get something here
        //  might be checks, but anything can be deletd here
//		guard let associatedLocation = draftLocation.associatedLocation else {
//			return false
//		}
//		return !associatedLocation.isUnknownLocation
	}
	
	var body: some View {
		Form {
				// 1: Name (Visitation Order) and Colors.  These are shown for both an existing
				// location and a potential new Location about to be created.
			Section(header: Text("Basic Information")) {
				HStack {
					SLFormLabelText(labelText: "Name: ")
					TextField("Location name", text: $name)
				}
				ColorPicker("Location Color", selection: $color)

            } // end of Section 1
            .onChange(of: color) { _ in
                mygetcolor()
            }
				// Section 2: Delete button, if the data is associated with an existing Location
			if locationCanBeDeleted {
				Section(header: Text("Location Management")) {
					Button("Delete This Location")  {
						isConfirmDeleteLocationPresented = true // trigger confirmation dialog
					}
					.foregroundColor(Color.red)
					.myCentered()
					.confirmationDialog("Delete \'\(draftLocation.name)\'?",
															isPresented: $isConfirmDeleteLocationPresented,
															titleVisibility: .visible) {
						Button("Yes", role: .destructive) {
                            modellocation.delete(location: draftLocation) { returnvalue in
                                print(returnvalue)
                            }
                            mastervalues.isChangeLocationSheetPresented = false
                            // FIXME: delete record
//							if let location = draftLocation.associatedLocation {
//								Location.delete(location)
//								dismissAction?()
//							}
						}
					} message: {
						Text("Are you sure you want to delete the Location named \'\(draftLocation.name)\'? All items at this location will be moved to the Unknown Location.  This action cannot be undone.")
					}

				}
			} // end of Section 2
			
				// Section 3: Items assigned to this Location, if we are editing a Location
            // FIXed: show items for this locstion
            if (mastervalues.isChangeLocationSheetPresented ) {
				Section(header: ItemsListHeader()) {
					SimpleItemsList(location: draftLocation)
				}
			}
			
		} // end of Form

        .onAppear() {
            color = Color(red: red, green: green, blue: blue, opacity: opacity)
        }
        .sheet(isPresented: $mastervalues.isAddNewItemSheetPresented) {
            Text("add new item screen required")
//			AddNewItemView(location: draftLocation.associatedLocation)
		}

	} // end of var body: some View

    var locationItemCount: Int {

        return modelitem.countOfItemsAtLocation(listnumber: draftLocation.listnumber, locationnumber: draftLocation.locationnumber)
	}

	func ItemsListHeader() -> some View {
		HStack {
			Text("At this Location: \(locationItemCount) items")
			Spacer()
			Button {
                mastervalues.isAddNewItemSheetPresented = true
			} label: {
				Image(systemName: "plus")
			}
		}
	}
    func mygetcolor() {
        red = (color.components?.r ?? 0.5) as Double
        green = (color.components?.g ?? 0.5) as Double
        blue = (color.components?.b ?? 0.5) as Double
        opacity = (color.components?.o ?? 0.5) as Double
    }
}
//
// got this from a stackoverflow question
// https://stackoverflow.com/questions/56586055/how-to-get-rgb-components-from-color-in-swiftui
//
extension Color {

    var components: (r: Double, g: Double, b: Double, o: Double)? {
        let uiColor: UIColor

        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0

        if self.description.contains("NamedColor") {
            let lowerBound = self.description.range(of: "name: \"")!.upperBound
            let upperBound = self.description.range(of: "\", bundle")!.lowerBound
            let assetsName = String(self.description[lowerBound..<upperBound])

            uiColor = UIColor(named: assetsName)!
        } else {
            uiColor = UIColor(self)
        }

        guard uiColor.getRed(&r, green: &g, blue: &b, alpha: &o) else { return nil }

        return (Double(r), Double(g), Double(b), Double(o))
    }
}
// this is a quick way to see a list of items associated
// with a given location that we're editing.
// FIXed: implement to see items at this location
struct SimpleItemsList: View {

	@State var location: CKLocationRec
    @EnvironmentObject var modelitem: ModelItem

    var body: some View {
        List {
            ForEach(modelitem.items) { item in
                if item.locationnumber == location.locationnumber {
                    NavigationLink {
                        ModifyExistingItemView(item: item)
                    } label: {
                        HStack {
                            Text(item.name)
                            if item.onList {
                                Spacer()
                                Image(systemName: "cart")
                                    .foregroundColor(.green)
                            }
                        }
                        .contextMenu {
                            ItemContextMenu(item: item)
                        }
                    }
                }
            }
        }
    }

	@ViewBuilder
	func ItemContextMenu(item: CKItemRec) -> some View {
        Button(action: { modelitem.toggleOnListStatus(item: item) }) {
			Text(item.onList ? "Move to Purchased" : "Move to ShoppingList")
			Image(systemName: item.onList ? "purchased" : "cart")
		}
	}

}
