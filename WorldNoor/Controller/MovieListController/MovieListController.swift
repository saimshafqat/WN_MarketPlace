//
//  MovieListController.swift
//  WorldNoor
//
//  Created by Raza najam on 4/1/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import AlamofireRSSParser
class MovieListController: UIViewController {
    
    @IBOutlet weak var movieTableView: UITableView!
    
    @IBOutlet weak var lblEmpty: UILabel!
    
    var movieArray:[RSSFeed] = [RSSFeed]()
    var catNameArray:[String] = [String]()
    var counter = 0
    
    override func viewDidLoad() {
        self.lblEmpty.isHidden = true
        super.viewDidLoad()
        self.title = "Movies".localized()
        self.manageRSS()
        self.callbackHandler()
    }
    
    func callbackHandler(){
        
        DispatchQueue.main.async {
//            SharedManager.shared.showOnWindow()
            Loader.startLoading()
        }
        GroupHandler.shared.movieCallBackHandler = { (link) in
            if let url = URL(string: link) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    func manageRSS(){
        let urlString1 = "https://movieweb.com/rss/movie-trailers/"
        let urlString2 = "https://movieweb.com/rss/movie-news/"
        let urlString3 = "https://movieweb.com/rss/celebrity-interviews/"
        self.callingPageListService(urlString: urlString1, action: "Movie Trailers".localized())
        self.callingPageListService(urlString: urlString2, action: "Movie News".localized())
        self.callingPageListService(urlString: urlString3, action: "Celebrity News".localized())
    }
    
    func callingPageListService(urlString:String, action:String){
        RequestManager.fetchRSS(Completion: { response in
            switch response {
            case .failure(let error):
                
                DispatchQueue.main.async {
//                    SharedManager.shared.hideLoadingHubFromKeyWindow()
                    Loader.stopLoading()
                }
                
            case .success(let res):
                
                LogClass.debugLog("res ===>")
                LogClass.debugLog(res)
                if res is String {
                    self.lblEmpty.isHidden = false
                    if self.movieArray.count > 0 {
                        self.lblEmpty.isHidden = true
                    }
                }else {
                    self.movieArray.append(res as! RSSFeed)
                    self.catNameArray.append(action)
                    self.counter = self.counter + 1
                    if self.counter == 3 {
                        self.movieTableView.reloadData()
                    }
                    self.lblEmpty.isHidden = false
                    if self.movieArray.count > 0 {
                        self.lblEmpty.isHidden = true
                    }
                }
                DispatchQueue.main.async {
//                    SharedManager.shared.hideLoadingHubFromKeyWindow()
                    Loader.stopLoading()
                }
            }
        }, urlString: urlString)
    }
}

extension MovieListController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 245
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movieArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let arr = self.movieArray[indexPath.row]
        if arr.items.count == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyGroupCell", for: indexPath) as? EmptyGroupCell {
                return cell
            }
        }else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableCell", for: indexPath) as? MovieTableCell {
                cell.descLbl.text = self.catNameArray[indexPath.row]
                cell.manageCategoryData(catArray: arr as RSSFeed)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
