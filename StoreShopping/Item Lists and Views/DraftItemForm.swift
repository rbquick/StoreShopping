	//
	//  DraftItemForm.swift
	//  ShoppingList
	//
	//  Created by Jerry on 12/8/21.
	//  Copyright © 2021 Jerry. All rights reserved.
	//

import SwiftUI

	// the DraftItemForm is a simple Form that allows the user to edit
	// the value of a DraftItem, which can represent either default values
	// for a new Item to create, or an existing Item.  additionally, for
	// an existing Item, we are provided a dismissAction to perform
	// after deleting the Item, which allows the parent view to dismiss
	// itself.
struct DraftItemForm: View {

    // incoming data represents either
    // -- default data for an existing Item that we wish to create
    //
    // -- or data for an existing Item that we wish to modify, plus a function
    //      to dismiss ourself should the user confirm they want to delete
    //      this Item ... because we cannot leave this view on screen after
    //      the Item is deleted.

    @State var item: CKItemRec

    var dismissAction: (() -> Void)?

    @EnvironmentObject var modelshoplist: ModelShopList
    @EnvironmentObject var modellocation: ModelLocation
    @EnvironmentObject var modelitem: ModelItem
    @EnvironmentObject var modelitemsection: ModelItemSection

    @Binding var shopper: Int64
    @Binding var listnumber: Int64
    @Binding var locationnumber: Int64
    @Binding var onList: Bool
    @Binding var quantity: Int
    @Binding var isAvailable: Bool
    @Binding var name: String
    @Binding var dateLastPurchased: Date?

    // this used to implement confirmation alert process for deleting an Item.
    @State private var alertIsPresented = false
    @State private var initialized = false

    @State var mylocations = [CKLocationRec]()

    // MARK: - Computed Variables

    // MARK: - BODY

    var body: some View {
        Form {
            // Section 1. Basic Information Fields
            Section(header: Text("Basic Information")) {

                HStack(alignment: .firstTextBaseline) {
                    SLFormLabelText(labelText: "Name: ")
                    TextField("Item name", text: $name)
                }

                Stepper(value: $quantity, in: 1...10) {
                    HStack {
                        SLFormLabelText(labelText: "Quantity: ")
                        Text("\(quantity)")
                    }
                }

                Picker(selection: $listnumber, label: SLFormLabelText(labelText: "List: ")) {
                    ForEach(modelshoplist.shoplists) { list in
                        Text("\(list.listnumber): \(list.name)").tag(list.listnumber)
                    }
                }

                Picker(selection: $locationnumber, label: SLFormLabelText(labelText: "Location: ")) {
                    ForEach(mylocations) { location in
                        Text("\(location.locationnumber): \(location.name)").tag(location.locationnumber)
                    }
                }

                HStack(alignment: .firstTextBaseline) {
                    Toggle(isOn: $onList) {
                        SLFormLabelText(labelText: "On Shopping List: ")
                    }
                }

                HStack(alignment: .firstTextBaseline) {
                    Toggle(isOn: $isAvailable) {
                        SLFormLabelText(labelText: "Is Available: ")
                    }
                }

                if dateLastPurchased != nil {
                    HStack(alignment: .firstTextBaseline) {
                        SLFormLabelText(labelText: "Last Purchased: ")
                        Text("\(dateLastPurchased!)")
                    }
                }

            } // end of Section 1

            // Section 2. Item Management (Delete), if present
            if modelitem.isOnFile(item: item)  {
                Section(header: Text("Shopping Item Management")) {
                    Button("Delete This Shopping Item") {
                        alertIsPresented = true
                    }
                    .foregroundColor(Color.red)
                    .myCentered()
                    .alert("Delete \'\(name)\'?",
                                        isPresented: $alertIsPresented) {
                        Button("Yes", role: .destructive) {
                            modelitem.delete(item: item) { completion in
                                print(completion)
                                modelitemsection.setItemSection(locations: modellocation.locations, items: modelitem.items)
                                dismissAction?()
                            }

                        }
                    } message: {
                        Text("Are you sure you want to delete the Item named \'\(name)\'? This action cannot be undone.")
                    }


                } // end of Section 2
            } // end of if ...

        } // end of Form
        .onChange(of: listnumber) { newValue in
            print("onchange listnumber:\(listnumber) location:\(locationnumber)")
            if initialized {
                modellocation.getAllLocationsByListNumber(shopper: Int(shopper), listnumber: Int(listnumber)) { completion in
                    mylocations = completion
                    locationnumber = mylocations[0].locationnumber
                    print("onchange listnumber:\(listnumber) location:\(locationnumber) complete ")
                }
            }
        }
        .onAppear() {
            print("onappear listnumber:\(listnumber) location:\(locationnumber)")
            modellocation.getAllLocationsByListNumber(shopper: Int(shopper), listnumber: Int(listnumber)) { completion in
                mylocations = completion
                initialized = true
                print("onappear listnumber:\(listnumber) location:\(locationnumber) complete")
            }
        }
        .onDisappear() {
            initialized = false
        }

    } // end of var body: some View

}
