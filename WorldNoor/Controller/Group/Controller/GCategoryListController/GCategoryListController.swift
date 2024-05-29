//
//  GCategoryListController.swift
//  WorldNoor
//
//  Created by Raza najam on 3/31/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class GCategoryListController: UIViewController {
    
    @IBOutlet weak var groupTitleLbl: UILabel!
    @IBOutlet weak var groupCollectionView: UICollectionView!
    var catArray:NSArray?
    var groupObj:GroupValue?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.groupTitleLbl.text = self.groupObj?.groupName
        self.callingGroupCategoryService()
    }
    
    func callingGroupCategoryService(){
        let parameters = ["action": "group/search", "token": SharedManager.shared.userToken(), "category_id":String(self.groupObj!.groupID)]
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataGet(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is String {
                }
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is String {
                    //  SharedManager.shared.showAlert(message: res as! String, view: self)
                }else {

                    self.catArray = (res as! NSArray)
                    self.groupCollectionView.reloadData()
                }
            }
        }, param:parameters)
    }
    
}

extension GCategoryListController:UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if let count = self.catArray?.count {
            return count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupOtherCell", for: indexPath) as? GroupOtherCell else {
           return UICollectionViewCell()
        }
        
        
        let dict = self.catArray![indexPath.row] as! NSDictionary
        
        cell.catImageView.loadImageWithPH(urlMain:dict["cover_photo_path"] as! String)
        
        
        self.view.labelRotateCell(viewMain: cell.catImageView)
        cell.nameLbl.text = (dict["name"] as! String)
        cell.countLbl.text = self.ReturnValueCheck(value: dict["total_members"] as Any) + " members"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize: CGRect = UIScreen.main.bounds
        return CGSize(width: ((screenSize.width/2)-20), height: 175)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell,forItemAt indexPath: IndexPath)    {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dict = self.catArray![indexPath.row] as! NSDictionary
        let groupObj = GroupValue.init()
        
        if let grpID = dict["id"] as? Int {
            groupObj.groupID = String(grpID)
        }
        groupObj.groupName = dict["name"] as! String
        groupObj.groupImage = dict["cover_photo_path"] as! String
        if let grpID = dict["description"] as? String {
            groupObj.groupDesc = String(grpID)
        }
        
        
        groupObj.visibility = false        
        if self.ReturnValueCheck(value: dict["visibility"]) == "1" {
            groupObj.visibility = true
        }
        
//        let groupView = AppStoryboard.Kids.instance.instantiateViewController(withIdentifier: "NewGroupDetailVC") as! NewGroupDetailVC
//        groupView.groupObj = groupObj
//        self.navigationController?.pushViewController(groupView, animated: true)
        
        let groupView = AppStoryboard.Kids.instance.instantiateViewController(withIdentifier: "GroupPostController1") as! GroupPostController1
        groupView.groupObj = groupObj
        self.navigationController?.pushViewController(groupView, animated: true)
        
        
        
//        let groupView = AppStoryboard.Kids.instance.instantiateViewController(withIdentifier: "GroupFeedViewCollectionController") as! GroupFeedViewCollectionController
//        groupView.viewModel.groupObj = groupObj
//        self.navigationController?.pushViewController(groupView, animated: true)
    }
}
