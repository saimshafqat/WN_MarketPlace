//
//  EditProfileLifeEventCategoryVC.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 25/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit
import Combine

class EditProfileLifeEventCategoryVC: UIViewController {
    
    // MARK: - IBOutlets -
    @IBOutlet weak var collectionView: CollectionEmptyView! {
        didSet {
            collectionView.collectionViewLayout = layoutHelper.createLayout()
        }
    }
    
    // MARK: - Properties -
    var lifeEventsList: [LifeEventCategoryModel] = []
    var refreshParentView: (()->())?
    var type = -1
    var rowIndex = -1
    var layoutHelper = EditProfileLifeEventCategoryLayout()
    private var apiService = APITarget()
    private var subscription: Set<AnyCancellable> = []
    
    // MARK: - Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        showError()
        if SharedManager.shared.lifeEventCategoryArray.count == 0 {
            lifeEventCategoriesRequest()
        } else {
            lifeEventsList = SharedManager.shared.lifeEventCategoryArray
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - IBActions -
    @IBAction func onClickBack(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    // MARK: - Methods -
    func reloadView(type : Int , rowIndexP : Int ) {
        self.type = type
        self.rowIndex = rowIndexP
    }
    
    func showError() {
        Loader.stopLoading()
        apiService.errorMessagePublisher
            .receive(on: DispatchQueue.main)
            .sink { message in
                SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: message)
            }.store(in: &subscription)
    }
    
    func lifeEventCategoriesRequest() {
        Loader.startLoading()
        let parms : [String: String] = [:]
        apiService.lifeEventCategoriesRequest(endPoint: .lifeEventCategory(parms))
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    LogClass.debugLog("Deleted Website")
                    Loader.stopLoading()
                case .failure(_):
                    LogClass.debugLog("Failed Delete Website.")
                    Loader.stopLoading()
                }
            }, receiveValue: { response in
                Loader.stopLoading()
                self.lifeEventsList.removeAll()
                if response.data.count > 0 {
                    for category in response.data {
                        self.lifeEventsList.append(category)
                    }
                    SharedManager.shared.lifeEventCategoryArray = response.data
                    self.collectionView.reloadData()
                }
            })
            .store(in: &self.subscription)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource -
extension EditProfileLifeEventCategoryVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        lifeEventsList.isEmpty ? (collectionView as? CollectionEmptyView)?.showEmptyState(with: Const.noCategoryFound.localized()) : (collectionView as? CollectionEmptyView)?.hideEmptyState()
        return lifeEventsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: LifeEventCategoryCell.self), for: indexPath) as! LifeEventCategoryCell
        let lifeEvent = lifeEventsList[indexPath.item]
        cell.configureView(item: lifeEvent, indexPath: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch lifeEventsList[indexPath.item].name {
        case "Work", "Education", "Relationship", "Home & Living", "Family":
            let controller = LifeEventCategoryDetailVC.instantiate(fromAppStoryboard: .EditProfile)
            controller.lifeEventCategoryModel = lifeEventsList[indexPath.row]
            navigationController?.pushViewController(controller, animated: true)
        default:
            let controller = CreateLifeEventViewController.instantiate(fromAppStoryboard: .EditProfile)
            controller.isFromMainCategory = true
            controller.lifeEventCategoryModel = lifeEventsList[indexPath.row]
            presentFullVC(controller)
        }
    }
}
