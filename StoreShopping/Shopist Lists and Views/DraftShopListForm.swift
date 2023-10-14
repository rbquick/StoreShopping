//
//  DraftShopListForm.swift
//  ShoppingList
//
//  Created by Brian Quick on 2023-04-01.
//  Copyright © 2023 Jerry. All rights reserved.
//

import SwiftUI

struct DraftShopListForm: View {

    @State var shoplist: CKShopListRec
    @EnvironmentObject var modelshoplist: ModelShopList
    @EnvironmentObject var mastervalues: MasterValues
    @Binding public var name: String

    // trigger for adding a new item at this Location
    @State private var isAddNewLocationSheetPresented = false
    // trigger for confirming deletion of the associated Location (if the
    // draft represents an existing Location that is not the Unknown Location)
    @State private var isConfirmDeleteShopListPresented = false
    
    // definition of whether we can offer a deletion option in this view
    // (it's a real location that's not the unknown shoplist)
    // rbq 2023-04-01 don't really care if this is unknown
    var shoplistCanBeDeleted: Bool = true

    var body: some View {
        Form {
            Section(header: Text("Basic Information")) {
                HStack {
                    SLFormLabelText(labelText: "Name: ")
                    TextField("Shop List name", text: $name)
                }
            } // end of Section 1

            // Section 2:

            if shoplistCanBeDeleted && mastervalues.isChangeShopListSheetPresented {
                Section(header: Text("ShopList Management")) {
                    Button("Delete This ShopList") {
                        isConfirmDeleteShopListPresented = true // trigger confirmation dialog
                    }
                    .foregroundColor(Color.red)
                    .myCentered()
                    .confirmationDialog("Delete \'\(shoplist.name)\'?", isPresented: $isConfirmDeleteShopListPresented, titleVisibility: .visible) {
                        Button("Yes", role: .destructive) {
                                modelshoplist.delete(shoplist: shoplist) { returnvalue in
                                    print("shoplist deleted")
                                }
                            mastervalues.isChangeShopListSheetPresented = false
                        }
                    } message: {
                        Text("Are you sure you want tot delete the ShopList named \'\(shoplist.name)\'? All Locations and items will be removed.  This action cannot be undone.")
                    }
                }
            } // end of Section 2

            // Section 3: Locations assigned to this ShopList, if we are editing a ShopList
//            if let associatedShopList = draftShopList.associatedShopList {
                Section(header: LocationsListHeader()) {
                    VStack {
                        SimpleLocationsList(shoplist: shoplist)
                    }
                }
//            }
        } // end of Form
        .onAppear() {
           // name = draftShopList.name
        }
        .sheet(isPresented: $isAddNewLocationSheetPresented) {
            UpdateShopListView(draftShopList: CKShopListRec(shopper: shoplist.shopper, listnumber: modelshoplist.GetNextlistnumber(), name: "New List")!)
        }
    } // end of var body: some View

    var shoplistLocationCount: Int {
        // FIXME: to be implemented
//        if let shoplist = draftShopList.associatedShopList {
//            return shoplist.locations.count
//        }
        return 0
    }

    func LocationsListHeader() -> some View {
        HStack {
            Spacer()
            Text("This Shoplist has the following Locations")
            Spacer()

        }
    }
}

// this is a quick way to see a list of items associated
// with a given location that we're editing.
struct SimpleLocationsList: View {

    @State var shoplist: CKShopListRec
    @EnvironmentObject var modellocation: ModelLocation

    @State var holdLoctions =  [CKLocationRec.example1()]
    // myCount MUST be shown on the view and set when the holdLocations is set
    //         if this is not done, nothing happens in this view
    @State var myCount = 0
    var body: some View {

            Text("There are \(myCount) locations on file")


            List {
                ForEach(holdLoctions) { location in
                    LocationRowView(location: location) { setChangeLocation(location: location) }
                }
            }

        .onAppear() {
            modellocation.getAllLocationsByListNumber(shopper: Int(shoplist.shopper), listnumber: Int(shoplist.listnumber)) { completion in
                holdLoctions = completion
                myCount = holdLoctions.count
                print(completion.count)
            }
        }
    }
    func setChangeLocation(location: CKLocationRec) {

    }
}

//struct DraftShopListForm_Previews: PreviewProvider {
//    static var previews: some View {
//        DraftShopListForm()
//    }
//}
