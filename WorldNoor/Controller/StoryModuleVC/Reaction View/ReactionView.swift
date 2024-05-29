//
//  ReactionView.swift
//  WorldNoor
//
//  Created by apple on 7/26/22.
//  Copyright © 2022 Raza najam. All rights reserved.
//

import Foundation
import UIKit


protocol ReactionDelegateResponse {
    func reactionResponse(feedObj:FeedData)
}

class ReactionView : UIView {
    
    var feedObj : FeedData!
    var isfromStory = false
    var storyindex :Int!
    var delegateReaction : ReactionDelegateResponse!
    var earlyUpdateReactionCompletion: ((String, IndexPath)->Void)? = nil
    
    public class var shared: ReactionView {
        struct Singleton {
            static let instance = ReactionView(frame: CGRect.zero)
        }
        return Singleton.instance
    }
    
    
    override func awakeFromNib() {
        self.collectionViewGif.register(UINib.init(nibName: "GifLikeCollectionCell", bundle: nil), forCellWithReuseIdentifier: "GifLikeCollectionCell")
    }
    
    @IBOutlet var viewGif : UIView!
    @IBOutlet var collectionViewGif : UICollectionView!
    
}


class GifLikeCollectionCell : UICollectionViewCell {
    @IBOutlet var imgviewGif : UIImageView!
}



extension ReactionView : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: self.viewGif.frame.size.height - 3, height: self.viewGif.frame.size.height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SharedManager.shared.arrayGif.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellGif = collectionView.dequeueReusableCell(withReuseIdentifier: "GifLikeCollectionCell", for: indexPath) as! GifLikeCollectionCell
        cellGif.imgviewGif.loadGifImage(with: SharedManager.shared.arrayGif[indexPath.row])
        return cellGif
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let userToken = SharedManager.shared.userToken()
        let parameters = ["action": "react", "token": userToken,
                          "type": SharedManager.shared.arrayGifType[indexPath.row],
                          "post_id":String(self.feedObj?.postID ?? 	0)]
        earlyUpdateReactionCompletion?(SharedManager.shared.arrayGifType[indexPath.row], indexPath)
            RequestManager.fetchDataPost(Completion: { response in
                Loader.stopLoading()
                DispatchQueue.main.async {
                    switch response {
                    case .failure(let error):
                        SwiftMessages.apiServiceError(error: error)
                    case .success(let res):

                        if res is Int {
                            AppDelegate.shared().loadLoginScreen()
                        } else if res is String {
                            SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: res as? String ?? .emptyString)
                        } else {

                            self.feedObj.isReaction = SharedManager.shared.arrayGifType[indexPath.row]
                            
                            var isFound = false
                            
                            if(self.isfromStory) {
                                
                                SharedManager.shared.isfromStory = true
                                let respDict = res as! [String : Any]
                                self.feedObj.storyReactionMobile.removeAll()
                                
                                if self.feedObj.reationsTypesMobile != nil {
                                    self.feedObj.reationsTypesMobile!.removeAll()
                                }
                                if let reactionsArray = respDict["reationsTypesMobile"] as? [[String : Any]] {
                                    for indexObj in reactionsArray {
                                        
                                        self.feedObj.storyReactionMobile.append(StoryReactionModel.init(dict: indexObj as NSDictionary))
                                        if self.feedObj.reationsTypesMobile == nil {
                                            self.feedObj.reationsTypesMobile =  [ReactionModel]()
                                        }
                                        self.feedObj.reationsTypesMobile!.append(ReactionModel.init(dict: indexObj as NSDictionary))
                                    }
                                }
                                
                                self.feedObj.likeCount = self.feedObj.storyReactionMobile.count
                                self.delegateReaction.reactionResponse(feedObj: self.feedObj)
                                return
                            }
                            
//                            if self.feedObj.reationsTypesMobile != nil {
//                                if self.feedObj.reationsTypesMobile!.count > 0  {
//                                    for obj in 0..<self.feedObj.reationsTypesMobile!.count {
//                                        if self.feedObj.reationsTypesMobile![obj].type == SharedManager.shared.arrayGifType[indexPath.row] {
//                                            isFound = true
//                                            self.feedObj.reationsTypesMobile![obj].count! = self.feedObj.reationsTypesMobile![obj].count! + 1
//                                        }
//                                    }
//                                }
//                            }
//                            
//                            if !isFound {
//                                var newreaction = ReactionModel.init(countP: 1, typeP: SharedManager.shared.arrayGifType[indexPath.row])
//                                
//                                if self.feedObj.reationsTypesMobile != nil {
//                                    self.feedObj.reationsTypesMobile!.append(newreaction)
//                                } else {
//                                    self.feedObj.reationsTypesMobile = [newreaction]
//                                }
//                            }
//                            
//                            if self.feedObj.likeCount == nil {
//                                self.feedObj.likeCount = 1
//                            } else {
//                                self.feedObj.likeCount! = 1 + self.feedObj.likeCount!
//                            }
                            
                            
                          //  self.delegateReaction.reactionResponse(feedObj: self.feedObj)
                        }
                    }
                }
            }, param:parameters)
    }
}
