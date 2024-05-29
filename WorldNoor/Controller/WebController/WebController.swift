//
//  WebController.swift
//  WorldNoor
//
//  Created by Raza najam on 10/8/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import WebKit
final class WebCacheCleaner {

    class func clear() {
        URLCache.shared.removeAllCachedResponses()

        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)

        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}

class WebController: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var webView: WKWebView!{
        didSet {
            webView.isOpaque = true
            webView.backgroundColor = .white
        }
    }

    var isFromFaq : Int = 0
    var urlMAin = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        populateWebView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK:- Custom
    func populateWebView() {
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        
        
        let strValue = UserDefaults.standard.value(forKey: "Lang") as? String ?? "english"
        
        
        let  languageCode = SharedManager.shared.getLanguageIDForTop(languageP: strValue)
        if isFromFaq == 0 {
            title = "FAQs".localized()
            webView.load(URLRequest(url: URL(string: "https://worldnoor.com/docs/faqs.html?mobile=1&language_code=" + languageCode)!))
        }else if isFromFaq == 1 {
            title = "Privacy Policy".localized()
            webView.load(URLRequest(url: URL(string: "https://worldnoor.com/privacy-policy?mobile=1&language_code=" + languageCode)!))
        }else if isFromFaq == 2 {
            title = "Terms & Conditions".localized()
            webView.load(URLRequest(url: URL(string: "https://worldnoor.com/terms-and-conditions?mobile=1&language_code=" + languageCode)!))
        }else if isFromFaq == 3 {
            title = "End User License Agreement".localized()
            webView.load(URLRequest(url: URL(string: "https://worldnoor.com/eula.html?mobile=1&language_code=" + languageCode)!))
        }else if isFromFaq == 4 {
            title = ""
            webView.load(URLRequest(url: URL(string: urlMAin)!))
        }
    }
}
