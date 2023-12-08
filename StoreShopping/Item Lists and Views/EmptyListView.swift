//
//  EmptyListView.swift
//  ShoppingList
//
//  Created by Jerry on 7/12/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

// this consolidates the code for what to show when a list is empty
struct EmptyListView: View {
	var listName: String
    @EnvironmentObject var modellocation: ModelLocation
    @EnvironmentObject var modelitem: ModelItem
    @EnvironmentObject var modelitemsection: ModelItemSection
	var body: some View {
            List {
                HStack {
                    Spacer()
                    VStack() {
                        Text("There are no items")
                        //					.padding([.top], 200)
                        Text("on your \(listName) List.")
                    }
                    .font(.title)
                    .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .refreshable {
                if modelitem.items.count < 0 {
                    modelitem.getAll(shopper: Int(modelitem.items[0].shopper), listnumber: Int(modelitem.items[0].listnumber))
                modelitemsection.setItemSection(locations: modellocation.locations, items: modelitem.items)
                }
            }
	}
}
struct EmptyListView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyListView(listName: "Groceries")
            .environmentObject(ModelItem())
    }
}

