//
//  NotificationSettingDetailsViewController.swift
//  WorldNoor
//
//  Created by Omnia Samy on 19/10/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

protocol NotificationSettingDetailsDelegate: AnyObject {
    func subTypeStatusChanges(subType: NotificationSettingSubTypeModel, status: Int)
}

class NotificationSettingDetailsViewController: UIViewController {
    
    @IBOutlet private weak var notificationGeneralSwitch: UISwitch!
    @IBOutlet private weak var subTypesHeaderTitleLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    
    var viewModel: NotificationSettingDetailsViewModelProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpScreenDesign()
        bindData()
    }
    
    init(viewModel: NotificationSettingDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NotificationSettingDetailsViewController {
    
    // general status change
    @IBAction func statusChanged(_ sender: UISwitch) {
        
        guard let generalType = self.viewModel?.notificationSettings?.name else { return }
        if sender.isOn {
            self.turnGeneralNotificationStatus(notificationType: generalType,
                                              notificationTurnStatus: 1) // on 1
        } else {
            self.turnGeneralNotificationStatus(notificationType: generalType,
                                              notificationTurnStatus: 0) // off 0
        }
    }
}

extension NotificationSettingDetailsViewController {
    
    private func setUpScreenDesign() {
        if viewModel?.notificationSettings?.name == "new_friend_request" {
            self.title = "New Friend Request".localized()
        } else {
            self.title = viewModel?.notificationSettings?.localizedTitle
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: NotificationSettingDetailsTableViewCell.className, bundle: nil),
                           forCellReuseIdentifier: NotificationSettingDetailsTableViewCell.className)
    }
    
    private func bindData() {
        
        subTypesHeaderTitleLabel.isHidden = true
        tableView.isHidden = true
        
        if self.viewModel?.notificationSettings?.status == "1" { // on
            self.notificationGeneralSwitch.isOn = true
        } else { // off
            self.notificationGeneralSwitch.isOn = false
        }
        
        if (self.viewModel?.notificationSettings?.subtypes.count ?? 0) > 1 &&
            self.viewModel?.notificationSettings?.status == "1" {
            
            tableView.isHidden = false
            subTypesHeaderTitleLabel.isHidden = false
        }
        tableView.reloadData()
    }
    
    func bindDataAfterChangeGeneralStatus() {
        
        subTypesHeaderTitleLabel.isHidden = true
        tableView.isHidden = true
        
        if self.viewModel?.notificationSettings?.status == "1" { // on
            self.notificationGeneralSwitch.isOn = true
            // allow all subtypes
            self.viewModel?.notificationSettings?.subtypes.forEach({ type in
                type.status = "1"
            })
            
        } else { // off
            self.notificationGeneralSwitch.isOn = false
        }
        
        if (self.viewModel?.notificationSettings?.subtypes.count ?? 0) > 1 &&
            self.viewModel?.notificationSettings?.status == "1" {
            
            tableView.isHidden = false
            subTypesHeaderTitleLabel.isHidden = false
        }
        tableView.reloadData()
    }
    
    private func turnGeneralNotificationStatus(notificationType: String, notificationTurnStatus: Int) {
        
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        self.viewModel?.turnOffNotification(notificationTurnStatus: notificationTurnStatus,
                                            notificationType: notificationType,
                                            completion: { [weak self] (msg, success) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            guard let self = self else { return }
            if success {
                
                self.viewModel?.notificationSettings?.status = String(notificationTurnStatus)
                self.bindDataAfterChangeGeneralStatus()
                
            } else {
                SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: msg ?? .emptyString)
//                SharedManager.shared.showAlert(message: Const.networkProblemMessage.localized(),
//                                               view: self)
            }
        })
    }
    
    private func turnNotificationSubTypeStatus(subType: NotificationSettingSubTypeModel,
                                               notificationTurnStatus: Int) {
        
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        self.viewModel?.turnOffNotification(notificationTurnStatus: notificationTurnStatus,
                                            notificationType: subType.type,
                                            completion: { [weak self] (msg, success) in
            
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            guard let self = self else { return }
            if success {

                let subType = self.viewModel?.notificationSettings?.subtypes.first(where: { $0.type == subType.type })
                subType?.status = String(notificationTurnStatus)
                self.tableView.reloadData()

            } else {
                SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: msg ?? .emptyString)
            }
        })
    }
}

extension NotificationSettingDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.notificationSettings?.subtypes.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NotificationSettingDetailsTableViewCell.className, for: indexPath) as? NotificationSettingDetailsTableViewCell else {
            return UITableViewCell()
        }
        
        guard let subType = self.viewModel?.notificationSettings?.subtypes[indexPath.row] else {
            return UITableViewCell()
        }
        
        cell.bind(subType: subType, delegate: self)
        return cell
    }
}

extension NotificationSettingDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension NotificationSettingDetailsViewController: NotificationSettingDetailsDelegate {
    
    func subTypeStatusChanges(subType: NotificationSettingSubTypeModel, status: Int) {
        self.turnNotificationSubTypeStatus(subType: subType, notificationTurnStatus: status)
    }
}
