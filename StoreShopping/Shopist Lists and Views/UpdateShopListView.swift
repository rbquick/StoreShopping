//
//  UpdateShopListView.swift
//  ShoppingList
//
//  Created by Brian Quick on 2023-04-01.
//

import SwiftUI

struct UpdateShopListView: View {

    @EnvironmentObject var modelshoplist: ModelShopList
    @EnvironmentObject var mastervalues: MasterValues
    @EnvironmentObject var modelitem: ModelItem

        // a draftLocation is initialized here, holding default values for
        // a new Location.
    @State var draftShopList: CKShopListRec
    @State var returnedMessage: String = ""
    @State var name = ""
    @State var addOrUpdateLiteral = ""
    var body: some View {
//        NavigationStack {
            DraftShopListForm(draftShopList: draftShopList, name: $name)
                .navigationBarTitle(addOrUpdateLiteral)
                .navigationBarTitleDisplayMode(.inline)
                //.navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction, content: cancelButton)
                    ToolbarItem(placement: .confirmationAction) { saveButton().disabled(!draftShopList.canBeSaved) }
                }
//        }
        .onAppear() {
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
        change()

        mastervalues.isChangeShopListSheetPresented = false
        mastervalues.isAddNewShopListSheetPresented = false
    } label: {
        Text("Save")
    }
}
    func change() {
        
        guard let changeRec = draftShopList.update(shopper: draftShopList.shopper, listnumber: draftShopList.listnumber, name: name) else { return }

        modelshoplist.addOrUpdate(shoplist: changeRec) { rtnMessage in
            returnedMessage = rtnMessage
            modelshoplist.MasterShopListName = name
            modelshoplist.MasterShopListListnumber = Int(changeRec.listnumber)
            print(returnedMessage)
            for shoplist in modelshoplist.shoplists {
                print(shoplist.name)
            }
            modelitem.getAll(shopper: MyDefaults().myMasterShopperShopper, listnumber: MyDefaults().myMasterShopListListnumber)
            
        }
    }
}

struct UpdateShopListView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateShopListView(draftShopList: CKShopListRec(shopper: 1, listnumber: 1, name: "Costco")!)
    }
}
