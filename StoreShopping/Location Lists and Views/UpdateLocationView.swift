//
//  UpdateLocationView.swift
//  StoreShopping
//
//  Created by Brian Quick on 2023-10-06.
//

import SwiftUI

struct UpdateLocationView: View {

    @EnvironmentObject var modellocation: ModelLocation
    @EnvironmentObject var mastervalues: MasterValues

    @State  var draftLocation: CKLocationRec


    var body: some View {
            // the trailing closure provides the DraftLocationView with what to do after the user has
            // chosen to delete the Location, namely to dismiss this view,"
            // so we "go back" up the navigation stack
        DraftLocationForm(draftLocation: draftLocation) {
            mastervalues.isChangeLocationSheetPresented = false
            mastervalues.isAddNewLocationSheetPresented = false
        }
            .navigationBarTitle("Modify Location")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: customBackButton)
            }
    }

    func customBackButton() -> some View {
            //...  see comments in ModifyExistingItemView about using
            // our own back button.
        Button {
            modellocation.addOrUpdate(location: draftLocation) {_ in
                print("location updated")
            }

            mastervalues.isChangeLocationSheetPresented = false
            mastervalues.isAddNewLocationSheetPresented = false
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "chevron.left")
                Text("Back")
            }
        }
    }


}

struct UpdateLocationView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateLocationView(draftLocation: CKLocationRec.example1())
            .environmentObject(ModelLocation())
            .environmentObject(MasterValues())
    }
}
