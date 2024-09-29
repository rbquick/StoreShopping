//
//  WatchContentView.swift
//  WatchandIphone Watch App
//
//  Created by Brian Quick on 2024-07-07.
//

import SwiftUI

struct WatchContentView: View {
    @StateObject var watchToiOSConnector = WatchToiOSConnector()
    @EnvironmentObject var modelItem: ModelItem
    @EnvironmentObject var modelLocation: ModelLocation
    
    @State var isLoading = false

        var body: some View {
            ZStack {
                VStack {
                    HStack {
                        
                        Button(action: restoreItems) {
                            Image(systemName: "restart.circle")
                                .foregroundColor(.green)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        Text("Items: \(modelItem.onListItemCount)")
                                                Spacer()
                    }
                    List {
                        ForEach(modelItem.groupedItems.keys.sorted(), id: \.self) { location in
                            Section(header: 
                                        HStack {
                                Spacer()
                                Text(" \(modelLocation.GetLocationNameByListNumber(listnumber: location))")
                                    .foregroundColor(.green)
                                Spacer()
                            }
                            ) {
                                ForEach(modelItem.groupedItems[location]!.sorted(by: { $0.name < $1.name }), id: \.self) { item in
                                    ItemRow(item: item, deleteAction: {
                                        deleteItem(item: item)
                                    })
                                }
                            }
                        }
                    }
                }
                .padding()
                .ignoresSafeArea()
                .onAppear() {
                    watchToiOSConnector.modelitem = modelItem
                    watchToiOSConnector.modelLocation = modelLocation
//                    if watchToiOSConnector.session.isReachable {
//                        print("onAppear ios session.isReachable")
//                    } else {
//                        print("onAppear ios NOT session.isReachable")
//                    }
                }
                
                if modelItem.items.count == 0 {
                    Color.primary.opacity(0.7)
                    
                    ProgressView()
                        .progressViewStyle(.automatic)
                        .scaleEffect(3)
                }
            }
            .ignoresSafeArea()
        }
        
    func deleteItem(item: CKItemRec) {
                
        watchToiOSConnector.sendItemToiOS(item: item)
        if let index = modelItem.items.firstIndex(where: {$0.name == item.name }) {
            modelItem.setOnListStatus(item: modelItem.items[index], onlist: false )
            modelItem.groupItemsByLocation()
        }

    }
    func restoreItems() {
        for i in 0..<modelItem.items.count {
            modelItem.setOnListStatus(item: modelItem.items[i], onlist: true )
        }
        modelItem.groupItemsByLocation()
    }
}

/*
 The use of the #Preview macro is explained at this website
 https://stackoverflow.com/questions/77209828/swiftui-preview-macro-not-working-with-observation
 */
#Preview {
    var modelitem = ModelItem()
    var modelLocation = ModelLocation()
    return WatchContentView()
        .environmentObject(modelitem)
        .environmentObject(modelLocation)
}
struct ItemRow: View {
    let item: CKItemRec
    let deleteAction: () -> Void
    
    var body: some View {
        
        HStack {
            Text(item.name)
            Spacer()
            Button(action: deleteAction) {
                Image(systemName: "cart")
                    .foregroundColor(.green)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}



//extension ContentView {
//     private var ExtractedView: some View {
//            List {
//                ForEach(Array(modelitem.items
//                    .filter { $0.onList }
//                    .reduce(into: [Int64: [CKItemRec]]()) { result, item in
//                        result[item.locationnumber, default: []].append(item)
//                    }), id: \.key) { location, items in
//                        Section(header: Text("Location \(location)")) {
//                            ForEach(items, id: \.id) { item in
//                                Text(item.name)
//                            }
//                            .onDelete { offsets in
//                                modelitem.deleteItem(at: offsets, in: location)
//                        }
//                        }
//                    }
//            }
//        
//    }
//}
