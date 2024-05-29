//
//  StoryReplyView.swift
//  kalam
//
//  Created by Raza najam on 12/6/21.
//  Copyright © 2021 apple. All rights reserved.
//

import UIKit
import GrowingTextView
class StoryReplyView: UIView {
    @IBOutlet weak var nameLbl:UILabel!
    @IBOutlet weak var descLbl:UILabel!
    @IBOutlet weak var typeImageView:UIImageView!
    @IBOutlet weak var thumbImageView:UIImageView!
    
    @IBOutlet weak var replySendBtn:UIButton!
    @IBOutlet weak var replyTxtView: GrowingTextView!{
        didSet {
            replyTxtView.text = Constants.chatScreenMessages.placeholder
            replyTxtView.textColor = UIColor.lightGray
            replyTxtView.delegate = self
            replyTxtView.backgroundColor = .white
            replyTxtView.trimWhiteSpaceWhenEndEditing = true
            replyTxtView.roundCorners(radius: 15, bordorColor: .lightGray, borderWidth: 0.5)
            replyTxtView.placeholderColor = UIColor(white: 0.8, alpha: 1.0)
            replyTxtView.minHeight = 40
            replyTxtView.maxHeight = 120.0
            replyTxtView.makeFontDynamicBody()
        }
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}

extension StoryReplyView:UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        return true
    }
    
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        //        UIView.animate(withDuration: 0.2) { [weak self] in
        //            self?.view.layoutIfNeeded()
        //        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool  {
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.replyTxtView.resignFirstResponder()
        if textView.text.isEmpty {
            textView.text = Constants.chatScreenMessages.placeholder
            textView.textColor = UIColor.lightGray
            self.replyTxtView.resignFirstResponder()
        }
    }
}
