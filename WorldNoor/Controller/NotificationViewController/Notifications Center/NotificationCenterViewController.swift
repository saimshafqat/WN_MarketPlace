//
//  NotificationCenterViewController.swift
//  WorldNoor
//
//  Created by Omnia Samy on 28/08/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit
import FittedSheets

protocol NotificationCenterDelegate: AnyObject {
    func moreTapped(notification: NotificationModel)
}

protocol NotificationOptionDelegate: AnyObject {
    func removeNotificationTapped(notification: NotificationModel)
    func turnOffNotificationTapped(notification: NotificationModel)
}

protocol NotificationRelationShipDelegate: AnyObject {
    func moreTapped(notification: NotificationModel)
    func relationShipAction(notification: NotificationModel, relationshipAction: String)
}

protocol FriendSuggestionsDelegate: AnyObject {
    func addFriendTapped(friendSuggestion: SuggestedFriendModel)
    func cancelFriendRequestTapped(friendSuggestion: SuggestedFriendModel)
    func removeFriendTapped(friendSuggestion: SuggestedFriendModel)
    func seeAllSuggestionsTapped()
}

class NotificationCenterViewController: UIViewController {
    
    @IBOutlet private weak var allButton: UIButton!
    @IBOutlet private weak var appsButton: UIButton!
    @IBOutlet private weak var unReadButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: NotificationCenterViewModelProtocol?
    
    var isNavigateDataRequested = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.title = "Notifications".localized()
        setUpScreenDesign()
        getAllNotificationList()
        markNotificationListRead()
        allButton.isEnabled = false
        unReadButton.isEnabled = false
        appsButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        SocketSharedManager.sharedSocket.delegateAppListner = self
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    init(viewModel: NotificationCenterViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NotificationCenterViewController {
    
    @IBAction func tabsTapped(_ sender: UIButton) {
        
        // selected color
        sender.backgroundColor = .notificationUnReadColor
        sender.setTitleColor(.notificationTabsSelectedTextColor, for: .normal)
        
        if sender.tag == 0 { // all
            
            if viewModel?.currentTabType != .All {
                self.viewModel?.currentPage = 1
                self.viewModel?.isNextPage = true
                getAllNotificationList()
                viewModel?.currentTabType = .All
                makeTabUnselectedDesign(tabsButton: [unReadButton, appsButton])
                self.resetData()
            }
        } else  if sender.tag == 1 { // unread
            
            if viewModel?.currentTabType != .unRead {
                getUnreadNotificationList()
                viewModel?.currentTabType = .unRead
                makeTabUnselectedDesign(tabsButton: [allButton, appsButton])
                self.resetData()
            }
        } else if sender.tag == 2 { // Apps
            
            if viewModel?.currentTabType != .apps {
                getAppsNotificationList()
                viewModel?.currentTabType = .apps
                makeTabUnselectedDesign(tabsButton: [allButton, unReadButton])
                self.resetData()
            }
        }
    }
    
    private func makeTabUnselectedDesign(tabsButton: [UIButton]) {
        for button in tabsButton {
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = .white
        }
    }
    
    private func resetData() {
        
        self.viewModel?.sectionList = []
        self.viewModel?.newNotificationList = []
        self.viewModel?.suggestedFriendList = []
        self.viewModel?.earlierNotificationList = []
        self.viewModel?.unreadNotificationList = []
        self.viewModel?.appsNotificationList = []
        self.tableView.reloadData()
        
        // disable tabs untill data return
        allButton.isEnabled = false
        unReadButton.isEnabled = false
        appsButton.isEnabled = false
    }
}

extension NotificationCenterViewController {
    
    private func setUpScreenDesign() {
        
        let searchButton = UIBarButtonItem(image: UIImage(named: "search_icon"), style: .plain, target: self, action: #selector(searchTapped))
        let settingsButton = UIBarButtonItem(image: UIImage(named: "settings_icon"), style: .plain, target: self, action: #selector(settingsTapped))
        settingsButton.imageInsets = UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 0)
        self.navigationItem.rightBarButtonItems = [searchButton]//, settingsButton]
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: NotificationCenterTableViewCell.className, bundle: nil),
                           forCellReuseIdentifier: NotificationCenterTableViewCell.className)
        
        tableView.register(UINib(nibName: RelationShipNotificationTableViewCell.className, bundle: nil),
                           forCellReuseIdentifier: RelationShipNotificationTableViewCell.className)
        
        tableView.register(UINib(nibName: FriendSuggestionTableViewCell.className, bundle: nil),
                           forCellReuseIdentifier: FriendSuggestionTableViewCell.className)
        
        tableView.register(UINib(nibName: NotificationCenterHeaderView.className, bundle: nil),
                           forHeaderFooterViewReuseIdentifier: NotificationCenterHeaderView.className)
        tableView.register(UINib(nibName: NotificationFooterView.className, bundle: nil),
                           forHeaderFooterViewReuseIdentifier: NotificationFooterView.className)
        tableView.register(UINib(nibName: AppNotificationTableViewCell.className, bundle: nil),
                           forCellReuseIdentifier: AppNotificationTableViewCell.className)
    }
    
    @objc func searchTapped() {
        // open search screen
        let controller = GlobalSearchViewController.instantiate(fromAppStoryboard: .EditProfile)
        navigationController?.pushViewController(controller, animated: false)
    }
    
    @objc func settingsTapped() {
        
        //        let popUpController = NotificationPopUpViewController()
        //
        //        popUpController.delegate = self
        //
        //        let sheetController = SheetViewController(controller: popUpController,
        //                                                  sizes: [.fixed(300), .fullScreen])
        //
        //        sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        //        sheetController.extendBackgroundBehindHandle = true
        //        sheetController.topCornersRadius = 20
        //        self.present(sheetController, animated: false, completion: nil)
    }
    
    
    private func getRelationshipNotificationCell(indexPath: IndexPath,
                                                 notification: NotificationModel) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: RelationShipNotificationTableViewCell.className, for: indexPath) as? RelationShipNotificationTableViewCell else {
            return UITableViewCell()
        }
        
        cell.bind(notification: notification, delegate: self)
        return cell
    }
    
    private func getNotificationCell(indexPath: IndexPath, notification: NotificationModel) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NotificationCenterTableViewCell.className, for: indexPath) as? NotificationCenterTableViewCell else {
            return UITableViewCell()
        }
        
        cell.bind(notification: notification, delegate: self)
        return cell
    }
    
    private func getNewNotificationCell(indexPath: IndexPath) -> UITableViewCell {
        
        guard let notification = self.viewModel?.newNotificationList[indexPath.row] else {
            return UITableViewCell()
        }
        
        let type = NotificationTypes(rawValue: notification.type)
        
        if type == .newFamilyMemberRequest || type == .newRelationshipRequest  {
            return self.getRelationshipNotificationCell(indexPath: indexPath, notification: notification)
            
        } else {
            return self.getNotificationCell(indexPath: indexPath, notification: notification)
        }
    }
    
    private func getFriendSuggestionCell(indexPath: IndexPath) -> UITableViewCell {
        
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
    
    private func getEarlierNotificationCell(indexPath: IndexPath) -> UITableViewCell {
        
        guard let notification = self.viewModel?.earlierNotificationList[indexPath.row] else {
            return UITableViewCell()
        }
        
        let type = NotificationTypes(rawValue: notification.type)
        
        if type == .newFamilyMemberRequest || type == .newRelationshipRequest  {
            return self.getRelationshipNotificationCell(indexPath: indexPath, notification: notification)
            
        } else {
            return self.getNotificationCell(indexPath: indexPath, notification: notification)
        }
    }
    
    private func getUnreadNotificationCell(indexPath: IndexPath) -> UITableViewCell {

        guard let notification = self.viewModel?.unreadNotificationList[indexPath.row] else {
            return UITableViewCell()
        }
        
        let type = NotificationTypes(rawValue: notification.type)
        
        if type == .newFamilyMemberRequest || type == .newRelationshipRequest  {
            return self.getRelationshipNotificationCell(indexPath: indexPath, notification: notification)
            
        } else {
            return self.getNotificationCell(indexPath: indexPath, notification: notification)
        }
    }
    
    private func getAppsNotificationCell(indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AppNotificationTableViewCell.className, for: indexPath) as? AppNotificationTableViewCell else {
            return UITableViewCell()
        }
        
        guard let notification = self.viewModel?.appsNotificationList[indexPath.row] else {
            return UITableViewCell()
        }
        
        cell.bind(appNotification: notification)
        return cell
    }
}

// api requests
extension NotificationCenterViewController {
    
    private func getAllNotificationList() {
        
        if viewModel?.currentPage == 1 {
//            SharedManager.shared.showOnWindow()
            Loader.startLoading()
        }
        viewModel?.getNotificationList(completion: {[weak self] (msg, success) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            
            guard let self = self else { return }
            
            // enable tabs
            self.allButton.isEnabled = true
            self.unReadButton.isEnabled = true
            self.appsButton.isEnabled = true
            
            if success {
                
                if viewModel?.sectionList.count == 0 {
                    let noDataView = NotificationNoDataView(frame: self.tableView.frame)
                    self.tableView.backgroundView = noDataView
                } else {
                    self.tableView.backgroundView = nil
                }
                self.tableView.reloadData()
                
            } else {
                SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: msg ?? .emptyString)
            }
        })
    }
    
    private func getUnreadNotificationList() {
        
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        viewModel?.getUnreadNotificationList(completion: {[weak self] (msg, success) in
            
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            guard let self = self else { return }
            
            // enable tabs
            self.allButton.isEnabled = true
            self.unReadButton.isEnabled = true
            self.appsButton.isEnabled = true
            
            if success {
                
                if viewModel?.sectionList.count == 0 {
                    let noDataView = NotificationNoDataView(frame: self.tableView.frame)
                    self.tableView.backgroundView = noDataView
                } else {
                    self.tableView.backgroundView = nil
                }
                self.tableView.reloadData()
            } else {
                SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: msg ?? .emptyString)
            }
        })
    }
    
    private func getAppsNotificationList() {
        
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        viewModel?.getAppsNotificationList(completion: {[weak self] (msg, success) in
            
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            guard let self = self else { return }
            
            // enable tabs
            self.allButton.isEnabled = true
            self.unReadButton.isEnabled = true
            self.appsButton.isEnabled = true
            
            if success {
                
                if viewModel?.sectionList.count == 0 {
                    let noDataView = NotificationNoDataView(frame: self.tableView.frame)
                    self.tableView.backgroundView = noDataView
                } else {
                    self.tableView.backgroundView = nil
                }
                self.tableView.reloadData()
            } else {
                SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: msg ?? .emptyString)
            }
        })
    }
    
    private func markNotificationAsRead(notification: NotificationModel, type: NotificationListSectionTypes) {
        
        switch type {
        case .new:
            if let index = self.viewModel?.newNotificationList
                .firstIndex(where: { $0.notificationID == notification.notificationID }) {
                self.viewModel?.newNotificationList[index].isRead = "1"
            }
            
        case .earlier:
            if let index = self.viewModel?.earlierNotificationList
                .firstIndex(where: { $0.notificationID == notification.notificationID }) {
                self.viewModel?.earlierNotificationList[index].isRead = "1"
            }
            
        case .unread:
            if let index = self.viewModel?.unreadNotificationList
                .firstIndex(where: { $0.notificationID == notification.notificationID }) {
                self.viewModel?.unreadNotificationList[index].isRead = "1"
            }
            
        default:
            LogClass.debugLog("default")
        }
        
        self.tableView.reloadData()
        
        viewModel?.markNotificationAsRead(notificationID: notification.notificationID,
                                          completion: {[weak self] (msg, success) in
            
            guard let self = self else { return }
            if success {
            } else {
                SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: msg ?? .emptyString)
            }
        })
    }
    
    func markNotificationListRead() {
        
        viewModel?.markNotificationListRead(completion: { [weak self] (msg, success) in
            
            guard let self = self else { return }
            
            if success {
            } else {
                SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: msg ?? .emptyString)
            }
        })
    }
}

extension NotificationCenterViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.sectionList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch viewModel?.sectionList[section].type {
        case .new:
            return viewModel?.newNotificationList.count ?? 0
        case .friendSuggestions:
            return viewModel?.suggestedFriendList.count ?? 0
        case .earlier:
            return viewModel?.earlierNotificationList.count ?? 0
        case .unread:
            return viewModel?.unreadNotificationList.count ?? 0
        case .apps:
            return viewModel?.appsNotificationList.count ?? 0
        case .none:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch viewModel?.sectionList[indexPath.section].type {
        case .new:
            return getNewNotificationCell(indexPath: indexPath)
        case .friendSuggestions:
            return getFriendSuggestionCell(indexPath: indexPath)
        case .earlier:
            return getEarlierNotificationCell(indexPath: indexPath)
        case .unread:
            return getUnreadNotificationCell(indexPath: indexPath)
        case .apps:
            return getAppsNotificationCell(indexPath: indexPath)
        case .none:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if (viewModel?.sectionList[section].haveItems ?? false) && viewModel?.sectionList[section].type != .unread { // true
            return 44
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: NotificationCenterHeaderView.className) as? NotificationCenterHeaderView
        else { return nil }
        
        let headerTitle = viewModel?.sectionList[section].title ?? ""
        switch viewModel?.sectionList[section].type {
        case .new:
            header.bind(title: headerTitle)
        case .friendSuggestions:
            header.bind(title: headerTitle)
        case .earlier:
            header.bind(title: headerTitle)
        case .unread:
            header.bind(title: headerTitle)
        case .apps:
            header.bind(title: headerTitle)
        default:
            LogClass.debugLog("none")
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        guard let footer = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: NotificationFooterView.className) as? NotificationFooterView
        else { return nil }
        
        if viewModel?.sectionList[section].type == .friendSuggestions {
            footer.bind(delegate: self)
            return footer
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if viewModel?.sectionList[section].type == .friendSuggestions {
            return 56
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // for pagination
        if viewModel?.sectionList[indexPath.section].type == .earlier &&
            (indexPath.row + 5) == (self.viewModel?.earlierNotificationList.count ?? 0) &&
            (self.viewModel?.isNextPage ?? true) {
            
            self.viewModel?.currentPage += 1
            getAllNotificationList()
        }
    }
}

extension NotificationCenterViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if viewModel?.sectionList[indexPath.section].type == .friendSuggestions {
            guard let friendSuggestion = self.viewModel?.suggestedFriendList[indexPath.row] else {
                return
            }
            
            let vcProfile = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            vcProfile.otherUserID = friendSuggestion.friendID
            vcProfile.otherUserisFriend = "0"
            vcProfile.isNavPushAllow = true
            self.navigationController?.pushViewController(vcProfile, animated: true)
            
        } else if viewModel?.sectionList[indexPath.section].type == .new { // notification
            
            guard let notification = self.viewModel?.newNotificationList[indexPath.row] else {
                return
            }
            if Int(notification.isRead) == 0 { // not read
                self.markNotificationAsRead(notification: notification, type: .new)
            }
            
            handleNotificationNavigation(notification: notification)
            
        } else if viewModel?.sectionList[indexPath.section].type == .earlier {
            
            guard let notification = self.viewModel?.earlierNotificationList[indexPath.row] else {
                return
            }
            if Int(notification.isRead) == 0 { // not read
                self.markNotificationAsRead(notification: notification, type: .earlier)
            }
            
            handleNotificationNavigation(notification: notification)
        } else if viewModel?.sectionList[indexPath.section].type == .unread {
            
            guard let notification = self.viewModel?.unreadNotificationList[indexPath.row] else {
                return
            }
            if Int(notification.isRead) == 0 { // not read
                self.markNotificationAsRead(notification: notification, type: .unread)
            }
            
            handleNotificationNavigation(notification: notification)
        } else if viewModel?.sectionList[indexPath.section].type == .apps {
            
            LogClass.debugLog("handle navigation here or handle read notification api for app tab")
            
            if viewModel?.appsNotificationList[indexPath.row].app.lowercased().range(of: "kalamtime") != nil  {
                SharedClass.shared.openXApp(senderType: .Kalamtime)
            }else  if viewModel?.appsNotificationList[indexPath.row].app.lowercased().range(of: "mizdah") != nil  {
                SharedClass.shared.openXApp(senderType: .Mizdah)
            }else  if viewModel?.appsNotificationList[indexPath.row].app.lowercased().range(of: "werfie") != nil  {
                SharedClass.shared.openXApp(senderType: .Werfie)
            }else  if viewModel?.appsNotificationList[indexPath.row].app.lowercased().range(of: "seezitt") != nil  {
                SharedClass.shared.openXApp(senderType: .Seezitt)
            }
        }
    }
}

extension NotificationCenterViewController : SocketAppListner {
    func appDataREcived() {
        
        print("appDataREcived ===>")
        
        if viewModel?.currentTabType == .apps {
            
            getAppsNotificationList()
        }
    }
}
