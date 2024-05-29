//
//  SharedManager.swift
//  WorldNoor
//
//  Created by Raza najam on 9/30/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import Foundation
//import RSLoadingView
import CoreMedia
import NaturalLanguage
import AVFoundation
import Photos
import DeviceKit
import SDWebImage
import AVKit
import FTPopOverMenu

open class SharedManager: NSObject {
    
    static let shared = SharedManager()
    var someVideoSize:CGSize?
    var userObj:User?
    var mpUserObj:MarketPlaceForYouUser?
    var mpUserObjId: Int?
    var timerMain : Timer!
    var isStoryMinimized = false
    var currenciesList: [Currency] = []
    var currentUserFriendList: [FriendModel] = []
    var lifeEventCategoryArray: [LifeEventCategoryModel] = []
    var userEditObj = UserProfile.init()
    var mySeekTime:CMTime?
    var progressRing: CircularProgressBar!
    var createPostView:UIView?
    var isNewPostExist:Bool = false
    var userBasicInfo:NSMutableDictionary = NSMutableDictionary()
    var createPostSelection = -1
    var createPostScreenShot: UIImageView?
    var selectedTabController:Any?
    var isGroup = -1
    var playingVideoIndex = -1
    var groupObj:GroupValue?
    var isGrouplistUpdate = false
    var isVideoPickerFromHeader = false
    var cityArrayCached = [[String:String]]()
    var feedRef:UIViewController?
    var lanaguageModelArray: [LanguageModel] = [LanguageModel]()
    var excludingArray:[UIActivity.ActivityType] = []
    let defaultsGroup = UserDefaults(suiteName: SharedUserDefaults.suiteName)
    var callKitToken = ""
    var PrivacyObj = PrivacyModel.init()
    var otherUserFriend = ""
    var isTransCalled = false
    var videoClipIndex = 0
    var isLanguageChange = true
    var arrayVideoURL = [Int]()
    var arrayVideoClip: [VideoClipModel] = []
    var currentIndex = IndexPath(row: 0, section: 0)
    fileprivate let viewLanguageModel = FeedLanguageViewModel()
    var updateSliderTimer : Timer!
    var timerMainNew : Timer!
    var postCreateTop : FeedData?
    var createReel : FeedData?
    var createStory : FeedVideoModel?
    var postCreatedReload = false
    var playIndex = 1
    var isfromStory = false
    var isfromReel = false
    var isWatchMuted = false
    var isFromReply = false
    var playerArray = [AVPlayer]()
    var colourBG : UIColor = UIColor.init().hexStringToUIColor(hex: "#127FA5") //UIColor.init(red: (57/255), green: (130/255), blue: (247/255), alpha: 1.0)
    var toastView : PopUpView!
    var chatUploadingDict:[String:ChatUploadManager] = [:]
    var mpChatUploadingDict:[String:MPChatUploadManager] = [:]
    var chatAudioPlayMsgId = ""
    var conditionList: [FilterCondition] = []
    var filterItem: [Item] = []
    var arrayGif = ["love" , "thanks" , "laugh" , "sad" , "happy"  , "excited" , "like" , "cry" , "angry"]
    
    
    var arrayGifType = ["love",
                        "thanks",
                        "laugh",
                        "sad",
                        "happy",
                        "excited",
                        "like",
                        "cry",
                        "angry"
    ]
    
    var arrayChatGif = ["happy", "laugh", "sad", "cry", "angry", "like"]
    var arrayChatGifType = ["happy", "laugh", "sad", "cry", "angry", "like"]
    
    var videoArray = [Any]()
    
    var ytPlayer : YouTubePlayeriOSHelperViewController!
    
    var popover: Popover!
    var popoverOptions: [PopoverOption] = [
        .type(.auto),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.0))
    ]
    
    
    
    var avPlayerItem : AVPlayerItem!
    var avPlayer = AVPlayer()
    var avplayerLayer : AVPlayerLayer!
    
    private override init() {
        super.init()
        self.getBasicProfileObj()
        
        self.addExcludingType()
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            LogClass.debugLog(error)
        }
    }
    static func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    func ReturnValueCheck(value : Any) -> String{
        if let MainValue = value as? Int {
            return String(MainValue)
        }else  if let MainValue = value as? String {
            return MainValue
        }else  if let MainValue = value as? Double {
            return String(MainValue)
        }
        return ""
    }
    
    
    func configWithMenuStyle() -> FTPopOverMenuConfiguration {
        let config = FTPopOverMenuConfiguration()
        
        config.backgroundColor = UIColor.white
        config.borderColor = UIColor.lightGray
        config.menuWidth = UIScreen.main.bounds.width / 3
        config.separatorColor = UIColor.lightGray
        config.menuRowHeight = 40
        config.menuCornerRadius = 6
        config.textColor = UIColor.black
        config.textAlignment = NSTextAlignment.center
        
        return config
    }
    
    func addExcludingType(){
        self.excludingArray = [.addToReadingList,
                               .airDrop,
                               .assignToContact,
                               .copyToPasteboard,
                               .mail,
                               .message,
                               .print,
                               .saveToCameraRoll,
                               .postToWeibo,
                               .copyToPasteboard,
                               .saveToCameraRoll,
                               .postToFlickr,
                               .postToVimeo,
                               .postToTencentWeibo,
                               .markupAsPDF,
                               .postToFacebook,
                               .postToTwitter,
        ]
    }
    
    public func userProfileImage() -> UIImage {
        let fileName = "myImageToUpload.jpg"
        return FileBasedManager.shared.loadImage(pathMain: fileName)
    }
    
    func downloadUserImage(imageUrl : String) {
        SDWebImageManager.shared.loadImage(with: URL.init(string: imageUrl), options: SDWebImageOptions.highPriority, progress: { (IntM, IntMP, URLM) in
        }, completed: { (imageMain, dataMain , ErrorMain, SDImageCacheTypeMain, BoolMain, URLMain) in
            if let imageMain {
                let fileName = "myImageToUpload.jpg"
                FileBasedManager.shared.saveFileTemporarily(fileObj: imageMain, name: fileName)
            }
        })
    }
        
    public func ShowAlertWithCompletaion(title: String = "" , message: String, isError: Bool , DismissButton : String = "No" , AcceptButton : String = "Yes", completion: ((_ status: Bool) -> Void)? = nil) {
        guard let topViewController = UIApplication.topViewController() else {
            // Handle gracefully if topViewController is nil
            AppLogger.log(tag: .error, "Error: Top view controller is nil.")
            return
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: DismissButton, style: .default) { _ in
            alert.dismiss(animated: true) {
                DispatchQueue.main.async {
                    completion?(false)
                }
            }
        }
        alert.addAction(dismissAction)
        
        let acceptAction = UIAlertAction(title: AcceptButton, style: .default) { _ in
            alert.dismiss(animated: true) {
                DispatchQueue.main.async {
                    completion?(true)
                }
            }
        }
        alert.addAction(acceptAction)
        
        DispatchQueue.main.async {
            topViewController.present(alert, animated: true, completion: nil)
        }
    }
        
    public func ShowsuccessAlert(title: String = "" , message: String , AcceptButton : String = "Yes", completion: ((_ status: Bool) -> Void)? = nil) {
        guard let topViewController = UIApplication.topViewController() else {
            AppLogger.log(tag: .error, "Error: Top view controller is nil.")
            return
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let acceptAction = UIAlertAction(title: AcceptButton, style: .default) { _ in
            alert.dismiss(animated: true) {
                DispatchQueue.main.async {
                    completion?(true)
                }
            }
        }
        alert.addAction(acceptAction)
        DispatchQueue.main.async {
            topViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    public func showBasicAlertGlobal (message: String) -> UIAlertController{
        let alert = UIAlertController(title: Const.AppName, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertAction.Style.default, handler: nil))
        return alert
    }
    
    public func showAlert(message:String, view:UIViewController){
        let alert = UIAlertController(title: Const.AppName, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Const.accept.localized(), style: .default, handler: { action in
            switch action.style {
            case .default:
                LogClass.debugLog("default")
            case .cancel:
                LogClass.debugLog("cancel")
            case .destructive:
                LogClass.debugLog("destructive")
            @unknown default:
                LogClass.debugLog("UnKnown value")
            }}))
        view.present(alert, animated: true, completion: nil)
    }

    public func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                LogClass.debugLog(error.localizedDescription)
            }
        }
        return nil
    }
    
    func getLanguageIDForTop(languageP : String) -> String {
        
        if languageP == "العربية" {
            return "ar"
        }else if languageP == "bahasa Indonesia" {
            return "id"
        }else if languageP == "Italiana" {
            return "it"
        }else if languageP == "русский" {
            return "ru"
        }else if languageP == "Soomaali" {
            return "so"
        }else if languageP ==  "Türk" {
            return "tr"
        }else if languageP == "فارسی" {
            return "fa"
        }else if languageP == "Española" {
            return "es"
        }else if languageP == "日本人" {
            return "ja"
        }else if languageP == "Française" {
            return "fr"
        }else if languageP == "বাংলা" {
            return "bn"
        }else if languageP == "Azərbaycan" {
            return "az"
        }else if languageP == "Deutsche" {
            return "de"
        }else if languageP == "اردو" {
            return "ur"
        }else if languageP == "ਪੰਜਾਬੀ" {
            return "pa"
        }else if languageP == "తెలుగు" {
            return "te"
        }else if languageP == "தமிழ்" {
            return "ta"
        }else if languageP == "سنڌي" {
            return "sd"
        }else if languageP == "Português" {
            return "pt"
        }else if languageP == "Pilipino" {
            return "fil"
        }else if languageP == "dansk" {
            return "da"
        }else if languageP == "հայերեն" {
            return "hy"
        }else if languageP == "हिंदी" {
            return "hi"
        }else if languageP == "বাংলা" {
            return "bn"
        }
        
        return "en"
    }
    
    func checkLanguageAlignment() -> Bool{
        let langCode = UserDefaults.standard.value(forKey: "Lang")  as! String
        
        //        LogClass.debugLog("langCode ===> checkLanguageAlignment")
        //        /*LogClass.debug*/Log(langCode)
        if langCode == "العربية" || langCode == "فارسی" || langCode == "اردو" || langCode == "ਪੰਜਾਬੀ" {
            return true
        }
        return false
    }
    
    func selectedCellBackgroundView()-> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    public func ShowSuccessAlert(message : String , view:UIViewController) {
        let alert = UIAlertController(title: "" , message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized(), style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
            _ = view.navigationController?.popViewController(animated: true)
        })
        view.present(alert, animated: true, completion: nil)
    }
    
    
    public func ShowSuccessforRoot(message : String , view:UIViewController) {
        let alert = UIAlertController(title: "" , message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized(), style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
            _ = view.navigationController?.popToRootViewController(animated: true)
        })
        view.present(alert, animated: true, completion: nil)
    }
    
    func userToken()->String {
        if let token = self.userObj?.data.token {
            if token != ""{
                return self.userObj!.data.token!
            }
        }
        return ""
    }
    
    func marketplaceUserToken()->String {
        if let token = self.userObj?.data.token {
            if token != ""{
                return self.userObj!.data.token!
                //                return "0a175f4946723cf87d38ade21a3989b0154c8a2f95b30d04115c5a4a0e80722e8b5dd20f8120b660558edb7d9ed697fd2359c79b3e337a19dd868b13"
            }
        }
        return ""
    }
    
    public func returnJsonObjectarray(dictionary:[Any]) -> String {
        var jsobobj:String = ""
        if #available(iOS 11.0, *) {
            let jsonData = try! JSONSerialization.data(withJSONObject: dictionary, options: JSONSerialization.WritingOptions.sortedKeys)
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
            jsobobj = jsonString
        } else {
            // Fallback on earlier versions
        }
        let valid = JSONSerialization.isValidJSONObject(jsobobj) // true
        if(valid){
            
        }
        return jsobobj
    }
    
    public func returnJsonObject(dictionary:[String:Any]) -> String{
        var jsobobj:String = ""
        if #available(iOS 11.0, *) {
            let jsonData = try! JSONSerialization.data(withJSONObject: dictionary, options: JSONSerialization.WritingOptions.sortedKeys)
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
            jsobobj = jsonString
        } else {
            
        }
        let valid = JSONSerialization.isValidJSONObject(jsobobj) // true
        if(valid){
            
        }
        return jsobobj
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
        return self.userObj!.data.firstname! + " " + self.userObj!.data.lastname!
    }
    
    func getProfileImage()->String {
        if let str = self.userObj!.data.profile_image   {
            return str
        }
        return ""
    }
    
    func getUserID()->Int {
        if self.userObj != nil {
            if let userID = self.userObj!.data.id   {
                return userID
            }
        }
        
        return -1
    }
    
    func getMPUserID()->Int {
        if self.mpUserObj != nil {
            if let userID = self.mpUserObj?.id   {
                return userID
            }
        }
        
        if let userID = self.mpUserObjId {
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
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    
    func getCurrentDateString()->String  {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = formatter.string(from: Date())
        return myString
    }
    
    func getIdentifierDateString()->String  {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-ddHH:mm:ss"
        let myString = formatter.string(from: Date())
        return myString
    }
    
    func getUTCDateTimeString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        return dateFormatter.string(from: Date())
    }
    
    func getIdentifierForMessage()->String {
        let number = Int.random(in: 0 ... 1000)
        let message = self.getIdentifierDateString()+""+String(number)
        return message
    }
    
    func dateFromString(dateString:String)  {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let yourDate = formatter.date(from: dateString)
        _ = formatter.string(from: yourDate!)
    }
    
    func detectedLangauge(for string: String) -> String? {
        if #available(iOS 12.0, *) {
            let recognizer = NLLanguageRecognizer()
            recognizer.processString(string)
            guard let languageCode = recognizer.dominantLanguage?.rawValue else { return nil }
            let direction = NSLocale.characterDirection(forLanguage:languageCode)
            if direction == .rightToLeft {
                return "right"
            }else {
                return "left"
            }
        } else {
            // Fallback on earlier versions
        }
        return "left"
    }
    
    
    func setTextandFont( viewText : Any) {
        
        
        if let lblMain = viewText as? UILabel {
            if lblMain.text != nil {
                let langDirection = self.detectedLangauge(for: lblMain.text!) ?? "left"
                (langDirection == "right") ? (lblMain.textAlignment = NSTextAlignment.right): (lblMain.textAlignment = NSTextAlignment.left)
                let langCode = self.detectedLangaugeCode(for: lblMain.text!)
                if langCode == "ar" {
                    lblMain.font = UIFont(name: "BahijTheSansArabicPlain", size: lblMain.font!.pointSize)
                }else {
                    lblMain.font = UIFont.systemFont(ofSize: lblMain.font!.pointSize)
                }
                
            }
            
        }
    }
    
    func detectedLangaugeCode(for string: String) -> String? {
        if #available(iOS 12.0, *) {
            let recognizer = NLLanguageRecognizer()
            recognizer.processString(string)
            guard let languageCode = recognizer.dominantLanguage?.rawValue else { return nil }
            return languageCode
        } else {
            // Fallback on earlier versions
        }
        return ""
    }
    
    
    func getAudioPlayerView()-> XQAudioPlayer   {
        let audioPlayer = Bundle.main.loadNibNamed(Const.XQAudioPlayer, owner: self, options: nil)?.first as! XQAudioPlayer
        return audioPlayer
    }
    
    func getTextViewSize(textView:UITextView)->CGRect{
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(fixedWidth, fixedWidth), height: newSize.height)
        return newFrame
    }
    
    func getTextFieldSize(textView:UILabel)->CGRect{
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(fixedWidth, fixedWidth), height: newSize.height)
        return newFrame
    }
    
    func showHudWithProgress(view:UIView){
        let xPosition = view.center.x
        let yPosition = view.center.y
        let position = CGPoint(x: xPosition, y: yPosition)
        progressRing = CircularProgressBar(radius: 80, position: position, innerTrackColor: UIColor.progressInnerBG, outerTrackColor: UIColor.progressBG, lineWidth: 20)
        view.layer.addSublayer(progressRing)
    }
    
    func removeProgressRing(){
        if self.progressRing != nil {
            self.progressRing.removeFromSuperlayer()
        }
        
    }
    
    func getBasicProfileObj(){
        let defaults = UserDefaults.standard
        if let savedPerson = defaults.object(forKey: "userBasicProfile")  {
            
            self.userBasicInfo = (savedPerson as! NSDictionary).mutableCopy() as! NSMutableDictionary
        }
    }
    
    func isLangSame(langID:Int)->Bool {
        let langCode = (SharedManager.shared.userBasicInfo["language_id"] as? Int)
        if let myLangCode = langCode {
            if myLangCode == langID {
                return false
            }
        }
        return true
    }
    
    func getCurrentLanguageID() -> String{
        var langCode = (SharedManager.shared.userBasicInfo["language_id"] as? Int)
        if langCode == nil {
            langCode = 1
        }
        let langString = String(langCode!)
        return langString
    }
    
    
    func setCurrentLanguageID(IdLanguage : Int){
        self.userBasicInfo["language_id"] = IdLanguage
        
        
        let defaults = UserDefaults.standard
        defaults.set(self.userBasicInfo, forKey: "userBasicProfile")
        defaults.synchronize()
        
    }
    
    // Save UserObject in defaults...
    func saveProfile(userObj: User?){
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(userObj) {
            defaultsGroup?.set(encoded, forKey: "SavedPerson")
            defaultsGroup?.synchronize()
        }
        
        SharedClass.shared.saveXDataApp()
    }
    //    // Get profile
    func getProfile() -> User?  {
        if let savedPerson = defaultsGroup?.object(forKey: "SavedPerson") as? Data {
            let decoder = JSONDecoder()
            if let loadedPerson = try? decoder.decode(User.self, from: savedPerson) {
                return loadedPerson
            }
        }
        return nil
    }
    
    func removeProfile(){
        if UserDefaultsUtility.get(with: .savedPerson) != nil {
            UserDefaultsUtility.remove(with: .savedPerson)
        }
    }
    
    func getJsonString(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    func getImageFromAsset(asset: PHAsset) -> UIImage? {
        var img =  UIImage.init(named: "VideoBlack")
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .current
        options.isSynchronous = true
        manager.requestImageData(for: asset, options: options) { data, NewP, NewPM, NewPK in
            
            if let data = data {
                img = UIImage(data: data)
            }
        }
        return img
    }
    
    
    //    func saveStoryArray(arrayFeedModel : [FeedVideoModel]){
    //        UserDefaults.standard.set(try? PropertyListEncoder().encode(arrayFeedModel), forKey:"StoryData")
    //    }
    //
    //    func getStoryArray()-> [FeedVideoModel]{
    //        var arrayFeed = [FeedVideoModel]()
    //
    //        if let data = UserDefaults.standard.value(forKey:"StoryData") as? Data {
    //            arrayFeed  = try! PropertyListDecoder().decode(Array<FeedVideoModel>.self, from: data)
    //        }
    //        return arrayFeed
    //    }
    //
    
    func saveFeedArray(arrayFeedModel : [FeedData]){
        UserDefaults.standard.set(try? PropertyListEncoder().encode(arrayFeedModel), forKey:"FeedData")
    }
    
    func getFeedArray() -> [FeedData] {
        var arrayFeed = [FeedData]()
        if let data = UserDefaults.standard.value(forKey: "FeedData") as? Data {
            do {
                arrayFeed = try PropertyListDecoder().decode([FeedData].self, from: data)
            } catch {
                LogClass.debugLog("Error decoding feed data: \(error)")
                // Handle the error gracefully, e.g., return an empty array or log the error.
            }
        }
        return arrayFeed
    }
    
    func saveWatchArray(arrayFeedModel : [FeedData]){
        UserDefaults.standard.set(try? PropertyListEncoder().encode(arrayFeedModel), forKey:"WatchData")
    }
    
    func getWatchArray()-> [FeedData]{
        var arrayFeed = [FeedData]()
        
        if let data = UserDefaults.standard.value(forKey:"WatchData") as? Data {
            do {
                arrayFeed  = try PropertyListDecoder().decode(Array<FeedData>.self, from: data)
            } catch {
                LogClass.debugLog("Error decoding Watch Data: \(error)")
            }
        }
        return arrayFeed
    }
    
    func removeFeedArray() {
        UserDefaults.standard.removeObject(forKey:"FeedData" )
        UserDefaults.standard.synchronize()
    }
    
    func reomveWatchArray() {
        UserDefaults.standard.removeObject(forKey:"WatchData")
        UserDefaults.standard.synchronize()
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
        catch _ as NSError
        {
            return nil
        }
    }
}


extension SharedManager {
    
    
    func isCallKitSupported() -> Bool {
        
        
        let userLocale = NSLocale.current
        guard let regionCode = userLocale.regionCode else { return false }
        if regionCode.contains("CN") ||
            regionCode.contains("CHN") {
            return false
        } else {
            return true // non -chaina
        }
        //      return false //china
    }
    //    func showLoadingHub(view:UIView) {
    //        let loadingView = RSLoadingView()
    //        loadingView.show(on: view)
    //    }
    
    //    func showOnViewTwins(view:UIView) {
    //        let loadingView = RSLoadingView(effectType: RSLoadingView.Effect.twins)
    //        loadingView.show(on: view)
    //    }
    
    //    func hideLoadingHub(view:UIView) {
    //        RSLoadingView.hide(from: view)
    //    }
    
    // Crash here on window null waseem crash
    func showOnWindow() {
        
        if UIApplication.shared.keyWindow != nil {
            let viewMain = AppStoryboard.Kids.instance.instantiateViewController(withIdentifier: "LoaderViewVC") as! LoaderViewVC
            
            viewMain.view.tag = -999
            UIApplication.shared.keyWindow!.addSubview(viewMain.view)
            
        }else     {
            
            if #available(iOS 13.0, *) {
                let window = UIApplication.shared.connectedScenes
                    .filter({$0.activationState == .foregroundActive})
                    .compactMap({$0 as? UIWindowScene})
                    .first?.windows
                    .filter({$0.isKeyWindow}).first
                
                
                let viewMain = AppStoryboard.Kids.instance.instantiateViewController(withIdentifier: "LoaderViewVC") as! LoaderViewVC
                
                if window != nil {
                    window!.addSubview(viewMain.view)
                }
                
            }
        }
    }
    
    func hideLoadingHubFromKeyWindow() {
        if UIApplication.shared.keyWindow != nil {
            let window = UIApplication.shared.keyWindow!
            if window != nil {
                if window.viewWithTag(-999) != nil{
                    window.viewWithTag(-999)?.removeFromSuperview()
                }
            }
            
        } else {
            
            if #available(iOS 13.0, *) {
                let window = UIApplication.shared.connectedScenes
                    .filter({$0.activationState == .foregroundActive})
                    .compactMap({$0 as? UIWindowScene})
                    .first?.windows
                    .filter({$0.isKeyWindow}).first
                
                
                if window != nil{
                    if window!.viewWithTag(-999) != nil{
                        window!.viewWithTag(-999)?.removeFromSuperview()
                    }
                }
            }
        }
        
    }
    
    
    //    func showOnWindow() {
    //        hideLoadingHubFromKeyWindow()
    //        guard let vc = UIApplication.topViewController() else { return }
    //        let viewMain = LoaderViewVC.instantiate(fromAppStoryboard: .Kids)
    //        viewMain.view.tag = -999
    //        DispatchQueue.main.async {
    //            vc.view.addSubview(viewMain.view)
    //        }
    //    }
    //
    //    func hideLoadingHubFromKeyWindow() {
    //        guard let vc = UIApplication.topViewController() else { return }
    //        DispatchQueue.main.async {
    //            if let loaderView = vc.view.viewWithTag(-999) {
    //                loaderView.removeFromSuperview()
    //            }
    //        }
    //    }
    
    func saveToDocuments(filename:String , imageMain : UIImage) -> Bool {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        if let data = imageMain.jpegData(compressionQuality: 1.0) {
            do {
                try data.write(to: fileURL)
                return true
            } catch {
                return false
            }
        }
        
        return false
    }
    
    func loadImageFromDocumentDirectory(nameOfImage : String) -> UIImage {
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if let dirPath = paths.first{
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent("Screenshots/\(nameOfImage)")
            guard let image = UIImage(contentsOfFile: imageURL.path) else { return  UIImage.init(named: "fulcrumPlaceholder")!}
            return image
        }
        return UIImage.init(named: "imageDefaultPlaceholder")!
    }
    
    @discardableResult
    func saveImage(image: UIImage, fileName: String) -> Bool {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            if let data = image.jpegData(compressionQuality: 1.0) {
                do {
                    try data.write(to: fileURL)
                    return true
                } catch {
                    //                    LogClass.debugLog("Error saving image: \(error)")
                    return false
                }
            } else {
                //                LogClass.debugLog("Failed to create image data.")
            }
        } else {
            //            LogClass.debugLog("Document directory not found.")
        }
        return false
    }
    
    func getPathFromDocumentDirectory(fileName: String) -> URL? {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return documentsDirectory.appendingPathComponent(fileName)
        }
        return nil
    }
    
    func saveFileToDocumentsDirectory(image: UIImage, fileName: String) {
        if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let imagePath = path.appendingPathComponent(fileName)
            let jpgImageData = image.jpegData(compressionQuality: 0.7)
            do {
                try jpgImageData!.write(to: imagePath)
                //                LogClass.debugLog("Image saved successfully to \(imagePath)")
            } catch {
                //                LogClass.debugLog("Failed to create image data.")
            }
        }
    }
    
    func loadImage(fileName: String) -> UIImage? {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                if let data = try? Data(contentsOf: fileURL) {
                    if let image = UIImage(data: data) {
                        return image
                    }
                }
            }
        }
        return nil
    }
    
    func ReturnValueAsString(value : Any) -> String{
        if let MainValue = value as? Int {
            return String(MainValue)
        }else  if let MainValue = value as? String {
            return MainValue
        }else  if let MainValue = value as? Double {
            return String(MainValue)
        }
        return ""
    }
    
    func ReturnValueAsBool(value : Any) -> Bool{
        if let MainValue = value as? Int {
            if MainValue == 1 {
                return true
            }
        }else  if let MainValue = value as? String {
            if MainValue == "1" {
                return true
            }
        }
        return false
    }
    
    func ReturnValueAsInt(value: Any) -> Int {
        var temp = 0
        if let number = value as? Int {
            temp = number
        } else if let str = value as? String {
            temp = Int(str) ?? 0
        }else if let strB = value as? Bool {
            temp = strB ? 1 : 0 // intValue will be 1
        }
        return temp
    }
    
    func supportedLanguage() {
        
        if SharedManager.shared.userBasicInfo["auto_translate"] != nil {
            if let auto_translate = SharedManager.shared.userBasicInfo["auto_translate"] as? Int {
                if auto_translate == 0 {
                    self.isTransCalled = false
                }else {
                    self.isTransCalled = true
                }
            }
            var langMain = ""
            var langMainP = "English"
            if UserDefaults.standard.value(forKey: "Lang") != nil {
                langMain = UserDefaults.standard.value(forKey: "Lang") as! String
            }
            
            if UserDefaults.standard.value(forKey: "LangN") != nil {
                langMainP = UserDefaults.standard.value(forKey: "LangN") as! String
            }
            
        }
    }
    
    func getTrsaltionLang() -> Bool{
        if self.getLang() == "English" {
            return true
        }else {
            return false
        }
    }
    
    func getLang() -> String{
        var langMainP = "English"
        
        if UserDefaults.standard.value(forKey: "LangN") != nil {
            langMainP = UserDefaults.standard.value(forKey: "LangN") as! String
        }
        
        
        return langMainP
    }
    
    
    func getLanguageName(id:String)->String {
        for langObj in self.lanaguageModelArray {
            if langObj.languageID == id {
                return langObj.languageName
            }
        }
        return "Select Language"
    }
    
    func getSelectedLanguageName()->String {
        let id = self.getCurrentLanguageID()
        for langObj in self.lanaguageModelArray {
            if langObj.languageID == id {
                return langObj.languageName
            }
        }
        return "Select Language"
    }
    
    
    func getPrivacySetting() {
        DispatchQueue.global(qos: .background).async {
            let parameters = ["action": "privacy/settings","token": SharedManager.shared.userToken()]
            RequestManager.fetchDataGet(Completion: { (response) in
                switch response {
                case .failure(_):
                    break
                case .success(let res):
                    if res is Int {
                        DispatchQueue.main.async {
                            AppDelegate.shared().loadLoginScreen()
                        }
                    } else if let newRes = res as? [[String:Any]] {
                        SharedManager.shared.PrivacyObj = PrivacyModel.init(fromDictionary: newRes)
                    }
                }
            }, param: parameters)
        }
    }
    
    func appLanguage() -> [String] {
        
        let appLanguageArray = [
            "العربية" ,
            "հայերեն" ,
            "Azərbaycan",
            "বাংলা",
            "dansk" ,
            "हिंदी",
            "English" ,
            "Pilipino",
            "Française",
            "Deutsche" ,
            "bahasa Indonesia",
            "Italiana",
            "日本人",
            "ਪੰਜਾਬੀ" ,
            "Português" ,
            "فارسی",
            "русский",
            "Española",
            "Soomaali",
            "سنڌي",
            "Türk" ,
            "తెలుగు" ,
            "தமிழ்",
            "اردو"
        ]
        return appLanguageArray
    }
    
    func populateLangData()->[LanguageModel]{
        return self.lanaguageModelArray
    }
    
    
    func downloadVideo(filePAth : String){
        
        DispatchQueue.global(qos: .utility).async {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100) , execute: {
                if let url = URL(string: filePAth),
                   let urlData = NSData(contentsOf: url) {
                    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                    let filePath="\(documentsPath)/tempFile.mp4"
                    DispatchQueue.main.async {
                        urlData.write(toFile: filePath, atomically: true)
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                        }) { completed, error in
                            if completed {
                                
                            }
                        }
                    }
                }
            })
        }
        
    }
    
    func downloadImage(filePAth : String){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100) , execute: {
            if let url = URL(string: filePAth),
               let data = try? Data(contentsOf: url),
               let image = UIImage(data: data)
            {
                DispatchQueue.main.async() {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    
                }
            }
        })
    }
    
    
    func downloadProfileImage(filePAth : String){
        self.downloadUserImage(imageUrl: filePAth)
    }
    
    
    func downloadProfileCover(filePAth : String){
        
        SDWebImageManager.shared.loadImage(with: URL.init(string: filePAth), options: SDWebImageOptions.highPriority, progress: { (IntM, IntMP, URLM) in
            
        }, completed: { (imageMain, dataMain , ErrorMain, SDImageCacheTypeMain, BoolMain, URLMain) in
            if imageMain != nil {
                let fileName = "myImageCoverToUpload.jpg"
                FileBasedManager.shared.saveFileTemporarily(fileObj: imageMain!, name: fileName)
                
            }
        })
        
    }
    
    var isIphoneSmall : Bool {
        let device = Device.current
        switch device {
        case .simulator(.iPhone4), .simulator(.iPhone4s), .simulator(.iPhone5), .simulator(.iPhone5s), . simulator(.iPhone5c), .simulator(.iPhoneSE):
            return true
        case .iPhone4, .iPhone4s, .iPhone5, .iPhone5s, .iPhone5c, .iPhoneSE:
            return true
        default:
            return false
        }
    }
    
    var isIphone: Bool {
        let device = Device.current
        switch device {
        case .iPhone6, .simulator(.iPhone6), .iPhone6s , .simulator(.iPhone6s) , .iPhone7, .simulator(.iPhone7), .iPhone8, .simulator(.iPhone8):
            return true
        default:
            return false
        }
    }
    
    var isIphonePlus : Bool {
        let device = Device.current
        switch device {
        case .iPhone6Plus, .simulator(.iPhone6Plus), .iPhone6sPlus, .simulator(.iPhone6sPlus)  ,.iPhone7Plus, .simulator(.iPhone7Plus), .iPhone8Plus, .simulator(.iPhone8Plus):
            return true
        default:
            return false
        }
    }
    
    var isIphoneX : Bool {
        let device = Device.current
        switch device {
        case .iPhoneX, .simulator(.iPhoneX), .iPhoneXS, .simulator(.iPhoneXS), .iPhone11Pro, .simulator(.iPhone11Pro) :
            return true
        default:
            return false
        }
    }
    
    var isIphoneMax: Bool {
        let device = Device.current
        switch device {
        case .iPhoneXSMax, .simulator(.iPhoneXSMax), .iPhone11ProMax, .simulator(.iPhone11ProMax):
            return true
        default:
            return false
        }
    }
    
    var isIphoneXR: Bool {
        let device = Device.current
        switch device {
        case .iPhoneXR, .simulator(.iPhoneXR), .iPhone11, .simulator(.iPhone11):
            return true
        default:
            return false
        }
    }
    
    var isiPadDevice: Bool {
        let device = Device.current
        if device.isPad {
            return true
        }
        return false
    }
    
    func getFontOfSize (size: Int) -> UIFont {
        if isIphoneSmall {
            return UIFont.systemFont(ofSize: CGFloat(size))
        } else if isIphone {
            return UIFont.systemFont(ofSize: CGFloat(size + 1))
        } else if isIphonePlus {
            return UIFont.systemFont(ofSize: CGFloat(size + 1))
        } else if isIphoneX {
            return UIFont.systemFont(ofSize: CGFloat(size + 1))
        } else if isIphoneMax {
            return UIFont.systemFont(ofSize: CGFloat(size + 3))
        } else if isIphoneXR {
            return UIFont.systemFont(ofSize: CGFloat(size + 3))
        } else if isiPadDevice {
            return UIFont.systemFont(ofSize: CGFloat(size + 6))
        } else {
            return UIFont.systemFont(ofSize: CGFloat(size))
        }
    }
    
    func saveLanguagePermanentally() {
        let defaults = UserDefaults.standard
        let data = NSKeyedArchiver.archivedData(withRootObject: self.lanaguageModelArray)
        defaults.set(data, forKey: "languageList")
        
    }
    
    func getPermanentlyLanguage() {
        
        let defaults = UserDefaults.standard
        
        if let data = defaults.object(forKey: "languageList") as? NSData {
            lanaguageModelArray = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! [LanguageModel]
        }
    }
}
