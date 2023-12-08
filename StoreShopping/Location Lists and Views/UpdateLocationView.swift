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
    @State var returnedMessage: String = ""
    @State var name = ""
    @State var red = 0.5
    @State var green = 0.5
    @State var blue = 0.5
    @State var opacity = 0.5
    @State var addOrUpdateLiteral = ""

    @State var locationnumber: Int64 = 0


    var body: some View {
        NavigationStack {
            DraftLocationForm(draftLocation: draftLocation, name: $name, red: $red, green: $green, blue: $blue, opacity: $opacity)
                .navigationBarTitle(addOrUpdateLiteral)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction, content: cancelButton)
                    ToolbarItem(placement: .confirmationAction) { saveButton().disabled(!draftLocation.canBeSaved) }
                }
        }
        .onAppear() {
            locationnumber = draftLocation.locationnumber
            if locationnumber == 9999 {
                modellocation.GetNextLocationNumber() { nextnumber in
                    locationnumber = nextnumber
                }
            }
            name = draftLocation.name
            red = draftLocation.red
            green = draftLocation.green
            blue = draftLocation.blue
            opacity = draftLocation.opacity
            print("mastervalues.isChangeLocationSheetPresented:\(mastervalues.isChangeLocationSheetPresented)")
            print("mastervalues.isAddNewLocationSheetPresented:\(mastervalues.isAddNewLocationSheetPresented)")
            if mastervalues.isChangeLocationSheetPresented {
                addOrUpdateLiteral = "Changing Location "
                if modellocation.locations.count == 1 {
                    modellocation.GetNextLocationNumber { number in
                        let newRec = CKLocationRec(shopper: draftLocation.shopper, listnumber: draftLocation.listnumber, locationnumber: number, name: "UnKnown", visitationOrder: 2, red: draftLocation.red, green: draftLocation.green, blue: draftLocation.blue, opacity: draftLocation.opacity)!
                        modellocation.addOrUpdate(location: newRec) { complete in
                            print("added UnKnown location")
                        }
                    }
                }
            } else {
                addOrUpdateLiteral = "Add New Location"
            }
        }
    }
    func cancelButton() -> some View {
        Button {
            mastervalues.isChangeLocationSheetPresented = false
            mastervalues.isAddNewLocationSheetPresented = false
        } label: {
            Text("Cancel")
        }
    }
    func saveButton() -> some View {
        Button {
            change()

            mastervalues.isChangeLocationSheetPresented = false
            mastervalues.isAddNewLocationSheetPresented = false
        } label: {
                Text("Save")
        }
    }
    func change() {
        guard let changeRec = draftLocation.update(shopper: draftLocation.shopper, listnumber: draftLocation.listnumber, locationnumber: locationnumber, name: name, visitationOrder: draftLocation.visitationOrder, red: red, green: green, blue: blue, opacity: opacity) else { return }
        modellocation.addOrUpdate(location: changeRec) { rtnMessage in
            returnedMessage = rtnMessage
            print(returnedMessage)
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
