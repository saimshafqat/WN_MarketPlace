//
//  MPFilterViewModel.swift
//  WorldNoor
//
//  created by Moeez akram on 20/05/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

final class MPFilterViewModel {
    var showAllOptions = false
    var params: [String: Any] = [:]
    func getAllItem() {
        SharedManager.shared.filterItem = [ Item(name: "Price", description: "Any", selectedItem: .price, isApplyFilter: false),
                                            Item(name: "Condition", description: "Any", selectedItem: .condition, condition: "", isApplyFilter: false),
                                            Item(name: "Availability", description: "Any", selectedItem: .availability, availability: "", isApplyFilter: false),
                                            Item(name: "Date listed", description: "Any", selectedItem: .dateListed, daysSinceListed: "", isApplyFilter: false)
        ]
        if showAllOptions {
            SharedManager.shared.filterItem.append(Item(name: "Bedrooms", description: "Any", selectedItem: .bedrooms, isApplyFilter: false))
            SharedManager.shared.filterItem.append(Item(name: "Bathrooms", description: "Any", selectedItem: .bathrooms, isApplyFilter: false))
            SharedManager.shared.filterItem.append(Item(name: "Rental types", description: "Any", selectedItem: .rentalTypes, isApplyFilter: false))
            SharedManager.shared.filterItem.append(Item(name: "Square meters", description: "Any", selectedItem: .squareMeters, isApplyFilter: false))
        }
    }
    
    func isResetButtonEnableOrDisable()-> Bool {
        return SharedManager.shared.filterItem.contains { $0.isApplyFilter }
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
            if item.selectedItem == .dateListed {
                params["daysSinceListed"] = item.isApplyFilter == true ? item.daysSinceListed : ""
            }
            if item.selectedItem == .squareMeters {
                params["minAreaSize"] = item.isApplyFilter == true ? item.minimumSq : ""
                params["maxAreaSize"] = item.isApplyFilter == true ? item.maximumSq : ""
            }
            if item.selectedItem == .bathrooms {
                params["minBathrooms"] = item.isApplyFilter == true ? item.bathroom : ""
            }
            if item.selectedItem == .bedrooms {
                params["minBedrooms"] = item.isApplyFilter == true ? item.bedroom : ""
            }
            if item.selectedItem == .rentalTypes {
                params["propertyType"] = item.isApplyFilter == true ? item.rentaltypes : ""
            }
            AppLogger.log("url \(item)")
        }
        
    }
}
