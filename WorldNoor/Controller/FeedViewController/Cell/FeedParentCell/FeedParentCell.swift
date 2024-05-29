//
//  FeedParentCell.swift
//  WorldNoor
//
//  Created by Raza najam on 10/10/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import SDWebImage
class FeedParentCell: UITableViewCell {
    public var headerViewRef:FeedTopBarView!
    public var commentViewRef:FeedCommentBarView!
    var feedArray:[FeedData] = []
    var textChanged: ((String) -> Void)?
    var likeDislikeUpdated: ((String) -> Void)?
    var updateTableClosure:((IndexPath)->())?
    var indexValue:IndexPath = IndexPath(row: 0, section: 0)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    static var nib:UINib {
           return UINib(nibName: identifier, bundle: nil)
       }
    static var identifier: String {
           return String(describing: self)
    }
    
    func getHeaderView()-> FeedTopBarView{
         let likeView = Bundle.main.loadNibNamed(Const.feedTopBar, owner: self, options: nil)?.first as! FeedTopBarView
         return likeView
     }
    
    func getCommentView()-> FeedCommentBarView   {
        let likeView = Bundle.main.loadNibNamed("FeedCommentBarView", owner: self, options: nil)?.first as! FeedCommentBarView
        return likeView
    }
    
    func getAudioPlayerView()-> XQAudioPlayer   {
           let audioPlayer = Bundle.main.loadNibNamed(Const.XQAudioPlayer, owner: self, options: nil)?.first as! XQAudioPlayer
           return audioPlayer
       }
}
