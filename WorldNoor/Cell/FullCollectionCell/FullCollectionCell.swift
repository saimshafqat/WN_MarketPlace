//
//  FullCollectionCell.swift
//  WorldNoor
//
//  Created by Raza najam on 11/1/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import WebKit

class FullCollectionCell: UICollectionViewCell {
    override var frame: CGRect {
        didSet {
            if frame.size != oldValue.size { setZoomScale() }
        }
    }
    
    var dismissClosure: (()->())?
    var cellSize:CGSize = CGSize(width: 0, height: 0)
    @IBOutlet weak var dateLbl: UILabel!
    
    
    
    @IBOutlet var imgScrollView: ImageScrollView!
    @IBOutlet weak var bgWidthConst: NSLayoutConstraint!
    @IBOutlet weak var bgHeightConst: NSLayoutConstraint!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var bgView: UIView!
    
    
    @IBOutlet var webViewMain : WKWebView!
    @IBOutlet var viewWebBG : UIView!
    @IBOutlet var activityView : UIActivityIndicatorView!
    
    
    var AttachmentCell : AttachmentCollectionCell? = nil
    
    override func awakeFromNib() {
        self.viewWebBG.isHidden = true
    }
    
    
    func addAttachView(postFile:PostFile){
        self.viewWebBG.isHidden = false
        self.viewWebBG.backgroundColor = UIColor.clear
        webViewMain.backgroundColor = UIColor.clear
        let url = URL(string: postFile.filePath!)
        webViewMain.load(URLRequest(url: url!))
        
    }
    
    func manageImageData(indexValue:Int,cellSize:CGSize, postFile:PostFile) {
        
        self.cellSize = cellSize
        
        
        
        if postFile.fileType == FeedType.file.rawValue {
            self.addAttachView(postFile: postFile)
        }else {
//            self.imgView.sd_setImage(with: URL(string: postFile.filePath ?? ""), placeholderImage: UIImage(named: "placeholder.png"))
            
            self.imgView.loadImageWithPH(urlMain: postFile.filePath ?? "")
            self.labelRotateCell(viewMain: self.imgView)
        }
        
        self.manageConstraint()
        self.manageScrollView()
    }
    
    func manageImageDataOfComment(indexValue:Int,cellSize:CGSize, commentObj:CommentFile) {
        self.cellSize = cellSize
//        self.imgView.sd_setImage(with: URL(string: commentObj.url ?? ""), placeholderImage: UIImage(named: "placeholder.png"))
        
        self.imgView.loadImageWithPH(urlMain: commentObj.url ?? "")
        self.labelRotateCell(viewMain: self.imgView)
        self.manageConstraint()
        self.manageScrollView()
    }
    
    func manageConstraint(){
        self.bgView.translatesAutoresizingMaskIntoConstraints = false
        let screenSize: CGRect = UIScreen.main.bounds
        self.bgWidthConst.constant = screenSize.width
        self.bgHeightConst.constant = self.cellSize.height
        self.imgView.heightAnchor.constraint(equalToConstant: self.bgHeightConst.constant).isActive = true
        self.imgView!.widthAnchor.constraint(equalToConstant: self.bgWidthConst.constant).isActive = true
    }
    
    func manageScrollView(){
        self.imgView.sizeToFit()

        self.imgScrollView.contentSize = self.bgView.bounds.size
        
        if #available(iOS 11.0, *) {
            self.imgScrollView.contentInsetAdjustmentBehavior = .never
        } else {    
            // Fallback on earlier versions
        } // Adjust content according to safe area if necessary
        self.imgScrollView.showsVerticalScrollIndicator = false
        self.imgScrollView.showsHorizontalScrollIndicator = false
        self.imgScrollView.alwaysBounceHorizontal = true
        self.imgScrollView.alwaysBounceVertical = true
        self.imgScrollView.delegate = self
        self.setZoomScale()
    }
    
    func setZoomScale() {
        let widthScale = self.bgView.frame.size.width / self.imgView.bounds.width
        let heightScale = self.bgView.frame.size.height / self.imgView.bounds.height
        let minScale = min(widthScale, heightScale)
        self.imgScrollView.minimumZoomScale = minScale
        self.imgScrollView.zoomScale = minScale
    }
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        self.dismissClosure?()
    }
}

extension FullCollectionCell:UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension FullCollectionCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imgView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let imageViewSize = self.imgView.frame.size
        let scrollViewSize = scrollView.bounds.size
        let verticalInset = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalInset = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }
}
