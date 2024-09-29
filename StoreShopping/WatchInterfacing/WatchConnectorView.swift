//
//  WatchContentView.swift
//  
//
//  Created by Brian Quick on 2024-07-07.
//

import SwiftUI
import CloudKit

struct WatchContentView: View {
    @StateObject var watchConnector = WatchConnector()
    @EnvironmentObject var modelitem: ModelItem
    @EnvironmentObject var modelLocation: ModelLocation
    
    @State var watchActivated = false
    var body: some View {
        VStack {
            Text("Watch activated is: \(watchActivated)")
            Button {
                activateWatch()
            } label: {
                Text("activate Watch")
            }
            Button {
                if watchActivated {
                    for i in 0...modelitem.items.count - 1 {
                        watchConnector.sendItemToWatch(item: modelitem.items[i], initialize: i == 0 ? true : false)
                    }
                }
            } label: {
                Text("Send message")
            }
            Text("Items: \(modelitem.items.count)")
            List {
                ForEach(modelitem.items.indices, id: \.self) { index in
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
            List {
                ForEach(modelLocation.locations.indices, id: \.self) { index in
                    HStack {
                        Text("\(modelLocation.locations[index].locationnumber)")
                        Text(modelLocation.locations[index].name)
                    }
                }
            }
        }
        .padding()
    }
    func activateWatch() {
        if watchConnector.session.isReachable {
            watchActivated = true
            watchConnector.modelitem = modelitem
            watchConnector.modelLocation = modelLocation
        } else {
            watchActivated = false
        }
    }
}

#Preview {
    var modelLocation = ModelLocation()
    var modelitem = ModelItem()
    return ContentView()
        .environmentObject(modelitem)
        .environmentObject(modelLocation)
}
