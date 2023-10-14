//
//  AddNewItemView.swift
//  StoreShopping
//
//  Created by Brian Quick on 2023-10-10.
//

import SwiftUI

struct AddNewItemView: View {
    @State var suggestedName: String
    var body: some View {
        Text(suggestedName)
    }
}

struct AddNewItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewItemView(suggestedName: "new item")
    }
}
