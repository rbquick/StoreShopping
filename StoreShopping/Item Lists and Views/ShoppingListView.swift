	//
	//  ShoppingListView.swift
	//  ShoppingList
	//
	//  Created by Jerry on 4/22/20.
	//  Copyright © 2020 Jerry. All rights reserved.
	//

import MessageUI
import SwiftUI

struct ShoppingListView: View {
	
    @EnvironmentObject var modellocation: ModelLocation
    @EnvironmentObject var modelitem: ModelItem
    @EnvironmentObject var mastervalues: MasterValues
		// MARK: - @State and @AppStorage Properties
	
		// trigger to confirm moving all items off the shopping list
	@State private var confirmMoveAllOffListIsPresented = false
	

	
		// user default for whether we are a multi-section display or not.
	@AppStorage(kShoppingListIsMultiSectionKey)
	private var multiSectionDisplay: Bool = kShoppingListIsMultiSectionDefaultValue

		// MARK: - BODY

	var body: some View {
        // debugging tool to display what has changed on this view to get a refresh
        //           do not leave in when distributing
        // let _ = Self._printChanges()
		VStack(spacing: 0) {
			
			Rectangle()
				.frame(height: 1)
			
/* ---------
 we display either a "List is Empty" view, a single-section shopping list view
 or multi-section shopping list view.  the list display has some complexity to it because
 of the sectioning, so we push it off to a specialized subview.
 ---------- */
			
            if modelitem.items.count == 0 {
				EmptyListView(listName: "Shopping")
			} else {
				ItemListView(itemSections: itemSections,
										 sfSymbolName: "purchased",
										 multiSectionDisplay: $multiSectionDisplay)
			}
			
/* ---------
 and for non-empty lists, we have a few buttons at the bottom for bulk operations
 ---------- */
			
            if modelitem.items.count > 0 {
				Divider()
				ShoppingListBottomButtons()
			} //end of if items.count > 0
			
		} // end of VStack
        // rbq changed 2023-03-31 put the shoplist name instead of "Shopping"
        .navigationBarTitle("\(MyDefaults().myMasterShopListName) List")
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing, content: trailingButtons)
		}
        .sheet(isPresented: $mastervalues.isAddNewItemSheetPresented) {
            ModifyExistingItemView(item: CKItemRec(shopper: Int64(MyDefaults().myMasterShopperShopper), listnumber: Int64(MyDefaults().myMasterShopListListnumber), locationnumber: 1, onList: true, quantity: 1, isAvailable: true, name: "New Item", dateLastPurchased: nil)!)
		}
        .onAppear(perform: handleOnAppear)
		
	} // end of body: some View
	
		// MARK: - Subviews
	
	private func trailingButtons() -> some View {
		HStack(spacing: 12) {
			ShareLink("", item: shareContent())
                .disabled(modelitem.items.count == 0)
			
			NavBarImageButton("plus") {
                mastervalues.isAddNewItemSheetPresented = true
			}
		} // end of HStack
	}
	
	private func ShoppingListBottomButtons() -> some View {
		HStack {
			Spacer()
			
			Button("Move All Off List") {
				confirmMoveAllOffListIsPresented = true
			}
			.confirmationDialog("Move All Off List?",
													isPresented: $confirmMoveAllOffListIsPresented,
													titleVisibility: .visible) {
				Button("Yes", role: .destructive,
							 action: modelitem.moveAllItemsOffShoppingList)
			}

			
            if !modelitem.items.allSatisfy({ $0.isAvailable })  {
				Spacer()
				Button("Mark All Available") {
                    modelitem.items.forEach { modelitem.markAvailable(item: $0) }
				}
			}
			
			Spacer()
		} // end of HStack
		.padding(.vertical, 6)
	}

	// MARK: - Helper Functions
    func handleOnAppear() {
        print("ShoppingListView.onappear \(MyDefaults().myMasterShopListName)")
    }
	
	private var itemSections: [ItemSection] {
		// the code in this section has been restructured in SL16 so that the
		// view becomes responsive to any change in the order of Locations
		// that might take place in the Locations tab.
		// the key element is that we must use the  `locations` @FetchRequest
		// definition in this code to determine the visitation order of items
		// so that sectioning is done correctly.  if we relied solely on an item's
		// visitationOrder property, SwiftUI would never update this view based
		// on a change made in the Locations tab. (changing a visitation order
		// in SL15 and earlier sent an objectWillChange() message to all associated
		// Items, which will update any view that holds one of those objects as an
		// @ObservedObject, but it won't trigger a @FetchRequest -- i.e., SL15
		// did not handle this at all).
		
		// note that for a little more clarity, i have removed the use of a dictionary
		// to group items on the list by location ... for SL16, let's keep it simple.
		
		// the first step is to construct pairs of the form (location: Location, items: [Item]) for
		// items on the shopping list, where we match each location with its items on the list.
		// (locations with no items on the list will be ignored, and we sort by visitationOrder).
		// however, we do this based on the values in the `locations` @FetchRequest
		// property and not the item's properties (e.g., location).
        print("shoppinglistview.itemSection called mastername: \(MyDefaults().myMasterShopListName)")
//        let cou = modelitem.items.reduce(0) { $0 + Int((($1.listnumber == 3) && ($1.locationnumber == 1)) ? 1 : 0)  }
        let cou = modelitem.items.reduce(0) { $0 + ($1.onList ? 1 : 0)  }
        print("items on list: \(cou)")
        let locationItemPairs: [(location: CKLocationRec, items: [CKItemRec])] = modellocation.locations
			.map({ location in
                ( location, modelitem.items.filter({ $0.onList && $0.locationnumber == location.locationnumber }) )
			})
			.filter({ !$0.items.isEmpty })
			.sorted(by: { $0.location.visitationOrder < $1.location.visitationOrder })

			// if we have nothing on the list, there's nothing for ItemListView to show
        guard modelitem.items.count > 0 else { return [] }

		// now restructure from (Location, [Item]) to [ItemSection].
		// for a single section, just lump all the items of all the pairs
		// into a single list with flatMap.
		if !multiSectionDisplay {
			return [ItemSection(index: 1,
                                title: "Items Remaining: \(modelitem.items.count)",
                                items: locationItemPairs.flatMap{( $0.items )} .sorted(by: {$0.name < $1.name}))
			]
		}
		// for multiple sections, we mostly have what we need, but must add an indexing
		// (by agreement with ItemListView), so we'll handle that using .enumerated
		return locationItemPairs.enumerated().map({ (index, pair) in
			ItemSection(index: index + 1, title: pair.location.name, items: pair.items)
		})

	} // end of var itemSections: [ItemSection]
		
		// MARK: - Sharing support
	
	private func shareContent() -> String {
			// we share a straight-forward text description of the
			// shopping list.  note: in SL16, we'll leverage the itemSections variable (!)
		var message = "Items on your Shopping List: \n"
		for section in itemSections {
			message += "\n\(section.title)"
			if !multiSectionDisplay {
				message += ", \(section.items.count) item(s)"
			}
			message += "\n\n"
			for item in section.items {
				message += "  \(item.name)\n"
			}
		}
		return message
	}
	
} // end of ShoppingListBottomButtons
