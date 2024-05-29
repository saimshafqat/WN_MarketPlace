//
//  PostHeaderInfoViewViewModel.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 12/05/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit
import Combine
import Alamofire

class PostHeaderInfoViewViewModel {
    
    private var subscription: Set<AnyCancellable> = []
    private var apiService: APIService?
    var sendLanguageModel = PassthroughSubject<LanguageTranslateModel?, Never>()
    
    init(apiService: APIService? = APITarget()) {
        self.apiService = apiService
        showError()
    }
    
    func showError() {
        Loader.stopLoading()
        (apiService as? APITarget)?.errorMessagePublisher
            .receive(on: DispatchQueue.main)
            .sink { message in
                SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: message)
            }.store(in: &subscription)
    }
    
    func getInfoText(_ obj: FeedData?) -> String? {
        return (obj?.isTranslation ?? false) ? obj?.orignalBody : obj?.body
    }
    
    func setTextDirection(_ text: String?) -> NSTextAlignment{
        let langDirection = SharedManager.shared.detectedLangauge(for: text ?? .emptyString)
        var alignment: NSTextAlignment = .left
        if langDirection == Const.right {
            alignment = .right
        }
        return alignment
    }
    
    func setFontStyle(at obj: FeedData?) -> UIFont? {
        guard let strValue = UserDefaultsUtility.get(with: .Lang) as? String else { return nil }
        
        let langCode = SharedManager.shared.getLanguageIDForTop(languageP: strValue)
        return fontDecision(langCode)
    }
    
    func setFontStyleForText(_ str: String) -> UIFont? {
        guard let langCode = SharedManager.shared.detectedLangaugeCode(for: str) else { return nil }
        return fontDecision(langCode)
    }
    
    func fontDecision(_ str: String) -> UIFont? {
        switch str {
        case "ar":
            return UIFont(name: "BahijTheSansArabicPlain", size: 13)
        case "ur":
            return UIFont(name: "Jameel-Noori-Nastaleeq", size: 15)
        default:
            return UIFont(name: "HelveticaNeue-Regular", size: 16.0)
        }
    }
    
    func setRequestBtnLayout(_ frienRequestButton: LoaderButton?, addFriendImg: UIImageView?, _ title: String = .emptyString, _ bgColor: UIColor = .clear, isHide: Bool = true) {
        frienRequestButton?.isHidden = isHide
        addFriendImg?.isHidden = isHide
    }
    
    func setfriendRequest(_ parentPostObj: FeedData?, _ postObj: FeedData?, _ frienRequestButton: LoaderButton?, addFriendImg: UIImageView?) {
        let authorID = parentPostObj?.postType != FeedType.shared.rawValue ? String(postObj?.authorID ?? 0) : (String(parentPostObj?.sharedData?.authorID ?? 0))
        let params: [String: String] = [
            "user_id" : authorID
        ]
        sendFriendRequest(.sendFriendRequest(params), addFriendImg: addFriendImg, frienRequestButton, postObj: parentPostObj)
    }
    
    // MARK: - Service -
    func getTranslation(_ postObj: FeedData?) {
        var langCode = "en"
        if let strValue = UserDefaults.standard.value(forKey: "LangN") as? String {
            for indexObj in SharedManager.shared.populateLangData() {
                if indexObj.languageName == UserDefaults.standard.value(forKey: "LangN") as! String {
                    langCode = indexObj.languageCode
                    break
                }
            }
        } else {
            if let langID = SharedManager.shared.userBasicInfo["language_id"] as? Int   {
                for indexObj in SharedManager.shared.populateLangData() {
                    if Int(indexObj.languageID) == langID {
                        langCode = indexObj.languageCode
                        UserDefaults.standard.set(indexObj.languageName, forKey: "LangN")
                        UserDefaults.standard.synchronize()
                        break
                    }
                }
            }
        }
        let parameters: [String: String] = ["lang_code": langCode]
        apiService?.getTranslation(endPoint: APIEndPoints.getTranslationText(parameters, postObj?.postID ?? 0))
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    LogClass.debugLog("Successfully fetched Saved Feed")
                case .failure(_):
                    LogClass.debugLog("Unable to Saved Feed.")
                    self.sendLanguageModel.send(nil)
                }
            }, receiveValue: { languageModel in
                self.sendLanguageModel.send(languageModel)
            })
            .store(in: &subscription)
    }
    
    func sendFriendRequest(_ endPoint: APIEndPoints, addFriendImg: UIImageView?,_ frienRequestButton: LoaderButton?, postObj: FeedData?) {
        frienRequestButton?.startLoading(color: .darkGray)
        addFriendImg?.isHidden = true
        apiService?.sendFriendReuqest(endPoint: endPoint)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(_):
                    frienRequestButton?.stopLoading()
                    addFriendImg?.isHidden = false
                }
            }, receiveValue: { request in
                SwiftMessages.showMessagePopup(theme: .success, title: "Congratulations", body: request.meta.message ?? .emptyString)
                frienRequestButton?.stopLoading()
                self.setRequestBtnLayout(frienRequestButton, addFriendImg: addFriendImg, Const.cancelFriendRequest, .red, isHide: true)
                postObj?.isAuthorFriendOfViewer = Const.pending
            })
            .store(in: &subscription)
    }
    
    func cancelFriendRequest(_ endPoint: APIEndPoints, _ frienRequestButton: LoaderButton?, addFriendImg: UIImageView?, postObj: FeedData?) {
        Loader.startLoading()
        apiService?.cancelFriendReuqest(endPoint: endPoint)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(_):
                    Loader.stopLoading()
                }
            }, receiveValue: { request in
                Loader.stopLoading()
                self.setRequestBtnLayout(frienRequestButton, addFriendImg: addFriendImg, Const.addFriendRequest, UIColor().hexStringToUIColor(hex: "0E5DCC"), isHide: false)
                postObj?.isAuthorFriendOfViewer = Const.friendNotExist
            })
            .store(in: &subscription)
    }
}


