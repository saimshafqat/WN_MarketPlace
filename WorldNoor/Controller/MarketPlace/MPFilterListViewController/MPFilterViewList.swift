//
//  MPFilterViewList.swift
//  WorldNoor
//
//  Created by Ahmad on 20/05/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

extension MPApplyFilterListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getNumberOfRowsInSections()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String.className(MPFilterCell.self), for: indexPath) as? MPFilterCell, let item = viewModel.getItemAt(index: indexPath.row) else { return UITableViewCell() }
        cell.setFilterUI(item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = MPFilterSelectcontroller.instantiate(fromAppStoryboard: .Marketplace)
        if let item = viewModel.getItemAt(index: indexPath.row) {
            controller.viewModel.selectedItem = item
            controller.viewModel.indexPath = indexPath
            controller.filterDelegate = self
//            self.navigationController?.pushViewController(controller, animated: true)
            self.presentVC(controller)
        }
    }
}

extension MPApplyFilterListViewController: ApplyFilterDelegate {
    func applyFilterParameter(item: Item,  indexPath: IndexPath?, isComeFromSelectFilter: Bool) {
        if let index = indexPath {
            let context = (self)
            viewModel.updateItemArray(item: item, index: index)
            if isComeFromSelectFilter {
                self.dismissVC {
                    context.viewModel.searchPrameter()
                    context.delegate?.applyFilterOnSelectedItem(params: context.viewModel.params)
                }
            }else {
                self.tbleView.beginUpdates()
                self.tbleView.reloadRows(at: [index].compactMap { $0 }, with: .none)
                self.tbleView.endUpdates()
            }
        }
    }
    
    func resetFilter() {
        self.dismissVC {
            SharedManager.shared.filterItem.removeAll()
            self.delegate?.resetApplyFilter()
        }

    }
}
