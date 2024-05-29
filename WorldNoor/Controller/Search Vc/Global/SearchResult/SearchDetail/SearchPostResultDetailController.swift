//
//  SearchPostResultDetailController.swift
//  WorldNoor
//
//  Created by Asher Azeem on 29/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class SearchPostResultDetailController: PostBaseViewController {
    
    override func setupViewModel() -> PostBaseViewModel? {
        let vm = SearchPostResultDetailViewModel()
        vm.isPostSearch = searchPost
        return vm
    }
    
    override func screenTitle() -> String {
        return "Search Post".localized()
    }
}
