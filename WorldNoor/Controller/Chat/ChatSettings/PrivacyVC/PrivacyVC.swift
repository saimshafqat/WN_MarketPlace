//
//  PrivacyVC.swift
//  WorldNoor
//
//  Created by ogouluser1-mac6 on 12/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class PrivacyVC: UIViewController {
    
    @IBOutlet var tableView : UITableView!
    
//    let dataArray = ["Message request delivery".localized(), "Blocked accounts".localized(), "Restricted accounts".localized()] //"Hidden contacts".localized()]
  
    let dataArray = ["Message request delivery".localized(), "Blocked accounts".localized()] //"Hidden contacts".localized()]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Privacy".localized()
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

extension PrivacyVC : UITableViewDelegate , UITableViewDataSource  {
    
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
            label.text = "Manage contacts".localized()
            label.rotateViewForLanguage()
            label.rotateForTextAligment()
            view.addSubview(label)
            return view
        }
        return UIView.init()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PrivacyTVCell", for: indexPath) as? PrivacyTVCell else {
            return UITableViewCell()
        }
        
        cell.titleLbl.text = dataArray[indexPath.row]
        cell.titleLbl.rotateViewForLanguage()
        cell.titleLbl.rotateForTextAligment()
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            let vc = AppStoryboard.Chat.instance.instantiateViewController(withIdentifier: MessageDeliveryVC.className) as! MessageDeliveryVC
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = AppStoryboard.Chat.instance.instantiateViewController(withIdentifier: ChatBlockVC.className) as! ChatBlockVC
            self.navigationController?.pushViewController(vc, animated: true)
            
            LogClass.debugLog(dataArray[indexPath.row])
        case 2:
            let vc = AppStoryboard.Chat.instance.instantiateViewController(withIdentifier: RestrictedListVC.className) as! RestrictedListVC
            self.navigationController?.pushViewController(vc, animated: true)
            LogClass.debugLog(dataArray[indexPath.row])
        case 3:
            let vc = AppStoryboard.Chat.instance.instantiateViewController(withIdentifier: HiddenContactVC.className) as! HiddenContactVC
            self.navigationController?.pushViewController(vc, animated: true)
            LogClass.debugLog(dataArray[indexPath.row])
        default:
            break
        }
        
    }
}
