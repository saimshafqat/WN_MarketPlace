//
//  AppLanguagesVC.swift
//  WorldNoor
//
//  Created by apple on 10/13/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class AppLanguagesVC : UIViewController {
    
    @IBOutlet var tblViewLanguage : UITableView!
    
    var arrayLanguage = [String]()
    
    var selectedLanguage = ""
    override func viewDidLoad() {
        tblViewLanguage.registerCustomCells([
            "DropDownTableViewCell",
        ])

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        selectedLanguage = UserDefaults.standard.value(forKey: "Lang") as! String
        
        self.arrayLanguage.removeAll()
        self.arrayLanguage = SharedManager.shared.appLanguage()
        self.tblViewLanguage.reloadData()
        
        self.navigationController?.navigationBar.isHidden = false
    
        self.navigationController?.addRightButtonWithTitle(self, selector: #selector(self.SaveAction), lblText: "Save", widthValue: 75.0)
    }
    
    @objc func SaveAction(){
        
        UserDefaults.standard.setValue(selectedLanguage, forKey: "Lang")
        UserDefaults.standard.synchronize()
        
        SharedManager.shared.isLanguageChange = true
        
        self.ChangeTabbarText()
        
        self.tabBarController?.dismiss(animated: false, completion: {
            SocketSharedManager.sharedSocket
            self.appDelegate.loadTabBar()
        })
        
        self.navigationController?.popViewController(animated: true)
    }
}


extension AppLanguagesVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayLanguage.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cellLang = tableView.dequeueReusableCell(withIdentifier: "DropDownTableViewCell", for: indexPath) as! DropDownTableViewCell
        
        guard let cellLang = tableView.dequeueReusableCell(withIdentifier: "DropDownTableViewCell", for: indexPath) as? DropDownTableViewCell else {
           return UITableViewCell()
        }
        cellLang.countryNameLabel.text = self.arrayLanguage[indexPath.row]
        
        cellLang.accessoryType = .none
        if selectedLanguage == cellLang.countryNameLabel.text {
            cellLang.accessoryType = .checkmark
        }
        cellLang.selectionStyle = .none
        return cellLang
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedLanguage = self.arrayLanguage[indexPath.row]
        self.tblViewLanguage.reloadData()
    }
}
