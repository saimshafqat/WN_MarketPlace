//
//  SkeletonCell.swift
//  WorldNoor
//
//  Created by Raza najam on 10/18/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
class SkeletonCell: FeedParentCell {
    @IBOutlet weak var imgLbl: DesignableImageView!
    @IBOutlet weak var firstLbl: UILabel!
    @IBOutlet weak var secondLbl: UILabel!
    @IBOutlet weak var thirdLbl: UILabel!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var img2Lbl: DesignableImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        @IBOutlet weak var firstLbl: UILabel!
//          @IBOutlet weak var secondLbl: UILabel!
//          @IBOutlet weak var thirdLbl: UILabel!
//          @IBOutlet weak var btn1: UIButton!
//          @IBOutlet weak var btn2: UIButton!
//          @IBOutlet weak var btn3: UIButton!
//          @IBOutlet weak var img2Lbl:
//

        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    static var nib:UINib {
//           return UINib(nibName: identifier, bundle: nil)
//       }
//
//    static var identifier: String {
//           return String(describing: self)
//       }

    func enableSkeleton(){
//        self.firstLbl.showAnimatedSkeleton()
//                self.secondLbl.showAnimatedSkeleton()
//                self.thirdLbl.showAnimatedSkeleton()
//                self.btn1.showAnimatedSkeleton()
//                self.btn2.showAnimatedSkeleton()
//                self.btn3.showAnimatedSkeleton()
//                self.imgLbl.showAnimatedSkeleton()
//                self.img2Lbl.showAnimatedSkeleton()
    }

}
