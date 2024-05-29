//
//  CallSettingsViewController.swift
//  kalam
//
//  Created by apple on 9/30/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class CallSettingsViewController: UIViewController,UIActionSheetDelegate {
    
    @IBOutlet weak var helpLabel: UILabel!
    @IBOutlet weak var callSettingsTable: UITableView!
    @IBOutlet weak var callSettingsText: UILabel!
    @IBOutlet weak var callSettingsLbl: UILabel!
    @IBOutlet weak var callQualityLabel: UILabel!
    @IBOutlet weak var qualityBtn: UIButton!
    
    var settingsArray = ["HD (For High speed Wifi)","High (For good networks)","Medium (For 4G networks)","Low (For 3G and slow networks)"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callSettingsLbl.isHidden = true
        callSettingsTable.delegate = self
        callSettingsTable.dataSource = self
        callSettingsTable.reloadData()
        manageUI()
        
        let str = UserDefaults.standard.string(forKey: "callquality")
        if(str == nil){
            UserDefaults.standard.setValue("Low (For 3G and slow networks)", forKey: "callquality")
            UserDefaults.standard.synchronize()
        }
    }
    
    func manageUI() {
        navigationItem.title = "Network Settings".localized()
    }
}

extension CallSettingsViewController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return settingsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "callsettingscell", for: indexPath)
        cell.textLabel?.text = settingsArray[indexPath.row]
        //cell.textLabel?.makeFontDynamicBody()
        let str = UserDefaults.standard.string(forKey: "callquality")
        if(str == settingsArray[indexPath.row] ){
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }else{
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        UserDefaults.standard.setValue(settingsArray[indexPath.row], forKey: "callquality")
        UserDefaults.standard.synchronize()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
