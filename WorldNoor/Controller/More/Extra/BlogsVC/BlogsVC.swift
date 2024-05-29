//
//  BlogsVC.swift
//  WorldNoor
//
//  Created by apple on 9/7/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class BlogsVC : UIViewController {
    
    @IBOutlet var webViewMain : WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Blogs".localized()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let url = URL(string: "https://blog.worldnoor.com/")
        webViewMain.load(URLRequest(url: url!))
    }
}
