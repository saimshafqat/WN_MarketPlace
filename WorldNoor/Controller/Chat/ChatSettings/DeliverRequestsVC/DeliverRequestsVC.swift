//
//  DeliverRequestsVC.swift
//  WorldNoor
//
//  Created by ogouluser1-mac6 on 12/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class DeliverRequestsVC: UIViewController {
    @IBOutlet var tableView : UITableView!
    var isFromOthers: Bool = false
    
    var dataArray = ["Chats", "Message requests", "Don't receive requests"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = isFromOthers ? "Others on WorldNoor".localized() : "Friends of friends on WorldNoor".localized()
        
        if(isFromOthers)
        {
            dataArray.remove(at: 0)
        }
        
        tableView.reloadData()
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

extension DeliverRequestsVC : UITableViewDelegate , UITableViewDataSource  {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
            let label = UILabel(frame: CGRect(x: 16, y: 10, width: view.frame.size.width, height: 30))
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.text = "Deliver requests to".localized()
            label.rotateViewForLanguage()
            label.rotateForTextAligment()
            view.addSubview(label)
            return view
        }
        return UIView.init()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DeliverRequestsTVCell", for: indexPath) as? DeliverRequestsTVCell else {
            return UITableViewCell()
        }
        
        cell.titleLbl.text = dataArray[indexPath.row].localized()
        cell.titleLbl.rotateViewForLanguage()
        cell.titleLbl.rotateForTextAligment()
        
        let str = UserDefaults.standard.string(forKey: isFromOthers ? "others_message_request" : "friends_message_request") ?? "Message requests"
        if(str == dataArray[indexPath.row] ){
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }else{
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        UserDefaults.standard.setValue(dataArray[indexPath.row], forKey: isFromOthers ? "others_message_request" : "friends_message_request")
        UserDefaults.standard.synchronize()
        tableView.reloadData()
    }
}
