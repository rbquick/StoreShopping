//
//  DraftShopListForm.swift
//  ShoppingList
//
//  Created by Brian Quick on 2023-04-01.
//  Copyright © 2023 Jerry. All rights reserved.
//

import SwiftUI
import CloudKit

struct DraftShopListForm: View {

    @State var shoplist: CKShopListRec
    @EnvironmentObject var modelshoplist: ModelShopList
    @EnvironmentObject var modellocation: ModelLocation
    @EnvironmentObject var modelitem: ModelItem
    @EnvironmentObject var mastervalues: MasterValues
    @Binding public var name: String
    @Binding public var copyFromLocations: Bool
    @Binding public var copyFromItems: Bool
    @Binding public var copyFromListNumber: Int64

    // trigger for confirming deletion of the associated Location (if the
    // draft represents an existing Location that is not the Unknown Location)
    @State private var isConfirmDeleteShopListPresented = false
    
    // definition of whether we can offer a deletion option in this view
    // (it's a real location that's not the unknown shoplist)
    // rbq 2023-04-01 don't really care if this is unknown
    // rbq 2023-12-06 this is not being setup for deletion
    var shoplistCanBeDeleted: Bool = true




    var body: some View {
        Form {
            Section(header: Text("Basic Information")) {
                HStack {
                    SLFormLabelText(labelText: "Name: ")
                    TextField("Shop List name", text: $name)
                }
            } // end of Section 1

            if mastervalues.isAddNewShopListSheetPresented {
                Section(header: Text("New List Locations and Items")) {
                    VStack(spacing: 30) {
                        HStack {
                            SLFormLabelText(labelText: copyFromLocations ? "Select a location" : "Copy Locations from list?")

                            if copyFromLocations {
                                Picker(selection: $copyFromListNumber, label: SLFormLabelText(labelText: "")) {
                                    ForEach(modelshoplist.shoplists) { list in
                                        Text("\(list.listnumber): \(list.name)").tag(list.listnumber)
                                    }
                                }
                            }
                            Toggle(isOn: $copyFromLocations) {
//                                Text("")
                            }
                        }
                        if copyFromLocations {
                            HStack {
                                SLFormLabelText(labelText: "Items: ")
                                Toggle(isOn: $copyFromItems) {
                                    Text(copyFromItems ? "Items will be copied" : "NO Items will be copied")
                                }
                            }
                        }
                    }
                }
            }

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
                                var myLocations = [CKRecord.ID]()
                                for location in modellocation.locations {
                                    myLocations.append(location.record.recordID)
                                }
                                CloudKitUtility.deleteAllRecords(myLocations)
                                var myItems = [CKRecord.ID]()
                                for item in modelitem.items {
                                    myItems.append(item.record.recordID)
                                }
                                CloudKitUtility.deleteAllRecords(myItems)
                            }
                            mastervalues.isChangeShopListSheetPresented = false
                        }
                    } message: {
                        Text("Are you sure you want tot delete the ShopList named \'\(shoplist.name)\'? All Locations and items will be removed.  This action cannot be undone.")
                    }
                }
            } // end of Section 2

            // Section 3: Locations assigned to this ShopList, if we are editing a ShopList
            if mastervalues.isChangeLocationSheetPresented {
                Section(header: LocationsListHeader()) {
                    VStack {
                        SimpleLocationsList(shoplist: shoplist)
                    }
                }
            }
        } // end of Form
        .onAppear() {
           // name = draftShopList.name
        }
    } // end of var body: some View

    func LocationsListHeader() -> some View {
        HStack {
            Spacer()
            Text("This Shoplist has the following Locations")
            Spacer()

        }
    }
}


struct DraftShopListForm_Previews: PreviewProvider {
    static var previews: some View {
        DraftShopListForm(shoplist: CKShopListRec.example1(), name: .constant("new"), copyFromLocations: .constant(false), copyFromItems: .constant(false), copyFromListNumber: .constant(1))
//            .environmentObject(MasterValues())
            .environmentObject({ () -> MasterValues in
                let envObj = MasterValues()
                envObj.isAddNewShopListSheetPresented = true
                return envObj
            }() )
            .environmentObject(ModelShopList())
            .environmentObject(ModelLocation())
            .environmentObject(ModelItem())
    }
}
