//
//  MPProductDetailViewModel.swift
//  WorldNoor
//
//  created by Moeez akram on 13/05/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import Alamofire

protocol ProductListDelegate: AnyObject {
    func isProductAvalaibleOrNot(_ avalaible: Bool, newIndexes: [IndexPath])
}


enum ReCallApiSelection: Int {
    case category_items
    case search_products
    case search_productsOnFilterBase
}


final class MPProductListingViewModel {
    var categoryItem: Category?
    var searchText: String = ""
    var productsPerCategory = 20
    var productPage = 1
    var isLoading = false
    var selectedApi: ReCallApiSelection = .category_items
    var updateParam: [String: Any] = [:]
    private var productInfo: ReturnResponse?
    weak var delegate: ProductListDelegate?

    // MARK: - Method -
    
    func pullToRefresh() {
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
        let params: [String : Any] = [
            paramName: paramNameValue,
            "productsPerCategory": productsPerCategory,
            "productPage": productPage
        ]
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
                                let productStartIndex = context.productInfo?.products?.count ?? 0
                                
                                let groupIndexPaths = (groupStartIndex..<groupStartIndex + (categoryResult.data?.returnResp?.groups?.count ?? 0)).map { IndexPath(item: $0, section: 0) }
//                                    let productIndexPaths = (productStartIndex..<productStartIndex + newProducts.count).map { IndexPath(item: $0, section: 1) }

                                
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
