//
//  MPProductListingView.swift
//  WorldNoor
//
//  created by Moeez akram on 14/05/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import FittedSheets

extension MPProductListingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = MPProductDetailViewController.instantiate(fromAppStoryboard: .Marketplace)
        controller.marketProduct = viewModel.getItemAt(index: indexPath.row)
//        controller.mpProductDetailDelegate = self
        showTransition(to: controller, withAnimationType: .fade)

    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let height = scrollView.frame.size.height

            if offsetY > contentHeight - height * 1.5 {
                if !viewModel.isLoading {
                    viewModel.loadMoreData()
                }
            }
        }
    
}

extension MPProductListingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.getNumberOfRowsInSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String.className(ProductListCell.self), for: indexPath) as? ProductListCell, let item = viewModel.getItemAt(index: indexPath.row) else { return UICollectionViewCell() }
        cell.setProductInfoCell(item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            if viewModel.selectedApi == .search_products {
                guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MPProductSearchListHeaderView.headerName, for: indexPath) as? MPProductSearchListHeaderView else { return MPProductSearchListHeaderView() }
                headerView.filterViewDelegate = self
                headerView.configure(viewModel: viewModel)
                return headerView as MPProductSearchListHeaderView

            }else{
                guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MPProductListHeaderView.headerName, for: indexPath) as? MPProductListHeaderView else { return MPProductListHeaderView() }
                headerView.filterViewDelegate = self
                headerView.configure(viewModel: viewModel)
                return headerView as MPProductListHeaderView
            }
        default:
            preconditionFailure("Invalid supplementary view type for this collection view")
        }
    }
    
    
}


extension MPProductListingViewController: UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let collectionViewWidth = self.collectionView?.frame.width else { return .zero }
        let cellWidth = (collectionViewWidth - 5 ) / 2
        return CGSize(width: cellWidth , height: cellWidth+20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch section {
        case 0:
            if viewModel.selectedApi == .category_items {
                return CGSize(width: collectionView.bounds.width, height: 130)
            }else{
                return CGSize(width: collectionView.bounds.width, height: 50)

            }
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        .zero
    }
}


extension MPProductListingViewController: FilterViewDelegate {
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

extension MPProductListingViewController: ApplyFilterViewDelegate {
    func resetApplyFilter() {
        if viewModel.categoryItem == nil {
            viewModel.selectedApi = .search_products
            viewModel.updateParam = [:]
            viewModel.fetchProductListOnSearchResult(viewModel.searchText)
        }else{
            viewModel.updateParam = [:]
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
        viewModel.updateParam["productsPerCategory"] = viewModel.productsPerCategory
        viewModel.updateParam["productPage"] = viewModel.productPage
        viewModel.getAllProduct(endPointName: viewModel.endPointSelected(), params: viewModel.updateParam)
    }
}

extension Dictionary {
    mutating func mergeAndUpdate(from other: Dictionary) {
        for (key, value) in other {
            self[key] = value
        }
    }
}
