//
//  ReportDetailController.swift
//  WorldNoor
//
//  Created by Raza najam on 2/28/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
//import IQKeyboardManagerSwift

protocol DismissReportDetailSheetDelegate {
    func dismissReport(message:String)
}

class ReportDetailController: UIViewController {
    
    var reportArray = NSArray()
    var lastOffset: CGPoint!
    var keyboardHeight: CGFloat!
    var feedObj:FeedData?
    var commentObj:Comment?
    var userObj:UserProfile?
    var isPost:ReportType = ReportType.Post
    var selectedCatID = ""
    var isfromPage : Bool = false
    var delegate: DismissReportDetailSheetDelegate?
    var groupObj:GroupValue?
    
    @IBOutlet weak private var collection: UICollectionView!
    @IBOutlet private var dataSource : ViewControllerDataSource!
    @IBOutlet weak var reportTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var constraintContentHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if  let flowLayout = collection.collectionViewLayout as? PartyPicksVerticalFlowLayout {
            // #warning: Your app will crash if you don't implement this property
            flowLayout.delegate = dataSource
            // Additional setups
            flowLayout.cellHeight = 40
            flowLayout.cellSpacing = 8
            flowLayout.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        }
        collection.delegate = self
        collection.collectionViewLayout.invalidateLayout()
        self.callingGetCategoriesService()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super .viewDidDisappear(animated)
//        IQKeyboardManager.shared.enable = true
    }
    
    @IBAction func reportButtonClicked(_ sender: Any) {
        var parameters = [String: Any]()
        if self.selectedCatID == "" || self.reportTextView.text == ""{
            SharedManager.shared.showAlert(message: "Please select the problem and write description before submitting the request.".localized(), view: self)
            return
        }
        
        if groupObj != nil && isfromPage {
            parameters = ["action": "page/report", "token":SharedManager.shared.userToken(), "page_id":self.groupObj!.groupID, "report_category_id":self.selectedCatID, "user_reviews":self.reportTextView.text!]
        }else if groupObj != nil {
            parameters = ["action": "group/report", "token":SharedManager.shared.userToken(), "group_id":self.groupObj!.groupID, "report_category_id":self.selectedCatID, "user_reviews":self.reportTextView.text!]
        }else if isPost == ReportType.Post{
            parameters = ["action": "post/report", "token":SharedManager.shared.userToken(), "report_post_id":String(self.feedObj!.postID!), "report_id":self.selectedCatID, "body":self.reportTextView.text!]
        }else if isPost == ReportType.Story{
            parameters = ["action": "post/report", "token":SharedManager.shared.userToken(), "story_id":String(self.feedObj!.postID!), "report_id":self.selectedCatID, "body":self.reportTextView.text!]
        }else if isPost == ReportType.Comment {
            parameters = ["action": "comment/report", "token":SharedManager.shared.userToken(),"comment_id":String(self.commentObj!.commentID!),"report_category_id":self.selectedCatID, "user_reviews":self.reportTextView.text!]
        }else if isPost == ReportType.User {
            parameters = ["action": "report/profile", "token":SharedManager.shared.userToken(),"reported_profile_username":self.userObj?.username ?? "","report_id":self.selectedCatID, "body":self.reportTextView.text!]

        }
        self.callingReportSubmitService(parameters: parameters, action: "report")
    }
    
    func callingGetCategoriesService(){
        let parameters = ["action": "meta/report_post_categories","token":SharedManager.shared.userToken()]
        RequestManager.fetchDataGet(Completion: { (response) in
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else {
                    let array = res as! [[String : Any]]
                    let reportModelObj = ReportModel()
                    self.dataSource.source = reportModelObj.manageReportArray(array: array)
                    self.collection.reloadData()
                }
            }
        }, param: parameters)
    }
    
    func callingReportSubmitService(parameters:[String:Any], action:String) {
        Loader.startLoading()
        RequestManager.fetchDataPost(Completion: {[weak self] (response) in
            guard let self else { return }
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                var message = ""
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    message = res as? String ?? .emptyString
                    dismissScreen(message)
                } else {
                    message = "Reported Successfully, we will review the matter soon.".localized()
                    dismissScreen(message)
                }
            }
        }, param: parameters)
    }
        
    func dismissScreen(_ msg: String) {
        self.dismiss(animated: true) {
            self.delegate?.dismissReport(message: msg)
        }
    }
}

extension ReportDetailController:UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        lastOffset = self.scrollView.contentOffset
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.scrollView.contentOffset = self.lastOffset
        })
    }
}

extension ReportDetailController:UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var counter = 0
        for reportObj in self.dataSource.source {
            if counter == indexPath.row {
                if reportObj.isSelected {
                    reportObj.isSelected = false
                    self.selectedCatID = ""
                }else {
                    reportObj.isSelected = true
                    self.selectedCatID = reportObj.id
                }
            }else {
                reportObj.isSelected = false
            }
            self.dataSource.source[counter] = reportObj
            counter = counter + 1
        }
        self.collection.reloadData()
    }
}

// MARK: - UI Resources
class ReportCategoryCell : UICollectionViewCell {
    static let cellIdentifier : String = "ReportCategoryCell"
    @IBOutlet var title : UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
}
