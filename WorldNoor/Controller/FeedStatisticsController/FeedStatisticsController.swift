
//
//  FeedStatisticsController.swift
//  WorldNoor
//
//  Created by Raza najam on 1/21/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit


class FeedStatisticsController: UIViewController {

    @IBOutlet weak var feedTableView: UITableView!
    var postID:String = ""
    var counterArray = NSArray()
    var action = ""
    var isType = ""
    var isComment = false
    var index = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.feedTableView.estimatedRowHeight = 70
        self.feedTableView.rowHeight = UITableView.automaticDimension
        self.callingLikeCountService()
    }
    
    func callingLikeCountService(){
        let userToken = SharedManager.shared.userToken()
        var parameters = ["action": action,"token": userToken, "post_id":self.postID]
        if self.isComment {
            parameters.removeValue(forKey: "post_id")
            parameters["comment_id"] = self.postID
            parameters["action"] = "comment/get_likes_dislikes"
            parameters["type"] = self.isType
        }
        RequestManager.fetchDataGet(Completion: { response in
            switch response {
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is NSArray {
                    self.counterArray = res as! NSArray
                    self.feedTableView.reloadData()
                }else {
                   
                }
            }
        }, param:parameters)
    }
}

extension FeedStatisticsController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.counterArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FeedStatCell", for: indexPath) as? FeedStatCell {
            let mainDict = self.counterArray[indexPath.row] as! NSDictionary
            let userDict = mainDict["user"] as! NSDictionary
//            cell.userImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
            if !(userDict.value(forKey: "profile_image_thumbnail") is NSNull) {
//                cell.userImage.sd_setImage(with: URL(string: userDict["profile_image_thumbnail"] as! String), placeholderImage: UIImage(named: "placeholder.png"))
                
                cell.userImage.loadImageWithPH(urlMain:userDict["profile_image_thumbnail"] as! String)
                
                self.view.labelRotateCell(viewMain: cell.userImage)
            }else {
//                 cell.userImage.sd_setImage(with: URL(string: ""), placeholderImage: UIImage(named: "placeholder.png"))
                
                
                cell.userImage.image = UIImage.init(named: "placeholder.png")
                
                
                self.view.labelRotateCell(viewMain: cell.userImage)
            }
            cell.userNameLbl.text = String(format: "%@ %@", userDict["firstname"] as! String, userDict["lastname"] as! String)
//            cell.thankBtn.isHidden = false
//            if self.action == "post/dislikes" {
//                cell.thankBtn.isHidden = true
//            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
