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
    @EnvironmentObject var modelitemsection: ModelItemSection
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
			
            if modelitemsection.itemSections.count == 0 {
				EmptyListView(listName: "Shopping")
			} else {
                ItemListView(itemSections: modelitemsection.itemSections,
										 sfSymbolName: "purchased",
										 multiSectionDisplay: $multiSectionDisplay)
			}
			
/* ---------
 and for non-empty lists, we have a few buttons at the bottom for bulk operations
 ---------- */
			
            if modelitemsection.itemSections.count > 0 {
				Divider()
				ShoppingListBottomButtons()
			} //end of if items.count > 0
			
		} // end of VStack
        // rbq changed 2023-03-31 put the shoplist name instead of "Shopping"
        .navigationBarTitle("\(MyDefaults().myMasterShopListName) \(modelitemsection.currentSection)")
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
        modelitemsection.currentSection = "List"
//        modelitemsection.setItemSection(locations: modellocation.locations, items: modelitem.items)
    }
	
	
		// MARK: - Sharing support
	
	private func shareContent() -> String {
			// we share a straight-forward text description of the
			// shopping list.  note: in SL16, we'll leverage the itemSections variable (!)
		var message = "Items on your Shopping List: \n"
        for section in modelitemsection.itemSections {
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
