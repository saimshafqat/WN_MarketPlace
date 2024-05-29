//
//  SettingMoreVC.swift
//  WorldNoor
//
//  Created by apple on 4/20/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class SettingMoreVC: UIViewController {
    
    @IBOutlet var tbleviewSettings: UITableView!
    
    var arraySettings = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Settings".localized()
        self.tbleviewSettings.register(UINib.init(nibName: "SettingMoreTableCell", bundle: nil), forCellReuseIdentifier: "SettingMoreTableCell")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = false
        self.tbleviewSettings.rotateViewForLanguage()
        self.arraySettings.removeAll()
        
        self.arraySettings.append("Network Settings".localized())
        
        
        if !SharedManager.shared.userObj!.data.isSocialLogin! {
            self.arraySettings.append("Change Password".localized())
        }
        
        self.arraySettings.append("Security & Login".localized())
        self.arraySettings.append("App Language".localized())
        self.arraySettings.append("Privacy".localized())
        self.arraySettings.append("Blocked Users".localized())
        self.arraySettings.append("Hidden Posts".localized())
        self.arraySettings.append("Notification".localized())
        self.tbleviewSettings.reloadData()
    }
}

extension SettingMoreVC : UITableViewDelegate , UITableViewDataSource  {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
//        if indexPath.row == 4 {
//            return 0
//        }
//        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arraySettings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let cellSettings = tableView.dequeueReusableCell(withIdentifier: "SettingMoreTableCell", for: indexPath) as! SettingMoreTableCell
        
        guard let cellSettings = tableView.dequeueReusableCell(withIdentifier: "SettingMoreTableCell", for: indexPath) as? SettingMoreTableCell else {
            return UITableViewCell()
        }
        
        cellSettings.lblName.text = self.arraySettings[indexPath.row]
        
        cellSettings.lblName.rotateViewForLanguage()
        cellSettings.lblName.rotateForTextAligment()
        
        cellSettings.selectionStyle = .none
        return cellSettings
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.arraySettings[indexPath.row] == "Network Settings".localized() {
            let vc = AppStoryboard.Main.instance.instantiateViewController(withIdentifier: "CallSettingsViewController") as! CallSettingsViewController
            self.navigationController?.pushViewController(vc, animated: true)
        } else if self.arraySettings[indexPath.row] == "Change Password".localized() {
            let videoVC = self.GetView(nameVC: "ChangePasswordVC", nameSB:"EditProfile" ) as! ChangePasswordVC
            self.navigationController?.pushViewController(videoVC, animated: true)
        } else if self.arraySettings[indexPath.row] == "Security & Login".localized() {
            let videoVC = self.GetView(nameVC: "LoginSessionVC", nameSB:"EditProfile" ) as! LoginSessionVC
            self.navigationController?.pushViewController(videoVC, animated: true)
        } else if self.arraySettings[indexPath.row] == "App Language".localized() {
            let hiddenVC = self.GetView(nameVC: "AppLanguagesVC", nameSB:"EditProfile" ) as! AppLanguagesVC
            self.navigationController?.pushViewController(hiddenVC, animated: true)
//        } else if indexPath.row == 4 {
//            let hiddenVC = self.GetView(nameVC: "CommandsListVC", nameSB:"VideoClipStoryBoard" ) as! CommandsListVC
//            self.navigationController?.pushViewController(hiddenVC, animated: true)
        } else if self.arraySettings[indexPath.row] == "Privacy".localized() {
            let settingVC = self.GetView(nameVC: "PrivacySettingVC", nameSB:"Notification" ) as! PrivacySettingVC
            self.navigationController?.pushViewController(settingVC, animated: true)
        } else if self.arraySettings[indexPath.row] == "Blocked Users".localized() {
            let videoVC = self.GetView(nameVC: "BlockUsersVC", nameSB:"EditProfile" ) as! BlockUsersVC
            self.navigationController?.pushViewController(videoVC, animated: true)
        } else if self.arraySettings[indexPath.row] == "Hidden Posts".localized() {
            let controller = HiddenFeedViewController.instantiate(fromAppStoryboard: .More)
            self.navigationController?.pushViewController(controller, animated: true)
        } else if self.arraySettings[indexPath.row] == "Notification".localized() {
            let notificationSettingsVC = Container.Notification.getNotificationSettingsScreen()
            self.navigationController?.pushViewController(notificationSettingsVC, animated: true)
        }
    }
}


class SettingMoreTableCell : UITableViewCell {
    
    @IBOutlet var lblName : UILabel!
}
