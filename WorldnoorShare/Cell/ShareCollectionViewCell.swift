//
//  ShareCollectionViewCell.swift
//  WorldnoorShare
//
//  Created by Raza najam on 7/6/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class ShareCollectionViewCell: ParentCollectionCell {
    var createPostView:CreatePostView? = nil
    var currentIndexPath:IndexPath = IndexPath(row: 0, section: 0)
    @IBOutlet weak var postBgView: UIView!
    
    override func awakeFromNib() {
        self.createPostView = Bundle.main.loadNibNamed(Const.createPostView, owner: self, options: nil)?.first as? CreatePostView
        //self.createPostView?.frame = self.postBgView.frame
    }
    
    func manageImageData(indexValue:Int,cellSize:CGRect, showLangBar:Bool, index:IndexPath, newObj:ShareCollectionViewObject) {
        self.currentIndexPath = index
        if self.createPostView != nil {
            self.createPostView?.removeFromSuperview()
        }
        self.postBgView.addSubview(self.createPostView!)
        let screenSize: CGRect = UIScreen.main.bounds
        self.createPostView!.widthConst.constant = screenSize.width
        //self.createPostView!.heightConst.constant = cellSize.height
        
        if showLangBar {
            self.createPostView!.heightConst.constant = 240
            self.createPostView?.center = self.postBgView.center
            self.createPostView?.myImageView.contentMode = .scaleAspectFill
            self.createPostView?.langDropDownView.isHidden = false
        }else {
            self.createPostView?.langDropDownView.isHidden = true
            self.createPostView?.myImageView.contentMode = .scaleAspectFit
            self.createPostView!.heightConst.constant = cellSize.height
            self.createPostView?.frame = CGRect(x: 0, y: 0, width: self.createPostView!.frame.size.width, height: self.createPostView!.frame.size.height)
        }
        self.createPostView!.myImageView.heightAnchor.constraint(equalToConstant: self.createPostView!.heightConst.constant).isActive = true
        self.createPostView!.myImageView!.widthAnchor.constraint(equalToConstant: self.createPostView!.widthConst.constant).isActive = true
        self.createPostView!.dropDownBtn.addTarget(self, action: #selector(dropDownBtnClicked), for: .touchUpInside)
        if newObj.langName != "" {
            self.createPostView!.dropDownBtn.setTitle(" "+newObj.langName, for: .normal)
        }
    }
    
    func manageLanguage(langName:String){
        self.createPostView!.dropDownBtn.setTitle(" "+langName, for: .normal)
    }
    
    func manageAudio(showLangBar:Bool = false, indexPath:IndexPath){
        self.currentIndexPath = indexPath
        if self.createPostView != nil {
            self.createPostView?.removeFromSuperview()
        }
        self.postBgView.addSubview(self.createPostView!)
        self.createPostView?.langDropDownView.isHidden = false
    }
    
     @objc func dropDownBtnClicked() {
        SharePostHandler.shared.showLangSelectionHandler?(self.currentIndexPath)
    }
}

//extension PostCollectionViewCell: MakeDropDownDataSourceProtocol{
//    @objc func dropDownBtnClicked() {
//        self.dropDown.showDropDown(height: 20 * 10)
//    }
//
//    func getDataToDropDown(cell: UITableViewCell, indexPos: Int, makeDropDownIdentifier: String) {
//        if makeDropDownIdentifier == "DROP_DOWN_NEW"{
//            let customCell = cell as! DropDownTableViewCell
//            customCell.countryNameLabel.text = self.lanaguageModelArray[indexPos].languageName
//        }
//    }
//
//    func numberOfRows(makeDropDownIdentifier: String) -> Int {
//        return self.lanaguageModelArray.count
//    }
//
//    func selectItemInDropDown(indexPos: Int, makeDropDownIdentifier: String) {
//        self.selectedLangModel = self.lanaguageModelArray[indexPos]
//        let languageName = self.lanaguageModelArray[indexPos].languageName
//        let languageID = self.lanaguageModelArray[indexPos].languageID
//        self.createPostView!.dropDownBtn.setTitle(" "+languageName, for: .normal)
//        self.dropDown.hideDropDown()
//        CreatePostHandler.shared.videoLangChangeHandler?(self.currentIndexPath, languageID)
//    }
//
//    func setUpDropDown(){
//        dropDown.makeDropDownIdentifier = "DROP_DOWN_NEW"
//        dropDown.cellReusableIdentifier = "dropDownCell"
//        dropDown.makeDropDownDataSourceProtocol = self
//        var frm = CGRect(x: 0, y: 0, width: 0, height: 0)
//        if UIDevice.current.hasNotch {
//            frm = CGRect(x: 37 + self.createPostView!.dropDownBtn.frame.origin.x, y: self.createPostView!.langDropDownView.frame.origin.y - 182, width: self.createPostView!.dropDownBtn.frame.size.width, height: self.createPostView!.dropDownBtn.frame.size.height)
//        } else {
//            frm = CGRect(x: 37 + self.createPostView!.dropDownBtn.frame.origin.x, y: self.createPostView!.langDropDownView.frame.origin.y - 182, width: self.createPostView!.dropDownBtn.frame.size.width, height: self.createPostView!.dropDownBtn.frame.size.height)
//        }
//        dropDown.setUpDropDown(viewPositionReference: (frm), offset: 0)
//        dropDown.nib = UINib(nibName: "DropDownTableViewCell", bundle: nil)
//        dropDown.setRowHeight(height: self.dropDownRowHeight)
//        self.addSubview(dropDown)
//        self.populateLangugaeData()
//        self.viewLanguageModel.langugageHandlerDetected = { [weak self] (langugageID) in
//            self?.selectedLangModel = self?.lanaguageModelArray[(langugageID-1)]
//            self!.createPostView!.dropDownBtn.setTitle(" "+(self?.selectedLangModel?.languageName)!, for: .normal)
//        }
//    }
//
//    func populateLangugaeData(){
//        self.lanaguageModelArray = self.viewLanguageModel.populateLangData()
//    }
//}
