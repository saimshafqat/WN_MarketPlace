//
//  TextBackgroundController.swift
//  WorldNoor
//
//  Created by Raza najam on 11/21/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import CommonKeyboard
//import IQKeyboardManagerSwift

protocol ImageTextBgDelegate {
    func imageTextSaved(img: UIImage)
}

class TextBackgroundController: UIViewController {
    @IBOutlet weak var bgImageCollectionBottomConst: NSLayoutConstraint!
    @IBOutlet weak var txtViewBgImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewColors: UICollectionView!
    @IBOutlet weak var txtViewBG: UIView!
    @IBOutlet weak var txtView: TextViewCenter!
    
    let keyboardObserver = CommonKeyboardObserver()
    var bgArray:[String] = []
    var bgColorArray:[UIColor] = []
    var delegate: ImageTextBgDelegate?
    var keyboardHeightVar = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionViewColors.tag = 100
        self.txtView.delegate = self
        
        self.bgArray.removeAll()
        
        
        for index in 1...70 {
            self.bgArray.append("etbg" + String(index) + ".jpg")
        }
        
//        self.bgArray = ["etbg1.jpg","etbg2.jpg","etbg3.jpg","etbg4.jpg","etbg5.jpg","etbg6.jpg","etbg7.jpg","etbg8.jpg","etbg9.jpg","etbg10.jpg",
//            "etbg11.jpg","etbg12.jpg","etbg13.jpg","etbg14.jpg","etbg15.jpg","etbg16.jpg","etbg17.jpg","etbg18.jpg","etbg19.jpg","etbg20.jpg",
//            "etbg21.jpg","etbg22.jpg","etbg23.jpg","etbg4.jpg","etbg5.jpg","etbg6.jpg","etbg7.jpg","etbg8.jpg","etbg9.jpg","etbg10.jpg",
//            "etbg1.jpg","etbg2.jpg","etbg3.jpg","etbg4.jpg","etbg5.jpg","etbg6.jpg","etbg7.jpg","etbg8.jpg","etbg9.jpg","etbg10.jpg",
//            "etbg1.jpg","etbg2.jpg","etbg3.jpg","etbg4.jpg","etbg5.jpg","etbg6.jpg","etbg7.jpg","etbg8.jpg","etbg9.jpg","etbg10.jpg",
//            "etbg1.jpg","etbg2.jpg","etbg3.jpg","etbg4.jpg","etbg5.jpg","etbg6.jpg","etbg7.jpg","etbg8.jpg","etbg9.jpg","etbg10.jpg",]
        self.bgColorArray = [.black ,
                             .yellow ,
                             .red ,
                             .magenta ,
                             .green ,
                             .cyan ,
                             .blue ,
                             .brown ,
                             .darkGray ,
                             .gray,
                             .orange ,
                             .purple
        ]
        self.manageKeyboard()
        self.manageTextView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        IQKeyboardManager.shared.enableAutoToolbar = false
//        IQKeyboardManager.shared.enable = false

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        txtView.centerVertically()
        self.txtView.text = Const.textViewPlaceholder.localized()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        IQKeyboardManager.shared.enableAutoToolbar = true
//        IQKeyboardManager.shared.enable = true
//    }
    
    func manageTextView(){
        self.txtView.tag = 20
     }
    
    @IBAction func backBtnClicked(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneBtnClicked(_ sender: Any) {
        self.txtView.resignFirstResponder()
        if self.txtView.text == Const.textViewPlaceholder.localized() {
            self.txtView.text = ""
        }
        self.delegate?.imageTextSaved(img: self.txtViewBG.takeScreenshot())
        self.dismiss(animated: true, completion: nil)
    }
    
    func manageKeyboard(){
        //        keyboardObserver.subscribe(events: [.willShow]) { [weak self] (info) in
        keyboardObserver.subscribe(events: [.willChangeFrame,.dragDown]) { [weak self] (info) in
            guard let weakSelf = self else { return }
            var bottom = 0.0
            weakSelf.keyboardHeightVar = 0.0
            if info.isShowing {
                bottom = Double(-info.visibleHeight)
                weakSelf.keyboardHeightVar = bottom
                if #available(iOS 11, *) {
                    let guide = weakSelf.view.safeAreaInsets
                    bottom = bottom + Double(guide.bottom)
                    weakSelf.keyboardHeightVar = bottom
                }
                CommonKeyboard.shared.enabled = false
            }
            UIView.animate(info, animations: { [weak self] in
                self?.bgImageCollectionBottomConst.constant = CGFloat(-bottom+3)
                self?.view.layoutIfNeeded()
            })
        }
    }
}

extension TextBackgroundController:UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 100 {
            return self.bgColorArray.count
        }
        return self.bgArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Const.KTextBGCollectionCell, for: indexPath) as? TextBGCollectionCell else {
           return UICollectionViewCell()
        }
        
        if collectionView.tag == 100 {
            
            cell.imgView.image = UIImage.imageWithColor(color: self.bgColorArray[indexPath.row], size: cell.imgView.frame.size)
        }else {
            cell.imgView.image = UIImage(named: self.bgArray[indexPath.row])
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        
        
        if let cellMain = collectionView.cellForItem(at: indexPath) as? TextBGCollectionCell {
            self.txtViewBgImageView.image = cellMain.imgView.image
        }
        
//        if collectionView.tag == 100 {
//            self.txtViewBgImageView.image = UIImage(named: self.colo[indexPath.row])
//        }else {
//            self.txtViewBgImageView.image = UIImage(named: self.bgArray[indexPath.row])
//        }
        
    }
}

extension TextBackgroundController:UITextViewDelegate   {
    func textViewDidChange(_ textView: UITextView) {
        textView.centerVertically()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
         if self.txtView.tag == 20 {
             self.txtView.text = nil
             self.txtView.textColor = UIColor.white
            self.txtView.tag = 21
         }
     }
     
     func textViewDidEndEditing(_ textView: UITextView) {
         if self.txtView.text.isEmpty {
             self.txtView.text = Const.textViewPlaceholder.localized()
             self.txtView.textColor = UIColor.white
             self.txtView.tag = 20
         }
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
                   self?.bgImageCollectionBottomConst.constant = CGFloat(5.0)
                   self?.view.layoutIfNeeded()
               })
     }
}
