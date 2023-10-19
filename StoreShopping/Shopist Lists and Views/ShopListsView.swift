//
//  ShopListsView.swift
//  ShoppingList
//
//  Created by Brian Quick on 2023-04-01.
//  Copyright © 2023 Jerry. All rights reserved.
//

import SwiftUI

struct ShopListsView: View {

    @EnvironmentObject var modelshoplist: ModelShopList
    @EnvironmentObject var modellocation: ModelLocation
    @EnvironmentObject var modelitem: ModelItem
    @EnvironmentObject var mastervalues: MasterValues

    // MARK: - @State and @StateObject Properties

    // MARK: - BODY

    var body: some View {
        VStack(spacing: 0) {

            Rectangle()
                .frame(height: 1)
            HStack {
                Text("Current Shopping list is \(modelshoplist.MasterShopListName)")
                    .padding()
                        .background(.blue)
                        .foregroundColor(.white)
                        .font(.headline)
            }

            List {
                Section(header: Text("Shopping Lists: \(modelshoplist.shoplists.count) with the master list being \(modelshoplist.MasterShopListName)")) {
                    ForEach(modelshoplist.shoplists) { shoplist in
//                        NavigationLink(value: shoplist) {
                            ShopListRowView(shoplist: shoplist) { setmasterShopList(shoplist: shoplist) }
//                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            Divider()
        }
        .navigationBarTitle("Lists Available")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing, content: addNewButton)
            ToolbarItem(placement: .navigationBarLeading, content: changeButton)
        }
        .sheet(isPresented: $mastervalues.isAddNewShopListSheetPresented) {
            UpdateShopListView(draftShopList: CKShopListRec(shopper: Int64(MyDefaults().myMasterShopperShopper), listnumber: 9999, name: "newList")!)
        }
        .sheet(isPresented: $mastervalues.isChangeShopListSheetPresented) {
            UpdateShopListView(draftShopList: modelshoplist.getMaster())
        }
        .onAppear { handleOnAppear() }
    }
    func handleOnAppear() {

        if modelshoplist.shoplists.count == 0 {
            // don't know what to do here with no ShopList?
//            let _ = ShopList.unknownLocation()
        }
    }
    func changeButton() -> some View {
        Button {
            mastervalues.isChangeShopListSheetPresented = true
        } label: {
            HStack {
                Text("Edit ")
                Image(systemName: "pencil")
            }
        }
    }
    // defines the usual "+" button to add a Location
    func addNewButton() -> some View {
        Button {
            mastervalues.isAddNewShopListSheetPresented = true
        } label: {
            HStack {
                Text("Add ")
                Image(systemName: "plus")
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

//struct ShopListsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ShopListsView()
//    }
//}
