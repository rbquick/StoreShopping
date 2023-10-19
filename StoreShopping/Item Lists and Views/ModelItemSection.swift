//
//  ModelItemSection.swift
//  StoreShopping
//
//  Created by Brian Quick on 2023-10-17.
//

import Foundation
import SwiftUI
import ClockKit

class ModelItemSection: ObservableObject {
    @Published var itemSections = [ItemSection]()
    @Published var currentSection = "List"
    var multiSectionDisplay = true
    init() {
        setItemSection(locations: sampleLocations, items: sampleItems)
    }

    var sampleItems = [CKItemRec.example1()]
    var sampleLocations = [CKLocationRec.example1()]

    func setItemSection(locations: [CKLocationRec], items: [CKItemRec]) {
        if currentSection == "List" {
            setShoppingSection(locations: locations, items: items)
        } else {
            setPurchasedSection(locations: locations, items: items)
        }

    }
    private func setShoppingSection(locations: [CKLocationRec], items: [CKItemRec]) {
        print("setShoppingSection locations:\(locations.count) Items:\(items.count)")
        let locationItemPairs: [(location: CKLocationRec, items: [CKItemRec])] = locations
            .map({ location in
                ( location, items.filter({ $0.onList && $0.locationnumber == location.locationnumber }) )
            })
            .filter({ !$0.items.isEmpty })
            .sorted(by: { $0.location.visitationOrder < $1.location.visitationOrder })

            // if we have nothing on the list, there's nothing for ItemListView to show
        if items.count == 0  { itemSections = [ItemSection]() }

        // now restructure from (Location, [Item]) to [ItemSection].
        // for a single section, just lump all the items of all the pairs
        // into a single list with flatMap.

        var itemsectionformated = [ItemSection]()
        if !multiSectionDisplay {
            itemsectionformated = [ItemSection(index: 1,
                                title: "Items Remaining: \(items.count)",
                                items: locationItemPairs.flatMap{( $0.items )} .sorted(by: {$0.name < $1.name}))
            ]
        } else {
            // for multiple sections, we mostly have what we need, but must add an indexing
            // (by agreement with ItemListView), so we'll handle that using .enumerated
            itemsectionformated =  locationItemPairs.enumerated().map({ (index, pair) in
                ItemSection(index: index + 1, title: pair.location.name, items: pair.items)
            })
        }
        itemSections = itemsectionformated
    }

    // the usual @State variables to handle the Search field
@Published var searchText: String = ""
@Published var mysearchText: String = ""
    var historyMarker =  3

    private func setPurchasedSection(locations: [CKLocationRec], items: [CKItemRec]) {
        print("setPurchasedSection locations:\(locations.count) Items:\(items.count)")
        let searchQualifiedItems = items.filter({ searchText.appearsIn($0.name) })

            // do we show one big section or two (recent + everything else)?
            // the one big section case is pretty darn easy:
        var itemsectionformated = [ItemSection]()
        if !multiSectionDisplay {
            if searchText.isEmpty {
                itemsectionformated = [ItemSection(index: 1, title: "Items Purchased: \(items.count)",
                                    items: items.map({ $0 }))]
            } else {
                itemsectionformated = [ItemSection(index: 1, title: "Items Purchased containing: \"\(searchText)\": \(searchQualifiedItems.count)",
                                                   items: searchQualifiedItems)]
            }
        } else {

            // so we're doing two sections where we break these out
            // into (Today + back historyMarker days) and (all the others)
            let calendar = Calendar.current
            let startingMarker = calendar.date(byAdding: .day, value: -historyMarker, to: Date())!

            let recentItems = searchQualifiedItems.filter({ $0.dateLastPurchased ?? startingMarker - 1 >= startingMarker })
            let allOlderItems =  searchQualifiedItems.filter({ $0.dateLastPurchased ?? startingMarker - 1 < startingMarker })

            // return an array of two sections only
            itemsectionformated = [
                ItemSection(index: 1,
                            title: section1Title(count: recentItems.count),
                            items: recentItems),
                ItemSection(index: 2,
                            title: section2Title(count: allOlderItems.count),
                            items: allOlderItems)
            ]
        }
        itemSections = itemsectionformated
    }
    func section1Title(count: Int) -> String {
        var title = "Items Purchased "
        if historyMarker == 0 {
            title += "Today "
        } else {
            title += "in the last \(historyMarker) days "
        }
        if !searchText.isEmpty {
            title += "containing \"\(searchText)\" "
        }
        title += "(\(count) items)"
        return title
    }

    func section2Title(count: Int) -> String {
        var title = "Items Purchased Earlier"
        if !searchText.isEmpty {
            title += " containing \"\(searchText)\""
        }
        title += ": \(count)"
        return title
    }
}

/*

 // from the PurchasedItemsView.swift

 // the idea of this function is to break out the purchased Items into sections,
 // where we can produce either one section for everything, or else two sections
 // if multiSectionDisplay == true with:
 // -- those items purchased within the last N days,
 // -- and everything else
var itemSections: [ItemSection] {
//        print("PurchasedItemsView.itemSection called mastername \(MyDefaults().myMasterShopListName))")
     // reduce items by search criteria
 let searchQualifiedItems = modelitem.items.filter({ searchText.appearsIn($0.name) })

     // do we show one big section or two (recent + everything else)?
     // the one big section case is pretty darn easy:
 if !multiSectionDisplay {
     if searchText.isEmpty {
         return [ItemSection(index: 1, title: "Items Purchased: \(modelitem.items.count)",
                             items: modelitem.items.map({ $0 }))]
     }
     return [ItemSection(index: 1, title: "Items Purchased containing: \"\(searchText)\": \(searchQualifiedItems.count)",
                                             items: searchQualifiedItems)]
 }

     // so we're doing two sections where we break these out
     // into (Today + back historyMarker days) and (all the others)
 let startingMarker = calendar.date(byAdding: .day, value: -historyMarker, to: today.start)!

 let recentItems = searchQualifiedItems.filter({ $0.dateLastPurchased ?? startingMarker - 1 >= startingMarker })
 let allOlderItems =  searchQualifiedItems.filter({ $0.dateLastPurchased ?? startingMarker - 1 < startingMarker })

     // return an array of two sections only
 return [
     ItemSection(index: 1,
                             title: section1Title(count: recentItems.count),
                             items: recentItems),
     ItemSection(index: 2,
                             title: section2Title(count: allOlderItems.count),
                             items: allOlderItems)
 ]
}
 */

/*

 // from the ShoppingListView.swift


private var itemSections: [ItemSection] {
    // the code in this section has been restructured in SL16 so that the
    // view becomes responsive to any change in the order of Locations
    // that might take place in the Locations tab.
    // the key element is that we must use the  `locations` @FetchRequest
    // definition in this code to determine the visitation order of items
    // so that sectioning is done correctly.  if we relied solely on an item's
    // visitationOrder property, SwiftUI would never update this view based
    // on a change made in the Locations tab. (changing a visitation order
    // in SL15 and earlier sent an objectWillChange() message to all associated
    // Items, which will update any view that holds one of those objects as an
    // @ObservedObject, but it won't trigger a @FetchRequest -- i.e., SL15
    // did not handle this at all).

    // note that for a little more clarity, i have removed the use of a dictionary
    // to group items on the list by location ... for SL16, let's keep it simple.

    // the first step is to construct pairs of the form (location: Location, items: [Item]) for
    // items on the shopping list, where we match each location with its items on the list.
    // (locations with no items on the list will be ignored, and we sort by visitationOrder).
    // however, we do this based on the values in the `locations` @FetchRequest
    // property and not the item's properties (e.g., location).
    print("shoppinglistview.itemSection called mastername: \(MyDefaults().myMasterShopListName)")
//        let cou = modelitem.items.reduce(0) { $0 + Int((($1.listnumber == 3) && ($1.locationnumber == 1)) ? 1 : 0)  }
    let cou = modelitem.items.reduce(0) { $0 + ($1.onList ? 1 : 0)  }
    print("items on list: \(cou)")
    let locationItemPairs: [(location: CKLocationRec, items: [CKItemRec])] = modellocation.locations
        .map({ location in
            ( location, modelitem.items.filter({ $0.onList && $0.locationnumber == location.locationnumber }) )
        })
        .filter({ !$0.items.isEmpty })
        .sorted(by: { $0.location.visitationOrder < $1.location.visitationOrder })

        // if we have nothing on the list, there's nothing for ItemListView to show
    guard modelitem.items.count > 0 else { return [] }

    // now restructure from (Location, [Item]) to [ItemSection].
    // for a single section, just lump all the items of all the pairs
    // into a single list with flatMap.
    if !multiSectionDisplay {
        return [ItemSection(index: 1,
                            title: "Items Remaining: \(modelitem.items.count)",
                            items: locationItemPairs.flatMap{( $0.items )} .sorted(by: {$0.name < $1.name}))
        ]
    }
    // for multiple sections, we mostly have what we need, but must add an indexing
    // (by agreement with ItemListView), so we'll handle that using .enumerated
    return locationItemPairs.enumerated().map({ (index, pair) in
        ItemSection(index: index + 1, title: pair.location.name, items: pair.items)
    })

} // end of var itemSections: [ItemSection]



*/
