//
//  TabberViewController.swift
//  WorldNoor
//
//  Created by Raza najam on 1/25/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class TabberViewController: TabmanViewController {
    
    private var viewControllers:[UIViewController] = []
    
    var postID:String = ""
    
    func  getViewControl()-> UIViewController {
        let feedStats = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: Const.KFeedStatisticsController) as! FeedStatisticsController
        feedStats.postID = self.postID
        feedStats.title = "One"
        return feedStats
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers.append(self.getViewControl())
        viewControllers.append(self.getViewControl())
        
        self.dataSource = self
        // Create bar
        let bar = TMBar.ButtonBar()
    
        bar.layout.transitionStyle = .snap // Customize
        bar.buttons.customize { (button) in
            //            button.color = .orange
            //            button.selectedColor = .red
            
            
        }
        // Add to view
        addBar(bar, dataSource: self, at: .top)
    }
}

extension TabberViewController: PageboyViewControllerDataSource, TMBarDataSource {
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        let title = "Page \(index)"
//        return TMBarItem(title: title)
        return TMBarItem(title: "Hi", image:#imageLiteral(resourceName: "playBlackButton"))
    }
    
    func barItem(for tabViewController: TabmanViewController, at index: Int) -> TMBarItemable {
        let title = "Page \(index)"
//        return TMBarItem(title: title)
        return TMBarItem(title: title, image:#imageLiteral(resourceName: "playBlackButton"))

    }
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
    
    
}

