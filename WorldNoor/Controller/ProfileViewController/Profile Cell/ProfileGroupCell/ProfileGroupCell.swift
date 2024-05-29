//
//  ProfileGroupCell.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 22/02/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

protocol ProfileGroupDelegate {
    func deleteProfileGroup(obj: GroupValue?, at index: Int?, pageTab: String)
}
class ProfileGroupCell: UITableViewCell {

    // MARK: - Properties -
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    var isFromProfile: Bool = false
    var index: Int? = 0
    var pageGroupModel: GroupValue?
    var profileGroupDelegate: ProfileGroupDelegate?
    var pageTab: String = .emptyString
    
    // MARK: - IBOutlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var imgPage: UIImageView!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var deleteView: UIView!
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        imageLayout()
    }
    
    @IBAction func onClickDelete(_ sender: UIButton) {
       profileGroupDelegate?.deleteProfileGroup(obj: pageGroupModel, at: index, pageTab: pageTab)
    }
    
    // MARK: - Methods
    func imageLayout() {
        imgPage.layer.cornerRadius = imgPage.frame.width / 2
        imgPage.layer.borderWidth = 1
        imgPage.layer.borderColor = UIColor.lightGray.cgColor
        imgPage.clipsToBounds = true
    }
    
    func configureCell(obj: GroupValue?, index: Int?, pageTab: String) {
        self.index = index
        self.pageGroupModel = obj
        self.pageTab = pageTab
        deleteView.isHidden = self.isFromProfile
        lblTitle.text = obj?.groupName
        lblCategory.text = obj?.category
        imgPage.loadImageWithPH(urlMain: obj?.groupImage ?? .emptyString)
    }
}
