//
//  ChatThemeColourVC.swift
//  WorldNoor
//
//  Created by Waseem Shah on 22/11/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class ChatThemeColourVC : UIViewController {

    @IBOutlet var themeCollectionView : UICollectionView!
    var delegateTheme : ChatThemeDelegate!
    
    var arrayTheme = [ChatThemeModel]()
    var selectedValue : Int = -1
    var chatConversationObj:Chat?
    var colourObj : ChatThemeModel!

    override func viewDidLoad() {
        self.themeCollectionView.register(UINib.init(nibName: "ThemeCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ThemeCollectionCell")
    }

    override func viewDidAppear(_ animated: Bool) {
        self.arrayTheme.removeAll()
        self.getAllThemes()
    }

    @IBAction func cancelAction(sender : UIButton){
        self.view.removeFromSuperview()
    }
    
    
    @IBAction func doneAction(sender : UIButton){
        
        apiCall()
    }
    
    func getAllThemes(){
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let userToken = SharedManager.shared.userToken()
        let parameters = ["action": "conversation/chatThemes", "token":userToken, "serviceType":"Node"]
        
        RequestManager.fetchDataGet(Completion: { response in

//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)                
            case .success(let res):
                LogClass.debugLog("res ===>")
                LogClass.debugLog(res)
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: res as? String ?? .emptyString)
                } else if let newRes = res as? [[String:Any]] {
                    for indexObj in newRes {
                        self.arrayTheme.append(ChatThemeModel.init(fromDictionary: indexObj))
                    }
                }
                
                self.themeCollectionView.reloadData()
            }
        }, param:parameters)
    }
    
    func apiCall() {
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        
        let userToken = SharedManager.shared.userToken()
        let parameters = ["action": "conversation/updateTheme", "token": userToken, "serviceType":"Node"  , "conversationId" : self.chatConversationObj!.conversation_id , "colorId" : self.colourObj.color_id]
        
        RequestManager.fetchDataPost(Completion: { response in

//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)                
            case .success(let res):
                LogClass.debugLog(res)
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: res as? String ?? .emptyString)
                } else {

                    SharedManager.shared.colourBG = UIColor.init().hexStringToUIColor(hex: self.colourObj.color_code.replacingOccurrences(of: "#", with: ""))
                    
                    self.delegateTheme.chooseOption(chatOption: self.colourObj.color_code.replacingOccurrences(of: "#", with: ""))
                    self.view.removeFromSuperview()
                }
            }
        }, param:parameters)
    }
}

extension ChatThemeColourVC : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize.init(width:40, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayTheme.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let celltheme = collectionView.dequeueReusableCell(withReuseIdentifier:"ThemeCollectionCell", for: indexPath) as! ThemeCollectionCell
        
        celltheme.lblName.text = ""
        celltheme.viewColor.backgroundColor = UIColor.init().hexStringToUIColor(hex: self.arrayTheme[indexPath.row].color_code.replacingOccurrences(of: "#", with: ""))

        celltheme.viewSelected.isHidden = true
        if self.selectedValue == indexPath.row {
            celltheme.viewSelected.isHidden = false
        }
        return celltheme
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        self.colourObj = self.arrayTheme[indexPath.row]
        self.selectedValue = indexPath.row
        self.themeCollectionView.reloadData()
    }
}

class ThemeCollectionCell : UICollectionViewCell {
    @IBOutlet var lblName : UILabel!
    @IBOutlet var viewColor : UIView!
    @IBOutlet var viewSelected : UIView!
}

protocol ChatThemeDelegate {
    func chooseOption(chatOption : String)
}
