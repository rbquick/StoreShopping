	//
	//  ModifyExistingItemView.swift
	//  ShoppingList
	//
	//  Created by Jerry on 12/8/21.
	//  Copyright © 2021 Jerry. All rights reserved.
	//

import SwiftUI

	// the ModifyExistingItemView is opened via a navigation link from the ShoppingListView
	// or the PurchasedItemTabView to do as it says: edit an existing shopping item.
	//
	// this will be an "almost live edit," in the sense that when the user touches the <Back button,
	// we update the values of the Item with the edited values.  however, because we have to intercept
	// when the user taps the Back button, we'll use our own Back button.  (we don't really need
	// this ... we could handle the update in an .onDisappear modifier as we do over in
	// ModifyExistingLocationView.  you decide!  the downside of handling this in .onDisappear is
	// that we'll return to the previous screen on the navigation stack, see the old presentation, and
	// then see it update for the edit.  also, we never really know when .onDisappear will be called --
	// or even if it could be called more than once).
	//
	// the strategy is simple:
	//
	// -- create an editable representation of values for the item (a StateObject)
	// -- the body shows a Form in which the user can edit the values
	// -- and update the Item's values from the editable representation when finished.
	//
struct ModifyExistingItemView: View {
	
	@Environment(\.dismiss) private var dismiss: DismissAction
    @EnvironmentObject var modelitem: ModelItem
    @EnvironmentObject var mastervalues: MasterValues
	
		// an editable copy of the Item's data -- a "draft," if you will
	@State var item: CKItemRec
    @State var shopper: Int64 = 1
    @State var listnumber: Int64 = 1
    @State var locationnumber: Int64 = 1
    @State var onList: Bool = false
    @State var quantity: Int = 1
    @State var isAvailable: Bool = true
    @State var name: String = "New Item"
    @State var dateLastPurchased: Date? = nil

    @State var alertIsPresented: Bool = false
    @State var addingNewItem: Bool = false
	var body: some View {
			// the dismissAction function provides the DraftItemView with a way to dismiss
			// us, which is necessary should the item be deleted.  we could write this using
			// a trailing closure, but it's nice to know we can just pass the function's name
			// which is not "dismiss," but for syntax reasons with type DismissAction, we
			// must use its callAsFunction property.
//        Text("draftitemform replacement")
//        PurchasedItemsView(item: item)
//                    .navigationBarTitle("Modify Item")
//                    .navigationBarTitleDisplayMode(.inline)
//                    .navigationBarBackButtonHidden(true)
//                    .toolbar {
//                        ToolbarItem(placement: .navigationBarLeading, content: customBackButton)
//                    }
        VStack {
                    if mastervalues.isAddNewItemSheetPresented {
            HStack {
                customBackButton()
                Spacer()
                Text("Adding new Item")
                Spacer()
                saveButton()
            }
            .padding()
            Divider()
                    }

            DraftItemForm(item: item, dismissAction: dismiss.callAsFunction, shopper: $shopper, listnumber: $listnumber, locationnumber: $locationnumber, onList: $onList, quantity: $quantity, isAvailable: $isAvailable, name: $name, dateLastPurchased: $dateLastPurchased)
                .navigationBarTitle("Modify Item")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading, content: customBackButton)
                    ToolbarItem(placement: .confirmationAction) { saveButton() }
                }
                .onAppear() {
                    shopper = item.shopper
                    listnumber = item.listnumber
                    locationnumber = item.locationnumber
                    onList = item.onList
                    quantity = item.quantity
                    isAvailable = item.isAvailable
                    name = item.name
                    dateLastPurchased = item.dateLastPurchased
                    addingNewItem = mastervalues.isAddNewItemSheetPresented
                }
                .interactiveDismissDisabled()
        }
	} // end of var body: some View
	
		// i have never liked the idea of using a custom Back button ... it does not
		// really look all that good.  it has to be localized, and might actually point
		// in the wrong direction in some languages.
		// however, i do not know of a way to detect when the user taps the
		// system-generated Back button.  also see discussion above.
        // this is also used when showing the .sheet.  The top line of the .sheet
        //     is built with a back and a save button if you are adding an item
	func customBackButton() -> some View {
		Button {
				// we need to ask if the draft "still" represents an existing Item.  it
				// certainly did when we opened this View, but if we hit the delete button
				// and confirmed the deletion, then this draft no longer represents a
				// real Item and we would not want to put the item back into Core Data.
            // FIXed: updating on exit? if still there
//			if draftItem.associatedItem != nil {
//				Item.updateAndSave(using: draftItem)
//			}
			dismiss()
		} label: {
			HStack(spacing: 5) {
				Image(systemName: "chevron.left")
				Text("Back")
			}
		}
	}
    func saveButton() -> some View {
        Button {
            change()
            dismiss()
        } label: {
            Text("Save")
        }
    }
    func change() {
        guard let changerec = item.update(shopper: shopper, listnumber: listnumber, locationnumber: locationnumber, onList: onList, quantity: quantity, isAvailable: isAvailable, name: name, dateLastPurchased: dateLastPurchased) else { return }

        modelitem.addOrUpdate(item: changerec) { completion in
            print(completion)
        }
    }
	
}
struct ModifyExistingItemView_Previews: PreviewProvider {
    static var previews: some View {
        ModifyExistingItemView(item: CKItemRec.example1())
            .environmentObject(ModelShopList())
            .environmentObject(ModelLocation())
            .environmentObject(ModelItem())
            .environmentObject(MasterValues())
    }
}

