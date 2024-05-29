//
//  ViewControllerExtension.swift
//  WorldNoor
//
//  Created by apple on 1/24/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import Photos
import Alamofire
//import RSLoadingView
//import RSLoadingContainerView
import Hero

extension UINavigationController {
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
            popToViewController(vc, animated: animated)
        }
    }
}

extension UIViewController {
    
    
    var topbarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        } else {
            let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
            return topBarHeight
        }
    }
    var statusbarheight: CGFloat {
        if #available(iOS 13.0, *) {
            return view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0
        } else {
            let topBarHeight = UIApplication.shared.statusBarFrame.size.height
            return topBarHeight
        }
    }
    var navbarheight: CGFloat {
        if #available(iOS 13.0, *) {
            return self.navigationController?.navigationBar.frame.height ?? 0.0
        } else {
            let topBarHeight = self.navigationController?.navigationBar.frame.height ?? 0.0
            return topBarHeight
        }
    }
}

extension UIViewController {
    
    public func presentFullVC(_ vc: UIViewController) {
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
    
    public func presentVC(_ vc: UIViewController) {
        present(vc, animated: true, completion: nil)
    }
    
    public func presentVC(_ vc: UIViewController, completion: (() -> Swift.Void)?) {
        present(vc, animated: true, completion: completion)
    }
    
    public func dismissVC(completion: (() -> Void)? ) {
        dismiss(animated: true, completion: completion)
    }
    
    public func addAsChildViewController(_ vc: UIViewController, toView: UIView) {
        self.addChild(vc)
        toView.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
    
    public func pushFromBottom(_ vc: UIViewController) {
        let navigationController = self.navigationController
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.moveIn
        transition.subtype = CATransitionSubtype.fromTop
        navigationController?.view.layer.add(transition, forKey: nil)
        navigationController?.pushViewController(vc, animated: false)
    }
    
    @objc open func hideFromBottom() {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        navigationController?.view.layer.add(transition, forKey: nil)
        _ = navigationController?.popViewController(animated: false)
    }
    
    func pushVC(_ vc: UIViewController, animated: Bool = true) {
        navigationController?.pushViewController(vc, animated: animated)
    }
    
    func popVC(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
    }
    
}

extension UIViewController {
    
    func clearAllFile() {
        let fileManager = FileManager.default
        let myDocuments = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            try fileManager.removeItem(at: myDocuments)
        } catch {
            return
        }
    }
    
    func sharedata(dataMain: Any, orignalFile: String? = nil, feedObj: FeedData) {
        guard let dataStr = dataMain as? String, !dataStr.isEmpty else {
            return
        }
        let videoURL = URL(fileURLWithPath: dataStr)
        let textMain = feedObj.body
        let itemsToShare: [Any] = [videoURL, textMain ?? .emptyString]
        
        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.completionWithItemsHandler = { activityType, completed, _, _ in
            if completed && activityType == .copyToPasteboard {
                if dataStr.hasSuffix(".mp4") || dataStr.hasSuffix(".mov") {
                    UIPasteboard.general.string = orignalFile ?? .emptyString
                }
            }
        }
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func getURLForImage(filename:String) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        return fileURL
    }
    
    func GetViewcontrollerWithName(nameViewController : String) -> UIViewController {
        let viewObj = (self.storyboard?.instantiateViewController(withIdentifier: nameViewController))! as UIViewController
        return viewObj
    }
    
    func PushViewWithStoryBoard(name : String , StoryBoard : String ) {
        let viewController = self.GetView(nameVC: name, nameSB: StoryBoard)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func DialNumber(PhoneNumber : String){
        if let url = URL(string: "tel://\(PhoneNumber)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    
    func OpenLink(webUrl:String){
        
        var urlAdded = webUrl
        let fullWebSite = urlAdded.components(separatedBy: ".")
        
        if fullWebSite.count > 0 {
            
            if fullWebSite.first!.lowercased().contains("https") || fullWebSite.first!.lowercased().contains("http"){
                
            }else if fullWebSite.first!.lowercased().contains("www"){
                urlAdded = "https://" + urlAdded
            }else {
                urlAdded = "https://www." + urlAdded
            }
        }
        
        if let url = URL(string: urlAdded) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
    }
    
    
    func OpenKalamTimeLink(webUrl:String){
        
        LogClass.debugLog("webUrl ====>")
        LogClass.debugLog(webUrl)
        if webUrl.count > 0 {
            let textMain  = webUrl
            let imageToShare = [ textMain] as [Any]
            let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that
            activityViewController.completionWithItemsHandler = { activityType, completed, returnItems, activityError in
                // check if the content has copied
                if completed && activityType == .copyToPasteboard {

                    let paste = UIPasteboard.general
                    paste.string = webUrl ?? .emptyString
                }
            }
            self.present(activityViewController, animated: true, completion: nil)
        }
        
    }
    
    func GetView(nameVC : String , nameSB : String) -> UIViewController {
        let storyboard = UIStoryboard(name: nameSB, bundle: nil)
        let viewObj = (storyboard.instantiateViewController(withIdentifier: nameVC)) as UIViewController
        return viewObj
    }
        
    func updateLocation(latMain : String , longMain : String){
        var parameters = [
            "action": "user/store-location",
            "token": SharedManager.shared.userToken(),
            "lat": latMain,
            "long": longMain
        ]
        
        RequestManager.fetchDataPost(Completion: { (response) in
            switch response {
            case .failure(let error):
                LogClass.debugLog(error)
            case .success(let res):
                LogClass.debugLog("Success ==>")
            }
        }, param: parameters)
    }
}


extension UserDefaults {
    func object<T: Codable>(_ type: T.Type, with key: String, usingDecoder decoder: JSONDecoder = JSONDecoder()) -> T? {
        guard let data = self.value(forKey: key) as? Data else { return nil }
        return try? decoder.decode(type.self, from: data)
    }
    
    func set<T: Codable>(object: T, forKey key: String, usingEncoder encoder: JSONEncoder = JSONEncoder()) {
        let data = try? encoder.encode(object)
        self.set(data, forKey: key)
    }
    
    
    
}


extension UIViewController {
    
    func setFileName(_ obj: FeedData) -> String {
        var authorName = obj.authorName?.replacingOccurrences(of: " ", with: "_") ?? .emptyString
        let feedPostId = String(obj.postID ?? 0)
        let fileName = authorName + "_" + feedPostId
        return fileName
    }
    
    func downloadFile(filePath : String , isImage : Bool ,isShare : Bool , FeedObj : FeedData, dismissCompletion: (()-> Void)? = nil) {
//        self.downloadFileShare(filePath: filePath, isImage: isImage, isShare: isShare, FeedObj: FeedObj) {
//            return
//        }
        SharedClass.shared.clearAllFiles()
        
        
        var isAbleToSave : Bool = false
        if #available(iOS 14, *) {
            switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
            case .notDetermined:
                // ask for access
                isAbleToSave = false
            case .restricted, .denied:
                // sorry
                isAbleToSave = false
            case .authorized:
                // we have full access
                isAbleToSave = true
                // new option:
            case .limited:
                isAbleToSave = false
                // we only got access to some photos of library
            default:
                isAbleToSave = false
            }
        } else {
            isAbleToSave = true
        }
        if !isAbleToSave {
            let alert = UIAlertController(title: "Go to Settings?".localized(), message: "Open setting to change permission?".localized(), preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Cancel".localized(), style: .destructive) {(_) -> Void in
                LogClass.debugLog("Pressed Setting alert Cancel")
                dismissCompletion?()
            }
            alert.addAction(okAction)
            
            let settingsAction = UIAlertAction(title: "Open".localized(), style: .default) { (_) -> Void in
                
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        if success {
                            LogClass.debugLog("Pressed Setting Open Cancel")
                        }
                    })
                }
            }
            alert.addAction(settingsAction)
            
            self.present(alert, animated: true)
            return
        }
        
        FileBasedManager.shared.iscancelReuest = false
        if isImage {
            let strPath = filePath
            let strPAthArray = strPath.components(separatedBy: "/")
            let strPAthArrayExt = strPath.components(separatedBy: ".")
            
            LogClass.debugLog("strPAthArrayExt")
            LogClass.debugLog(strPAthArrayExt)
            if FileBasedManager.shared.fileExist(nameFile: strPAthArray.last!).1 {
                LogClass.debugLog("strPAthArray.last !  ===>")
                LogClass.debugLog(strPAthArray.last!)
                let image = FileBasedManager.shared.loadImage(pathMain: strPAthArray.last!)
                if isShare {
                    self.sharedata(dataMain: FileBasedManager.shared.fileExist(nameFile: strPAthArray.last!).0, orignalFile: filePath , feedObj: FeedObj)
                }else {
                    DispatchQueue.main.async() {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        let alert = UIAlertController(title: "Saved".localized(), message: "Your image has been saved".localized(), preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok".localized(), style: .default) { (_) -> Void in
                            dismissCompletion?()
                        }
                        alert.addAction(okAction)
                        self.present(alert, animated: true)
                    }
                }
            }else {
                DispatchQueue.main.async() {
                    Loader.startLoading()
                    let btnProgress = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
                    btnProgress.addTarget(self, action: #selector(self.cancelrequest), for: .touchUpInside)
                    btnProgress.backgroundColor = UIColor.clear
                    btnProgress.setTitle("", for: .normal)
                    let lblProgress = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 30))
                    lblProgress.center = self.view.center
                    lblProgress.backgroundColor = UIColor.clear
                    lblProgress.textColor = UIColor.white
                    lblProgress.text = "0.00 %"
                    lblProgress.tag = -9090
                    lblProgress.textAlignment = .center
                    self.view.addSubview(lblProgress)
                    self.view.addSubview(btnProgress)
                    let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
                    Alamofire.download(
                        URL.init(string: filePath)!,
                        method: .get,
                        parameters: nil,
                        encoding: JSONEncoding.default,
                        headers: nil,
                        to: destination).downloadProgress(closure: { (progress) in
                            lblProgress.text =  String(progress.fractionCompleted * 100).addDecimalPoints() + " %"
                            
                            
                        }).response(completionHandler: { (DefaultDownloadResponse) in
                            
                            //                            SharedManager.shared.hideLoadingHubFromKeyWindow()
                            Loader.stopLoading()
                            
                            LogClass.debugLog("FeedObj.postType!")
                            LogClass.debugLog(FeedObj.postType!)
                            
                            if FeedObj.postType!.count == 0 {
                                if isImage {
                                    FeedObj.postType! = "Image"
                                }else {
                                    FeedObj.postType! = "video"
                                }
                            }
                            
                            if DefaultDownloadResponse.destinationURL != nil {
                                let dataMain = try?  Data.init(contentsOf: DefaultDownloadResponse.destinationURL!)
                                
                                self.changeFileName(oldName: strPAthArray.last!, newName: FeedObj.postType! + "." + strPAthArrayExt.last!)
                                let fileName = FeedObj.postType! + "." + strPAthArrayExt.last!
                                
                                let image = UIImage(data: dataMain!)
                                
                                
                                lblProgress.removeFromSuperview()
                                btnProgress.removeFromSuperview()
                                
                                if isShare {
                                    self.sharedata(dataMain: FileBasedManager.shared.fileExist(nameFile: fileName).0, orignalFile: filePath , feedObj: FeedObj)
                                }else {
                                    DispatchQueue.main.async() {
                                        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
                                        let alert = UIAlertController(title: "Saved".localized(), message: "Your image has been saved".localized(), preferredStyle: .alert)
                                        let okAction = UIAlertAction(title: "Ok".localized(), style: .default) { (_) -> Void in
                                            dismissCompletion?()
                                        }
                                        alert.addAction(okAction)
                                        self.present(alert, animated: true)
                                    }
                                    
                                }
                            } else {
                                lblProgress.removeFromSuperview()
                                btnProgress.removeFromSuperview()
                            }
                            
                        })
                }
            }
        } else {
            if true {
                let strPath = filePath
                let strPAthArray = strPath.components(separatedBy: "/")
                let strPAthArrayExt = strPath.components(separatedBy: ".")
                if FileBasedManager.shared.fileExist(nameFile: strPAthArray.last!).1 {
                    if isShare {
                        self.sharedata(dataMain: FileBasedManager.shared.fileExist(nameFile: strPAthArray.last!).0, orignalFile: filePath , feedObj: FeedObj)
                    }else {
                        DispatchQueue.main.async() {
                            PHPhotoLibrary.shared().performChanges({
                                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath:FileBasedManager.shared.fileExist(nameFile: strPAthArray.last!).0))
                            }) { completed, error in
                                //                                SharedManager.shared.hideLoadingHubFromKeyWindow()
                                Loader.stopLoading()
                                if completed {
                                    DispatchQueue.main.async() {
                                        let alert = UIAlertController(title: "Saved".localized(), message: "Your video has been saved".localized(), preferredStyle: .alert)
                                        let okAction = UIAlertAction(title: "Ok".localized(), style: .default) { (_) -> Void in
                                            dismissCompletion?()
                                        }
                                        alert.addAction(okAction)
                                        self.present(alert, animated: true)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async() {
                        Loader.startLoading()
                        let lblProgress = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 30))
                        lblProgress.center = self.view.center
                        lblProgress.backgroundColor = UIColor.clear
                        lblProgress.textColor = UIColor.white
                        lblProgress.text = "0.00 %"
                        lblProgress.textAlignment = .center
                        lblProgress.tag = -9090
                        let btnProgress = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
                        btnProgress.addTarget(self, action: #selector(self.cancelrequest), for: .touchUpInside)
                        btnProgress.backgroundColor = UIColor.clear
                        btnProgress.setTitle("", for: .normal)
                        self.view.addSubview(lblProgress)
                        self.view.addSubview(btnProgress)
                        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
                        Alamofire.download(
                            URL.init(string: filePath)!,
                            method: .get,
                            parameters: nil,
                            encoding: JSONEncoding.default,
                            headers: nil,
                            to: destination).downloadProgress(closure: { (progress) in
                                lblProgress.text =  String(progress.fractionCompleted * 100).addDecimalPoints() + " %"
                            }).response(completionHandler: { (DefaultDownloadResponse) in
                                lblProgress.removeFromSuperview()
                                btnProgress.removeFromSuperview()
                                //                                SharedManager.shared.hideLoadingHubFromKeyWindow()
                                Loader.stopLoading()
                                
                                
                                if FeedObj.postType!.count == 0 {
                                    if isImage {
                                        FeedObj.postType! = "Image"
                                    }else {
                                        FeedObj.postType! = "video"
                                    }
                                }
                                
                                
                                self.changeFileName(oldName: strPAthArray.last!, newName: FeedObj.postType! + "." + strPAthArrayExt.last!)
                                let fileName = FeedObj.postType! + "." + strPAthArrayExt.last!
                                
                                
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                                    if isShare {
                                        self.sharedata(dataMain: FileBasedManager.shared.fileExist(nameFile: fileName).0, orignalFile: filePath , feedObj: FeedObj)
                                    }else {
                                        
                                        PHPhotoLibrary.shared().performChanges({
                                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath:FileBasedManager.shared.fileExist(nameFile: strPAthArray.last!).0))
                                        }) { completed, error in
                                            if completed {
                                                DispatchQueue.main.async() {
                                                    
                                                    let alert = UIAlertController(title: "Saved".localized(), message: "Your video has been saved".localized(), preferredStyle: .alert)
                                                    let okAction = UIAlertAction(title: "Ok".localized(), style: .default) { (_) -> Void in
                                                        dismissCompletion?()
                                                    }
                                                    alert.addAction(okAction)
                                                    self.present(alert, animated: true)
                                                }
                                            } else {
                                                if !FileBasedManager.shared.iscancelReuest {
                                                    DispatchQueue.main.async() {
                                                        let alert = UIAlertController(title: "Try again".localized(), message: "It appears that you are not connected with internet. Please check your internet connection and try again.".localized(), preferredStyle: .alert)
                                                        let okAction = UIAlertAction(title: "Ok".localized(), style: .default) { (_) -> Void in
                                                            dismissCompletion?()
                                                        }
                                                        alert.addAction(okAction)
                                                        self.present(alert, animated: true)
                                                    }
                                                }
                                                
                                            }
                                        }
                                    }
                                    
                                }
                            })
                    }
                }
            }
        }
    }
    
    
    
    
    func isReadWriteAuthorized() -> Bool {
        if #available(iOS 14, *) {
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            return (status == .authorized)
        } else {
            return true
        }
    }
    
    func showSettingsAlert(_ dismissCompletion: (() -> Void)?) {
        let alertTitle = "Go to Settings?".localized()
        let alertMessage = "Open setting to change permission?".localized()
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .destructive) { (_) -> Void in
            LogClass.debugLog("Pressed Setting alert Cancel")
            dismissCompletion?()
        }
        alert.addAction(cancelAction)
        let openAction = UIAlertAction(title: "Open".localized(), style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl) else { return }
            UIApplication.shared.open(settingsUrl) { success in
                if success {
                    LogClass.debugLog("Pressed Setting Open Cancel")
                }
            }
        }
        alert.addAction(openAction)
        self.present(alert, animated: true)
    }
    
    
    
    func downloadFileShare(filePath : String , isImage : Bool ,isShare : Bool , FeedObj : FeedData, dismissCompletion: (()-> Void)? = nil) {
        
        SharedClass.shared.clearAllFiles()
        
        let fileName = setFileName(FeedObj)
        LogClass.debugLog(fileName)
        
        let isAbleToSave = isReadWriteAuthorized()
        if !isAbleToSave {
            showSettingsAlert(dismissCompletion)
            return
        }
        
        FileBasedManager.shared.iscancelReuest = false
        if isImage {
            let strPath = filePath
            let strPAthArray = strPath.components(separatedBy: "/")
            let fileURLPath = strPAthArray.last?.components(separatedBy: ".")
            
            let strPAthArrayExt = strPath.components(separatedBy: ".")
            
            var fileURLPathName = fileURLPath?.first ?? .emptyString
            let fileURLPathExtension = fileURLPath?.last ?? .emptyString
            fileURLPathName = fileName + "." + fileURLPathExtension
            
            if FileBasedManager.shared.fileExist(nameFile: fileURLPathName).1 {
                let image = FileBasedManager.shared.loadImage(pathMain: strPAthArray.last!)
                if isShare {
                    self.sharedata(dataMain: FileBasedManager.shared.fileExist(nameFile: fileURLPathName).0, orignalFile: filePath , feedObj: FeedObj)
                } else {
                    DispatchQueue.main.async() {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        let alert = UIAlertController(title: "Saved".localized(), message: "Your image has been saved".localized(), preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok".localized(), style: .default) { (_) -> Void in
                            dismissCompletion?()
                        }
                        alert.addAction(okAction)
                        self.present(alert, animated: true)
                    }
                }
            } else {
                DispatchQueue.main.async() {
                    Loader.startLoading()
                    let btnProgress = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
                    btnProgress.addTarget(self, action: #selector(self.cancelrequest), for: .touchUpInside)
                    btnProgress.backgroundColor = UIColor.clear
                    btnProgress.setTitle("", for: .normal)
                    let lblProgress = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 30))
                    lblProgress.center = self.view.center
                    lblProgress.backgroundColor = UIColor.clear
                    lblProgress.textColor = UIColor.white
                    lblProgress.text = "0.00 %"
                    lblProgress.tag = -9090
                    lblProgress.textAlignment = .center
                    self.view.addSubview(lblProgress)
                    self.view.addSubview(btnProgress)
                    let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
                    Alamofire.download(
                        URL.init(string: filePath)!,
                        method: .get,
                        parameters: nil,
                        encoding: JSONEncoding.default,
                        headers: nil,
                        to: destination).downloadProgress(closure: { (progress) in
                            lblProgress.text =  String(progress.fractionCompleted * 100).addDecimalPoints() + " %"
                        }).response(completionHandler: { (DefaultDownloadResponse) in
                            Loader.stopLoading()
                            if DefaultDownloadResponse.destinationURL != nil {
                                let dataMain = try?  Data.init(contentsOf: DefaultDownloadResponse.destinationURL!)
                                let image = UIImage(data: dataMain!)
                                
                                self.changeFileName(oldName: strPAthArray.last!, newName: FeedObj.postType! + "." + strPAthArrayExt.last!)
                                let fileName = FeedObj.postType! + "." + strPAthArrayExt.last!
                                
                                
                                lblProgress.removeFromSuperview()
                                btnProgress.removeFromSuperview()
                                if isShare {
                                    self.sharedata(dataMain: FileBasedManager.shared.fileExist(nameFile: fileName).0, orignalFile: filePath , feedObj: FeedObj)
                                } else {
                                    DispatchQueue.main.async() {
                                        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
                                        let alert = UIAlertController(title: "Saved".localized(), message: "Your image has been saved".localized(), preferredStyle: .alert)
                                        let okAction = UIAlertAction(title: "Ok".localized(), style: .default) { (_) -> Void in
                                            dismissCompletion?()
                                        }
                                        alert.addAction(okAction)
                                        self.present(alert, animated: true)
                                    }
                                }
                            } else {
                                lblProgress.removeFromSuperview()
                                btnProgress.removeFromSuperview()
                            }
                        })
                }
            }
        } else {
            if true {
                let strPath = filePath
                let strPAthArray = strPath.components(separatedBy: "/")
                let strPAthArrayExt = strPath.components(separatedBy: ".")
                if FileBasedManager.shared.fileExist(nameFile: strPAthArray.last!).1 {
                    if isShare {
                        self.sharedata(dataMain: FileBasedManager.shared.fileExist(nameFile: strPAthArray.last!).0, orignalFile: filePath , feedObj: FeedObj)
                    } else {
                        DispatchQueue.main.async() {
                            PHPhotoLibrary.shared().performChanges({
                                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath:FileBasedManager.shared.fileExist(nameFile: strPAthArray.last!).0))
                            }) { completed, error in
                                //                                SharedManager.shared.hideLoadingHubFromKeyWindow()
                                Loader.stopLoading()
                                if completed {
                                    DispatchQueue.main.async() {
                                        let alert = UIAlertController(title: "Saved".localized(), message: "Your video has been saved".localized(), preferredStyle: .alert)
                                        let okAction = UIAlertAction(title: "Ok".localized(), style: .default) { (_) -> Void in
                                            dismissCompletion?()
                                        }
                                        alert.addAction(okAction)
                                        self.present(alert, animated: true)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async() {
                        Loader.startLoading()
                        let lblProgress = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 30))
                        lblProgress.center = self.view.center
                        lblProgress.backgroundColor = UIColor.clear
                        lblProgress.textColor = UIColor.white
                        lblProgress.text = "0.00 %"
                        lblProgress.textAlignment = .center
                        lblProgress.tag = -9090
                        let btnProgress = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
                        btnProgress.addTarget(self, action: #selector(self.cancelrequest), for: .touchUpInside)
                        btnProgress.backgroundColor = UIColor.clear
                        btnProgress.setTitle("", for: .normal)
                        self.view.addSubview(lblProgress)
                        self.view.addSubview(btnProgress)
                        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
                        Alamofire.download(
                            URL.init(string: filePath)!,
                            method: .get,
                            parameters: nil,
                            encoding: JSONEncoding.default,
                            headers: nil,
                            to: destination).downloadProgress(closure: { (progress) in
                                lblProgress.text =  String(progress.fractionCompleted * 100).addDecimalPoints() + " %"
                            }).response(completionHandler: { (DefaultDownloadResponse) in
                                lblProgress.removeFromSuperview()
                                btnProgress.removeFromSuperview()
                                Loader.stopLoading()
                                
                                self.changeFileName(oldName: strPAthArray.last!, newName: FeedObj.postType! + "." + strPAthArrayExt.last!)
                                let fileName = FeedObj.postType! + "." + strPAthArrayExt.last!
                                
                                
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                                    if isShare {
                                        let value = FileBasedManager.shared.fileExist(nameFile: fileName).0
                                        self.sharedata(dataMain: value, orignalFile: filePath , feedObj: FeedObj)
                                    } else {
                                        PHPhotoLibrary.shared().performChanges({
                                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath:FileBasedManager.shared.fileExist(nameFile: strPAthArray.last!).0))
                                        }) { completed, error in
                                            if completed {
                                                DispatchQueue.main.async() {
                                                    let alert = UIAlertController(title: "Saved".localized(), message: "Your video has been saved".localized(), preferredStyle: .alert)
                                                    let okAction = UIAlertAction(title: "Ok".localized(), style: .default) { (_) -> Void in
                                                        dismissCompletion?()
                                                    }
                                                    alert.addAction(okAction)
                                                    self.present(alert, animated: true)
                                                }
                                            } else {
                                                if !FileBasedManager.shared.iscancelReuest {
                                                    DispatchQueue.main.async() {
                                                        let alert = UIAlertController(title: "Try again".localized(), message: "It appears that you are not connected with internet. Please check your internet connection and try again.".localized(), preferredStyle: .alert)
                                                        let okAction = UIAlertAction(title: "Ok".localized(), style: .default) { (_) -> Void in
                                                            dismissCompletion?()
                                                        }
                                                        alert.addAction(okAction)
                                                        self.present(alert, animated: true)
                                                    }
                                                }
                                                
                                            }
                                        }
                                    }
                                    
                                }
                            })
                    }
                }
            }
        }
    }
    
    @objc func cancelrequest(sender : UIButton){
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            //            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            downloadData.forEach { $0.cancel() }
            FileBasedManager.shared.iscancelReuest = true
        }
    }
}

extension UIViewController {
    
    func setHeroAnimation(type: HeroDefaultAnimationType, enabled: Bool = true) {
        navigationController?.isHeroEnabled = enabled
        navigationController?.heroNavigationAnimationType = type
    }
    
    func showTransition(to controller: UIViewController, withAnimationType type: HeroDefaultAnimationType, animated: Bool = true) {
        controller.isHeroEnabled = true
        setHeroAnimation(type: type)
        navigationController?.pushViewController(controller, animated: animated)
    }
    
    func popTransition(withAnimationType type: HeroDefaultAnimationType, animated: Bool = true) {
        setHeroAnimation(type: type)
        navigationController?.popViewController(animated: animated)
    }
    
    // dismiss keyboard tapped gesture on view
    func dismissKeyboardOnTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func popController(animate: Bool = true) {
        if let nav = navigationController {
            nav.popViewController(animated: animate)
        }
    }
}

extension UIViewController {
    func changeFileName(oldName : String , newName : String){
        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let documentDirectory = URL(fileURLWithPath: path)
            let originPath = documentDirectory.appendingPathComponent(oldName)
            let destinationPath = documentDirectory.appendingPathComponent(newName)
            try FileManager.default.moveItem(at: originPath, to: destinationPath)
        } catch {
            print(error)
        }
    }
}
