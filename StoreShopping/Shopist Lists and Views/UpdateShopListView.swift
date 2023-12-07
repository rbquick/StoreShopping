//
//  UpdateShopListView.swift
//  ShoppingList
//
//  Created by Brian Quick on 2023-04-01.
//

import SwiftUI
import CloudKit

struct UpdateShopListView: View {

    @EnvironmentObject var modelshoplist: ModelShopList
    @EnvironmentObject var modelitem: ModelItem
    @EnvironmentObject var modellocation: ModelLocation
    @EnvironmentObject var mastervalues: MasterValues

    // a draftLocation is initialized here, holding default values for
    // a new Location.
    @State var draftShopList: CKShopListRec
    @State var returnedMessage: String = ""
    @State var name = ""
    @State var addOrUpdateLiteral = ""
    @State var listnumber: Int64 = 1

    @State var copyFromLocations: Bool = false
    @State var copyFromItems: Bool = false
    @State var copyFromListNumber: Int64 = 1

    @State private var alertPresented = false

    var body: some View {
        NavigationStack {
            DraftShopListForm(shoplist: draftShopList, name: $name, copyFromLocations: $copyFromLocations, copyFromItems: $copyFromItems, copyFromListNumber: $copyFromListNumber)
                .navigationBarTitle(addOrUpdateLiteral)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction, content: cancelButton)
                    ToolbarItem(placement: .confirmationAction) { saveButton().disabled(!draftShopList.canBeSaved) }
                }
        }
        .alert("Adding a new List", isPresented: $alertPresented) {
            Button("Cancel") {

            }
            Button("OK") {
                change()

                mastervalues.isChangeShopListSheetPresented = false
                mastervalues.isAddNewShopListSheetPresented = false
            }
        } message: {
            Text("\(copyFromLocations ? "Locations will be created from the \(modelshoplist.getShopListName(listnumber: copyFromListNumber)) list.  The items will \(copyFromItems ? "also" : "NOT") be created " : "No locations will be copied")")
        }
        .onAppear() {
            listnumber = draftShopList.listnumber
            if listnumber == 9999 {
                modelshoplist.GetNextlistnumber() { nextnumber in
                    listnumber = nextnumber
                }
            }
            name = draftShopList.name
            if mastervalues.isChangeShopListSheetPresented {
                addOrUpdateLiteral = "Changing List "
            } else {
                addOrUpdateLiteral = "Add New List"
            }
        }
    }
    // the cancel button
    func cancelButton() -> some View {
        Button {
            mastervalues.isChangeShopListSheetPresented = false
            mastervalues.isAddNewShopListSheetPresented = false
        } label: {
            Text("Cancel")
        }
    }

    // the save button
    func saveButton() -> some View {
        Button {
            if mastervalues.isAddNewShopListSheetPresented {
                alertPresented = true
            } else {
                change()

                mastervalues.isChangeShopListSheetPresented = false
                mastervalues.isAddNewShopListSheetPresented = false
            }
        } label: {
            Text("Save")
        }
    }
    func change() {

        guard let changeRec = draftShopList.update(shopper: draftShopList.shopper, listnumber: listnumber, name: name) else { return }

        modelshoplist.addOrUpdate(shoplist: changeRec) { rtnMessage in
            returnedMessage = rtnMessage
            setmasterShopList(shoplist: changeRec)

            if copyFromLocations {
                modellocation.getAllLocationsByListNumber(shopper: Int(changeRec.shopper), listnumber: Int(copyFromListNumber)) { fromLocations in
                    var toLocations = [CKRecord]()
                    for location in fromLocations {
                        let newRec = CKLocationRec(shopper: changeRec.shopper, listnumber: changeRec.listnumber, locationnumber: location.locationnumber, name: location.name, visitationOrder: location.visitationOrder, red: location.red, green: location.green, blue: location.blue, opacity: location.opacity)
                        toLocations.append(newRec!.record)
                    }
                    CloudKitUtility.saveAllRecords(toLocations)
                    if copyFromItems {
                        modelitem.getAllItemsByListnumber(shopper: Int(changeRec.shopper), listnumber: Int(copyFromListNumber)) { fromItems in
                            var toItems = [CKRecord]()
                            for item in fromItems {
                                let newItem = CKItemRec(shopper: changeRec.shopper, listnumber: changeRec.listnumber, locationnumber: item.locationnumber, onList: item.onList, quantity: item.quantity, isAvailable: item.isAvailable, name: item.name, dateLastPurchased: nil)
                                toItems.append(newItem!.record)
                            }
                            CloudKitUtility.saveAllRecords(toItems)
                        }
                    }
                }
            }
            
        }
    }
    func setmasterShopList(shoplist: CKShopListRec) {
        modelshoplist.MasterShopListName = shoplist.name
        modelshoplist.MasterShopListListnumber = Int(shoplist.listnumber)
        modellocation.getAll(shopper: MyDefaults().myMasterShopperShopper, listnumber: Int(shoplist.listnumber))
        modelitem.getAll(shopper: MyDefaults().myMasterShopperShopper, listnumber: Int(shoplist.listnumber))
        print(MyDefaults().myMasterShopListName)
//        MyDefaults().myMasterShopListListnumber = Int(truncatingIfNeeded: shoplist.listnumber)
    }
}

struct UpdateShopListView_Previews: PreviewProvider {
//    @State var draftShopList: CKShopListRec
    static var previews: some View {
        UpdateShopListView(draftShopList: CKShopListRec(shopper: 1, listnumber: 1, name: "Costco")!)
        //            .environmentObject(MasterValues())
        // set a value in the environment preview after init is done
        // https://www.hackingwithswift.com/forums/swiftui/swiftui-preview-and-atenvironmentobject/6844


            .environmentObject({ () -> MasterValues in
                let envObj = MasterValues()
                envObj.isAddNewShopListSheetPresented = true
                envObj.isChangeShopListSheetPresented = true
                return envObj
            }() )
            .environmentObject(ModelShopList())
            .environmentObject(ModelItem())
            .environmentObject(ModelLocation())
    }
}
