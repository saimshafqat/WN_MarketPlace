//
//  GroupPhotoCell.swift
//  WorldNoor
//
//  Created by Waseem Shah on 19/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class GroupPhotoCell : UICollectionViewCell  , UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var viewBG: UIView!
    
    var viewWidth : CGFloat = 0.0
    
    var arrayImages = [Any]()
    
    var isImage = false
    var isAPICallInProgress : Bool = false
    var delegate: ProfileImageSelectionDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib.init(nibName: "ProfileImageCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ProfileImageCollectionCell")
        self.collectionView.reloadData()
        
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    
    func reloadView() {
        self.collectionView.reloadData()
    }
    
   
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.arrayImages.count == 0 && self.isAPICallInProgress {
            return 6
        }
        return self.arrayImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileImageCollectionCell", for: indexPath as IndexPath) as? ProfileImageCollectionCell else {
           return UICollectionViewCell()
        }
        
        cell.viewShimmer.stopAnimating()
        if self.arrayImages.count == 0 && self.isAPICallInProgress {
            cell.viewShimmer.startAnimating()
        }else {
            cell.imgViewPlay.isHidden = true
            cell.btnPlay.isHidden = true
            cell.viewLoading.isHidden = true
            cell.imgViewAddNew.isHidden = true
            cell.viewTranscript.isHidden = true
            self.labelRotateCell(viewMain: cell.lblTranscript)
            cell.lblTranscript.rotateForTextAligment()
            
            if isImage {
                cell.imgViewPlay.isHidden = true
                
                
                
                if let newString = self.arrayImages[indexPath.row] as? String {
                    
                    if newString == "-1" {
                        cell.imgViewAddNew.image = UIImage.init(named: "AddNewPlaceHolder")
                        cell.imgViewAddNew.isHidden = false
                    }else {
                        self.DownloadImage(imgview: cell.imgViewMain, URL: newString)
                    }
                }else {
                    cell.imgViewMain.image = (self.arrayImages[indexPath.row] as! UIImage)
                }
                
                cell.btnPlay.isHidden = true
                
            }else {
                
                cell.imgViewPlay.isHidden = false
                
                if let newString = self.arrayImages[indexPath.row] as? String {
                    if newString == "-1" {
                        cell.imgViewAddNew.image = UIImage.init(named: "AddNewPlaceHolder")
                        cell.imgViewAddNew.isHidden = false
                        cell.viewTranscript.isHidden = true
                    }else {
                        cell.viewTranscript.isHidden = false
                        cell.btnTranscript.tag = indexPath.row
                        cell.btnTranscript.addTarget(self, action: #selector(self.OpenTranscript), for: .touchUpInside)
                        self.DownloadImageonVideo(imgview: cell.imgViewMain, URL: newString)
                    }
                }else {
                    cell.imgViewMain.image = UIImage.init(named: "VideoBlack")
                }
                
                cell.btnPlay.isHidden = true
            }
            
            cell.imgViewMain.backgroundColor = UIColor.clear
        }
        
        
        
        return cell
    }
    @objc func OpenTranscript(sender : UIButton){
        self.delegate?.viewTranscript(tabValue: sender.tag)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize.init(width: (self.viewWidth / 3) - 6, height: (self.viewWidth / 3) - 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if self.arrayImages.count - 1 == indexPath.row {
            self.delegate?.ReloadNewPage()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        var NewValue = indexPath.row
        if self.arrayImages.count - 1 <= indexPath.row {
            if let newString = self.arrayImages[indexPath.row] as? String {
                 if newString == "-1" {
                    NewValue = -1
                }
                
            }
            self.delegate?.profileImageSelection(tabValue: NewValue, isImage: self.isImage)
        }
        
    }
    
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        
        self.collectionView.layoutIfNeeded()
        let contentSize = self.collectionView.collectionViewLayout.collectionViewContentSize
        if self.collectionView.numberOfItems(inSection: 0) < 4 {
            return CGSize(width: self.viewWidth, height: 114)
        }
        
        return CGSize(width: self.viewWidth, height: contentSize.height + 20)
        
    }
    
    func DownloadImage(imgview : UIImageView , URL : String){
        
        if URL.count > 0 {
            if let urlMain =  NSURL(string:  URL)  {
                imgview.loadImageWithPH(urlMain:URL)
                self.labelRotateCell(viewMain: imgview)
            }
            
        }
        
        
    }
    
    func DownloadImageonVideo(imgview : UIImageView , URL : String){
        
        if URL.count > 0 {
            if let urlMain =  NSURL(string:  URL)  {
                
                imgview.loadImageWithPH(urlMain:URL)
                self.labelRotateCell(viewMain: imgview)
            }
            
        }
        
        
    }
}

//class ProfileImageCollectionCell : UICollectionViewCell {
//    @IBOutlet var imgViewMain : UIImageView!
//    
//    @IBOutlet var imgViewAddNew : UIImageView!
//    
//    @IBOutlet var imgViewPlay : UIImageView!
//    @IBOutlet var btnPlay : UIButton!
//    
//    
//    @IBOutlet var viewLoading : UIView!
//    @IBOutlet var viewLoader : UIView!
//    
//    @IBOutlet var viewTranscript : UIView!
//    @IBOutlet var lblTranscript : UILabel!
//    @IBOutlet var btnTranscript : UIButton!
//    
//    
////    func AddLoader(){
////        let frame = CGRect(x: 0, y: 0, width: viewLoader.frame.size.width, height: viewLoader.frame.size.height)
////        let activityIndicator = NVActivityIndicatorView(frame: frame)
////        activityIndicator.type = . ballSpinFadeLoader // add your type
////        activityIndicator.color = UIColor.white // add your color
////
////        viewLoader.addSubview(activityIndicator) // or use  webView.addSubview(activityIndicator)
////        activityIndicator.startAnimating()
////    }
////
//    
//}

