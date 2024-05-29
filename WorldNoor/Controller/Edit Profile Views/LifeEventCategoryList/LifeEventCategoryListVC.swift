//
//  LifeEventCategoryListVC.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 02/01/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class LifeEventCategoryListVC: PostBaseViewController {
    
    // MARK: - Properties -
    var type = -1
    var rowIndex = -1
    var lifeEventModel: UserLifeEventsModel?
    
    // MARK: - Override -
    override func setupViewModel() -> PostBaseViewModel? {
        return LifeEventVideoModel(lifeEventModel: SharedManager.shared.userEditObj.userLifeEventsArray[rowIndex])
    }
    
    override func screenTitle() -> String {
        return Const.savedPost.localized()
    }
    
    // MARK: - IBActions -
    @IBAction func onClickDismiss(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    // MARK: - Methods -
    func reloadView(type : Int , rowIndexP : Int ) {
        self.type = type
        self.rowIndex = rowIndexP
    }
}
