//
//  CategoryLikeCell.swift
//  WorldNoor
//
//  Created by HAwais on 31/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

protocol CategoryLikeDelegate: AnyObject {
    func deleteCategory(obj: LikePageModel?, at index: Int?, pageTab: String)
}

class CategoryLikeCell: UITableViewCell {
    
    // MARK: - Properties -
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    var isFromProfile: Bool = false
    var index: Int? = 0
    var likePageModel: LikePageModel?
    var categoryLikeDelegate: CategoryLikeDelegate?
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
        categoryLikeDelegate?.deleteCategory(obj: likePageModel, at: index, pageTab: pageTab)
    }
    
    // MARK: - Methods
    func imageLayout() {
        imgPage.layer.cornerRadius = imgPage.frame.width / 2
        imgPage.layer.borderWidth = 1
        imgPage.layer.borderColor = UIColor.lightGray.cgColor
        imgPage.clipsToBounds = true
    }
    
    func configureCell(obj: LikePageModel?, index: Int?, pageTab: String) {
        self.index = index
        self.likePageModel = obj
        self.pageTab = pageTab
        deleteView.isHidden = self.isFromProfile
        lblTitle.text = obj?.title
        lblCategory.text = obj?.name
        imgPage.loadImageWithPH(urlMain: obj?.profile ?? .emptyString)
    }
}
