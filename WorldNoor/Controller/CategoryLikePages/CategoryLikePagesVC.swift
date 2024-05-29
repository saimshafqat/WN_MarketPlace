//
//  CategoryLikePagesVC.swift
//  WorldNoor
//
//  Created by Awais on 01/01/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
import Combine

struct CategoryLikePageModel {
    var tabName: String
    var item: LikePageModel
}

class CategoryLikePagesVC: UIViewController {
    
    // MARK: - IBOutlets -
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    
    // MARK: - Properties -
    var arrayData = [LikePageModel]()
    var titleStr: String = .emptyString
    var apiService = APITarget()
    var cancellables = Set<AnyCancellable>()
    var pageTab: String = .emptyString
    
    // MARK: - Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = titleStr
        tableView.registerCustomCells([CategoryLikeCell.className])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - IBAtions -
    @IBAction func onClickBack(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    // MARK: - API Service -
    func deleteCategoryRequest(to pageId: String) {
        apiService.categoryDeleteRequest(endPoint: .checkEmail([:]))
            .sink { result in
                switch result {
                case .finished:
                    LogClass.debugLog("Delete Category finished")
                case .failure(let error):
SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: error.localizedDescription)                }
            } receiveValue: { response in
                LogClass.debugLog("Response \(response)")
            }.store(in: &cancellables)
    }
    
    func getAllCategoryLikedPages() {
        // sports
        // tv
        // movies
        // games
    }
    
    func getCategoryLikedPages(type: String) {
        //        var parameters = ["type": type]
        //        if self.parentView.otherUserID.count > 0 {
        //            parameters["user_id"] = self.parentView.otherUserID
        //        }
        //        apiService.getCategoryLikedPagesRequest(endPoint: .getCatergoryLikedPages(parameters))
        //            .sink(receiveCompletion: { completion in
        //                switch completion {
        //                case .finished:
        //                    LogClass.debugLog("Successfully stored CategoryLikedPages")
        //                case .failure(let error):
        //                    LogClass.debugLog("Unable to store CategoryLikedPages.")
        //SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: error.localizedDescription)        //                }
        //            }, receiveValue: { [self] response in
        //                if let bookArray = response.data["Book"] {
        //                    self.arrayBook.removeAll()
        //                    for dict in bookArray {
        //                        self.arrayBook.append(dict)
        //                    }
        //                }
        //                if let sportArr = response.data["Sports"] {
        //                    self.arraySports.removeAll()
        //                    for dict in sportArr {
        //                        self.arraySports.append(dict)
        //                    }
        //                }
        //                if let movieArr = response.data["Movie"] {
        //                    self.arrayMovie.removeAll()
        //                    for dict in movieArr {
        //                        self.arrayMovie.append(dict)
        //                    }
        //                }
        //                if let tvArr = response.data["TV Show"] {
        //                    self.arrayTv.removeAll()
        //                    for dict in tvArr {
        //                        self.arrayTv.append(dict)
        //                    }
        //                }
        //                LogClass.debugLog("CategoryLikedPages Response ==> \(response)")
        //                LogClass.debugLog(response.data[type] ?? "No data")
        //            })
        //            .store(in: &subscription)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource -
extension CategoryLikePagesVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryLikeCell.identifier, for: indexPath) as! CategoryLikeCell
        cell.configureCell(obj: arrayData[indexPath.row], index: indexPath.row, pageTab: pageTab)
        cell.categoryLikeDelegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let pageObj = GroupValue.init()
        let pageData = arrayData[indexPath.row]
        pageObj.groupID = String(pageData.pageId)
        pageObj.category = pageData.name
        pageObj.groupName = pageData.title
        pageObj.title = pageData.title
        pageObj.profilePicture = pageData.profile ?? .emptyString
        pageObj.slug = pageData.slug
        let page = NewPageDetailVC.instantiate(fromAppStoryboard: .Kids)
        page.groupObj = pageObj
        navigationController?.pushViewController(page, animated: true)
    }
}

// MARK: - CategoryLikeDelegate -
extension CategoryLikePagesVC: CategoryLikeDelegate {
    
    func deleteCategory(obj: LikePageModel?, at index: Int?, pageTab: String) {
        LogClass.debugLog(pageTab)
        let pageTitle = obj?.title ?? .emptyString
        let pageCategoryName = pageTab
        let pageId = obj?.pageId ?? .emptyString
        SharedManager.shared.ShowAlertWithCompletaion(title: pageCategoryName.capitalized, message: "Do you really want to delete this category \(pageTitle)?", isError: true) {[weak self] status in
            guard let self else { return }
            if status {
                // call api service
                // sports
                // tv
                // movies
                // games
                let params = [
                    "tab" : pageCategoryName,
                    "page_id" : pageId
                ]
                self.apiService.categoryDeleteRequest(endPoint: .categoryDeleteRequest(params))
                    .sink { completion in
                        switch completion {
                        case .finished:
                            LogClass.debugLog("Finished")
                        case .failure(let error):
        SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: error.localizedDescription)                        }
                    } receiveValue: { response in
                        let itemsObj = response.data[pageCategoryName]
                        guard itemsObj?.count ?? 0 > 0 else { return }
                        if let index = itemsObj?.firstIndex(where: {"\($0.pageId)" == obj?.pageId}) {
                            LogClass.debugLog("Deleted Item ==> \(index)")
                            if let obj {
                                let categoryLikePageItem = CategoryLikePageModel(tabName: pageCategoryName, item: obj)
                                NotificationCenter.default.post(name: .CategoryLikePages, object: categoryLikePageItem)
                            }
                        }
                    }.store(in: &cancellables)
            }
        }
    }
}


extension Notification.Name {
    static let CategoryLikePages = Notification.Name("CategoryLikePages")
    static let recentSearchData = Notification.Name("RecentSearchData")
}
