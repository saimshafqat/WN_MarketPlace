//
//  ReelsPrivacyVC.swift
//  WorldNoor
//
//  Created by Waseem Shah on 11/11/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class ReelsPrivacyVC : UIViewController {
    
    @IBOutlet var imgViewPublic : UIImageView!
    @IBOutlet var imgViewOnlyMe : UIImageView!
    @IBOutlet var imgViewFriends : UIImageView!
    @IBOutlet var imgViewTick : UIImageView!
    
    var delegatePrivacy : ReelPrivacyDelegate!
    var valueChoose : String = "Public"
    var isSelected: Bool = false
    override func viewDidLoad() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.valueChoose.lowercased() == "only_me".lowercased() {
            self.onlyMeAction(sender: UIButton.init())
        }else if self.valueChoose.lowercased() == "Friends".lowercased() {

        }else {
            self.publicAction(sender: UIButton.init())
        }
    
        
    }
    
    @IBAction func publicAction(sender : UIButton){
        self.imgViewPublic.isHidden = false
        self.imgViewFriends.isHidden = true
        self.imgViewOnlyMe.isHidden = true
        self.valueChoose = "Public"
    }
    
    @IBAction func friendAction(sender : UIButton){
        self.imgViewPublic.isHidden = true
        self.imgViewFriends.isHidden = false
        self.imgViewOnlyMe.isHidden = true
        self.valueChoose = "Friends"
    }
    
    @IBAction func onlyMeAction(sender : UIButton){
        self.imgViewPublic.isHidden = true
        self.imgViewFriends.isHidden = true
        self.imgViewOnlyMe.isHidden = false
        self.valueChoose = "Only Me"
    }
    
    @IBAction func cancelAction(sender : UIButton){
        self.view.removeFromSuperview()
    }
    
    @IBAction func tickAction(sender : UIButton){
        self.isSelected = !self.isSelected
        self.imgViewTick.image = isSelected ?  UIImage(named: "CheckboxS.png") : UIImage(named: "CheckboxU.png")
    }
    @IBAction func doneAction(sender : UIButton){
        
        if self.isSelected {
            UserDefaults.standard.setValue(self.valueChoose, forKey: "memory")
            UserDefaults.standard.synchronize()
        }
        self.delegatePrivacy!.chooseOption(privacyOption: self.valueChoose)
        self.view.removeFromSuperview()
    }
    
}

protocol ReelPrivacyDelegate {
    func chooseOption(privacyOption : String)
}
