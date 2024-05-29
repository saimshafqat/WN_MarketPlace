//
//  PostSharingViewViewModel.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 17/05/2023.
//

import UIKit
import Combine

class PostSharingViewViewModel {
    
    // MARK: - Properties -
    private var subscription: Set<AnyCancellable> = []
    private var apiService: APIService?
    
    // MARK: - Initilizer -
    init(apiService: APIService? = nil) {
        self.apiService = apiService
    }
    
    // MARK: - Methods -
    func dislikeLike(_ feedObj: FeedData, _ indexPath: IndexPath, successCompletion: @escaping(FeedData, IndexPath) -> Void) {
        let userToken = SharedManager.shared.userToken()
        let parameters = ["action": "react",
                          "token": userToken,
                          "type": feedObj.isReaction ?? .emptyString,
                          "post_id": String(feedObj.postID!)]
        DispatchQueue.global(qos: .userInitiated).async {
            RequestManager.fetchDataPost(Completion: { response in
//                SharedManager.shared.hideLoadingHubFromKeyWindow()
                Loader.stopLoading()
                DispatchQueue.main.async {
                    switch response {
                    case .failure(let error):
                        SwiftMessages.apiServiceError(error: error)
                    case .success(let res):
                        if res is Int {
                            AppDelegate.shared().loadLoginScreen()
                        } else if res is String {
                            SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: res as? String ?? .emptyString)
                        } else {
//                            if let reactionsMobile = feedObj.reationsTypesMobile, !reactionsMobile.isEmpty {
//                                if let index = reactionsMobile.firstIndex(where: { $0.type == feedObj.isReaction }) {
//                                    reactionsMobile[index].count! -= 1
//                                    if reactionsMobile[index].count! == 0 {
//                                        feedObj.reationsTypesMobile!.remove(at: index)
//                                    }
//                                }
//                            }
//                            feedObj.likeCount = (feedObj.likeCount) == nil ? 0 : (feedObj.likeCount ?? 0) - 1
                            
                             feedObj.isReaction = ""
                            successCompletion(feedObj, indexPath)
                        }
                    }
                }
            }, param: parameters)
        }
    }
    
}

