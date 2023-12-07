//
//  SimpleLocationsList.swift
//  StoreShopping
//
//  Created by Brian Quick on 2023-12-06.
//

import SwiftUI

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

struct SimpleLocationsList_Previews: PreviewProvider {
    static var previews: some View {
        SimpleLocationsList(shoplist: CKShopListRec.example1())
            .environmentObject(ModelLocation())
    }
}
