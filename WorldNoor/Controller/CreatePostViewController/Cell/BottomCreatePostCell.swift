//
//  BottomCreatePostCell.swift
//  WorldNoor
//
//  Created by Lucky on 31/10/2019.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit

class BottomCreatePostCell : UICollectionViewCell {
    
    @IBOutlet var imgViewMain : UIImageView!
    @IBOutlet weak var bgView: UIView!
    var createPostView:CreatePostView? = nil
    
    override func awakeFromNib() {
        self.createPostView = Bundle.main.loadNibNamed(Const.createPostView, owner: self, options: nil)?.first as? CreatePostView
        self.createPostView?.langDropDownView.isHidden = true
    }
    
    func manageBottomCollection(indexValue:Int){
        self.bgView.addSubview(self.createPostView!)
        self.createPostView!.translatesAutoresizingMaskIntoConstraints = false
        self.createPostView?.myImageView.contentMode = .scaleAspectFill
        self.createPostView?.topAnchor.constraint(equalTo: self.bgView.topAnchor, constant: 0).isActive = true
        self.createPostView?.bottomAnchor.constraint(equalTo: self.bgView.bottomAnchor, constant: 5).isActive = true
        self.createPostView?.leadingAnchor.constraint(equalTo: self.bgView.leadingAnchor, constant: 5).isActive = true
        self.createPostView?.trailingAnchor.constraint(equalTo: self.bgView.trailingAnchor, constant: 5).isActive = true
        self.createPostView!.widthConst.constant = 80.0
        self.createPostView!.heightConst.constant = 80.0
        self.createPostView?.playButtonWidthConst.constant=20.0
        self.createPostView?.playButtonHeightConst.constant=20.0
        self.createPostView!.heightAnchor.constraint(equalToConstant: self.createPostView!.heightConst.constant).isActive = true
        self.createPostView!.widthAnchor.constraint(equalToConstant: self.createPostView!.widthConst.constant).isActive = true
        self.createPostView!.myImageView.heightAnchor.constraint(equalToConstant: self.createPostView!.heightConst.constant).isActive = true
        self.createPostView!.myImageView!.widthAnchor.constraint(equalToConstant: self.createPostView!.widthConst.constant).isActive = true
    }
}
