//
//  NewSignupCell.swift
//  WorldNoor
//
//  Created by apple on 6/25/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import CountryPickerView

class SULogoCell : UITableViewCell {
    
//    @IBOutlet weak var viewLng: UIView!
//    @IBOutlet weak var imgLng: UIImageView!
//    @IBOutlet var lblLng : UILabel!
//    @IBOutlet var imgViewLogo : UIImageView!
    @IBOutlet var lblHeading : UILabel!
//    @IBOutlet var btnLng : UIButton!
    
    @IBOutlet var btnback : UIButton!
    @IBOutlet var viewBack : UIView!
    
    @IBOutlet weak var userLbl: UILabel!
}

protocol setEmailAndPasswordDelegate {
    func setEmailAndPasswordDelegate(emailPassTF : UITextField)
}

class SUTFCell : UITableViewCell  {
    @IBOutlet var imgViewMain : UIImageView!
    @IBOutlet var lblHeading : UILabel!
    @IBOutlet var lblbottomHeading : UILabel!
    @IBOutlet var tfMain : UITextField!
    @IBOutlet weak var seenUnseenImg: UIImageView!
    @IBOutlet weak var seenUnseenBtn: UIButton!
}
class FandLNameCell : UITableViewCell  {
   
    @IBOutlet var lblHeading : UILabel!
    @IBOutlet var lblbottomHeading : UILabel!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var LastNameLbl: UILabel!
}


class PhoneEmailCell: UITableViewCell
{
    @IBOutlet var imgViewMain : UIImageView!
    @IBOutlet var lblHeading : UILabel!
    @IBOutlet var lblbottomHeading : UILabel!
    @IBOutlet var tfMain : UITextField!
    @IBOutlet weak var viewPhone: UIView!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var phonecodeBtn: UIButton!
    var countryCode = ""
    var emailPassDelegate :setEmailAndPasswordDelegate!
    @IBOutlet weak var phoneCodeLbl: UILabel!{
        didSet{
            phoneCodeLbl.makeFontDynamicBody()
        }
    }
    let pickerView = CountryPickerView()
    @objc func updateText(){
        let stringFirst = String(self.tfMain.text!.prefix(3))
        
        
        if self.tfMain.text!.count > 2 {
            
            if Int(stringFirst) != nil {
                if self.viewPhone.isHidden {
                    self.viewPhone.isHidden = false
                    self.tfMain.isHidden = true
                    self.phoneTF.text! = self.tfMain.text!
                    self.phoneTF.becomeFirstResponder()

                }
              
            }
        }else if self.phoneTF.text!.count < 3 {
            
                }
    }
    @objc func updateTextForgot(){
        let stringFirst = String(self.phoneTF.text!.prefix(3))
        
        if self.phoneTF.text!.count < 3 {
            
            
            if !self.viewPhone.isHidden {
                
                self.viewPhone.isHidden = true
                self.tfMain.isHidden = false
                
                self.tfMain.text! = self.phoneTF.text!
                self.tfMain.becomeFirstResponder()
            }
        }
    }
}
extension PhoneEmailCell: UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 111 {
            _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateText), userInfo: nil, repeats: false)
        }else if textField.tag == 222 {
            _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateTextForgot), userInfo: nil, repeats: false)
        }
        
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        self.emailPassDelegate.setEmailAndPasswordDelegate(emailPassTF: textField)
    }
}


class SUCountryCell : UITableViewCell {
    @IBOutlet var lblHeading : UILabel!
    @IBOutlet var lblInfo : UILabel!
    
    
    @IBOutlet var lblYear : UILabel!
    @IBOutlet var tfYear : UITextField!
    
    @IBOutlet var lblMonth : UILabel!
    @IBOutlet var tfMonth : UITextField!
    
    @IBOutlet var lblDay : UILabel!
    @IBOutlet var tfDay : UITextField!
    
}

class SUCustomGenderCell : UITableViewCell {
    @IBOutlet weak var customTitleLbl: UILabel!
    @IBOutlet weak var pronounLbl: UILabel!
    @IBOutlet weak var genderTF: UITextField!
    @IBOutlet weak var btnDropDown: UIButton!
    
}

class SUBackCell : UITableViewCell {
    
    @IBOutlet weak var btnBack: UIButton!
}
class SUGenderCell : UITableViewCell {
    
    @IBOutlet weak var tfMale: UITextField!
    @IBOutlet weak var tfFemale: UITextField!
    @IBOutlet weak var tfCustom: UITextField!
    
    @IBOutlet var lblHeading : UILabel!
    @IBOutlet var lblInfo : UILabel!
    @IBOutlet var lblYear : UILabel!
    @IBOutlet var lblMonth : UILabel!
    @IBOutlet var lblDay : UILabel!
}


class SUButtonCell : UITableViewCell {
    @IBOutlet var lblHeading : UILabel!
    @IBOutlet var btnMain : UIButton!
    @IBOutlet var viewBG : UIView!
    @IBOutlet var viewLine : UIView!
}


class SUButtonLogoutCell : UITableViewCell {
    @IBOutlet var lblHeading : UILabel!
    @IBOutlet var btnMain : UIButton!
    @IBOutlet var viewBG : UIView!
    @IBOutlet var viewLine : UIView!
}


class SUTextViewCell : UITableViewCell {
    @IBOutlet var lblHeading : UILabel!
    @IBOutlet var btnMain : UIButton!
}

class SUPhoneCell : UITableViewCell {
    @IBOutlet var lblHeading : UILabel!
    @IBOutlet var lblCode : UILabel!
    @IBOutlet var tfPhone : UITextField!
    @IBOutlet var btnCode : UIButton!
    
    @IBOutlet weak var phoneNumbView: UIView!{
        didSet {
            phoneNumbView.roundedLeftTopBottom()
        }
    }
    
    @IBOutlet weak var phoneNumbLblView: UIView!{
        didSet {
            phoneNumbLblView.roundRight(bordorColor: UIColor.themeBlueColor, borderWidth: 0.5)
        }
    }
    
    override func awakeFromNib() {
        let locale = Locale.current
        let countCode = FindPhoneCode.shared.getCountryPhonceCode(locale.regionCode ?? "")
        if countCode != "" {
            lblCode.text = "+" + countCode
        }
    }
}




class SUButtonLoginCell : UITableViewCell {
    @IBOutlet var lblLogin : UILabel!
    @IBOutlet var btnLogin : UIButton!
    @IBOutlet var lblHeading : UILabel!
}
