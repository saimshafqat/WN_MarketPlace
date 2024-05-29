//
//  SharedClassRefine.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 26/04/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper


class SharedClass {
    
    static let shared = SharedClass()
    
    enum AppType: String {
        case Werfie = "WerfieApp"
        case Mizdah = "MizdahApp"
        case Kalamtime = "KTMessenger"
        case Seezitt = "SeezittApp"
        var urlString: String {
            switch self {
            case .Werfie:
               return "https://apps.apple.com/pk/app/werfie-create-a-werf/id1599453650"
            case .Mizdah:
                return "https://apps.apple.com/pk/app/mizdah-video-communications/id6445909307"
            case .Kalamtime:
                return "https://apps.apple.com/sa/app/kt-messenger/id6478195913"
            case .Seezitt:
                return "https://apps.apple.com/pk/app/seezitt/id6444735823"
            }
        }
    }
    
    func openXApp(senderType : AppType) {
        saveXDataApp()
        openApp(type: senderType)
    }
    
    func openApp(type: AppType) {
        let openAppString = type.rawValue + "://"
        guard let openUrl = URL(string: openAppString) else { return }
        UIApplication.shared.open(openUrl , options:[:]) { (success) in
            if !success {
                if openAppString.contains(type.rawValue) {
                    guard let url = URL(string: type.urlString) else { return }
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    // MARK: - Save X App Data -
    func saveXDataApp(){
        LogClass.debugLog(SharedManager.shared.userObj?.data.phone ?? .emptyString)
        let keychain = KeychainWrapper(serviceName: "PoshData",accessGroup: "DJ3DSQD2BW.com.ogoul.PoshGroup")
        keychain.set(SharedManager.shared.userObj?.data.posh_id ?? "", forKey: "posh_id")
        keychain.set(SharedManager.shared.userObj?.data.email ?? "", forKey: "posh_email")
        keychain.set(SharedManager.shared.userObj?.data.profile_image ?? "", forKey: "posh_image")
        keychain.set(SharedManager.shared.userObj?.data.fullname ?? "", forKey: "posh_name")
        keychain.set(SharedManager.shared.userObj?.data.phone ?? "", forKey: "posh_Phone")
    }
    
    func clearAllFiles() {
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        AppLogger.log(tag: .debug, "Directory: \(paths)")
        do {
            let fileName = try fileManager.contentsOfDirectory(atPath: paths)
            for file in fileName {
                LogClass.debugLog("file ===>")
                LogClass.debugLog(file)
                if !file.contains("myImageToUpload") {
                    LogClass.debugLog("If ===>")
                    let filePath = URL(fileURLWithPath: paths).appendingPathComponent(file).absoluteURL
                    try fileManager.removeItem(at: filePath)
                }else {
                    LogClass.debugLog("Else ===>")
                }
            }
        } catch let error {
            print(error)
        }
    }
    
    func logoutFromKeychain() {
        let keychain = KeychainWrapper(serviceName: "PoshData",accessGroup: "DJ3DSQD2BW.com.ogoul.PoshGroup")
        keychain.removeAllKeys()
    }
}
