//
//  ImageCellThree.swift
//  WorldNoor
//
//  Created by Raza najam on 9/17/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit

class ImageCellThree: FeedParentCell {
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var commentView: UIView!
    
    var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    var identifier: String {
        return String(describing: self)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.addingCommentViewInsideCell()
//        self.addingHeaderViewInsideCell()
       
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
//    func addingCommentViewInsideCell(){
//        let likeView = Bundle.main.loadNibNamed(Const.likeBarViewName, owner: self, options: nil)?.first as! FeedCommentBarView
//        self.commentView.addSubview(likeView)
//    }
//    
//    func addingHeaderViewInsideCell(){
//        let likeView = Bundle.main.loadNibNamed(Const.feedTopBar, owner: self, options: nil)?.first as! FeedTopBarView
//        self.topBar.addSubview(likeView)
//    }
}
