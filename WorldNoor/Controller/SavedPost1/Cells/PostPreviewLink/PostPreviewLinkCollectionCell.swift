//
//  PostPreviewLinkCollectionCell.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 27/05/2023.
//

import UIKit

@objc(PostPreviewLinkCollectionCell)
class PostPreviewLinkCollectionCell: PostBaseCollectionCell {
    
    // MARK: - IBOutlets -
    @IBOutlet weak var linkPHImageView: UIImageView!
    @IBOutlet weak var linkImageView: UIImageView!
    @IBOutlet weak var linkTitleLbl: UILabel!
    @IBOutlet weak var linkDescLbl: UILabel!
    @IBOutlet weak var imgViewPlay: UIImageView!
    @IBOutlet weak var imageVideoHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Override
    override func displayCellContent(data: AnyObject?, parentData: AnyObject?, at indexPath: IndexPath) {
        super.displayCellContent(data: data, parentData: parentData, at: indexPath)
        let obj = data as? FeedData
        // let parentObj = parentData as? FeedData
        if let obj {
            let hasYotubeLink = (obj.previewLink ?? .emptyString).contains("youtube")
            setLayoutDesign(height: obj.linkImage?.count ?? 0 > 0 ? 250 : 0, isPlayHide: !(hasYotubeLink), urlStr: obj.linkImage)
            placeHolderVisibility(obj)
            linkTitleLbl.text = obj.linkTitle
            linkDescLbl.text = obj.linkDesc
        }
    }
    
    // MARK: - Methods -
       @IBAction func onClickPlay(_ sender: UIButton) {
           // go to youtube with url link
           UIApplication.topViewController()?.OpenLink(webUrl: postObj?.previewLink ?? .emptyString)
       }
    
    
    // MARK: - Methods -

    func setLayoutDesign(height: CGFloat, isPlayHide: Bool, urlStr: String? = nil) {
        imageVideoHeightConstraint.constant = height
        imgViewPlay.isHidden = isPlayHide
        linkImageView.imageLoad(with: urlStr)
    }
    
    func placeHolderVisibility(_ obj: FeedData) {
        let hasPreviewLink = obj.previewLink?.count ?? 0 > 0
        let hasYoutubeLink = ((obj.previewLink ?? .emptyString).contains("youtube"))
        linkPHImageView.isHidden = hasYoutubeLink || (!hasYoutubeLink && hasPreviewLink)
    }
}
