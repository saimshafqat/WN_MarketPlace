//
//  ProfileNewImageHeaderCell.swift
//  WorldNoor
//
//  Created by apple on 12/30/22.
//  Copyright © 2022 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class ProfileNewImageHeaderCell : UITableViewCell {
    
    @IBOutlet var imgViewBanner : UIImageView!
    @IBOutlet var imgViewLogo : UIImageView!
    @IBOutlet var imgViewProfile : UIImageView!
    
    @IBOutlet weak var cstwidth: NSLayoutConstraint!
    
    @IBOutlet weak var cstBackwidth: NSLayoutConstraint!
    
    @IBOutlet var viewBanner : UIView!
    @IBOutlet var viewProfile : UIView!
    @IBOutlet var viewBack : UIView!
    @IBOutlet var viewMore : UIView!
    @IBOutlet var viewlanguage : UIView!
    
    @IBOutlet var viewAddMessage : UIView!
    @IBOutlet var viewAddUSer : UIView!
    @IBOutlet var btnAddMessage : UIButton!
    @IBOutlet var btnAddUSer : UIButton!
    @IBOutlet var imgViewAddUSer : UIImageView!
    
    @IBOutlet var btnCoverPhoto : UIButton!
    @IBOutlet var btnProfilePhoto : UIButton!
    
    @IBOutlet var btnViewCoverPhoto : UIButton!
    @IBOutlet var btnViewProfilePhoto : UIButton!
    @IBOutlet var btnViewLanguage : UIButton!
    @IBOutlet var btnMore : UIButton!
    @IBOutlet var btnBack : UIButton!
    
    @IBOutlet var btnDelete : UIButton!
    @IBOutlet var btnUpload : UIButton!
    @IBOutlet var viewDelete : UIView!
    
    @IBOutlet var btnSearch : UIButton!
    
    @IBOutlet weak var uploadingImageLoadingView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}
