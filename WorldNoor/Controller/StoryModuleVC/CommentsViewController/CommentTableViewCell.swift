//
//  CommentTableViewCell.swift
//  RDT
//
//  Created by Shahriyar Ahmed on 12/9/21.
//

import UIKit
protocol ReelsCommentDelegate{
    func didPressEditBtn(_ sender: UIButton)
    func didPressDeleteBtn(_ sender: UIButton)
    func didPressCancelBtn(_ sender: UIButton)
    func didPressUpdateBtn(_ sender: UIButton)
}

class CommentTableViewCell: UITableViewCell {

    var delegate: ReelsCommentDelegate?
    
    @IBOutlet weak var cancelEditBtn: UIButton!
    @IBOutlet weak var updateCommentBtn: UIButton!
    @IBOutlet weak var editTextView: UITextView!
    @IBOutlet weak var editablebgV: UIView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var userBtnbgV: UIView!
    @IBOutlet weak var lblReceiveChat: UILabel!
    @IBOutlet weak var lblSendChectCell: UILabel!
    @IBOutlet weak var lblReceveTime: UILabel!
    @IBOutlet weak var lblSendTime: UILabel!
    @IBOutlet weak var imgReceive: UIImageView!
    @IBOutlet weak var imgSend: UIImageView!
    @IBOutlet weak var viewReceive: UIView!
    @IBOutlet weak var viewSend: UIView!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var userProfilePic: UIImageView!
    
    
    var comment: Comment? {
        didSet {
            guard let comment = comment else { return }
            authorName.dynamicSubheadRegular15()
            lblReceiveChat.dynamicFootnoteRegular13()
            lblReceveTime.dynamicCaption2Regular11()
            
            lblReceiveChat.text = comment.body
            lblReceveTime.text = comment.commentTime
        
            if comment.author != nil {
                userProfilePic.setImage(url: (comment.author?.profileImage)!)
                authorName.text = (comment.author?.firstname)! + " " + (comment.author?.lastname)!
                userBtnbgV.isHidden = comment.userID == SharedManager.shared.getUserID() ? false : true
                editTextView.text = comment.body
            }
            viewReceive.roundCorners()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.userProfilePic.roundCorners()
        // Initialization code
        setEditbgVUI()
   
    }
    override func prepareForReuse() {
       super.prepareForReuse()
       lblReceiveChat.text = nil
       lblReceiveChat.dynamicFootnoteRegular13()
   }

    func setEditbgVUI(){
        editablebgV.isHidden = true
        editTextView.autocorrectionType = .no
        editTextView.spellCheckingType = .no
        editTextView.layer.cornerRadius = 6
        editTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        editTextView.layer.borderWidth = 1
        editTextView.layer.borderColor = UIColor.gray.cgColor
        deleteBtn.setTitleColor(UIColor.init().hexStringToUIColor(hex: "EB0A1E"), for: .normal)
        deleteBtn.setTitle("Delete".localized(), for: .normal)
        editBtn.setTitle("Edit".localized(), for: .normal)
        cancelEditBtn.setTitle("Cancel".localized(), for: .normal)
        updateCommentBtn.setTitle("Save".localized(), for: .normal)
        updateCommentBtn.setTitleColor(.white, for: .normal)
        updateCommentBtn.backgroundColor = UIColor.init().hexStringToUIColor(hex: "1967D8")
        cancelEditBtn.layer.borderWidth = 1
        cancelEditBtn.layer.borderColor = UIColor.gray.cgColor
        cancelEditBtn.setTitleColor(UIColor.gray, for: .normal)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func editBtnPressed(_ sender: Any) {
        delegate?.didPressEditBtn(editBtn)
    }
    @IBAction func deleteBtnPressed(_ sender: Any) {
        delegate?.didPressDeleteBtn(deleteBtn)
    }
    @IBAction func updateCommentPressed(_ sender: Any) {
        delegate?.didPressUpdateBtn(updateCommentBtn)
    }
    @IBAction func cancelBtnPressed(_ sender: Any) {
        delegate?.didPressCancelBtn(cancelEditBtn)
    }
    
}
