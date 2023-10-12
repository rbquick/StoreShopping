//
//  PurchasedItemsView.swift
//  StoreShopping
//
//  Created by Brian Quick on 2023-09-29.
//

import SwiftUI

struct PurchasedItemsView: View {
    @State var item: CKItemRec
    var body: some View {
        Text(item.name)
    }
}

//struct PurchasedItemsView_Previews: PreviewProvider {
//    static var previews: some View {
//        PurchasedItemsView()
//    }
//}
