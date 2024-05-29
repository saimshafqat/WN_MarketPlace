//
//  StoryViewsController.swift
//  kalam
//
//  Created by Raza najam on 12/1/21.
//  Copyright © 2021 apple. All rights reserved.
//

import UIKit

protocol StoryViewsControllerDelegate:class {
    func dismissUserViewDelegate()
}

class StoryViewsController: UIViewController {

    weak var delegate:StoryViewsControllerDelegate?
    var coreArray = [[String:Any]]()
    var storyID = ""
    var storyObj:FeedVideoModel?
    
    @IBOutlet weak var userViewTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
     //   self.callingGetUserViews()
      //  storyObj = DBStoryManager.shared.getExistinMessage(storyID: Int(storyID) ?? 0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.delegate?.dismissUserViewDelegate()
    }

}

extension StoryViewsController:UITableViewDataSource,UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:StoryViewsCell = tableView.dequeueReusableCell(withIdentifier: StoryViewsCell.className, for: indexPath) as! StoryViewsCell
        let userViewObj = self.coreArray[indexPath.row]
        cell.nameLbl.text = userViewObj["firstname"] as? String
    //    cell.userImageView.setImage(url: URL.init(string: userViewObj["profile_image"] as! String))
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.coreArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        LogClass.debugLog(indexPath.row)
    }
}
