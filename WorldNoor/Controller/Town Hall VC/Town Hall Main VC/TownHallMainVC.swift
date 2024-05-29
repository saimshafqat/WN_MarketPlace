//
//  TownHallMainVC.swift
//  WorldNoor
//
//  Created by apple on 1/24/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import SwiftDate
import MessageUI

class TownHallMainVC: UIViewController, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    @IBOutlet var tbleViewTownHall : UITableView!
    var arrayTownHall = [TownhallModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Town Hall".localized()
        tbleViewTownHall.registerCustomCells([
            "TownHallCell",
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getAllTownHall()
    }
    
    func getAllTownHall(){
        if self.arrayTownHall.count > 0 {
            self.tbleViewTownHall.reloadData()
            return
        }
        let userToken = SharedManager.shared.userToken()
        let parameters = ["action": "town_hall","token": userToken]
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataGet(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is [[String : Any]] {
                    let array = res as! [[String : Any]]
                    for indexObj in array {
                        self.arrayTownHall.append(TownhallModel.init(fromDictionary: indexObj))
                    }
                }
                self.tbleViewTownHall.reloadData()
            }
        }, param:parameters)
    }
}

extension TownHallMainVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayTownHall.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cellTownHall = tableView.dequeueReusableCell(withIdentifier: "TownHallCell", for: indexPath) as! TownHallCell
        
        guard let cellTownHall = tableView.dequeueReusableCell(withIdentifier: "TownHallCell", for: indexPath) as? TownHallCell else {
                  return UITableViewCell()
               }
        
        cellTownHall.lblInfo.text = self.arrayTownHall[indexPath.row].page_description
        cellTownHall.lblLike.text = "Likes:".localized() + " " + self.arrayTownHall[indexPath.row].page_like_count
        cellTownHall.lblComments.text = "Comments:".localized() + " " + self.arrayTownHall[indexPath.row].page_follower_counts
        cellTownHall.lblName.text = self.arrayTownHall[indexPath.row].page_title
        cellTownHall.lblaboutheading.text = "About " + self.arrayTownHall[indexPath.row].page_title
        cellTownHall.lblTitle.text = self.arrayTownHall[indexPath.row].designation
        cellTownHall.lblPhotos.text = "0 " + "Photos".localized()
        cellTownHall.lblVideos.text = "0 " + "Videos".localized()
        cellTownHall.lblReviews.text = "0 " + "reviews".localized()
        cellTownHall.lblElected.text = self.arrayTownHall[indexPath.row].elected_in.toDate()!.toFormat("dd EEE YYYY")
        
        let urlMain = self.arrayTownHall[indexPath.row].page_cover_image
//        cellTownHall.imgViewcover.sd_setImage(with: URL(string:(urlMain)), placeholderImage: UIImage(named: "placeholder.png"))
        
        
        cellTownHall.imgViewcover.loadImageWithPH(urlMain:urlMain)
        
        
        self.view.labelRotateCell(viewMain: cellTownHall.imgViewcover)
        let urlMainProfile = self.arrayTownHall[indexPath.row].page_profile_image
//        cellTownHall.imgViewProfile.sd_setImage(with: URL(string:(urlMainProfile)), placeholderImage: UIImage(named: "placeholder.png"))
        
        cellTownHall.imgViewProfile.loadImageWithPH(urlMain:urlMainProfile)
        
        self.view.labelRotateCell(viewMain: cellTownHall.imgViewProfile)
        cellTownHall.btnCall.tag = indexPath.row
        cellTownHall.btnEmail.tag = indexPath.row
        cellTownHall.btnMessage.tag = indexPath.row
        cellTownHall.btnCall.addTarget(self, action: #selector(self.CallAction), for: .touchUpInside)
        cellTownHall.btnEmail.addTarget(self, action: #selector(self.EmailAction), for: .touchUpInside)
        cellTownHall.btnMessage.addTarget(self, action: #selector(self.MessageAction), for: .touchUpInside)
        cellTownHall.selectionStyle = .none
        return cellTownHall
    }
    
    @objc func CallAction(sender : UIButton){
        if self.arrayTownHall[sender.tag].phone.count > 0 {
            self.DialNumber(PhoneNumber: self.arrayTownHall[sender.tag].phone)
        }else {
            SharedManager.shared.showAlert(message: "Phone number not available".localized(), view: self)
        }
    }
    
    @objc func MessageAction(sender : UIButton){
           if self.arrayTownHall[sender.tag].phone.count > 0 {
               if (MFMessageComposeViewController.canSendText()) {
                   let controller = MFMessageComposeViewController()
                   controller.body = "Message Body".localized()
                   controller.recipients = [self.arrayTownHall[sender.tag].phone]
                   controller.messageComposeDelegate = self
                self.present(controller, animated: true, completion: nil)
               }
           }else {
               SharedManager.shared.showAlert(message: "Phone number not availabe".localized(), view: self)
           }
       }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func EmailAction(sender : UIButton){
          if self.arrayTownHall[sender.tag].email.count > 0 {
            let mc: MFMailComposeViewController = MFMailComposeViewController()
              mc.mailComposeDelegate = self
              mc.setSubject(self.arrayTownHall[sender.tag].designation)
//            mc.setMessageBody(messageBody, isHTML: false)
              mc.setToRecipients([self.arrayTownHall[sender.tag].email])
             self.present(mc, animated: true, completion: nil)
          }else {
              SharedManager.shared.showAlert(message: "Email not available".localized(), view: self)
          }
      }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}

class TownHallCell : UITableViewCell {
    @IBOutlet var lblTitle : UILabel!
    @IBOutlet var lblLike : UILabel!
    @IBOutlet var lblComments : UILabel!
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblElected : UILabel!
    @IBOutlet var lblPhotos : UILabel!
    @IBOutlet var lblVideos : UILabel!
    @IBOutlet var lblReviews : UILabel!
    @IBOutlet var lblInfo : UILabel!
    @IBOutlet var lblaboutheading : UILabel!
    @IBOutlet var imgViewProfile : UIImageView!
    @IBOutlet var imgViewcover : UIImageView!
    @IBOutlet var btnCall : UIButton!
    @IBOutlet var btnMessage : UIButton!
    @IBOutlet var btnEmail : UIButton!
}
