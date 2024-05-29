//
//  Shared.swift
//  WorldnoorShare
//
//  Created by Raza najam on 7/6/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import AVFoundation

class Shared: NSObject {
    static let instance = Shared()
    var userObj:User?

    let defaultsGroup = UserDefaults(suiteName: SharedUserDefaults.suiteName)
    
    private override init() {
        super.init()
    }
    
    func userToken()->String {
        if let token = self.userObj?.data.token {
            if token != ""{
                return self.userObj!.data.token!
            }
        }
        return ""
    }
    
    func getFirstName()->String {
        if self.userObj!.data.firstname! == "" {
            return ""
        }
        return self.userObj!.data.firstname!
    }
    
    func getlastName()->String {
        if self.userObj!.data.lastname! == "" {
            return ""
        }
        return self.userObj!.data.lastname!
    }
    
    func getFullName()->String {
        return self.userObj!.data.firstname!+" "+self.userObj!.data.lastname!
    }
    
    func getProfileImage()->String {
        if let str = self.userObj!.data.profile_image   {
            return str
        }
        return ""
    }
    
    func getUserID()->Int {
        if let userID = self.userObj!.data.id   {
            return userID
        }
        return -1
    }
    
    func getProfileCoverImage()->String {
        if let str = self.userObj!.data.cover_image   {
            return str
        }
        return ""
    }
    
    //    // Get profile
    func getProfile() -> User?  {
        if let savedPerson = defaultsGroup!.data(forKey: "SavedPerson") {
            let decoder = JSONDecoder()
            if let loadedPerson = try? decoder.decode(User.self, from: savedPerson ) {
                self.userObj = loadedPerson
                return loadedPerson
            }
        }
        return nil
    }
    
    // Display Alert messages
    public func showAlert(message:String, view:UIViewController){
        let alert = UIAlertController(title: Const.AppName, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Const.accept, style: .default, handler: { action in
            switch action.style{
            case .default:
                debugPrint("default")
            case .cancel:
                debugPrint("cancel")
            case .destructive:
                debugPrint("destructive")
            @unknown default:
                debugPrint("UnKnown value")
            }}))
        view.present(alert, animated: true, completion: nil)
    }
    
    func getTextViewSize(textView:UITextView)->CGRect{
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(fixedWidth, fixedWidth), height: newSize.height)
        return newFrame
    }
    
    func getIdentifierForMessage()->String {
        let number = Int.random(in: 0 ... 1000)
        let message = self.getCurrentDateString()+""+String(number)
        return message
    }
    
    func getCurrentDateString()->String  {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = formatter.string(from: Date())
        return myString
    }
    
    func videoSnapshot(filePathLocal:URL) -> UIImage? {
         do
         {
             let asset = AVURLAsset(url: filePathLocal)
             let imgGenerator = AVAssetImageGenerator(asset: asset)
             imgGenerator.appliesPreferredTrackTransform = true
             let cgImage = try imgGenerator.copyCGImage(at:CMTimeMake(value: Int64(0), timescale: Int32(1)),actualTime: nil)
             let thumbnail = UIImage(cgImage: cgImage)
             return thumbnail
         }
         catch let error as NSError
         {
             return nil
         }
     }
}
