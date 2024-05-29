//
//  ImagesViewController.swift
//  WorldNoor
//
//  Created by Omnia Samy on 05/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class ImagesViewController: PostBaseViewController {

    override func setupViewModel() -> PostBaseViewModel? {
        return ImagesViewModel()
    }
    
    override func screenTitle() -> String {
        return "Images".localized()
    }
}
