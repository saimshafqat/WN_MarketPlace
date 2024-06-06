//
//  MPProductDetailViewModel.swift
//  WorldNoor
//
//  Created by Imran Baloch on 06/06/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import Alamofire

//protocol ProductListDelegate: AnyObject {
//    func isProductAvalaibleOrNot(_ avalaible: Bool, newIndexes: [IndexPath])
//}
//
//
//enum ReCallApiSelection: Int {
//    case category_items
//    case search_products
//    case search_productsOnFilterBase
//}


final class MPProfileViewModel {
    var categoryItem: Category?
    var searchText: String = ""
    var productsPerCategory = 20
    var productPage = 1
    var isLoading = false
    var selectedApi: ReCallApiSelection = .category_items
    var updateParam: [String: Any] = [:]
    var productInfo: ReturnResponse?
    weak var delegate: ProductListDelegate?
    
    var cellList = [DynamicCellModel]()
    
    var section1Items: [String] = ["Row 1", "Row 2", "Row 3"]
    var section2Item: String = "Single Row"
    var section3Items: [ProfileItem] = [
        ProfileItem(id: 1, name: "Item 1"),
        ProfileItem(id: 2, name: "Item 2"),
        ProfileItem(id: 3, name: "Item 3"),
        ProfileItem(id: 4, name: "Item 4"),
        ProfileItem(id: 5, name: "Item 5"),
        ProfileItem(id: 6, name: "Item 6")
    ]
    
    // MARK: - Method
    
    func createCellList(){
        //Only handling section 0 items
        cellList.append(DynamicCellModel(cellIndentifier: String(describing: MPProfileSettingsInfoTableViewCell.self), type: MPProfileCellType.settingsInfo.rawValue))
        cellList.append(DynamicCellModel(cellIndentifier: String(describing: MPProfileCoverPhotoTableViewCell.self), type: MPProfileCellType.coverPhoto.rawValue))
        cellList.append(DynamicCellModel(cellIndentifier: String(describing: MPProfileShareButtonTableViewCell.self), type: MPProfileCellType.shareButton.rawValue))
        cellList.append(DynamicCellModel(cellIndentifier: String(describing: MPProfileAboutMeTableViewCell.self), type: MPProfileCellType.aboutMe.rawValue))
        cellList.append(DynamicCellModel(cellIndentifier: String(describing: MPProfileSellerRatingTableViewCell.self), type: MPProfileCellType.sellerRating.rawValue))
        cellList.append(DynamicCellModel(cellIndentifier: String(describing: MPProfileYourStrengthsTableViewCell.self), type: MPProfileCellType.yourStrengths.rawValue))
        cellList.append(DynamicCellModel(cellIndentifier: String(describing: MPProfileAccessYourRatingsTableViewCell.self), type: MPProfileCellType.accessYourRatings.rawValue))
    }
    
    func pullToRefresh() {
        resetToFreshState()
        switch selectedApi {
        case .category_items:
            fetchProductListOnCategorieSelection()
            break
        case .search_products:
            fetchProductListOnSearchResult(searchText)
            break
        case .search_productsOnFilterBase:
            getAllProduct(endPointName: endPointSelected(), params: updateParam)
        }
    }
    func fetchProductListOnCategorieSelection() {
        guard let categoryItem =  categoryItem else { return}
        getAllCategoriesPorduct(endPointName: endPointSelected(), paramName: "slug", paramNameValue: categoryItem.slug)
    }
    
    func fetchProductListOnSearchResult(_ text: String?) {
        guard let search =  text, !search.isEmpty else { return}
        getAllCategoriesPorduct(endPointName: endPointSelected(), paramName: "name", paramNameValue: search)
    }
    
    func resetToFreshState(){
        self.productPage = 1
        self.productInfo = nil
    }
    
    func loadMoreData(){
        if !isLoading && self.productPage < productInfo?.total_pages ?? 0{
            self.isLoading = true
            self.productPage += 1
            switch selectedApi {
            case .category_items:
                fetchProductListOnCategorieSelection()
                break
            case .search_products:
                fetchProductListOnSearchResult(searchText)
                break
            case .search_productsOnFilterBase:
                getAllProduct(endPointName: endPointSelected(), params: updateParam)
            }
        }
    }
    
    
    // MARK: - Methods -

    func getAllCategoriesPorduct(endPointName: String, paramName: String, paramNameValue: String) {
        var params: [String : Any] = [
            paramName: paramNameValue,
            "productsPerCategory": productsPerCategory,
            "productPage": productPage
        ]
        
        if categoryItem?.type == "Generic Categories"{
            params["radius"] = categoryItem?.radius ?? "50"
            params["location"] = categoryItem?.location ?? "0.0,0.0"
            params["productsPerCategory"] = categoryItem?.productsPerCategory ?? "30"
        }
        
        updateParam["productPage"] = productPage
        
        
        for (key, value) in updateParam {
            if params[key] == nil {
                params[key] = value
            }
        }
        
        self.getAllProduct(endPointName: endPointName, params: params)
    }
    
    func getAllProduct(endPointName: String, params: [String : Any]) {
        let context = (self)
        MPRequestManager.shared.request(endpoint: endPointName, method: .post, params: params) { response in
            self.isLoading = false
            switch response {
            case .success(let data):
                LogClass.debugLog("success")
                if let jsonData = data as? Data {
                    do {
                        
                        let decoder = JSONDecoder()
                        let categoryResult = try decoder.decode(CategoryDetailData.self, from: jsonData)
                        
                        if context.productInfo != nil{
                            DispatchQueue.main.async {
//                                context.productInfo = categoryResult.data?.returnResp
                                
                                let groupStartIndex = context.productInfo?.groups?.count ?? 0
                                
                                let groupIndexPaths = (groupStartIndex..<groupStartIndex + (categoryResult.data?.returnResp?.groups?.count ?? 0)).map { IndexPath(item: $0, section: 0) }
                                
                                context.productInfo?.groups?.append(contentsOf: categoryResult.data?.returnResp?.groups ?? [])
                                context.productInfo?.products?.append(contentsOf: categoryResult.data?.returnResp?.products ?? [])
                                context.productInfo?.total_pages = categoryResult.data?.returnResp?.total_pages
                                context.productInfo?.current_page = categoryResult.data?.returnResp?.current_page
                                context.delegate?.isProductAvalaibleOrNot(true, newIndexes: groupIndexPaths)
                            }
                        } else {
                            context.productInfo?.products?.removeAll()
                            context.productInfo = categoryResult.data?.returnResp
                            context.delegate?.isProductAvalaibleOrNot(true, newIndexes: [])
                        }
                        
                        
                        LogClass.debugLog(categoryResult)
                    } catch {
                        LogClass.debugLog("Error decoding JSON: \(error)")
                        context.delegate?.isProductAvalaibleOrNot(false, newIndexes: [])
                    }
                }
                else {
                    LogClass.debugLog("not getting good response")
                    context.delegate?.isProductAvalaibleOrNot(false, newIndexes: [])
                }
            case .failure(let error):
                LogClass.debugLog(error.localizedDescription)
                context.delegate?.isProductAvalaibleOrNot(false, newIndexes: [])
            }
        }
    }
    
    
    func endPointSelected() -> String {
        if categoryItem != nil  {
            return "category_items"
        }else
        {
            return "search_products"
        }
    }
    
    func getNumberOfRowsInSections() -> Int {
        productInfo?.products?.count ?? 0
    }
    
    func getItemAt(index: Int) -> MarketPlaceForYouItem? {
        productInfo?.products?[safe: index]
    }
}
