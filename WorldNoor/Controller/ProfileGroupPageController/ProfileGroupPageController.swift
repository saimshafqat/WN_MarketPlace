//
//  ProfileGroupPageController.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 22/02/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
import Combine

struct ProfileGroupPageModel {
    var tabName: String
    var item: GroupValue?
}

class ProfileGroupPageController: UIViewController {
    
    // MARK: - IBOutlets -
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    
    // MARK: - Properties -
    var arrayData = [GroupValue]()
    var titleStr: String = .emptyString
    var apiService = APITarget()
    var subscription = Set<AnyCancellable>()
    var pageTab: String = .emptyString
    
    // MARK: - Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = titleStr
        tableView.registerCustomCells([ProfileGroupCell.className])
        setupObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - IBAtions -
    @IBAction func onClickBack(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    // MARK: - Methods -
    func setupObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(updatePageLikeCategory(_:)), name: .CategoryLikePages, object: nil)
    }
    
    @objc func updatePageLikeCategory(_ notification: Notification) {
        if let pageGroupModel = notification.object as? ProfileGroupPageModel {
            if pageGroupModel.tabName == "group" {
                SharedManager.shared.userEditObj.groupArray = SharedManager.shared.userEditObj.groupArray.filter({$0.groupID != pageGroupModel.item?.groupID})
                arrayData = arrayData.filter({$0.groupID != pageGroupModel.item?.groupID})
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource -
extension ProfileGroupPageController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileGroupCell.identifier, for: indexPath) as! ProfileGroupCell
        cell.configureCell(obj: arrayData[indexPath.row], index: indexPath.row, pageTab: pageTab)
        cell.profileGroupDelegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let controller = NewGroupDetailVC.instantiate(fromAppStoryboard: .Kids)
        controller.groupObj = arrayData[indexPath.row]
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension ProfileGroupPageController: ProfileGroupDelegate {
    func deleteProfileGroup(obj: GroupValue?, at index: Int?, pageTab: String) {
        LogClass.debugLog(pageTab)
        let pageTitle = obj?.groupName ?? .emptyString
        let pageCategoryName = pageTab
        let groupID = obj?.groupID ?? .emptyString
        SharedManager.shared.ShowAlertWithCompletaion(title: pageCategoryName.capitalized, message: "Do you really want to delete this Group \(pageTitle)?", isError: true) {[weak self] status in
            guard let self else { return }
            if status {
                let params = [
                    "group_id" : groupID,
                    "user_id": "\(SharedManager.shared.userObj?.data.id ?? 0)",
                    "token": SharedManager.shared.userToken()
                ]
                self.apiService.leaveGroupMemberRequest(endPoint: .groupMemberLeave(params))
                    .sink { completion in
                        switch completion {
                        case .finished:
                            LogClass.debugLog("Finished")
                        case .failure(let error):
        SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: error.localizedDescription)                        }
                    } receiveValue: { response in
                        if response.data.status {
                            if let obj {
                                let profileGroupModel = ProfileGroupPageModel(tabName: pageTab, item: obj)
                                NotificationCenter.default.post(name: .CategoryLikePages, object: profileGroupModel)
                                LogClass.debugLog("Deleted Item ==> One")
                            }
                        }
                    }.store(in: &subscription)
            }
        }
    }
}
