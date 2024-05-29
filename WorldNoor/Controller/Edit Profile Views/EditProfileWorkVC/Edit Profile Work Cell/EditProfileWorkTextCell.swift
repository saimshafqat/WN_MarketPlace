//
//  EditProfileWorkTextCell.swift
//  WorldNoor
//
//  Created by apple on 1/20/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class EditProfileWorkTextCell : UITableViewCell {
    @IBOutlet var lblHeading : UILabel!
    @IBOutlet var txtFieldMain : UITextField!
}


class EditProfileWorkTextViewCell : UITableViewCell {
    @IBOutlet var lblHeading : UILabel!
    @IBOutlet var txtViewMain : UITextView!
}


class EditProfileWorkCheckBoxCell : UITableViewCell {
    @IBOutlet var imgViewTick : UIImageView!
    @IBOutlet var btntick : UIButton!
}


class EditProfilePhoneTextCell : UITableViewCell {
    @IBOutlet var lblHeading : UILabel!
    @IBOutlet var txtFieldMain : UITextField!
    @IBOutlet var txtFieldCountry : UITextField!
}
