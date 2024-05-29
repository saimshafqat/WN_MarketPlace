//
//  LifeEventCategoryDetailVC.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 25/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class LifeEventCategoryDetailVC: UIViewController {
 
    @IBOutlet weak var categoryDetailLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties -
    var lifeEventCategoryModel: LifeEventCategoryModel?
    
    // MARK: - Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryDetailLabel.text = lifeEventCategoryModel?.name
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource -
extension LifeEventCategoryDetailVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lifeEventCategoryModel?.subCategory.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EditProfileSubCategoryEventCell.self), for: indexPath) as! EditProfileSubCategoryEventCell
        let item = lifeEventCategoryModel?.subCategory[indexPath.row]
        cell.configureView(item: item as Any, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = CreateLifeEventViewController.instantiate(fromAppStoryboard: .EditProfile)
        controller.lifeEventSubCategoryModel = lifeEventCategoryModel?.subCategory[indexPath.row]
        controller.lifeEventCategoryModel = lifeEventCategoryModel
        controller.isFromMainCategory = false
        presentFullVC(controller)
    }
}
