//
//  FriendsBirthdayViewController.swift
//  WorldNoor
//
//  Created by Omnia Samy on 04/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

protocol friendsBirthdayDelegate: AnyObject {
    func chatTapped(friendBirthday: FriendBirthdayModel)
}

class FriendsBirthdayViewController: UIViewController {
    
    var viewModel: FriendsBirthdayViewModelProtocol?
    
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.title = "Birthdays".localized()
        setUpscreenDesign()
        getFriendsBirthdayList()
    }
    
    init(viewModel: FriendsBirthdayViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FriendsBirthdayViewController {
    
    private func setUpscreenDesign() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: FriendBirthdayTableViewCell.className, bundle: nil),
                           forCellReuseIdentifier: FriendBirthdayTableViewCell.className)
        tableView.register(UINib(nibName: FriendsBirthdayHeaderView.className, bundle: nil),
                           forHeaderFooterViewReuseIdentifier: FriendsBirthdayHeaderView.className)
    }
    
    private func getFriendsBirthdayList() {
        
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        viewModel?.getFriendsBirthdayList(completion: {[weak self] (msg, success) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            guard let self = self else { return }
            if success {
                self.tableView.reloadData()
            } else {
                SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: msg ?? .emptyString)
            }
        })
    }
}

extension FriendsBirthdayViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel?.sectionList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel?.sectionList[section].list?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FriendBirthdayTableViewCell.className, for: indexPath) as? FriendBirthdayTableViewCell else {
            return UITableViewCell()
        }
        
        guard let friend = self.viewModel?.sectionList[indexPath.section].list?[indexPath.row],
                let type = self.viewModel?.sectionList[indexPath.section].type else {
            return UITableViewCell()
        }
        
        cell.bind(friendBirthday: friend, type: type, delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 22
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: FriendsBirthdayHeaderView.className) as? FriendsBirthdayHeaderView
        else { return nil }
        
        guard let section = self.viewModel?.sectionList[section] else {
            return UITableViewCell()
        }
        header.bind(section: section)
        return header
    }
}

extension FriendsBirthdayViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // navigate to user profile
        guard let friend = self.viewModel?.sectionList[indexPath.section].list?[indexPath.row] else {
            return
        }
        
        let vcProfile = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vcProfile.otherUserID = friend.friendID
        vcProfile.otherUserisFriend = "0"
        vcProfile.isNavPushAllow = true
        self.navigationController?.pushViewController(vcProfile, animated: true)
    }
}

extension FriendsBirthdayViewController: friendsBirthdayDelegate {
    
    func chatTapped(friendBirthday: FriendBirthdayModel) {
        
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        viewModel?.openChat(friendID: friendBirthday.friendID,
                            completion: { [weak self] (msg, success) in
            
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            guard let self = self else { return }
            if success {
                
              // navigate to chat
                guard let converationID = self.viewModel?.currentConversationID else { return }
                let moc = CoreDbManager.shared.persistentContainer.viewContext
                let objModel = Chat(context: moc)
                objModel.profile_image = friendBirthday.profileImage
                objModel.member_id = friendBirthday.friendID
                objModel.name = friendBirthday.firstName + " " + friendBirthday.lastName
                objModel.latest_conversation_id = converationID
                objModel.conversation_id = converationID
                objModel.conversation_type = "single"
                
                let contactGroup = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.ChatViewController) as! ChatViewController
                contactGroup.conversatonObj = objModel
                self.navigationController?.pushViewController(contactGroup, animated: true)
                
            } else {
                SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: msg ?? .emptyString)
            }
        })
    }
}
