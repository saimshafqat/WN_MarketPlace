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
    func isProductAvalaibleOrNot(_ avalaible: Bool)
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
            switch response {
            case .success(let data):
                LogClass.debugLog("success")
                if let jsonData = data as? Data {
                    do {
                        context.productInfo?.products?.removeAll()
                        let decoder = JSONDecoder()
                        let categoryResult = try decoder.decode(CategoryDetailData.self, from: jsonData)
                        context.productInfo = categoryResult.data?.returnResp
                        context.delegate?.isProductAvalaibleOrNot(true)
                        LogClass.debugLog(categoryResult)
                    } catch {
                        LogClass.debugLog("Error decoding JSON: \(error)")
                        context.delegate?.isProductAvalaibleOrNot(false)
                    }
                }
                else {
                    LogClass.debugLog("not getting good response")
                    context.delegate?.isProductAvalaibleOrNot(false)
                }
            case .failure(let error):
                LogClass.debugLog(error.localizedDescription)
                context.delegate?.isProductAvalaibleOrNot(false)
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
