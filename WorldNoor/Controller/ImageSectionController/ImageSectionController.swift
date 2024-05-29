//
//  PageListController.swift
//  WorldNoor
//
//  Created by Raza najam on 4/1/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import SKPhotoBrowser
class ImageSectionController: UIViewController, CreatePageDelegate {
    
    @IBOutlet weak var imageTableView: UITableView!
    var pageMainDict:[String:Any] = [String:Any]()
    var pageArray:[Any] = [Any]()
    var pageCatName:[String] = [String]()
    var pageCatNumber:[Int] = [Int]()
    var selectedImageObj:GroupValue? = nil
    var catArray:NSArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Images".localized()
        self.callingPageListService()
        self.callbackHandler()
        
        self.imageTableView.register(UINib.init(nibName: "AdCell", bundle: nil), forCellReuseIdentifier: "AdCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if SharedManager.shared.isGrouplistUpdate {
            SharedManager.shared.isGrouplistUpdate = false
            self.callingPageListService()
        }
    }

    
    func showFullScreenImage(section:Int, row:Int){
        var images = [SKPhoto]()
        let arr = self.pageArray[section] as! [Any]
        for dict in arr {
            if let myDict = dict as? NSDictionary {
                let filePath = myDict["file_path"]
                let photo = SKPhoto.photoWithImageURL(filePath as! String)
                images.append(photo)
            }
        }
        let browser = SKPhotoBrowser(photos: images)
        SKPhotoBrowserOptions.displayAction = false
        browser.initializePageIndex(row)
        self.present(browser, animated: true, completion: {})
    }
    
    func callbackHandler(){
        GroupHandler.shared.ImageSectionHandler = { [weak self] (section, row) in
            self!.showFullScreenImage(section: section, row: row)
        }
    }
    
    func callingPageListService(){
        let parameters = ["action": "images/by_sections", "token": SharedManager.shared.userToken()]
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataGet(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is String {
                }
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else  if res is String {
                    
                }else {
                    
                    self.pageMainDict = res as! [String:Any]
                    for (k, _) in self.pageMainDict {
                        
                        
                        if k != "suggested_images" {
                        
                            self.pageCatName.append(k)
                            self.pageCatNumber.append(1)
                            
                            self.pageArray.append(self.pageMainDict[k] as! [Any])
                            
                            if self.pageCatName.count == 1 {
                                self.pageCatName.append("Ad")
                                self.pageArray.append([])
                            }
                            
                        }
                        
                        
                        
                        
                    }
                    self.imageTableView.reloadData()
                }
            }
        }, param:parameters)
    }
    
    func pageCreatedSuccessfullyDelegate() {
        self.callingPageListService()
    }
}

extension ImageSectionController:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let arr = self.pageArray[indexPath.row] as! [Any]
        if self.pageCatName[indexPath.row] == "Ad" {
         return 100
        }else {
            var countSize = (arr.count / 3)  * 185
            if countSize == 0 {
                countSize = 50
                return (CGFloat(countSize) + 50.0)
            }
            return (CGFloat(countSize) + 90.0)
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let arr = self.pageArray[indexPath.row] as! [Any]
        if self.pageCatName[indexPath.row] == "Ad" {
            
            
            guard let cellAd = tableView.dequeueReusableCell(withIdentifier: "AdCell", for: indexPath) as? AdCell else {
               return UITableViewCell()
            }
            
            cellAd.bannerView.rootViewController = self
            return cellAd
        }
        
        if arr.count == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyGroupCell", for: indexPath) as? EmptyGroupCell {
                
                let stringName = self.pageCatName[indexPath.row].replacingOccurrences(of: "_", with: " ")
                cell.descLbl.text = stringName.capitalized
                return cell
            }
        }else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ImageSectionCell", for: indexPath) as? ImageSectionCell {
                
                if "contact_images" == self.pageCatName[indexPath.row] {
                    cell.descLbl.text = "Photos by my contact"
                }else if "nearby_images" == self.pageCatName[indexPath.row] {
                    cell.descLbl.text = "Nearby Images"
                }else if "popular_in_region" == self.pageCatName[indexPath.row] {
                    cell.descLbl.text = "Popular In Region"
                }else if "tagged_images" == self.pageCatName[indexPath.row] {
                    cell.descLbl.text = "My Photos"
                }
                    
                
                cell.manageCategoryData(catArray: arr as NSArray, currentSection: indexPath)
                cell.btnLoadMore.tag = indexPath.row
                cell.btnLoadMore.addTarget(self, action: #selector(self.loadMoreAction), for: .touchUpInside)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    @objc func loadMoreAction(sender : UIButton){
        
        self.pageCatNumber[sender.tag] = self.pageCatNumber[sender.tag] + 1
        let parameters = [
            "action": "images/by_sections",
            "token": SharedManager.shared.userToken(),
            "type" : self.pageCatName[sender.tag],
            "page" : String(self.pageCatNumber[sender.tag]) ,
            "load_more" : "true"
        ]
        
        
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataGet(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                LogClass.debugLog(error.localizedDescription)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else  if res is String {
                    
                }else {
                    
                    self.pageMainDict = res as! [String:Any]
                    for (k,name) in self.pageMainDict {
                        
                        for indexObj in 0..<self.pageCatName.count {
                            if self.pageCatName[indexObj] == k {
                                
                                for indexObjInner in self.pageMainDict[k] as! [Any] {
                                    
                                    if var arrayMain = self.pageArray[indexObj] as? [Any] {
                                        arrayMain.insert(indexObjInner, at: arrayMain.count)
                                        
                                        self.pageArray[indexObj] = arrayMain
                                    }
                                }
                            }
                        }
                    }                    
                    self.imageTableView.reloadData()
                }
            }
        }, param:parameters)
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
