//
//  MessageDeliveryVC.swift
//  WorldNoor
//
//  Created by ogouluser1-mac6 on 12/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class MessageDeliveryVC: UIViewController {
    @IBOutlet var tableView : UITableView!
    
    let dataArray = ["Friends of friends on WorldNoor".localized(), "Others on WorldNoor".localized()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Message delivery".localized()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        
        self.tableView.rotateViewForLanguage()
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
}

extension MessageDeliveryVC : UITableViewDelegate , UITableViewDataSource  {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessageDeliveryTVCell", for: indexPath) as? MessageDeliveryTVCell else {
            return UITableViewCell()
        }
        
        cell.titleLbl.text = dataArray[indexPath.row]
        
        let str = UserDefaults.standard.string(forKey: indexPath.row == 1 ? "others_message_request" : "friends_message_request") ?? "Message requests"
        
        cell.descriptionLbl.text = str.localized()
        
        cell.titleLbl.rotateViewForLanguage()
        cell.titleLbl.rotateForTextAligment()
        cell.descriptionLbl.rotateViewForLanguage()
        cell.descriptionLbl.rotateForTextAligment()
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = AppStoryboard.Chat.instance.instantiateViewController(withIdentifier: "DeliverRequestsVC") as! DeliverRequestsVC
        vc.isFromOthers = indexPath.row == 1
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
