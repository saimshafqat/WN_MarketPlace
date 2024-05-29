//
//  NotificationSettingsViewController.swift
//  WorldNoor
//
//  Created by Omnia Samy on 19/10/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class NotificationSettingsViewController: UIViewController {
    
    @IBOutlet private weak var allNotificationSwitch: UISwitch!
    @IBOutlet private weak var tableView: UITableView!
    
    var viewModel: NotificationSettingsViewModelProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Notifications Settings".localized()
        SetUpScreenDesign()
        getNotificationSettings()
    }

    init(viewModel: NotificationSettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func allNotificationSwitch(_ sender: UISwitch) {
        
        if sender.isOn {
            self.turnAllNotification(notificationTurnStatus: 1) // on 1
        } else {
            self.turnAllNotification(notificationTurnStatus: 0) // off 0
        }
    }
}

extension NotificationSettingsViewController {
    
    private func SetUpScreenDesign() {

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: NotificationSettingsTableViewCell.className, bundle: nil),
                           forCellReuseIdentifier: NotificationSettingsTableViewCell.className)
    }
    
    private func bindData() {
        
        if self.viewModel?.notificationAllTypes.status == "0" { // off
            self.allNotificationSwitch.isOn = false
            self.tableView.isHidden = true
        } else { // on
            self.allNotificationSwitch.isOn =  true
            self.tableView.isHidden = false
        }
        
        self.tableView.reloadData()
    }
    
    private func getNotificationSettings() {
        
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        viewModel?.getNotificationSettingsList(completion: { [weak self] (msg, success) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            guard let self = self else { return }
            
            if success {
                self.bindData()
            } else {
                SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: msg ?? .emptyString)
            }
        })
    }
    
    private func turnAllNotification(notificationTurnStatus: Int) {
        
        guard let type = self.viewModel?.notificationAllTypes.type else { return }
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        self.viewModel?.turnAllNotificationSettings(notificationTurnStatus: notificationTurnStatus,
                                            notificationType: type,
                                            completion: { [weak self] (msg, success) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            guard let self = self else { return }
            if success {

                self.viewModel?.notificationAllTypes.status = String(notificationTurnStatus)
                self.bindData()
                self.getNotificationSettings()
            } else {
                SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: msg ?? .emptyString)
            }
        })
    }
}

extension NotificationSettingsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.viewModel?.notificationSettingsList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NotificationSettingsTableViewCell.className, for: indexPath) as? NotificationSettingsTableViewCell else {
            return UITableViewCell()
        }
        
        guard let setting = self.viewModel?.notificationSettingsList[indexPath.row] else {
            return UITableViewCell()
        }
        
        cell.bind(setting: setting)
        return cell
    }
}

extension NotificationSettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let setting = self.viewModel?.notificationSettingsList[indexPath.row] else {
            return
        }
        let settingDetailsVC = Container.Notification.getNotificationSettingDetailsScreen(setting: setting)
        self.navigationController?.pushViewController(settingDetailsVC, animated: true)
    }
}
