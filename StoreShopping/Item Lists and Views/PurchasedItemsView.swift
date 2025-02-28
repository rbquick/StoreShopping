	//
	//  PurchasedItemsView.swift
	//  ShoppingList
	//
	//  Created by Jerry on 5/14/20.
	//  Copyright © 2020 Jerry. All rights reserved.
	//

import SwiftUI

	// a simple list of items that are not on the current shopping list
	// these are the items that were on the shopping list at some time and
	// were later removed -- items we purchased.  you could also call it a
	// catalog, of sorts, although we only show items that we know about
	// that are not already on the shopping list.

struct PurchasedItemsView: View {
	
		// MARK: - @Environment Properties

    @EnvironmentObject var modellocation: ModelLocation
    @EnvironmentObject var modelitem: ModelItem
    @EnvironmentObject var modelitemsection: ModelItemSection
    @EnvironmentObject var mastervalues: MasterValues
    @EnvironmentObject var watchConnector: WatchConnector
		// the value of Calendar.current is in the environment
	@Environment(\.calendar) private var calendar
	
		// MARK: - @FetchRequest
	
		// this is the @FetchRequest that ties this view to CoreData
//	@FetchRequest(fetchRequest: Item.allItemsFR(onList: false))
    // rbq changed this call to get ALL the items since they will be shown
    //     in the circle if they are already selected for the shopping list


		// MARK: - @State and @AppStorage Properties




		// items currently checked, on their way to the shopping list
//	@State private var itemsChecked = [CKItemRec]()
	
		// number of days in the past for the first section when using sections
	@AppStorage(kPurchasedMostRecentlyKey)
	private var historyMarker = kPurchasedMostRecentlyDefaultValue
	
	@AppStorage(kPurchasedListIsMultiSectionKey)
	private var multiSectionDisplay: Bool = kPurchasedListIsMultiSectionDefaultValue

    @State private var myshoplist = ""
		// MARK: - BODY

	var body: some View {
		VStack(spacing: 0) {
			
			Rectangle()
				.frame(height: 1)
            // This is put on the screen invisibly.  If you take this out, the mysearchText field
            // is empty when you are adding a non-exsistant searched item.
            // why? ask the wisdom of apple
            Text(modelitemsection.mysearchText)
                .foregroundColor(.clear)
                .frame(width: 0, height: 0)

				// display either a "List is Empty" view, or the sectioned list of purchased items.
            if modelitem.items.count == 0 {
				EmptyListView(listName: "Selection")
			} else {
                ItemListView(itemSections: modelitemsection.itemSections,
										 sfSymbolName: "cart",
										 multiSectionDisplay: $multiSectionDisplay)
			} // end of if-else
			
			Divider() // keeps list from overrunning the tab bar in iOS 15
		} // end of VStack
        .searchable(text: $modelitemsection.searchText)
        .onSubmit(of: .search) {
            modelitemsection.mysearchText = modelitemsection.searchText
            modelitemsection.searchText = ""
            mastervalues.isAddNewItemSheetPresented = true
        }
        // have to do this whereas before, it was being done by simply accessing the variable
        .onChange(of: modelitemsection.searchText) { text in
            modelitemsection.setItemSection(locations: modellocation.locations, items: modelitem.items)
        }
		.onAppear(perform: handleOnAppear)
		.onDisappear(perform: handleDisappear)
        //rbq changed 2023-03-31 put the ShopList name instead of generic List
        .navigationBarTitle("\(MyDefaults().myMasterShopListName) \(modelitemsection.currentSection)")
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing, content: addNewButton)
		}
        .sheet(isPresented: $mastervalues.isAddNewItemSheetPresented) {
            ModifyExistingItemView(item: CKItemRec(shopper: Int64(MyDefaults().myMasterShopperShopper), listnumber: Int64(MyDefaults().myMasterShopListListnumber), locationnumber: modellocation.locations[0].locationnumber, onList: true, quantity: 1, isAvailable: true, name: modelitemsection.mysearchText, dateLastPurchased: nil)!)
//			AddNewItemView(suggestedName: mysearchText)
		}
	} // end of var body: some View

		// MARK: - Subviews

		// makes a simple "+" to add a new item.  yapping on the button triggers a sheet to add a new item.
	func addNewButton() -> some View {
		NavBarImageButton("plus") {
            modelitemsection.mysearchText = "New Item"
            mastervalues.isAddNewItemSheetPresented = true
		}
	}
	
		// MARK: - Helper Functions
	
	func handleOnAppear() {
        print("PurchasedItemsView.onappear modelitem.items.count is \(modelitem.items.count)")
        modelitemsection.searchText = "" // clear searchText, get a clean screen
        myshoplist = MyDefaults().myMasterShopperName
        modelitemsection.currentSection = "Selection"
//        modelitemsection.setItemSection(locations: modellocation.locations, items: modelitem.items)
	}
	
	func handleDisappear() {
			// we save when this view goes off-screen.  we could use a more aggressive
			// strategy for saving data out to persistent storage, but saving here should
			// get the job done.
        // FIXed: everything s/b saved at this point
//		persistentStore.save()
	}
	

	

	

	
}
