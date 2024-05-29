//
//  HQPagerViewController.swift
//  WorldNoor
//
//  Created by Raza najam on 1/27/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class HQPagerViewController:HQPagerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        setSelectedIndex(index: 1, animated: false)
        
        // build viewcontrollers
        let vc1 = self.getViewControl()
        vc1.index = 0
        let vc2 = self.getViewControl()
        vc2.index = 1
        
        self.viewControllers = [vc1, vc2]
        
//        menuView.titleFont = UIFont.boldSystemFont(ofSize: 14)
//        menuView.titleTextColor = UIColor.black
    }
    
    func  getViewControl()-> UIViewController {
        let feedStats = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: Const.KFeedStatisticsController) as! FeedStatisticsController
        feedStats.postID = self.postID
        feedStats.title = "One"
        return feedStats
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
