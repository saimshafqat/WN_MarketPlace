//
//  ReactionView.swift
//  WorldNoor
//
//  Created by apple on 7/26/22.
//  Copyright © 2022 HAwais. All rights reserved.
//

import Foundation
import UIKit

protocol ReactionChatDelegateResponse:AnyObject {
    func reactionTapped(indexP:IndexPath)
}

class ReactionChatView : UIView {
    
    weak var delegateReaction : ReactionChatDelegateResponse!
    
    public class var shared: ReactionView {
        struct Singleton {
            static let instance = ReactionView(frame: CGRect.zero)
        }
        return Singleton.instance
    }
    
    override func awakeFromNib() {
        self.collectionViewGif.register(UINib.init(nibName: "GifLikeCollectionCell", bundle: nil), forCellWithReuseIdentifier: "GifLikeCollectionCell")
        
    }
    
    @IBOutlet var viewGif : UIView!{
        didSet{
            viewGif.roundCorners(radius: 25, bordorColor: .vLightGrayColor, borderWidth: 3)
        }
    }
    @IBOutlet var collectionViewGif : UICollectionView!
    
}

extension ReactionChatView : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: self.viewGif.frame.size.height, height: self.viewGif.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SharedManager.shared.arrayChatGif.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellGif = collectionView.dequeueReusableCell(withReuseIdentifier: "GifLikeCollectionCell", for: indexPath) as! GifLikeCollectionCell
        cellGif.imgviewGif.loadGifImage(with: SharedManager.shared.arrayChatGif[indexPath.row])
        return cellGif
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegateReaction.reactionTapped(indexP: indexPath)
    }
}
