//
//  NotificationPopUpViewController.swift
//  WorldNoor
//
//  Created by Omnia Samy on 30/08/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class NotificationPopUpViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    var notification: NotificationModel?
    var delegate: NotificationOptionDelegate?
    
    private var optionList: [NotificationSettingOptionModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpScreenDesign()
        makeOptionList()
    }
}

extension NotificationPopUpViewController {
    
    private func setUpScreenDesign() {
        
        tableView.register(UINib(nibName: NotificationPopUpTableViewCell.className, bundle: nil),
                           forCellReuseIdentifier: NotificationPopUpTableViewCell.className)
        tableView.register(UINib(nibName: NotificationPopUpHeaderView.className, bundle: nil),
                           forHeaderFooterViewReuseIdentifier: NotificationPopUpHeaderView.className)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func makeOptionList() {
        
        let remove = NotificationSettingOptionModel(type: .remove,
                                                    text: "Remove this notification".localized(),
                                                    icon: "remove")
        optionList.append(remove)
        let turnOff = NotificationSettingOptionModel(type: .turnOff,
                                                     text: "Turn off notification".localized(),
                                                     icon: "turnoff_notifications")
        optionList.append(turnOff)
    }
}

extension NotificationPopUpViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NotificationPopUpTableViewCell.className, for: indexPath) as? NotificationPopUpTableViewCell else {
            return UITableViewCell()
        }
        
        let option = optionList[indexPath.row]
        cell.bind(option: option)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: NotificationPopUpHeaderView.className) as? NotificationPopUpHeaderView
                
        else { return nil }
        
        guard let notification = self.notification else { return nil }
        header.bind(notification: notification)
        return header
    }
}

extension NotificationPopUpViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let notification = notification else { return }
        if indexPath.row == 0 {
            delegate?.removeNotificationTapped(notification: notification)
        } else if indexPath.row == 1 {
            delegate?.turnOffNotificationTapped(notification: notification)
        }
        
        self.dismissVC(completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

enum NotificationSettingOption {
    case remove
    case turnOff
    //    case report
}

struct NotificationSettingOptionModel {
    var type: NotificationSettingOption?
    var text: String?
    var icon: String?
}
