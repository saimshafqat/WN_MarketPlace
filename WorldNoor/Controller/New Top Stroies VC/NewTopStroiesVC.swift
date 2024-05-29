//
//  NewTopStroiesVC.swift
//  WorldNoor
//
//  Created by apple on 5/25/22.
//  Copyright © 2022 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class NewTopStroiesVC : UIViewController {
    
    
    var arrayVideo = [FeedVideoModel]()
    var indexObj : Int = 0
    var startingPoint = ""
    var isNextVideoExist = true
    var apiCall = false
    
    var consumptionVC : VideoConsumptionPageViewController!
    var isPush = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isPush {
            self.navigationController?.isNavigationBarHidden = true
            self.tabBarController?.tabBar.isHidden = true
            
            
            self.consumptionVC = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "VideoConsumptionPageViewController") as! VideoConsumptionPageViewController
            consumptionVC.currentVideoIndex = self.indexObj
            consumptionVC.nodeList = arrayVideo
            consumptionVC.delegateVideo = self
            consumptionVC.modalPresentationStyle = .fullScreen
    //        self.present(consumptionVC, animated: false, completion: nil)
            
            self.navigationController?.pushViewController(consumptionVC, animated: true)
            
            self.startingPoint = arrayVideo.last!.videoID
            self.isPush = false
        }
        
    }
    
    
    
    func callAPIForNExt(){
        var param = ["action": "stories/search",
                     "token": SharedManager.shared.userToken(),
                     "filters[section_type]":"all_stories"]
        if startingPoint != "" {
            param["starting_point_id"] = self.startingPoint
        }
        self.callingGetService(action: "storiesList", param: param)
    }
    
    
    func callingGetService(action:String, param:[String:String]){
        RequestManager.fetchDataGet(Completion: { response in
            switch response {
            case .failure(let error):
                if error is String {
                }
            case .success(let res):
                self.apiCall = false
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is String {
                    self.isNextVideoExist = false
                }else {
                    
                    let arr =  res as! [[String : Any]]
                    if arr.count == 0 {
                        self.isNextVideoExist = false
                    }else {
                        let feedVideoObj:[FeedVideoModel] = self.getVideoModelArray(arr:arr)
                        FeedCallBManager.shared.videoClipArray.append(contentsOf: feedVideoObj)
                        
                        self.consumptionVC.nodeList = FeedCallBManager.shared.videoClipArray
                        
                        self.startingPoint = FeedCallBManager.shared.videoClipArray.last!.videoID
                    }
                }
            }
        }, param:param)
    }
    
    func getVideoModelArray(arr:[[String:Any]])->[FeedVideoModel] {
        var videoArray:[FeedVideoModel] = [FeedVideoModel]()
        for dict in arr {
            let videoModel = FeedVideoModel.init(dict: dict)
            videoArray.append(videoModel)
        }
        return videoArray
    }
}


extension NewTopStroiesVC : TopStoryDelegate {
    func gobackAction()
    {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
    }
    
    func nextPageAction()
    {

        
        if !apiCall {

                self.callAPIForNExt()
            
        }
        
        apiCall = true
        

    }
}


protocol TopStoryDelegate {
    func gobackAction()
    func nextPageAction()
}
