//
//  WNPagerViewController.swift
//  WorldNoor
//
//  Created by Raza najam on 1/27/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import MapKit

class WNPagerViewController: UIViewController {
    
    var postID:String = ""
    var feedObj:FeedData?
    var commentObj:Comment?
    var isComment = false

    var counterArray = NSMutableArray()
    var isFromStory = false
    var isLoadMore = true
    var isLoadCount = true
    var selectedIndex = 0
    var pageNumber = 1
    
    var parentView : UIViewController!
    @IBOutlet var collectionViewMain : UICollectionView!
    @IBOutlet var lblEmpty : UILabel!
    @IBOutlet var tblViewLike : UITableView!
    
    var arrayTble = [ReactionModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Reactions"
        self.collectionViewMain.register(UINib.init(nibName: "CollectionTopCell", bundle: nil), forCellWithReuseIdentifier: "CollectionTopCell")
        self.lblEmpty.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if self.feedObj!.storyReactionMobile.count > 0 {
           isFromStory = true
        } else if(self.feedObj?.reationsTypesMobile != nil) {
            isFromStory = false
        }
        
        self.collectionViewMain.reloadData()
        self.counterArray.removeAllObjects()
        self.pageNumber = 1
        self.arrayTble.removeAll()
        self.callingLikeCountService()
    }
    
    
    func callingLikeCountService() {
        
        self.isLoadMore = true
        let userToken = SharedManager.shared.userToken()
        var parameters = ["action": "post/likes", "token": userToken, "post_id":String(self.feedObj!.postID!)]
        
        
        
        
        parameters["page"] = String(self.pageNumber)
        
        if self.selectedIndex != 0 {
//            if(isFromStory) {
//                parameters["type"] = self.feedObj!.storyReactionMobile[self.selectedIndex - 1].type
//            } else {
                parameters["type"] = self.arrayTble[self.selectedIndex - 1].type
//            }
        }
        print(parameters)
        RequestManager.fetchDataGet(Completion: { response in
            
            if self.pageNumber == 1 {
                self.counterArray.removeAllObjects()
            }
            switch response {
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)            case .success(let res):
                
                LogClass.debugLog("res  ==>")
                LogClass.debugLog(res)
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is NSArray {
                    let arrayMain = res as! NSArray
                    
                    for indexObj in arrayMain {
                        var isFound = false
                        for indexObjInner in self.arrayTble {
                            
                            if indexObjInner.type == ((indexObj as? [String : Any])!["reaction_type"] as? String) {
                                isFound = true
                                if self.isLoadCount {
                                    indexObjInner.count = indexObjInner.count! + 1
                                }
                                break
                            }
                        }
                        
                        if !isFound {
                            self.arrayTble.append(ReactionModel.init(countP: 1, typeP:(((indexObj as? [String : Any])!["reaction_type"] as? String)!)))
                        }
                        self.counterArray.add(indexObj)
                    }
                    
                    if arrayMain.count == 0 {
                        self.isLoadMore = false
                    }
                    self.tblViewLike.reloadData()
                } else {
                    self.pageNumber = -1
                }
                print(res)
                
                self.tblViewLike.reloadData()
                self.collectionViewMain.reloadData()
            }
        }, param:parameters)
    }
}



extension WNPagerViewController : UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize.init(width: 70, height: 35)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
//        if self.feedObj?.reationsTypesMobile != nil {
//            return self.feedObj!.reationsTypesMobile!.count + 1
//        }
//        if (isFromStory) {
//            return self.feedObj!.storyReactionMobile.count + 1
//        }
        return self.arrayTble.count + 1
//        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cellcollectiontop = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionTopCell", 
                                                                   for: indexPath) as! CollectionTopCell
        cellcollectiontop.lblAll.isHidden = true
         cellcollectiontop.viewSelected.isHidden = true
        
        if indexPath.row == self.selectedIndex {
            cellcollectiontop.viewSelected.isHidden = false
        }
        if indexPath.row == 0 {
            cellcollectiontop.imgViewIcon.isHidden = true
            cellcollectiontop.lblCount.text = "All"
//        } else if(isFromStory) {
//            cellcollectiontop.imgViewIcon.image = UIImage.init(named: "Img" + (self.feedObj?.storyReactionMobile[indexPath.row - 1].type)! + ".png")
//            cellcollectiontop.imgViewIcon.isHidden = false
//            cellcollectiontop.lblCount.text = String((self.feedObj?.storyReactionMobile[indexPath.row - 1].count!)!)
        } else {
            
            cellcollectiontop.imgViewIcon.image = UIImage.init(named: "Img" + (self.arrayTble[indexPath.row - 1].type)! + ".png")
            cellcollectiontop.imgViewIcon.isHidden = false
            cellcollectiontop.lblCount.text = String(self.arrayTble[indexPath.row - 1].count!)
            //        }
            
           
        }
        
        
        
//        if indexPath.row == 0 {
//            cellcollectiontop.imgViewIcon.isHidden = true
//            cellcollectiontop.lblCount.text = "All"
//        } else if(isFromStory) {
//            cellcollectiontop.imgViewIcon.image = UIImage.init(named: "Img" + (self.feedObj?.storyReactionMobile[indexPath.row - 1].type)! + ".png")
//            cellcollectiontop.imgViewIcon.isHidden = false
//            cellcollectiontop.lblCount.text = String((self.feedObj?.storyReactionMobile[indexPath.row - 1].count!)!)
//        } else {
//            cellcollectiontop.imgViewIcon.image = UIImage.init(named: "Img" + (self.feedObj?.reationsTypesMobile![indexPath.row - 1].type)! + ".png")
//            cellcollectiontop.imgViewIcon.isHidden = false
//            cellcollectiontop.lblCount.text = String((self.feedObj?.reationsTypesMobile![indexPath.row - 1].count!)!)
//        }
//        
        cellcollectiontop.viewSelected.isHidden = true
        if indexPath.row == self.selectedIndex {
            cellcollectiontop.viewSelected.isHidden = false
        }
        
        
//        if indexPath.row == 0 {
//            cellcollectiontop.imgViewIcon.isHidden = true
//            cellcollectiontop.lblCount.text = "All"
////        } else if(isFromStory) {
////            cellcollectiontop.imgViewIcon.image = UIImage.init(named: "Img" + (self.feedObj?.storyReactionMobile[indexPath.row - 1].type)! + ".png")
////            cellcollectiontop.imgViewIcon.isHidden = false
////            cellcollectiontop.lblCount.text = String((self.feedObj?.storyReactionMobile[indexPath.row - 1].count!)!)
//        } else {
//            
//            LogClass.debugLog(" asdadasdasd ")
//            LogClass.debugLog((self.arrayTble[indexPath.row - 1].type)!)
//            cellcollectiontop.imgViewIcon.image = UIImage.init(named: "Img" + (self.arrayTble[indexPath.row - 1].type)! + ".png")
//            cellcollectiontop.imgViewIcon.isHidden = false
//            cellcollectiontop.lblCount.text = String(self.arrayTble[indexPath.row - 1].count!)
//        }
//        
//        cellcollectiontop.viewSelected.isHidden = true
//        if indexPath.row == self.selectedIndex {
//            cellcollectiontop.viewSelected.isHidden = false
//        }
//        
//
        return cellcollectiontop
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        
        self.selectedIndex = indexPath.row
        self.collectionViewMain.reloadData()
        self.counterArray.removeAllObjects()
        self.pageNumber = 1
        self.isLoadCount = false
        
        self.callingLikeCountService()
    }
}



extension WNPagerViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        self.lblEmpty.isHidden = true
        if self.counterArray.count == 0 {
            self.lblEmpty.isHidden = false
        }
        return self.counterArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FeedStatCell", for: indexPath) as? FeedStatCell {
            let mainDict = self.counterArray[indexPath.row] as! NSDictionary
            let userDict = mainDict["user"] as! NSDictionary
            if !(userDict.value(forKey: "profile_image_thumbnail") is NSNull) {
                
                cell.userImage.loadImage(urlMain:userDict["profile_image_thumbnail"] as! String)
                self.view.labelRotateCell(viewMain: cell.userImage)
            }else {
                cell.userImage.image = UIImage(named: "placeholder.png")
                self.view.labelRotateCell(viewMain: cell.userImage)
            }
            cell.userNameLbl.text = String(format: "%@ %@", userDict["firstname"] as! String, userDict["lastname"] as! String)
            
            self.isFeedReachEnd(indexPath: indexPath)
            return cell
        }
        
        
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let mainDict = self.counterArray[indexPath.row] as! NSDictionary
        let userId = mainDict["user_id"] as? Int
        let controller = ProfileViewController.instantiate(fromAppStoryboard: .PostStoryboard)
        if let authorId =  userId {
            let userID = String(authorId)
            if Int(userID) != SharedManager.shared.getUserID() {
                controller.otherUserID = userID
                controller.otherUserisFriend = "1"
            }
        }
        controller.isNavPushAllow = false
        controller.isNavigationEnable = false
        self.dismiss(animated: true) {
            let navController = UINavigationController(rootViewController: controller)
            navController.modalPresentationStyle = .fullScreen
            navController.modalTransitionStyle = .crossDissolve
            UIApplication.topViewController()?.present(navController, animated: true, completion: nil)
        }
    }
    
    func isFeedReachEnd(indexPath:IndexPath) {
        if !self.isLoadMore {
            let feedCurrentCount = self.counterArray.count
            if indexPath.row == feedCurrentCount-1 {
                if self.pageNumber > -1 {
                    self.pageNumber = self.pageNumber + 1
                    self.callingLikeCountService()
                }
            }
        }
    }
}

class CollectionTopCell : UICollectionViewCell {
    @IBOutlet var imgViewIcon : UIImageView!
    @IBOutlet var lblCount : UILabel!
    @IBOutlet var lblAll : UILabel!
    
    @IBOutlet var viewSelected : UIView!
}
