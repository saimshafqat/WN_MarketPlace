//
//  PagerController.swift
//  DTPagerController
//
//  Created by tungvoduc on 22/09/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class PagerController: DTPagerController {
    var postID:String = ""
    
    init(postID:String) {
        super.init(viewControllers: [])
        title = "PagerController"
        self.postID = postID
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        perferredScrollIndicatorHeight = 4

        let like = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: Const.KFeedStatisticsController) as! FeedStatisticsController
        like.postID = self.postID
        like.title = "Like"
        like.type = "like"

        let disLike = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: Const.KFeedStatisticsController) as! FeedStatisticsController
        disLike.postID = self.postID
        disLike.title = "DisLike"
        disLike.type = "disLike"
        
        let feedStats1 = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: Const.KFeedStatisticsController) as! FeedStatisticsController
               feedStats1.postID = self.postID
               feedStats1.title = "DisLike"
               feedStats1.type = "disLike"

        viewControllers = [feedStats, feedStats1]
        scrollIndicator.backgroundColor = UIColor.pagerColor
        scrollIndicator.layer.cornerRadius = scrollIndicator.frame.height / 2
        setSelectedPageIndex(0, animated: false)
        pageSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.pagerColor], for: .selected)
        pageSegmentedControl.backgroundColor = .white
        pageSegmentedControl.layer.masksToBounds = false
        pageSegmentedControl.layer.shadowColor = UIColor.lightGray.cgColor
        pageSegmentedControl.layer.shadowOffset = CGSize(width: 0, height: 1)
        pageSegmentedControl.layer.shadowRadius = 1
        pageSegmentedControl.layer.shadowOpacity = 0.5
    }
}
