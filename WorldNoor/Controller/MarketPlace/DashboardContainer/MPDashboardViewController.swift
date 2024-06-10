//
//  MPDashboardViewController.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 04/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class MPDashboardViewController: ContainerBaseController {
    
    // MARK: - Lazy Properties -
    // 1- For you
    private lazy var forYouController: MPForYouViewController = {
        let forYouController = MPForYouViewController.instantiate(fromAppStoryboard: .Marketplace)
        return forYouController
    }()
    
    // 2- Categories
    private lazy var categoryListController: MPCategoryListViewController = {
        let categoryListController = MPCategoryListViewController.instantiate(fromAppStoryboard: .Marketplace)
        return categoryListController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeViewControllers()
    }
    
    // It will initilize child view
    func initializeViewControllers() {
        allViewControllers = [forYouController, categoryListController]
        buttonStyle(at: changeViewCollectionButton?[0] ?? UIButton())
        cycle(from: currentChildController, to: allViewControllers[0])
        changeSegmentControlView(to: 0)
    }
    
    override func changeViewAction(_ sender: UIButton) {
        buttonStyle(at: sender)
        super.changeViewAction(sender)
    }
    
    // MARK: - IBActions -
    @IBAction func onClickSell(_ sender: UIButton) {
        let controller = MPSellViewController.instantiate(fromAppStoryboard: .Marketplace)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func onClickProfile(_ sender: Any) {
        let controller = MPProfileViewController.instantiate(fromAppStoryboard: .Marketplace)
        let currentUserId = SharedManager.shared.getUserID()
        controller.viewModel = MPProfileViewModel(sellerId: currentUserId, userType: .currentUser)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    @IBAction func btnSearchBtn_Pressed(_ sender: UIButton) {
        let controller = MPGlobalSearchViewController.instantiate(fromAppStoryboard: .Marketplace)
        let navController = UINavigationController(rootViewController: controller)
        controller.delegate = self
        controller.isFromMPDashboardSearch = true
        presentFullVC(navController)
    }
}
extension MPDashboardViewController: SearchResultDelgate {
    func searchResult(_ text: String) {
        let controller = MPProductListingViewController.instantiate(fromAppStoryboard: .Marketplace)
        controller.viewModel.selectedApi = .search_products
        controller.viewModel.searchText = text
        navigationController?.pushViewController(controller, animated: true)
    }
}

