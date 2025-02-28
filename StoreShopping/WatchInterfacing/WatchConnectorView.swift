//
//  WatchConnectorView.swift
//
//
//  Created by Brian Quick on 2024-07-07.
//

import SwiftUI
import CloudKit

struct WatchConnectorView: View {
    @EnvironmentObject var mastervalues: MasterValues
    @EnvironmentObject var watchConnector: WatchConnector
    @EnvironmentObject var modelitem: ModelItem
    @EnvironmentObject var modelLocation: ModelLocation
    
    // user default. what to use when sending data to/from the watch
    @AppStorage(ktransferUserInfoKey)
    private var usetransferUserInfo = ktransferUserInfoDefaultValue
    @State var itemsSent = 0
    var body: some View {
        VStack {
            Text("Watch activated is: \(mastervalues.isWatchAvailable)")
//            Button {
//                activateWatch()
//            } label: {
//                Text("activate Watch")
//            }
            Button {
                activateWatch()
                itemsSent = 0
//                if watchConnector.session.isReachable{
                    for i in 0...modelitem.items.count - 1 {
                        if modelitem.items[i].onList {
                            itemsSent += 1
                        }
                        watchConnector.sendItemToWatch(item: modelitem.items[i], initialize: i == 0 ? true : false)
                    }
//                }
            } label: {
                Text("Send list to watch")
            }
            if watchConnector.session.isReachable || itemsSent != 0 {
                Text("Using \(usetransferUserInfo ? "transferUserInfo"  :  "sendMessage") for transfer")
                Text("Items sent: \(itemsSent)")
                Text("All items have been sent to the watch.  Leave this open to get updated as the watch clears things as finished").font(.headline)
            } else {
                Text("Activate the watch shopping list application first then click the Send list ")
                    .background(.red)
            }
            List {
                ForEach(modelitem.items.indices, id: \.self) { index in
                    if modelitem.items[index].onList {
                        HStack {
                            Text("\(modelitem.items[index].locationnumber)")
                            Text("\(modelLocation.GetvisitationOrderByLocationnumber(locationnumber: modelitem.items[index].locationnumber))")
                            Text(modelitem.items[index].name)
                            if modelitem.items[index].onList {
                                Spacer()
                                Image(systemName: "cart")
                                    .foregroundColor(.green)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
            }
            // This is used during development
//            List {
//                ForEach(modelLocation.locations.indices, id: \.self) { index in
//                    HStack {
//                        Text("\(modelLocation.locations[index].locationnumber)")
//                        Text(modelLocation.locations[index].name)
//                    }
//                }
//            }
        }
        .onAppear() {
            activateWatch()
        }
        .padding()
    }
    func activateWatch() {
        watchConnector.modelitem = modelitem
        watchConnector.modelLocation = modelLocation
        if watchConnector.session.isReachable {
            mastervalues.isWatchAvailable = true

        } else {
            mastervalues.isWatchAvailable = false
        }
    }
}

#Preview {
    var mastervalues = MasterValues()
    var modelLocation = ModelLocation()
    var modelitem = ModelItem()
    return WatchConnectorView()
        .environmentObject(mastervalues)
        .environmentObject(modelitem)
        .environmentObject(modelLocation)
}
