//
//  MPCategoryListViewController.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 04/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
import Alamofire

protocol MPCategoryListDelegate {
    func startScrolling()
}

class MPCategoryListViewController: UIViewController {
    
    // MARK: - Properties -
    var categoryList: Results?
    var viewHelper = MarketPlaceCategoryListViewHelper()
    var isFromGlobalSearch: Bool = false
    var mpCategoryListDelegate: MPCategoryListDelegate?
    lazy var dataSource: SSSectionedDataSource? = {
        let ds = SSSectionedDataSource(sections: [])
        return ds
    }()
    
    var isFromCreateListing: Bool = false
    var selectedCategory : ((Category) -> ())?
    
    // MARK: - IBOutlets -
    @IBOutlet weak var collectionView: UICollectionView?
    
    // MARK: - Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardOnTap()
        collectionView?.register(header: MarketPlaceCategoryListHeaderView.self)
        collectionView?.register(foorter: MarketPlaceCategoryListFooterView.self)
        viewHelper.dataSource = dataSource
        collectionView?.collectionViewLayout = viewHelper.compositionalLayout()
        collectionView?.delegate = self
        if categoryList == nil {
            callRequestForCategories()
        }
        configureView()
        if isFromGlobalSearch {
            dismissKeyboardOnTap()
        }
    }
    
    func configureView() {
        dataSource?.cellClass = MarketPlaceCategoryListCell.self
        dataSource?.cellConfigureBlock = { cell, object, _, indexPath in
            let currentSection = self.dataSource?.section(at: indexPath?.section ?? 0)
            let sectionIdentifier = currentSection?.sectionIdentifier
            (cell as? SSBaseCollectionCell)?.configureCell(sectionIdentifier, atIndex: indexPath, with: object)
            (cell as? SSBaseCollectionCell)?.layoutIfNeeded()
        }
        dataSource?.collectionSupplementaryCreationBlock = { kind, parentView, indexPath in
            if kind == UICollectionView.elementKindSectionHeader {
                return MarketPlaceCategoryListHeaderView.supplementaryView(for: parentView, kind: kind, indexPath: indexPath)
            } else {
                return MarketPlaceCategoryListFooterView.supplementaryView(for: parentView, kind: kind, indexPath: indexPath)
            }
        }
        dataSource?.collectionSupplementaryConfigureBlock = { view, kind, cv, indexPath in
            let section = self.dataSource?.section(at: indexPath?.section ?? 0) as? SSSection
            (view as? MarketPlaceCategoryListHeaderView)?.configureView(section: section, sectionIndex: indexPath?.section)
        }
        dataSource?.rowAnimation = .none
        dataSource?.collectionView = collectionView
    }
    
    func updateSection() {
        if categoryList?.top_categories.count ?? 0 > 0 && !isFromGlobalSearch && !isFromCreateListing {
            createSection(categoryList?.generic_categories ?? [], title: "Generic Categories", type: "Generic Categories")
        }
        if categoryList?.top_categories.count ?? 0 > 0 {
            createSection(categoryList?.top_categories ?? [], title: "Top Categories", type: "Top Categories")
        }
        if categoryList?.all_categories.count ?? 0 > 0 {
            createSection(categoryList?.all_categories ?? [], title: "All Categories", type: "All Categories")
        }
    }
    
    // will help to create section
    func createSection(_ items: [Any], title: String?, type: String?) {
        let section = SSSection(items: items, header: title ?? "", footer: "", identifier: type ?? "")
        dataSource?.appendSection(section)
    }
    
    func callRequestForCategories() {

        MPRequestManager.shared.request(endpoint: "categories") { response in
            switch response {
            case .success(let data):
                LogClass.debugLog("success")
                if let jsonData = data as? Data {
                    do {
                        // Use JSONDecoder to decode the data into your model
                        let decoder = JSONDecoder()
                        let categoryResult = try decoder.decode(CategoryResult.self, from: jsonData)
                        // Now you have your Swift model
                        LogClass.debugLog(categoryResult)
                        self.categoryList = categoryResult.data.results
                        self.dataSource?.collectionView.performBatchUpdates({
                            self.updateSection()
                        })
                    } catch {
                        LogClass.debugLog("Error decoding JSON: \(error)")
                    }
                }
                else {
                    LogClass.debugLog("not getting good response")
                }
                
            case .failure(let error):
                LogClass.debugLog(error.localizedDescription)
            }
        }
    }
}

// MARK: - UICollectionViewDelegatea
extension MPCategoryListViewController: UICollectionViewDelegate, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSource?.section(at: indexPath.section)
        if (item?.sectionIdentifier as? String) == "Generic Categories" {
            // Generic Categories ==> Case
            let newGenericCategory = dataSource?.item(at: indexPath) as? GenericCategory
            let controller = MPProductListingViewController.instantiate(fromAppStoryboard: .Marketplace)
            controller.viewModel.selectedApi = .category_items
            controller.viewModel.categoryItem = Category(created_at: "", icon: newGenericCategory?.icon ?? "", id: -1, market_category_type_id: nil, name: newGenericCategory?.name ?? "", parent_id: nil, slug: "local_listing", type: "Generic Categories", updated_at: "",radius: "50", location: "0.0,0.0", productsPerCategory: "30")
            navigationController?.pushViewController(controller, animated: true)
        } else {
            // All Categories ==> Case
            // Top Categories ==> Case
            let item = dataSource?.item(at: indexPath) as? Category
            if isFromCreateListing {
                if let selectedCategory = selectedCategory, let item = item {
                    selectedCategory(item)
                }
                
                dismissVC(completion: nil)
            }
            else {
                let controller = MPProductListingViewController.instantiate(fromAppStoryboard: .Marketplace)
                controller.viewModel.selectedApi = .category_items
                controller.viewModel.categoryItem = item
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        mpCategoryListDelegate?.startScrolling()
    }
}
