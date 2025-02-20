//
//  ShopListRowView.swift
//  ShoppingList
//
//  Created by Brian Quick on 2023-04-01.
//  Copyright © 2023 Jerry. All rights reserved.
//

import SwiftUI

struct ShopListRowView: View {

    var shoplist: CKShopListRec

    @EnvironmentObject var modellocation: ModelLocation
    @EnvironmentObject var modelitem: ModelItem

    var tapAction: () -> ()

    @State var myCount = 0
    @State var myOnlistCount = 0

    var body: some View {
        HStack {

            ZStack {
                    // not sure if i want to have at least a visible circle here at the bottom layer or not.  for
                    // some color choices (e.g., Dairy = white) nothing appears to be shown as tappable
                    //                Circle()
                    //                    .stroke(Color(.systemGray6))
                    //                    .frame(width: 28.5, height: 28.5)
                if shoplist.name == MyDefaults().myMasterShopListName {
                    Image(systemName: "circle.fill")
                        .foregroundColor(.blue)
                        .font(.title)
                }
                Image(systemName: "circle")
                    //                    .foregroundColor(Color(item.uiColor))
                    .foregroundColor(.blue)
                    .font(.title)
                if shoplist.name == MyDefaults().myMasterShopListName {
                    Image(systemName: "list.bullet.rectangle.portrait")
                        .foregroundColor(.white)
                        .font(.subheadline)
                }
            } // end of ZStack
            .animation(.easeInOut, value: shoplist.name == MyDefaults().myMasterShopListName)
            .frame(width: 24, height: 24)
            .onTapGesture(perform: tapAction)
            VStack(alignment: .leading) {
                HStack {
                    Text(shoplist.name)
                        .font(.headline)
                    Spacer()
                    Text(myOnlistCount > 0 ? "Items on list: \(myOnlistCount)" : "")
                        .font(.subheadline)
                    if myOnlistCount > 0 {
                        Image(systemName: "cart")
                            .foregroundColor(.blue)
                            .font(.subheadline)
                    }
                    
                }
            }
            .onAppear(perform: itemsOnList)
            // we do not show the location index in SL16
//            if !location.isUnknownLocation {
//                Spacer()
//                Text(String(.visitationOrder))
//            }
        } // end of HStack
    } // end of body: some View
    func itemsOnList()  {
            modelitem.getaCountOnAnyList(shopper: Int(shoplist.shopper), listnumber: Int(shoplist.listnumber)) { count in
                myOnlistCount = count
            }
        
//        DispatchQueue.main.async {
//            myOnlistCount = modelitem.getACountOnList( listnumber: Int(shoplist.listnumber))
//        }
//        return (myOnlistCount > 0 ? "Items on shopping list: \(myOnlistCount)" : "")
    }
    func subtitle() -> String {

        modellocation.getACount(shopper: Int(shoplist.shopper), listnumber: Int(shoplist.listnumber)) { count in
            myCount = count
        }
        return "\(myCount) Locations"

    }

}

struct ShopListRowView_Previews: PreviewProvider {
    static var previews: some View {
        ShopListRowView(shoplist: CKShopListRec.example1(), tapAction: {})
            .environmentObject(ModelLocation())
            .environmentObject(ModelItem())
    }

}
