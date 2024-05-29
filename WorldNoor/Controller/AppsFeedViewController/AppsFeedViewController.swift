//
//  AppsFeedViewController.swift
//  WorldNoor
//
//  Created by Waseem Shah on 05/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class AppsFeedViewController : UIViewController {
    
    @IBOutlet var lblHeading : UILabel!
    
    @IBOutlet var lblHeading_Seezitt : UILabel!
    @IBOutlet var lblHeading_Seezitt_Des : UILabel!
    
    @IBOutlet var lblHeading_Mizdah : UILabel!
    @IBOutlet var lblHeading_Mizdah_Des : UILabel!
    
    @IBOutlet var lblHeading_KT : UILabel!
    @IBOutlet var lblHeading_KT_Des : UILabel!
    
    @IBOutlet var lblHeading_Werfiee : UILabel!
    @IBOutlet var lblHeading_Werfiee_Des : UILabel!
    
    override func viewDidLoad() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.lblHeading.font = UIFont.boldSystemFont(ofSize: 18.0)
        
        self.lblHeading_KT.font = UIFont.boldSystemFont(ofSize: 15.0)
        self.lblHeading_Mizdah.font = UIFont.boldSystemFont(ofSize: 15.0)
        self.lblHeading_Seezitt.font = UIFont.boldSystemFont(ofSize: 15.0)
        self.lblHeading_Werfiee.font = UIFont.boldSystemFont(ofSize: 15.0)
        
        
        self.lblHeading_KT_Des.font = UIFont.systemFont(ofSize: 13.0)
        self.lblHeading_Mizdah_Des.font = UIFont.systemFont(ofSize: 13.0)
        self.lblHeading_Seezitt_Des.font = UIFont.systemFont(ofSize: 13.0)
        self.lblHeading_Werfiee_Des.font = UIFont.systemFont(ofSize: 13.0)
        
//        self.lblHeading.dynamicHeading(sizeFont: 18.0)
//        
//        self.lblHeading_KT.dynamicHeading(sizeFont: 12.0)
//        self.lblHeading_KT_Des.dynamicBody(sizeFont: 12.0)
//        
//        self.lblHeading_Mizdah.dynamicHeading(sizeFont: 12.0)
//        self.lblHeading_Mizdah_Des.dynamicBody(sizeFont: 12.0)
//        
//        self.lblHeading_Seezitt.dynamicHeading(sizeFont: 12.0)
//        self.lblHeading_Seezitt_Des.dynamicBody(sizeFont: 12.0)
//        
//        self.lblHeading_Werfiee.dynamicHeading(sizeFont: 12.0)
//        self.lblHeading_Werfiee_Des.dynamicBody(sizeFont: 12.0)
        
        
    }
    
    @IBAction func seezittAction(sender : UIButton){
        
        
        SharedClass.shared.openXApp(senderType: .Seezitt)
    }
    
    @IBAction func kalamTimeAction(sender : UIButton){
        SharedClass.shared.openXApp(senderType: .Kalamtime)
    }
    
    @IBAction func mizdahAction(sender : UIButton){
        SharedClass.shared.openXApp(senderType: .Mizdah)
    }
    
    @IBAction func closeAction(sender : UIButton){
        self.dismissVC {
            
        }
        
    }
    
    @IBAction func werfieAction(sender : UIButton){
        SharedClass.shared.openXApp(senderType: .Werfie)
    }
    
    
   
    
}
