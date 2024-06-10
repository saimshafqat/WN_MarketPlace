//
//  MPFilterSelectionModel.swift
//  WorldNoor
//
//  created by Moeez akram on 20/05/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

enum NavigationType: Int {
    case price
    case condition
    case availability
    case dateListed
    case bathrooms
    case bedrooms
    case rentalTypes
    case squareMeters
}

final class MPFilterSelectionModel {
    var selectedItem: Item?
    private var slotedItem: [SlotItem]?
    var conditionList: [FilterCondition]?
    weak var delegate: ProductListDelegate?
    var indexPath: IndexPath?
    var maintainSelectedCondition: [Any] = []
    var updatedItem: Item?
    
    func getCondition() {
        if selectedItem?.selectedItem == .rentalTypes {
            conditionList = [
                FilterCondition(id: 0, name: "Apartment/Condo", slug: "apartment-condo"),
                FilterCondition(id: 1, name: "House", slug: "house"),
                FilterCondition(id: 2, name: "Room only", slug: "room-only"),
                FilterCondition(id: 3, name: "Townhouse", slug: "townhouse")
            ]
            self.delegate?.isProductAvalaibleOrNot(true,newIndexes: [])
        }else{
            if SharedManager.shared.conditionList.isEmpty {
                callRequestForCondition()
            }else {
                conditionList = SharedManager.shared.conditionList
                self.delegate?.isProductAvalaibleOrNot(true,newIndexes: [])
            }
        }
    }
    
    func getSelectViewTitle() -> String {
        selectedItem?.name ?? ""
    }
    
    func getNumberOfRowsInSections() -> Int {
        if selectedItem?.selectedItem == .condition || selectedItem?.selectedItem == .rentalTypes{
           return conditionList?.count ?? 0
        }
        return slotedItem?.count ?? 0
    }
    
    func getItemAt(index: Int) -> Any? {
        if selectedItem?.selectedItem == .condition || selectedItem?.selectedItem == .rentalTypes {
           return conditionList?[safe: index]
        }
        return slotedItem?[safe: index]
    }

    func updateSelectedItem(item: Any) {
        maintainSelectedCondition.append(item)
    }
    
    func removeSelectedItem(item: Any) {
        maintainSelectedCondition.removeObject(item)
    }
    
    func containsObjectss( object: Any) -> Bool {
        for element in maintainSelectedCondition {
            if String(describing: element) == String(describing: object) {
                return true
            }
        }
        return false
    }
    
    func isResetButtonEnableOrDisable()-> Bool {
        SharedManager.shared.filterItem.isEmpty
    }

    func getFilterItem() -> String {
        let stringArray = (selectedItem?.selectedItem == .availability ||
                           selectedItem?.selectedItem == .dateListed ||
                           selectedItem?.selectedItem == .bathrooms ||
                           selectedItem?.selectedItem == .bedrooms) ?
                          maintainSelectedCondition.compactMap {
                              $0 as? SlotItem
                          }.map {
                              $0.slotedValue
                          }.joined(separator: ",") :
                          (selectedItem?.selectedItem == .rentalTypes) ?
                          maintainSelectedCondition.compactMap {
                              $0 as? FilterCondition
                          }.map {
                              $0.slug ?? ""
                          }.joined(separator: ",") :
                          maintainSelectedCondition.compactMap {
                              $0 as? FilterCondition
                          }.map {
                              String($0.id ?? 0)
                          }.joined(separator: ",")
        return stringArray
    }

//    func getFilterItem()-> String {
//        let stringArray = (selectedItem?.selectedItem == .availability || selectedItem?.selectedItem == .dateListed || selectedItem?.selectedItem == .bathrooms || selectedItem?.selectedItem == .bedrooms) ? maintainSelectedCondition.compactMap{ $0 as? SlotItem }.map({$0.slotedValue}).joined(separator: ",") : maintainSelectedCondition.compactMap { $0 as? FilterCondition }.map({String($0.id ?? 0)}).joined(separator: ",")
//        return stringArray
//    }

    func getSelectedCondition()-> String {
        let stringArray =  maintainSelectedCondition.compactMap { $0 as? FilterCondition }.map({$0.name ?? ""}).joined(separator: ",")
        return stringArray
    }
    
    func getSelectedDateAvailability()-> String {
        let stringArray =  maintainSelectedCondition.compactMap { $0 as? SlotItem }.map({$0.name}).joined(separator: ",")
        return stringArray
    }


    func callRequestForCondition() {
        let context = (self)
        MPRequestManager.shared.request(endpoint: "sidebar_menus") { response in
            switch response {
            case .success(let data):
                LogClass.debugLog("success")
                if let jsonData = data as? Data {
                    do {
                        // Use JSONDecoder to decode the data into your model
                        let decoder = JSONDecoder()
                        let condition = try decoder.decode(FilterModel.self, from: jsonData)
                        context.conditionList = condition.data?.results?.conditions
                        SharedManager.shared.conditionList = context.conditionList ?? []

                        // Now you have your Swift model
                        context.delegate?.isProductAvalaibleOrNot(true, newIndexes: [])
                        LogClass.debugLog(condition)
                    } catch {
                        LogClass.debugLog("Error decoding JSON: \(error)")
                        context.delegate?.isProductAvalaibleOrNot(false, newIndexes: [])
                    }
                }
                else {
                    context.delegate?.isProductAvalaibleOrNot(false, newIndexes: [])
                    LogClass.debugLog("not getting good response")
                }
                
            case .failure(let error):
                LogClass.debugLog(error.localizedDescription)
            }
        }
    }

}

extension MPFilterSelectionModel {
    func getAvailabilitySlot() {
        if selectedItem?.selectedItem == .dateListed {
            slotedItem = [ SlotItem(name: "All", slotedValue: ""),
                           SlotItem(name: "Last 24 hours", slotedValue: "1"),
                           SlotItem(name: "Last 7 days", slotedValue: "7"),
                           SlotItem(name: "Last 30 days", slotedValue: "30")
                        ]
        }else if selectedItem?.selectedItem == .bathrooms {
            slotedItem = [ SlotItem(name: "All", slotedValue: ""),
                           SlotItem(name: "1+", slotedValue: "1"),
                           SlotItem(name: "2+", slotedValue: "2"),
                           SlotItem(name: "3+", slotedValue: "3"),
                           SlotItem(name: "4+", slotedValue: "4"),
                           SlotItem(name: "5+", slotedValue: "5"),
                        ]
        }else if selectedItem?.selectedItem == .bedrooms {
            slotedItem = [ SlotItem(name: "All", slotedValue: ""),
                           SlotItem(name: "1+", slotedValue: "1"),
                           SlotItem(name: "2+", slotedValue: "2"),
                           SlotItem(name: "3+", slotedValue: "3"),
                           SlotItem(name: "4+", slotedValue: "4"),
                           SlotItem(name: "5+", slotedValue: "5"),
                           SlotItem(name: "6+", slotedValue: "6")
                        ]
        } else {
            slotedItem = [ SlotItem(name: "Available", slotedValue: "availability"),
                           SlotItem(name: "Sold", slotedValue: "sold")
                        ]
        }
    }
}

class SlotItem {
    var name: String = ""
    var slotedValue: String = ""
    var selectedID: String =  ""
    init(name: String = "", slotedValue: String = "" , selectedID : String = "") {
        self.name = name
        self.slotedValue = slotedValue
        self.selectedID = selectedID
    }
}
