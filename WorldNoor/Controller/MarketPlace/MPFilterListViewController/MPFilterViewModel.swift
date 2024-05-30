//
//  MPFilterViewModel.swift
//  WorldNoor
//
//  created by Moeez akram on 20/05/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

final class MPFilterViewModel {
    var params: [String: Any] = [:]
    func getAllItem() {
        SharedManager.shared.filterItem = [ Item(name: "Price", description: "Any", selectedItem: .price, isApplyFilter: false),
                      Item(name: "Condition", description: "Any", selectedItem: .condition, condition: "", isApplyFilter: false),
                      Item(name: "Availability", description: "Any", selectedItem: .availability, availability: "", isApplyFilter: false),
                      Item(name: "Date listed", description: "Any", selectedItem: .date_listed, daysSinceListed: "", isApplyFilter: false)
                    ]
    }
    
    func isResetButtonEnableOrDisable()-> Bool {
        SharedManager.shared.filterItem.isEmpty
    }
    func getNumberOfRowsInSections() -> Int {
          SharedManager.shared.filterItem.count
    }
    
    func getItemAt(index: Int) -> Item? {
         SharedManager.shared.filterItem[safe: index]
    }
    
    func updateItemArray(item: Item, index: IndexPath) {
        SharedManager.shared.filterItem[index.row] = item
    }
    
    func searchPrameter() {
        let _ = SharedManager.shared.filterItem.compactMap { item in
            if item.selectedItem == .price {
                params["minPrice"] = item.isApplyFilter == true ? item.minimumPrice : ""
                params["maxPrice"] = item.isApplyFilter == true ? item.maximumPrice : ""
            }
            if item.selectedItem == .condition {
                params["condition"] = item.isApplyFilter == true ? item.condition : ""
            }
            
            if item.selectedItem == .availability {
                params["availability"] = item.isApplyFilter == true ? item.availability : ""
            }
            if item.selectedItem == .date_listed {
                params["daysSinceListed"] = item.isApplyFilter == true ? item.daysSinceListed : ""
            }
        }
    }
}
