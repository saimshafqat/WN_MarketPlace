//
//  CreatePostView.swift
//  WorldNoor
//
//  Created by Raza najam on 10/26/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//
import UIKit

class CreatePostView: UIView {
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var myfileImageView: UIImageView!
    @IBOutlet weak var viewButton: UIView!
    @IBOutlet weak var buttonDelete: UIButton!
    @IBOutlet weak var viewPlayButton: UIView!
    @IBOutlet weak var buttonPly: UIButton!
    @IBOutlet weak var widthConst: NSLayoutConstraint!
    @IBOutlet weak var heightConst: NSLayoutConstraint!
    @IBOutlet weak var playButtonWidthConst: NSLayoutConstraint!
    @IBOutlet weak var playButtonHeightConst: NSLayoutConstraint!
    @IBOutlet weak var dropDownBtn: DesignableButton!
    @IBOutlet weak var langDropDownView: UIView!
    
    override func awakeFromNib() {
           super.awakeFromNib()
    }
}

