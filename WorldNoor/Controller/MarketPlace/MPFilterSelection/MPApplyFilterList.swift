//
//  MPApplyFilterList.swift
//  WorldNoor
//
//  created by Moeez akram on 21/05/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import UIKit
extension MPFilterSelectcontroller: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getNumberOfRowsInSections()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String.className(MPApplyFilterCell.self), for: indexPath) as? MPApplyFilterCell, let item = viewModel.getItemAt(index: indexPath.row) as? FilterCondition  else { return UITableViewCell() }
//        // Parse the comma-separated string of selected IDs
//          let selectedConditionString = viewModel.selectedItem?.condition ?? ""
//          let selectedConditionIDs = selectedConditionString.split(separator: ",").compactMap { Int($0) }
//
//          // Check if the current item's ID is in the array of selected IDs
//          let isItemSelected = item.id.flatMap { selectedConditionIDs.contains($0) } ?? false
//
//          // Use the containsObjectss method to handle additional logic
        let isItemSelected = viewModel.containsObjectss(object: item)
            cell.btnCheckBox.isSelected = isItemSelected
        cell.setFilterUI(item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = viewModel.getItemAt(index: indexPath.row){
            if viewModel.containsObjectss(object: item) {
                 viewModel.removeSelectedItem(item: item)
            }else {
                if viewModel.selectedItem?.selectedItem == .availability  || viewModel.selectedItem?.selectedItem == .date_listed {
                    if viewModel.maintainSelectedCondition.count == 0 {
                        viewModel.updateSelectedItem(item: item)
                    }
                }else {
                    viewModel.updateSelectedItem(item: item)
                }
            }
        }
        let indexPath = IndexPath(item: indexPath.row, section: 0)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

extension Array where Element == Any {
    func containsObject(_ object: Any) -> Bool {
        for element in self {
            if let element = element as? AnyHashable, let object = object as? AnyHashable {
                if element == object {
                    return true
                }
            } else if "\(element)" == "\(object)" {
                return true
            }
        }
        return false
    }

    mutating func removeObject(_ object: Any) {
        for (index, element) in self.enumerated() {
            if let element = element as? AnyHashable, let object = object as? AnyHashable {
                if element == object {
                    self.remove(at: index)
                    return
                }
            } else if "\(element)" == "\(object)" {
                self.remove(at: index)
                return
            }
        }
    }

}


