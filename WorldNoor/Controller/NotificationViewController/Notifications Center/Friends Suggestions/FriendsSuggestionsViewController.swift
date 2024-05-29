//
//  FriendsSuggestionsViewController.swift
//  WorldNoor
//
//  Created by Omnia Samy on 08/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class FriendsSuggestionsViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    var viewModel: FriendsSuggestionsViewModelProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpScreenDesign()
        getFriendsSuggestionsList()
    }
    
    init(viewModel: FriendsSuggestionsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FriendsSuggestionsViewController {
    
    private func setUpScreenDesign() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: FriendSuggestionTableViewCell.className, bundle: nil),
                           forCellReuseIdentifier: FriendSuggestionTableViewCell.className)
    }
    
    private func getFriendsSuggestionsList() {
        
//        SharedManager.shared.showOnWindow()
        
        viewModel?.getFriendsSuggestionsList(completion: {[weak self] (msg, success) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            
            guard let self = self else { return }
            if success {
                self.tableView.reloadData()
            } else {
                SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: msg ?? .emptyString)
            }
        })
    }
}

extension FriendsSuggestionsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel?.suggestedFriendList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FriendSuggestionTableViewCell.className, for: indexPath) as? FriendSuggestionTableViewCell else {
            return UITableViewCell()
        }
        
        guard let friendSuggestion = self.viewModel?.suggestedFriendList[indexPath.row] else {
            return UITableViewCell()
        }
        
        cell.bind(friendSuggestion: friendSuggestion, delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // for pagination
        if indexPath.row + 5 == self.viewModel?.suggestedFriendList.count {
            getFriendsSuggestionsList()
        }
    }
}

extension FriendsSuggestionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let friendSuggestion = self.viewModel?.suggestedFriendList[indexPath.row] else {
            return
        }
        
        let vcProfile = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vcProfile.otherUserID = friendSuggestion.friendID
        vcProfile.otherUserisFriend = "0"
        vcProfile.isNavPushAllow = true
        self.navigationController?.pushViewController(vcProfile, animated: true)
    }
}

extension FriendsSuggestionsViewController: FriendSuggestionsDelegate {
    
    func addFriendTapped(friendSuggestion: SuggestedFriendModel) {
        
        self.viewModel?.addFriend(friendSuggestion: friendSuggestion,
                                  completion: { [weak self] (msg, success) in
            if success {
            } else {
                SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: msg ?? .emptyString)
            }
        })
    }
    
    func cancelFriendRequestTapped(friendSuggestion: SuggestedFriendModel) {
        
        self.viewModel?.cancelFriendRequest(friendSuggestion: friendSuggestion, completion: {[weak self] (msg, success) in
            if success {
            } else {
                SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: msg ?? .emptyString)
            }
        })
    }
    
    func removeFriendTapped(friendSuggestion: SuggestedFriendModel) {
        
        if let index = self.viewModel?.suggestedFriendList
            .firstIndex(where: { $0.friendID == friendSuggestion.friendID }) {
            self.viewModel?.suggestedFriendList.remove(at: index)
            self.tableView.reloadData()
        }
        // call api
        self.viewModel?.removeFriendSuggestion(friendSuggestion: friendSuggestion, completion: {[weak self] (msg, success) in
            if !success {
                SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: msg ?? .emptyString)
            }
        })
    }
    
    func seeAllSuggestionsTapped() {
    }
}
