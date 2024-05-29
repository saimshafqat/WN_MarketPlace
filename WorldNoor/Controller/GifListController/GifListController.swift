//
//  GifListController.swift
//  WorldNoor
//
//  Created by Raza najam on 3/13/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

enum GifListType {
    case list
    case search
}

protocol GifImageSelectionDelegate {
    func gifSelected(gifDict: [Int: GifModel], currentIndex: IndexPath)
}

class GifListController: UIViewController {
    
    @IBOutlet private weak var gifCollectionView: UICollectionView!
    @IBOutlet private weak var searchBar: UISearchBar!
    
    private var gifArray: [GifModel] = [GifModel]()
    private var selectedGifDict: [Int: GifModel] = [Int: GifModel]()
    private var currentPage: Int = 1
    private var isNextPage: Bool = true
    private var screenType: GifListType = .list
    
    var isMultiple = true
    var delegate: GifImageSelectionDelegate?
    var indexPath: IndexPath = IndexPath(row: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchGIF(searchQuery: "")
        self.searchBar.delegate = self
        self.searchBar.placeholder = "Search Gif happy, sad etc ...".localized()
    }
    
    @IBAction func doneBtnClicked(_ sender: Any) {
        
        if self.selectedGifDict.count > 0 {
            self.delegate?.gifSelected(gifDict: self.selectedGifDict, currentIndex: self.indexPath)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension GifListController {
    
    //    private func getGifList() {
    //
    //        let parameters = ["action": "meta/gifs",
    //                          "token": SharedManager.shared.userToken(),
    //                          "page": String(currentPage)]
    //
    //        RequestManager.fetchDataGet(Completion: { (response) in
    //            SharedManager.shared.hideLoadingHubFromKeyWindow()
    //
    //            switch response {
    //            case .failure(let error):
    //                if error is ErrorModel {
    //                    if let error = error as? ErrorModel, let errorMessage = error.meta?.message {
    //                        SharedManager.shared.showPopupview(message: errorMessage)
    //                    }
    //                } else {
    //                    SharedManager.shared.showPopupview(message: Const.networkProblemMessage.localized())
    //                }
    //            case .success(let res):
    //                if res is Int {
    //                    AppDelegate.shared().loadLoginScreen()
    //                } else if res is [[String:Any]] {
    //
    //                    let gifModel = GifModel()
    //                    let gif = gifModel.manageReportArray(array: res as! [[String : Any]])
    //                    self.gifArray.append(contentsOf: gif)
    //
    //                    if gifModel.manageReportArray(array: res as! [[String : Any]]).count == 0 {
    //                        self.isNextPage = false
    //                    }
    //                    self.gifCollectionView.reloadData()
    //                }
    //            }
    //        }, param: parameters)
    //    }
    
    private func searchGIF(searchQuery: String) {
        
        let parameters = ["action": "get_gif",
                          "token": SharedManager.shared.userToken(),
                          "title": searchQuery,
                          "page": String(currentPage)]
        
        RequestManager.fetchDataGet(Completion: { (response) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            
            switch response {
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is [[String:Any]] {
                    
                    let gifModel = GifModel()
                    let gif = gifModel.manageReportArray(array: res as! [[String : Any]])
                    
                    self.gifArray.append(contentsOf: gif)
                    self.gifCollectionView.backgroundView = nil
                    if gifModel.manageReportArray(array: res as! [[String : Any]]).count == 0 {
                        self.isNextPage = false
                    }
                } else {
                    
                    if self.gifArray.count == 0 {
                        self.gifCollectionView.backgroundView = self.noDataView()
                    }
                }
                self.gifCollectionView.reloadData()
            }
        }, param: parameters)
    }
    
    private func noDataView() -> UIView {
        let label = UILabel()
        label.textAlignment = .center
        label.center = self.gifCollectionView.center
        label.text = "NO Gif Found".localized()
        label.textColor = .black
        return label
    }
}

extension GifListController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.gifArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GifCollectionCell",
                                                            for: indexPath) as? GifCollectionCell else {
            return UICollectionViewCell()
        }
        
        let gifObj = self.gifArray[indexPath.row]
        
        cell.bind(gif: gifObj)
        return cell
    }
    
    func resetAllSelected() {
        
        self.selectedGifDict.removeAll()
        var counter = 0
        for gifObj in self.gifArray {
            gifObj.isSelected = false
            self.gifArray[counter] = gifObj
            counter = counter + 1
        }
    }
}

extension GifListController: UICollectionViewDelegate , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let collectionViewSize = collectionView.frame.size.width - 10
        return CGSize(width: collectionViewSize / 3, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        
        if (indexPath.row + 7) == gifArray.count && self.isNextPage {
            
            switch self.screenType {
            case .list:
                self.currentPage += 1
                self.searchGIF(searchQuery: "")
            case .search:
                self.currentPage += 1
                if let query = searchBar.text {
                    searchGIF(searchQuery: query)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let gifObj = self.gifArray[indexPath.row]
        
        if isMultiple {
            if gifObj.isSelected {
                gifObj.isSelected = false
                self.gifArray[indexPath.row] = gifObj
                self.selectedGifDict.removeValue(forKey: indexPath.row)
            } else {
                gifObj.isSelected = true
                self.gifArray[indexPath.row] = gifObj
                self.selectedGifDict[indexPath.row] = gifObj
            }
        } else {
            if gifObj.isSelected {
                gifObj.isSelected = false
                self.gifArray[indexPath.row] = gifObj
                self.selectedGifDict.removeValue(forKey: indexPath.row)
            } else {
                self.resetAllSelected()
                gifObj.isSelected = true
                self.gifArray[indexPath.row] = gifObj
                self.selectedGifDict[indexPath.row] = gifObj
            }
        }
        self.gifCollectionView.reloadData()
    }
}

extension GifListController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let query = searchBar.text else { return }
        self.resetList()
        self.screenType = .search
        self.searchGIF(searchQuery: query)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
                self.resetList()
                self.screenType = .list
                self.searchGIF(searchQuery: searchText)
            }
        }
    }
    
    func resetList() {
        self.currentPage = 1
        self.isNextPage = true
        self.gifArray = []
        self.selectedGifDict = [:]
        self.gifCollectionView.reloadData()
    }
}
