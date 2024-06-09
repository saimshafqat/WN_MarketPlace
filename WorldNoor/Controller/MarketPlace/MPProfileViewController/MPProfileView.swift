//
//  MPProductListingView.swift
//  WorldNoor
//
//  Created by Imran Baloch on 06/06/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import FittedSheets

extension MPProfileViewController: UITableViewDelegate {
    //    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    //        let controller = MPProductDetailViewController.instantiate(fromAppStoryboard: .Marketplace)
    //        controller.marketProduct = viewModel.getItemAt(index: indexPath.row)
    ////        controller.mpProductDetailDelegate = self
    //        showTransition(to: controller, withAnimationType: .fade)
    //
    //    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        //            let height = scrollView.frame.size.height
        
        let visibleHeight = scrollView.frame.height - scrollView.contentInset.top - scrollView.contentInset.bottom
        
        if offsetY > contentHeight - visibleHeight + 100.0 {
            if !viewModel.isLoading {
                viewModel.loadMoreData()
            }
        }
    }
    
}

extension MPProfileViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return viewModel.cellList.count
        case 1:
            return 1
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            let lisitingItems = viewModel.userListingItemsCount()
            let itemWidth = ((tableView.frame.width - 5) / 3) + 20
            let rows = ceil(Double(lisitingItems) / Double(3))
            //let totalSpacing = 5 * CGFloat(rows - 1)
            let totalSpacing = max(5 * CGFloat(rows - 1), 0)
            let totalHeight = (CGFloat(rows) * itemWidth) + totalSpacing
            return totalHeight
        } else {
            
//            if let cellModel = viewModel.cellList[safe: indexPath.row] {
//                if cellModel.cellIndentifier == String(describing: MPProfileCoverPhotoTableViewCell.self) {
//                    
//                    return 300 //UITableView.automaticDimension
//                }
//                
//                return UITableView.automaticDimension //Set heights of cell list as per cell height
//            }
            
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MPProfileListingTableViewCell.self), for: indexPath) as! MPProfileListingTableViewCell
            cell.configure(with: viewModel.itemsForCellAt(index: indexPath.row), itemsCount: viewModel.userListingItemsCount())
            return cell
        } else if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MPProfileListingHeaderTableViewCell.self), for: indexPath) as! MPProfileListingHeaderTableViewCell
            cell.configure(firstName: viewModel.firstNameUser())
            cell.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            cell.filterBtn.addTarget(self, action: #selector(filterbuttonTapped(_:)), for: .touchUpInside)   
            return cell
        } else {
            
            let cellModel = viewModel.cellList[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: cellModel.cellIndentifier, for: indexPath)
            
            if let coverPhotoCell = cell as? MPProfileSettingsInfoTableViewCell {
                return coverPhotoCell
            }
            else if let coverPhotoCell = cell as? MPProfileCoverPhotoTableViewCell {
                coverPhotoCell.setupCellData(model: viewModel.aboutUserInfo())
                return coverPhotoCell
            }
            else if let coverPhotoCell = cell as? MPProfileShareButtonTableViewCell {
                //Configure Cell
//                coverPhotoCell.setupCellData()
                coverPhotoCell.backgroundColor = .blue
                return coverPhotoCell
            }
            
            else if let followAndChatCell = cell as? MPProfileFollowAndChatTableViewCell {
                return followAndChatCell
            }
            
            else if let aboutMCell = cell as? MPProfileAboutMeTableViewCell {
                aboutMCell.configure(model: viewModel.aboutUserInfo())
                return aboutMCell
            }
            else if let coverPhotoCell = cell as? MPProfileSellerRatingTableViewCell {
                //Configure Cell
//                coverPhotoCell.setupCellData()
                coverPhotoCell.backgroundColor = .yellow
                return coverPhotoCell
            }
            else if let coverPhotoCell = cell as? MPProfileYourStrengthsTableViewCell {
                //Configure Cell
//                coverPhotoCell.setupCellData()
                coverPhotoCell.backgroundColor = .magenta
                return coverPhotoCell
            }
            else if let coverPhotoCell = cell as? MPProfileAccessYourRatingsTableViewCell {
                //Configure Cell
//                coverPhotoCell.setupCellData()
                coverPhotoCell.backgroundColor = .orange
                return coverPhotoCell
            }
            
        }
        
        return UITableViewCell()
    }
    
    @objc func filterbuttonTapped(_ sender: UIButton) {
        self.sortTapped()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        viewModel.searchText = text
        if text.isEmpty {
            viewModel.userListingType = .none
        } else {
            viewModel.userListingType = .serach
        }
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(getUserListingItems), object: nil)
        self.perform(#selector(getUserListingItems), with: nil, afterDelay: 0.3)
    }
    
    @objc func getUserListingItems() {
        self.viewModel.pullToRefresh()
    }
    
}


extension MPProfileViewController: FilterViewDelegate {
    func filterViewDelegate() {
        //        SharedManager.shared.filterItem.removeAll()
        let controller = MPApplyFilterListViewController.instantiate(fromAppStoryboard: .Marketplace)
        controller.delegate = self
        self.presentVC(controller)
    }
    func categoryClicked() {
        let controller = MPCategoryListViewController.instantiate(fromAppStoryboard: .Marketplace)
        controller.isFromCreateListing = true
        controller.selectedCategory = { [weak self] category in
            guard let self = self else { return }
            viewModel.categoryItem = category
            fetchProductListCategorieBase()
        }
        openBottomSheet(controller, sheetSize: [.fixed(UIScreen.main.bounds.height * 0.7)], animated: false)
    }
    func sortTapped() {
        let controller = MPSortPickerViewController.instantiate(fromAppStoryboard: .Marketplace)
        controller.selectedOptionId = selectedSortItem?.radioId ?? "1"
        controller.selectedOption = { [weak self] item in
            guard let self = self else { return }
            self.selectedSortItem = item
            viewModel.updateParam["sortBy"] = self.selectedSortItem?.radioButtonValue
            applyFilterOnSelectedItem(params: viewModel.updateParam)
        }
        openBottomSheet(controller, sheetSize: [.fixed(350)], animated: false)
    }
    func createListingTapped() {
        openCreateListingBottomView()
    }
    func openCreateListingBottomView() {
        let controller = MPBottomCreateListingVC.instantiate(fromAppStoryboard: .Marketplace)
        controller.itemSelected = { item in
            LogClass.debugLog("Item: \(item.name)")
            
            if let currentVC = UIApplication.topViewController() as? SheetViewController {
                currentVC.dismiss(animated: false) { [weak self] in
                    let vc = MPCreateListingFormVC.instantiate(fromAppStoryboard: .Marketplace)
                    vc.modalPresentationStyle = .fullScreen
                    self?.presentVC(vc)
                }
            }
        }
        openBottomSheet(controller, sheetSize: [.fixed(250)], animated: false)
    }
    func locationTapped() {
#warning("open location screen and refresh the api on the screen")
    }
}

extension MPProfileViewController: ApplyFilterViewDelegate {
    func resetApplyFilter() {
        if viewModel.categoryItem == nil {
            viewModel.selectedApi = .search_products
            viewModel.resetToFreshState()
            viewModel.updateParam = [:]
            viewModel.fetchProductListOnSearchResult(viewModel.searchText)
        }else{
            viewModel.updateParam = [:]
            viewModel.resetToFreshState()
            viewModel.selectedApi = .category_items
            viewModel.fetchProductListOnCategorieSelection()
        }
    }
    
    func applyFilterOnSelectedItem(params: [String: Any]) {
        viewModel.updateParam.mergeAndUpdate(from: params)
        let name = self.viewModel.searchText.count != 0 ? self.viewModel.searchText : (self.viewModel.categoryItem?.slug ?? "")
        if viewModel.categoryItem == nil {
            viewModel.updateParam["name"] = name
        }else{
            viewModel.updateParam["slug"] = name
        }
        viewModel.resetToFreshState()
        viewModel.updateParam["productsPerCategory"] = viewModel.productsPerCategory
        viewModel.updateParam["productPage"] = viewModel.productPage
        viewModel.getAllProduct(endPointName: viewModel.endPointSelected(), params: viewModel.updateParam)
    }
}

