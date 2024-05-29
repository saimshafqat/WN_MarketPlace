//
//  FeedPopOverViewController.swift
//  WorldNoor
//
//  Created by Omnia Samy on 06/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

enum FeedPopPoverMenuType {
    case post, story, reel, live
}

struct PopMenu {
    var title: String!
    var image: String!
    var type: FeedPopPoverMenuType!
}

class FeedPopOverViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    weak var delegate: FeedPopOverMenuDelegate?
    private var popMenuList: [PopMenu] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setUpScreenDesign()
        makePopMenu()
        self.preferredContentSize = CGSize(width: 100, height: 160)
    }
    
    private func setUpScreenDesign() {
        
        tableView.register(UINib(nibName: PopOverMenuTableViewCell.className, bundle: nil),
                           forCellReuseIdentifier: PopOverMenuTableViewCell.className)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func makePopMenu() {
        
        let post = PopMenu(title: "Post".localized(), image: "popover_post_icon", type: .post)
        let story = PopMenu(title: "Story".localized(), image: "popover_story_icon", type: .story)
        let reel = PopMenu(title: "Reel".localized(), image: "popover_reel_icon", type: .reel)
        let live = PopMenu(title: "Live".localized(), image: "popover_live_icon", type: .live)
        
        self.popMenuList = [post, story, reel, live]
    }
}

extension FeedPopOverViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return popMenuList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PopOverMenuTableViewCell.className, for: indexPath) as? PopOverMenuTableViewCell else {
            return UITableViewCell()
        }
        
         let menuItem = self.popMenuList[indexPath.row]
        cell.bind(menuItem: menuItem)
        return cell
    }
}

extension FeedPopOverViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 38
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.dismiss(animated: true, completion: {
          
            let itemType = self.popMenuList[indexPath.row].type
            
            switch itemType {
            case .post:
                self.delegate?.openPostTapped()
            case .story:
                self.delegate?.openStoryTapped()
            case .reel:
                self.delegate?.openReelTapped()
            case .live:
                self.delegate?.openLiveTapped()
            default:
                LogClass.debugLog("default")
            }
        })
    }
}
