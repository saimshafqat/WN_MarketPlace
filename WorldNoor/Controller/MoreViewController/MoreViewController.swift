//
//  MoreViewController.swift
//  WorldNoor
//
//  Created by Raza najam on 10/16/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import GoogleSignIn


class MoreViewController: UIViewController {
    
    @IBOutlet weak var moreTableView: UITableView!
    @IBOutlet weak var lblVersionNumber: UILabel!
    
    var moreArray:[String] = []
    var sectionArray:[String] = []
    var sectionIconArray:[String] = []
    var twoDimensionalArray:[ExpandableNames] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        moreArray = ["Town-hall","Contacts","Logout"]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.lblVersionNumber.text = "Version:".localized() + Bundle.main.releaseVersionNumber!
        self.moreTableView.rotateViewForLanguage()
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        //        self.sectionArray = ["Profile".localized(), "Memories".localized(),"Friend Requests".localized(),"People Nearby".localized(), "Contacts".localized(), "Images".localized(), "watch".localized(),"Saved Posts".localized(),"Mizdah".localized(),"Kalam Time".localized(),"Seezitt".localized(),"Werfie".localized(),"Discover".localized() ,"Settings".localized() , "Invite Friends".localized() , "FAQs".localized(),"Privacy Policy".localized(),"Terms & Conditions".localized(),"End User License Agreement".localized(),"Blogs".localized(),"Delete Account".localized() ,"Logout".localized()]
        
        self.sectionArray = ["Profile".localized(), "Memories".localized(),"Friend Requests".localized(),"People Nearby".localized(), "Contacts".localized(), "Images".localized(), "watch".localized(),"Saved Posts".localized(),"Mizdah".localized(),"KT Messenger".localized(),"Seezitt".localized(),"Werfie".localized(),"Discover".localized() ,"Settings".localized() , "Invite Friends".localized() , "FAQs".localized(),"Privacy Policy".localized(),"Terms & Conditions".localized(),"End User License Agreement".localized(),"Blogs".localized(),"Delete Account".localized() ,"Logout".localized()]
        
        //  self.sectionIconArray = ["MoreProfile" ,"Memories" , "FriendRequest", "peopleNearby", "contactMore", "MoreImages" ,  "NewWatchMore","savePostIcon","Mizdah","KalamTime","Seezitt","Werfie", "discover", "MoreSettings" , "MoreInvite", "FAQs" ,"Ic_privacy_policy","Ic_tersm_and_conditions", "Ic_eula","Blog","DeleteChat","logout"]
        
//        self.sectionIconArray = ["MoreProfile" ,"Memories" , "FriendRequest", "peopleNearby", "contactMore", "MoreImages" ,  "NewWatchMore","savePostIcon","MizdahFeed","KalamTimeFeed","SeezittFeed","WerfieFeed", "discover", "MoreSettings" , "MoreInvite", "FAQs" ,"Ic_privacy_policy","Ic_tersm_and_conditions", "Ic_eula","Blog","DeleteChat","logout"]
        
        self.sectionIconArray = ["MoreProfile" ,"Memories" , "FriendRequest", "peopleNearby", "contactMore", "MoreImages" ,  "NewWatchMore","savePostIcon","mizdah","ktMessenger","sezitt","werfie", "discover", "MoreSettings" , "MoreInvite", "FAQs" ,"Ic_privacy_policy","Ic_tersm_and_conditions", "Ic_eula","Blog","DeleteChat","logout"]

        
        self.twoDimensionalArray = [
            ExpandableNames(isExpanded: false, names: [], restrictExpand: true, imgNameArray: []),
            ExpandableNames(isExpanded: false, names: [], restrictExpand: true, imgNameArray: []),
            ExpandableNames(isExpanded: false, names: [], restrictExpand: true, imgNameArray: []),
            ExpandableNames(isExpanded: false, names: [], restrictExpand: true, imgNameArray: []),
            ExpandableNames(isExpanded: false, names: [], restrictExpand: true, imgNameArray: []),
            ExpandableNames(isExpanded: false, names: [], restrictExpand: true, imgNameArray: []),
            ExpandableNames(isExpanded: false, names: [], restrictExpand: true, imgNameArray: []),
            ExpandableNames(isExpanded: false, names: [], restrictExpand: true, imgNameArray: []),
            
            ExpandableNames(isExpanded: false, names: [], restrictExpand: true, imgNameArray: []),
            
            ExpandableNames(isExpanded: false, names: [], restrictExpand: true, imgNameArray: []),
            ExpandableNames(isExpanded: false, names: [], restrictExpand: true, imgNameArray: []),
            ExpandableNames(isExpanded: false, names: [], restrictExpand: true, imgNameArray: []),
            ExpandableNames(isExpanded: false, names: ["Pages".localized(), "Groups".localized(), "Birthdays".localized(), "Movies".localized(), "Weather".localized(), "Town Hall".localized()], restrictExpand: false, imgNameArray: ["pagesMore", "groupsMore", "BirthdayMore", "moviesMore", "weatherMore", "townHall"]),
            ExpandableNames(isExpanded: false, names: [], restrictExpand: true, imgNameArray: []),
            ExpandableNames(isExpanded: false, names: [], restrictExpand: true, imgNameArray: []),
            ExpandableNames(isExpanded: false, names: [], restrictExpand: true, imgNameArray: []),
            ExpandableNames(isExpanded: false, names: [], restrictExpand: true, imgNameArray: []),
            ExpandableNames(isExpanded: false, names: [], restrictExpand: true, imgNameArray: []),
            ExpandableNames(isExpanded: false, names: [], restrictExpand: true, imgNameArray: []),
            ExpandableNames(isExpanded: false, names: [], restrictExpand: true, imgNameArray: []),
            ExpandableNames(isExpanded: false, names: [], restrictExpand: true, imgNameArray: []),
            ExpandableNames(isExpanded: false, names: [], restrictExpand: true, imgNameArray: [])
        ]
        self.moreTableView.estimatedRowHeight = 60
        self.moreTableView.rowHeight = UITableView.automaticDimension
        
        self.moreTableView.reloadData()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        //        SharedManager.shared.hideLoadingHubFromKeyWindow()
        Loader.stopLoading()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

extension MoreViewController:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        let moreSection = (Bundle.main.loadNibNamed("MoreSectionView", owner: self, options: nil)?.first as! MoreSectionView)
        moreSection.manageViewData(name:self.sectionArray[section], imgNamed: self.sectionIconArray[section])
        moreSection.selectionBtn.tag = section
        moreSection.selectionBtn.addTarget(self, action: #selector(handleExpandClose), for: .touchUpInside)
        moreSection.collapseImageView.isHidden = true
        if self.twoDimensionalArray[section].names.count > 0 {
            moreSection.collapseImageView.isHidden = false
        }
        
        moreSection.titleLbl.rotateViewForLanguage()
        moreSection.titleLbl.rotateForTextAligment()
        return moreSection
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return twoDimensionalArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !twoDimensionalArray[section].isExpanded {
            return 0
        }
        return twoDimensionalArray[section].names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: Const.MyContactCell, for: indexPath) as? MyContactCell {
            let name = twoDimensionalArray[indexPath.section].names[indexPath.row]
            let imageName = twoDimensionalArray[indexPath.section].imgNameArray[indexPath.row]
            cell.manageCellDataMore(value: name, imgName:imageName)
            
            cell.itemLbl.rotateViewForLanguage()
            cell.itemLbl.rotateForTextAligment()
            cell.layoutIfNeeded()
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let expandObj = self.twoDimensionalArray[12]
        
        
        
        switch expandObj.names[indexPath.row] {
            
        case "Pages".localized():
            let page = AppStoryboard.Group.instance.instantiateViewController(withIdentifier: "PageListController") as! PageListController
            self.navigationController?.pushViewController(page, animated: true)
        case "Groups".localized():
            let group = AppStoryboard.Group.instance.instantiateViewController(withIdentifier: "GroupListController") as! GroupListController
            self.navigationController?.pushViewController(group, animated: true)
            
        case "Birthdays".localized():
            let birthdayVC = Container.Notification.getFriendsBirthdayScreen()
            self.navigationController?.pushViewController(birthdayVC, animated: true)
            
            
        case "Weather".localized():
            let group = AppStoryboard.More.instance.instantiateViewController(withIdentifier: "WeatherViewController") as! WeatherViewController
            self.navigationController?.pushViewController(group, animated: true)
        case "Movies".localized():
            let movie = AppStoryboard.More.instance.instantiateViewController(withIdentifier: "MovieListController") as! MovieListController
            self.navigationController?.pushViewController(movie, animated: true)
        case "Town Hall".localized():
            let movie = AppStoryboard.EditProfile.instance.instantiateViewController(withIdentifier: "TownHallNewVC") as! TownHallNewVC
            self.navigationController?.pushViewController(movie, animated: true)
            
            
            
        default:
            LogClass.debugLog("No value found.")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 35
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat    {
        return 50
    }
    
    
    @objc func handleExpandClose(button: UIButton) {
        
        let expandObj = self.twoDimensionalArray[button.tag]
        if expandObj.restrictExpand {
            
            
            
            if self.sectionArray[button.tag] == "Mizdah".localized() {
                SharedClass.shared.openXApp(senderType: .Mizdah)
                
            }else if self.sectionArray[button.tag] == "Kalam Time".localized() {
                SharedClass.shared.openXApp(senderType: .Kalamtime)
            }else if self.sectionArray[button.tag] == "Seezitt".localized() {
                SharedClass.shared.openXApp(senderType: .Seezitt)
            }else if self.sectionArray[button.tag] == "Werfie".localized() {
                SharedClass.shared.openXApp(senderType: .Werfie)
            }else if self.sectionArray[button.tag] == "Profile".localized() {
                let profileVC = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                profileVC.isNavPushAllow = true
                UIApplication.topViewController()!.navigationController?.pushViewController(profileVC, animated: true)
            }else if self.sectionArray[button.tag] == "Memories".localized() {
                let profileVC = AppStoryboard.More.instance.instantiateViewController(withIdentifier: "MemoryVC") as! MemoryVC
                UIApplication.topViewController()!.navigationController?.pushViewController(profileVC, animated: true)
            }  else if self.sectionArray[button.tag] == "Friend Requests".localized() {
                let friendVC = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "FriendNotificationVC") as! FriendNotificationVC
                UIApplication.topViewController()!.navigationController?.pushViewController(friendVC, animated: true)
            } else if self.sectionArray[button.tag] == "People Nearby".localized() {
                let nearVC = self.GetView(nameVC: "NearByUsersVC", nameSB:"EditProfile" ) as! NearByUsersVC
                self.navigationController?.pushViewController(nearVC, animated: true)
            }else if self.sectionArray[button.tag] == "Contacts".localized() {
                let contactGroup = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: Const.ContactGroupIdentifier) as! ContactGroupController
                self.navigationController?.pushViewController(contactGroup, animated: true)
            } else if self.sectionArray[button.tag] == "Images".localized() {
                let imageSection = AppStoryboard.More.instance.instantiateViewController(withIdentifier: "ImagesViewController") as! ImagesViewController
                //              old image screen  ImageSectionController
                
                self.navigationController?.pushViewController(imageSection, animated: true)
            }else if self.sectionArray[button.tag] == "watch".localized() {
                
                self.tabBarController?.selectedIndex = 2
                
            }else if self.sectionArray[button.tag] == "Video Clips".localized() {
                let videoVC = self.GetView(nameVC: "VideoClipsVC", nameSB:"EditProfile" ) as! VideoClipsVC
                self.navigationController?.pushViewController(videoVC, animated: true)
            } else if self.sectionArray[button.tag] == "Saved Posts".localized() {
                let imageSection = SavedPostController1.instantiate(fromAppStoryboard: .More)
                self.navigationController?.pushViewController(imageSection, animated: true)
            }else if self.sectionArray[button.tag] == "Logout".localized() {
                self.ShowAlertWithCompletaionText(message: "Logout Message".localized(), noButtonText: "Cancel".localized(), yesButtonText: "Logout".localized()) { (pStatus) in
                    if pStatus {
                        
                        self.callingLogoutService()
                    }
                }
            } else if self.sectionArray[button.tag] == "Delete Account".localized() {
                self.callingDeleteService()
            }else if self.sectionArray[button.tag] == "FAQs".localized()  {
                
                //                let view = Container.Marketplace.getCategoryDetailsScreen()
                //                self.navigationController?.pushViewController(view, animated: true)
                //
                let imageSection = AppStoryboard.More.instance.instantiateViewController(withIdentifier: "WebController") as! WebController
                imageSection.isFromFaq = 0
                self.navigationController?.pushViewController(imageSection, animated: true)
                
            }else if self.sectionArray[button.tag] == "Settings".localized()  {
                let videoVC = self.GetView(nameVC: "SettingMoreVC", nameSB:"EditProfile" ) as! SettingMoreVC
                self.navigationController?.pushViewController(videoVC, animated: true)
            }else if self.sectionArray[button.tag] == "Invite Friends".localized()  {
                
                let videoVC = self.GetView(nameVC: "InviteFriendsVC", nameSB:"VideoClipStoryBoard" ) as! InviteFriendsVC
                self.navigationController?.pushViewController(videoVC, animated: true)
                
            }else    if self.sectionArray[button.tag] == "Privacy Policy".localized()  {
                let imageSection = AppStoryboard.More.instance.instantiateViewController(withIdentifier: "WebController") as! WebController
                imageSection.isFromFaq = 1
                self.navigationController?.pushViewController(imageSection, animated: true)
                
            }else  if self.sectionArray[button.tag] == "Terms & Conditions".localized()  {
                let imageSection = AppStoryboard.More.instance.instantiateViewController(withIdentifier: "WebController") as! WebController
                imageSection.isFromFaq = 2
                self.navigationController?.pushViewController(imageSection, animated: true)
                
            }else if self.sectionArray[button.tag] == "End User License Agreement".localized()  {
                
                let imageSection = AppStoryboard.More.instance.instantiateViewController(withIdentifier: "WebController") as! WebController
                imageSection.isFromFaq = 3
                self.navigationController?.pushViewController(imageSection, animated: true)
            }else if self.sectionArray[button.tag] == "Blogs".localized()  {
                let page = AppStoryboard.Kids.instance.instantiateViewController(withIdentifier: "BlogsVC") as! BlogsVC
                self.navigationController?.pushViewController(page, animated: true)
            }
        }else {
            let section = button.tag
            var indexPaths = [IndexPath]()
            for row in twoDimensionalArray[section].names.indices {
                let indexPath = IndexPath(row: row, section: section)
                indexPaths.append(indexPath)
            }
            let isExpanded = twoDimensionalArray[section].isExpanded
            twoDimensionalArray[section].isExpanded = !isExpanded
            if isExpanded {
                self.moreTableView.deleteRows(at: indexPaths, with: .fade)
            }else {
                self.moreTableView.insertRows(at: indexPaths, with: .fade)
            }
        }
    }
    
    
    
    func callingDeleteService() {
        SharedManager.shared.ShowAlertWithCompletaion(title: "Delete Account".localized(), message: "Are you sure to delete this account?".localized(), isError: false, DismissButton: "Cancel".localized(), AcceptButton: "Yes".localized()) { (statusP) in
            if statusP {
                //                SharedManager.shared.showOnWindow()
                Loader.startLoading()
                var parameters = [ "token": SharedManager.shared.userToken()]
                parameters["action"] = "user/deactive"
                RequestManager.fetchDataPost(Completion: { response in
                    //                    SharedManager.shared.hideLoadingHubFromKeyWindow()
                    Loader.stopLoading()
                    switch response {
                    case .failure(let error):
                        LogClass.debugLog( error.localizedDescription)
                    case .success(let res):
                        if res is String {
                            SharedManager.shared.showAlert(message: res as! String, view: self)
                        } else {
                            self.logoutFromApp()
                        }
                    }
                }, param:parameters)
            }
        }
    }
    
    func callingLogoutService() {
        
        FileBasedManager.shared.removeImage()
        SharedManager.shared.removeFeedArray()
        FileBasedManager.shared.removeImage(nameImage: "myImageCoverToUpload.jpg")
        
        let parameters = ["action": "logout","token":SharedManager.shared.userToken()]
        //        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataPost(Completion: { response in
            //            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)            case .success(let res):
                if res is String {
                    SharedManager.shared.ShowsuccessAlert(message: res as! String,AcceptButton: "OK".localized()) { status in
                        self.logoutFromApp()
                    }
                }
            }
        }, param:parameters)
    }
    
    func logoutFromApp() {
        
        
        SharedClass.shared.logoutFromKeychain()
        SharedManager.shared.removeFeedArray()
        GoogleSignInManager.signOut()
        FeedCallBManager.shared.videoClipArray.removeAll()
        SocketSharedManager.sharedSocket.manager?.disconnect()
        SocketSharedManager.sharedSocket.closeConnection()
        SharedManager.shared.userObj = nil
        SharedManager.shared.removeProfile()
        AppDelegate.shared().loadLoginScreen()
        RecentSearchRequestUtility.shared.clearFromCache()
    }
}

struct ExpandableNames {
    var isExpanded: Bool
    let names: [String]
    var restrictExpand:Bool
    let imgNameArray:[String]
}


extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
