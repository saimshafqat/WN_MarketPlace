//
//  SearchPostResultDetailViewModel.swift
//  WorldNoor
//
//  Created by Asher Azeem on 29/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

final class SearchPostResultDetailViewModel : PostBaseViewModel {
    
    // MARK: - Properties
    var isPostSearch: String = .emptyString
    
    // MARK: - Override
    override func visibilityMemorySharing() -> Bool {
        return false
    }
    
    // MARK: - API Service
    override func serviceEndPoint(with params: [String : String]) -> APIEndPoints? {
        var param = params
        param.updateValue(isPostSearch, forKey: "query")
        return .searchPost(param)
    }
}
