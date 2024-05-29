//
//  ChatSettingsVC.swift
//  WorldNoor
//
//  Created by ogouluser1-mac6 on 29/08/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class ChatSettingsVC: UIViewController {
    
    @IBOutlet var tbleviewSettings : UITableView!
    
    var arrChatSettings:[String] = []
    var arrChatSettingIcons:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Chat settings".localized()
        self.tbleviewSettings.register(UINib.init(nibName: "ChatSettingsTVCell", bundle: nil), forCellReuseIdentifier: "ChatSettingsTVCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        self.tbleviewSettings.rotateViewForLanguage()
        self.arrChatSettings.removeAll()
        
        self.arrChatSettings.append("Archived chats".localized())
        self.arrChatSettings.append("Active status".localized())
        self.arrChatSettings.append("Message requests".localized())
        self.arrChatSettings.append("Privacy".localized())
        
        self.arrChatSettingIcons.append("ic_archive")
        self.arrChatSettingIcons.append("ic_online_status")
        self.arrChatSettingIcons.append("ic_message_request")
        self.arrChatSettingIcons.append("ic_privacy")
        
        self.tbleviewSettings.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
}

extension ChatSettingsVC : UITableViewDelegate , UITableViewDataSource  {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrChatSettings.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
            let label = UILabel(frame: CGRect(x: 10, y: 10, width: view.frame.size.width, height: 30))
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.text = "Security & privacy".localized()
            label.rotateViewForLanguage()
            label.rotateForTextAligment()
            view.addSubview(label)
            return view
        }
        return UIView.init()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cellSettings = tableView.dequeueReusableCell(withIdentifier: "ChatSettingsTVCell", for: indexPath) as? ChatSettingsTVCell else {
            return UITableViewCell()
        }
        
        cellSettings.manageViewData(name: self.arrChatSettings[indexPath.row], imgNamed: self.arrChatSettingIcons[indexPath.row])
        
        cellSettings.titleLbl.rotateViewForLanguage()
        cellSettings.titleLbl.rotateForTextAligment()
        
        cellSettings.selectionStyle = .none
        return cellSettings
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            let vc = AppStoryboard.Chat.instance.instantiateViewController(withIdentifier: "ArchivedChatsVC") as! ArchivedChatsVC
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = AppStoryboard.Chat.instance.instantiateViewController(withIdentifier: "ActiveStatusVC") as! ActiveStatusVC
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc = AppStoryboard.Chat.instance.instantiateViewController(withIdentifier: "MessageRequestVC") as! MessageRequestVC
            self.navigationController?.pushViewController(vc, animated: true)
        case 3:
            let vc = AppStoryboard.Chat.instance.instantiateViewController(withIdentifier: "PrivacyVC") as! PrivacyVC
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}
