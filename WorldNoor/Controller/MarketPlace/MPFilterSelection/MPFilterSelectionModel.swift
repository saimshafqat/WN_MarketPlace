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
    case date_listed
}

final class MPFilterSelectionModel {
    var selectedItem: Item?
    private var slotedItem: [SlotItem]?
    private var conditionList: [FilterCondition]?
    weak var delegate: ProductListDelegate?
    var indexPath: IndexPath?
    var maintainSelectedCondition: [Any] = []
    var updatedItem: Item?
    
    func getCondition() {
        if SharedManager.shared.conditionList.isEmpty {
            callRequestForCondition()
        }else {
            conditionList = SharedManager.shared.conditionList
            self.delegate?.isProductAvalaibleOrNot(true,newIndexes: [])
        }
    }
    
    func getSelectViewTitle() -> String {
        selectedItem?.name ?? ""
    }
    
    func getNumberOfRowsInSections() -> Int {
        if selectedItem?.selectedItem == .condition {
           return conditionList?.count ?? 0
        }
        return slotedItem?.count ?? 0
    }
    
    func getItemAt(index: Int) -> Any? {
        if selectedItem?.selectedItem == .condition {
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

    func getFilterItem()-> String {
        let stringArray = (selectedItem?.selectedItem == .availability || selectedItem?.selectedItem == .date_listed) ? maintainSelectedCondition.compactMap{ $0 as? SlotItem }.map({$0.slotedValue}).joined(separator: ",") : maintainSelectedCondition.compactMap { $0 as? FilterCondition }.map({String($0.id ?? 0)}).joined(separator: ",")
        return stringArray
    }

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
        if selectedItem?.selectedItem == .date_listed {
            slotedItem = [ SlotItem(name: "All", slotedValue: ""),
                           SlotItem(name: "Last 24 hours", slotedValue: "1"),
                           SlotItem(name: "Last 7 days", slotedValue: "7"),
                           SlotItem(name: "Last 30 days", slotedValue: "30")
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
