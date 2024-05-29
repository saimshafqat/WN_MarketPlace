//
//  ReelsFeedBackVC.swift
//  WorldNoor
//
//  Created by Waseem Shah on 19/04/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import Cosmos

class ReelsFeedBackVC : UIViewController {
    
    var REASONS_BLUR = "reasons_blur"
       var REASONS_FROZEN = "reasons_frozen"
       var REASONS_LONG = "reasons_long"
       var REASONS_LAG = "reasons_lag"
       var REASONS_AUDIO = "reasons_audio"
    
    var optionsSubmit = [String]()
    var delegate: DismissReportDetailSheetDelegate?
    
    var feedObj : FeedData!
    @IBOutlet var tblViewRate : UITableView!
    
    @IBOutlet var viewStar : CosmosView!
    var arrayOptions = [FeedBAckOptions]()
    
    override func viewDidLoad() {
        self.tblViewRate.register(UINib.init(nibName: "FeedBackinfoCell", bundle: nil), forCellReuseIdentifier: "FeedBackinfoCell")
        self.tblViewRate.register(UINib.init(nibName: "FeedBackOptionCell", bundle: nil), forCellReuseIdentifier: "FeedBackOptionCell")
        self.tblViewRate.register(UINib.init(nibName: "SUButtonCell", bundle: nil), forCellReuseIdentifier: "SUButtonCell")
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.arrayOptions.removeAll()
        self.arrayOptions.append(FeedBAckOptions.init(id: 0,text:"Tell us more" ,value: 0))
        self.arrayOptions.append(FeedBAckOptions.init(id: 3,text:"Blur or pixelation" ,value: 0))
        self.arrayOptions.append(FeedBAckOptions.init(id: 4,text:"Frozen video" ,value: 0))
        self.arrayOptions.append(FeedBAckOptions.init(id: 5,text:"Video took a long time to start" ,value: 0))
        self.arrayOptions.append(FeedBAckOptions.init(id: 6,text:"Lag or buffering during playback" ,value: 0))
        self.arrayOptions.append(FeedBAckOptions.init(id: 7,text:"Audio problems" ,value: 0))
        self.arrayOptions.append(FeedBAckOptions.init(id: 2,text:"Submit" ,value: 0))

    }
}

extension ReelsFeedBackVC : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.arrayOptions[indexPath.row].id == 0 {
            let cellMain = tableView.dequeueReusableCell(withIdentifier: "FeedBackinfoCell", for: indexPath) as! FeedBackinfoCell
            cellMain.lblMain.text = self.arrayOptions[indexPath.row].text.localized()
            cellMain.lblDescription.text = "What kings of issues did you experience while watching this video?".localized()
            
            
            cellMain.lblMain.textAlignment = .left
            cellMain.lblDescription.textAlignment = .left
            
            if SharedManager.shared.checkLanguageAlignment() {
                cellMain.lblDescription.textAlignment = .right
                cellMain.lblMain.textAlignment = .right
            }
            
            return cellMain
        }else if self.arrayOptions[indexPath.row].id == 2 {
            let cellMain = tableView.dequeueReusableCell(withIdentifier: "SUButtonCell", for: indexPath) as! SUButtonCell
            cellMain.btnMain.addTarget(self, action: #selector(self.submit), for: .touchUpInside)
            
            
            cellMain.lblHeading.text = "Submit".localized()
            return cellMain
        }
        
        
        
        let cellMain = tableView.dequeueReusableCell(withIdentifier: "FeedBackOptionCell", for: indexPath) as! FeedBackOptionCell
        cellMain.lblMain.text = self.arrayOptions[indexPath.row].text.localized()
        cellMain.btnTick.tag = indexPath.row
        cellMain.btnTick.addTarget(self, action: #selector(self.chooseOption), for: .touchUpInside)
        return cellMain
    }
    
    
    @objc func submit(sender : UIButton){
        //        var newparam = [String : ]
        
        //        parameters["hash_tag_name"] = (self.parentView as? TagsVC)?.Hashtags
        
        //        parameters["page"] = String(self.pageNumber)
        
//
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        var parameters = [
            "action": "reel-feedback",
            "token": SharedManager.shared.userToken() ,
            "rating" : String(self.viewStar.rating) ,
            "post_files_id" : String(self.feedObj.postID!)
        ]
        
        var indexInner = 0
        for indexObj in self.optionsSubmit {
            parameters["reasons[" + String(indexInner) + "]"] = indexObj
            indexInner = indexInner + 1
        }
        

        RequestManager.fetchDataPost(Completion: { (response) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):

                if let newRes = res as? String {
                    self.delegate?.dismissReport(message: newRes)
                }
                
            }
        }, param: parameters)
        
    }
 
    
    @objc func chooseOption(sender : UIButton){
        if let cellMain = self.tblViewRate.cellForRow(at: IndexPath.init(row: sender.tag, section: 0)) as? FeedBackOptionCell {

            
            if cellMain.imgViewTick.isHidden {
                switch self.arrayOptions[sender.tag].id {
                case 3:
                    self.optionsSubmit.append(REASONS_BLUR)
                case 4:
                    self.optionsSubmit.append(REASONS_FROZEN)
                case 5:
                    self.optionsSubmit.append(REASONS_LONG)
                case 6:
                    self.optionsSubmit.append(REASONS_LAG)
                default:
                    self.optionsSubmit.append(REASONS_AUDIO)
                }
            }else {
                switch self.arrayOptions[sender.tag].id {
                case 3:
                    
                    self.optionsSubmit.remove(at:self.optionsSubmit.firstIndex(of: REASONS_BLUR)!)
//                    self.optionsSubmit.append(REASONS_BLUR)
                case 4:
//                    self.optionsSubmit.append(REASONS_FROZEN)
                    self.optionsSubmit.remove(at:self.optionsSubmit.firstIndex(of: REASONS_FROZEN)!)
                case 5:
//                    self.optionsSubmit.append(REASONS_LONG)
                    self.optionsSubmit.remove(at:self.optionsSubmit.firstIndex(of: REASONS_LONG)!)
                case 6:
//                    self.optionsSubmit.append(REASONS_LAG)
                    self.optionsSubmit.remove(at:self.optionsSubmit.firstIndex(of: REASONS_LAG)!)
                default:
//                    self.optionsSubmit.append(REASONS_AUDIO)
                    self.optionsSubmit.remove(at:self.optionsSubmit.firstIndex(of: REASONS_AUDIO)!)
                }
            }
            cellMain.imgViewTick.isHidden = !cellMain.imgViewTick.isHidden
        }
    }
}


struct FeedBAckOptions {
    var id : Int!
    var text : String!
    var value : Int!
}
