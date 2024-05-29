//
//  ActiveStatusVC.swift
//  WorldNoor
//
//  Created by ogouluser1-mac6 on 30/08/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class ActiveStatusVC: UIViewController {
    
    @IBOutlet weak var switchBtn: UISwitch!
    @IBOutlet weak var vwSwitch: UIView!
    @IBOutlet weak var lblSwitchText: UILabel!
    @IBOutlet weak var lblText1: UILabel!
    @IBOutlet weak var lblText2: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Active status".localized()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        
        vwSwitch.rotateViewForLanguage()
        switchBtn.rotateViewForLanguage()
        lblSwitchText.rotateViewForLanguage()
        lblSwitchText.rotateForTextAligment()
        lblText1.rotateForTextAligment()
        lblText2.rotateForTextAligment()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func SwitchValueChanged(_ sender: Any) {
        
        if switchBtn.isOn {
            SocketSharedManager.sharedSocket.changeStatus(valueMain: "1")
        }else {
            SocketSharedManager.sharedSocket.changeStatus(valueMain: "0")
        }
    }
}
