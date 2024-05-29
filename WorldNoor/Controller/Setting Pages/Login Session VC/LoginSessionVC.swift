//
//  LoginSessionVC.swift
//  WorldNoor
//
//  Created by apple on 4/20/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class LoginSessionVC: UIViewController {
    
    
    @IBOutlet var tbleViewLoginSession : UITableView!
    
    var arraySession = [LoginSessionModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tbleViewLoginSession.register(UINib.init(nibName: "LoginSessionCell", bundle: nil), forCellReuseIdentifier: "LoginSessionCell")
        self.tbleViewLoginSession.register(UINib.init(nibName: "LoginSessionHeaderCell", bundle: nil), forCellReuseIdentifier: "LoginSessionHeaderCell")
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tbleViewLoginSession.rotateViewForLanguage()
        self.getSessionLogin()
    }
    
    func getSessionLogin(){
        //        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let parameters = ["action": "profile/login_sessions","token": SharedManager.shared.userToken()]
        
        RequestManager.fetchDataGet(Completion: { (response) in
            //            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                if let newRes = res as? [[String:Any]] {
                    for indexObj in newRes {
                        self.arraySession.append(LoginSessionModel.init(fromDictionary: indexObj))
                    }
                }
                self.tbleViewLoginSession.reloadData()
            }
        }, param: parameters)
    }
}


extension LoginSessionVC : UITableViewDataSource , UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arraySession.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            guard let cellLogin = tableView.dequeueReusableCell(withIdentifier: "LoginSessionHeaderCell", for: indexPath) as? LoginSessionHeaderCell else {
                return UITableViewCell()
            }
            
            cellLogin.lblName.rotateViewForLanguage()
            cellLogin.lblName.rotateViewForInner()
            
            cellLogin.selectionStyle = .none
            return cellLogin
        }
        
        
        guard let cellLogin = tableView.dequeueReusableCell(withIdentifier: "LoginSessionCell", for: indexPath) as? LoginSessionCell else {
            return UITableViewCell()
        }
        
        
        cellLogin.lblName.text = self.arraySession[indexPath.row - 1].device_user_agent
        cellLogin.btnCross.tag = indexPath.row - 1
        cellLogin.btnCross.addTarget(self, action: #selector(self.crossAction), for: .touchUpInside)
        
        cellLogin.lblName.rotateViewForLanguage()
        cellLogin.lblName.rotateViewForInner()
        cellLogin.lblName.rotateForTextAligment()
        cellLogin.selectionStyle = .none
        return cellLogin
    }
    
    @objc func crossAction(sender : UIButton){
        
        //        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let parameters = ["action": "profile/delete_login_session","token": SharedManager.shared.userToken() , "session_id" : self.arraySession[sender.tag].id]
        
        RequestManager.fetchDataPost(Completion: { (response) in
            //            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                if let newRes = res as? [String:Any] {
                    self.arraySession.remove(at: sender.tag)
                }
                self.tbleViewLoginSession.reloadData()
            }
        }, param: parameters)
    }
}

class LoginSessionCell : UITableViewCell {
    @IBOutlet var lblName : UILabel!
    
    @IBOutlet var btnCross : UIButton!
}


class LoginSessionHeaderCell : UITableViewCell {
    @IBOutlet var lblName : UILabel!
}

