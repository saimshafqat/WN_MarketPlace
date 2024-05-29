//
//  OptionsPopover.swift
//  WorldNoor
//
//  Created by apple on 7/16/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

protocol OptionsPopoverDelegate: class{
    func selectedActionAtIndex(actionIndex: Int)
}

class OptionsPopover : UIViewController {

     //MARK:- Outlets
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    //MARK:- Properties
    var dataArray = [
        EditOptionsObject(name: "Edit".localized(), id: 1, image: "ChatEdit"  , sImage:"ChatEditS" ,isselected: false),
        EditOptionsObject(name: "Share".localized(), id: 2, image: "ChatShare" , sImage:"ChatShareS" ,isselected: false),
        EditOptionsObject(name: "Copy".localized(), id: 3, image: "ChatCopyN" , sImage: "ChatCopyNS",isselected: false),
        EditOptionsObject(name: "Reply".localized(), id: 4, image: "ChatReply" , sImage: "ChatReplyS",isselected: false),
        EditOptionsObject(name: "Delete".localized(), id: 5, image:"ChatDelete" , sImage: "ChatDeleteS",isselected: false),
        EditOptionsObject(name: "Forward".localized(), id: 6, image: "ChatForwardN", sImage: "ChatForwardNS",isselected: false),
        EditOptionsObject(name: "Pin".localized(), id: 7, image: "ChatPin", sImage: "ChatPinS",isselected: false)
        
//        EditOptionsObject(name: "Edit".localized(), id: 1, image: "Chatedit"  , sImage:"Chatedit" ,isselected: false),
//        EditOptionsObject(name: "Share".localized(), id: 2, image: "Chatshare" , sImage:"Chatshare" ,isselected: false),
//        EditOptionsObject(name: "Copy".localized(), id: 3, image: "ChatCopy" , sImage: "ChatCopy",isselected: false),
//        EditOptionsObject(name: "Reply".localized(), id: 4, image: "Chatreply" , sImage: "Chatreply",isselected: false),
//        EditOptionsObject(name: "Delete".localized(), id: 5, image:"Chatdelete" , sImage: "Chatdelete",isselected: false),
//        EditOptionsObject(name: "Forward".localized(), id: 6, image: "ChatForward", sImage: "ChatForward",isselected: false),
//        EditOptionsObject(name: "Pin".localized(), id: 7, image: "ic_pin", sImage: "ic_pin",isselected: false)
    ]
    
    weak var delegate: OptionsPopoverDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: NSNotification.Name("multipleMessagesSelected"), object: nil, queue: nil) { (action) in
            self.collectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func reloadDatawithOwnMessage(showUnpin: Bool = false){
        self.dataArray.removeAll()
        dataArray = [
//               EditOptionsObject(name: "Edit".localized(), id: 1, image: "Chatedit"  , sImage:"Chatedit" ,isselected: true),
//               EditOptionsObject(name: "Share".localized(), id: 2, image: "Chatshare" , sImage:"Chatshare" ,isselected: true),
//               EditOptionsObject(name: "Copy".localized(), id: 3, image: "ChatCopy" , sImage: "ChatCopy",isselected: true),
//               EditOptionsObject(name: "Reply".localized(), id: 4, image: "Chatreply" , sImage: "Chatreply",isselected: true),
//               EditOptionsObject(name: "Delete".localized(), id: 5, image:"Chatdelete" , sImage: "Chatdelete",isselected: true),
//               EditOptionsObject(name: "Forward".localized(), id: 6, image: "ChatForward", sImage: "ChatForward",isselected: true),
//               EditOptionsObject(name: showUnpin ? "Unpin".localized() : "Pin".localized(), id: 7, image: "ic_pin", sImage: "ic_pin",isselected: true)
            
            EditOptionsObject(name: "Edit".localized(), id: 1, image: "ChatEdit"  , sImage:"ChatEditS" ,isselected: true),
            EditOptionsObject(name: "Share".localized(), id: 2, image: "ChatShare" , sImage:"ChatShareS" ,isselected: true),
            EditOptionsObject(name: "Copy".localized(), id: 3, image: "ChatCopyN" , sImage: "ChatCopyNS",isselected: true),
            EditOptionsObject(name: "Reply".localized(), id: 4, image: "ChatReply" , sImage: "ChatReplyS",isselected: true),
            EditOptionsObject(name: "Delete".localized(), id: 5, image:"ChatDelete" , sImage: "ChatDeleteS",isselected: true),
            EditOptionsObject(name: "Forward".localized(), id: 6, image: "ChatForwardN", sImage: "ChatForwardNS",isselected: true),
            EditOptionsObject(name: showUnpin ? "Unpin".localized() : "Pin".localized(), id: 7, image: "ChatPin", sImage: "ChatPinS",isselected: true)
           ]
        if self.collectionView != nil {
            self.collectionView.reloadData()
        }
    }
    
    
    func reloadDatawithMultipleMessage(){
           self.dataArray.removeAll()
           dataArray = [
//                  EditOptionsObject(name: "Edit".localized(), id: 1, image: "Chatedit"  , sImage:"Chatedit" ,isselected: false),
//                  EditOptionsObject(name: "Share".localized(), id: 2, image: "Chatshare" , sImage:"Chatshare" ,isselected: false),
//                  EditOptionsObject(name: "Copy".localized(), id: 3, image: "ChatCopy" , sImage: "ChatCopy",isselected: false),
//                  EditOptionsObject(name: "Reply".localized(), id: 4, image: "Chatreply" , sImage: "Chatreply",isselected: false),
//                  EditOptionsObject(name: "Delete".localized(), id: 5, image:"Chatdelete" , sImage: "Chatdelete",isselected: true),
//                  EditOptionsObject(name: "Forward".localized(), id: 6, image: "ChatForward", sImage: "ChatForward",isselected: true),
//                  EditOptionsObject(name: "Pin".localized(), id: 7, image: "ic_pin", sImage: "ic_pin",isselected: false)
            
            EditOptionsObject(name: "Edit".localized(), id: 1, image: "ChatEdit"  , sImage:"ChatEditS" ,isselected: false),
            EditOptionsObject(name: "Share".localized(), id: 2, image: "ChatShare" , sImage:"ChatShareS" ,isselected: false),
            EditOptionsObject(name: "Copy".localized(), id: 3, image: "ChatCopyN" , sImage: "ChatCopyNS",isselected: false),
            EditOptionsObject(name: "Reply".localized(), id: 4, image: "ChatReply" , sImage: "ChatReplyS",isselected: false),
            EditOptionsObject(name: "Delete".localized(), id: 5, image:"ChatDelete" , sImage: "ChatDeleteS",isselected: true),
            EditOptionsObject(name: "Forward".localized(), id: 6, image: "ChatForwardN", sImage: "ChatForwardNS",isselected: true),
            EditOptionsObject(name: "Pin".localized(), id: 7, image: "ChatPin", sImage: "ChatPinS",isselected: false)
            
              ]
           if self.collectionView != nil {
               self.collectionView.reloadData()
           }
       }
    
    
    
    func reloadDatawithOtherUserMessage(showUnpin: Bool = false){
        self.dataArray.removeAll()
        dataArray = [
//               EditOptionsObject(name: "Edit".localized(), id: 1, image: "Chatedit"  , sImage:"Chatedit" ,isselected: false),
//               EditOptionsObject(name: "Share".localized(), id: 2, image: "Chatshare" , sImage:"Chatshare" ,isselected: true),
//               EditOptionsObject(name: "Copy".localized(), id: 3, image: "ChatCopy" , sImage: "ChatCopy",isselected: true),
//               EditOptionsObject(name: "Reply".localized(), id: 4, image: "Chatreply" , sImage: "Chatreply",isselected: true),
//               EditOptionsObject(name: "Delete".localized(), id: 5, image:"Chatdelete" , sImage: "Chatdelete",isselected: false),
//               EditOptionsObject(name: "Forward".localized(), id: 6, image: "ChatForward", sImage: "ChatForward",isselected: true),
//               EditOptionsObject(name: showUnpin ? "Unpin".localized() : "Pin".localized(), id: 7, image: "ic_pin", sImage: "ic_pin",isselected: true)
            
            EditOptionsObject(name: "Edit".localized(), id: 1, image: "ChatEdit"  , sImage:"ChatEditS" ,isselected: false),
            EditOptionsObject(name: "Share".localized(), id: 2, image: "ChatShare" , sImage:"ChatShareS" ,isselected: true),
            EditOptionsObject(name: "Copy".localized(), id: 3, image: "ChatCopyN" , sImage: "ChatCopyNS",isselected: true),
            EditOptionsObject(name: "Reply".localized(), id: 4, image: "ChatReply" , sImage: "ChatReplyS",isselected: true),
            EditOptionsObject(name: "Delete".localized(), id: 5, image:"ChatDelete" , sImage: "ChatDeleteS",isselected: false),
            EditOptionsObject(name: "Forward".localized(), id: 6, image: "ChatForwardN", sImage: "ChatForwardNS",isselected: true),
            EditOptionsObject(name: showUnpin ? "Unpin".localized() : "Pin".localized(), id: 7, image: "ChatPin", sImage: "ChatPinS",isselected: true)
           ]
        if self.collectionView != nil {
            self.collectionView.reloadData()
        }
        
    }
    
    
    func reloadDataforMediaMessage(isMine : Bool = false, showUnpin: Bool = false){
        self.dataArray.removeAll()
        dataArray = [
//               EditOptionsObject(name: "Edit".localized(), id: 1, image: "Chatedit"  , sImage:"Chatedit" ,isselected: false),
//               EditOptionsObject(name: "Share".localized(), id: 2, image: "Chatshare" , sImage:"Chatshare" ,isselected: false),
//               EditOptionsObject(name: "Copy".localized(), id: 3, image: "ChatCopy" , sImage: "ChatCopy",isselected: false),
//               EditOptionsObject(name: "Reply".localized(), id: 4, image: "Chatreply" , sImage: "Chatreply",isselected: true),
//               EditOptionsObject(name: "Delete".localized(), id: 5, image:"Chatdelete" , sImage: "Chatdelete",isselected: isMine),
//               EditOptionsObject(name: "Forward".localized(), id: 6, image: "ChatForward", sImage: "ChatForward",isselected: true),
//               EditOptionsObject(name: showUnpin ? "Unpin".localized() : "Pin".localized(), id: 7, image: "ic_pin", sImage: "ic_pin",isselected: true)
            
            EditOptionsObject(name: "Edit".localized(), id: 1, image: "ChatEdit"  , sImage:"ChatEditS" ,isselected: false),
            EditOptionsObject(name: "Share".localized(), id: 2, image: "ChatShare" , sImage:"ChatShareS" ,isselected: false),
            EditOptionsObject(name: "Copy".localized(), id: 3, image: "ChatCopyN" , sImage: "ChatCopyNS",isselected: false),
            EditOptionsObject(name: "Reply".localized(), id: 4, image: "ChatReply" , sImage: "ChatReplyS",isselected: true),
            EditOptionsObject(name: "Delete".localized(), id: 5, image:"ChatDelete" , sImage: "ChatDeleteS",isselected: isMine),
            EditOptionsObject(name: "Forward".localized(), id: 6, image: "ChatForwardN", sImage: "ChatForwardNS",isselected: true),
            EditOptionsObject(name: showUnpin ? "Unpin".localized() : "Pin".localized(), id: 7, image: "ChatPin", sImage: "ChatPinS",isselected: true)
           ]
        if self.collectionView != nil {
            self.collectionView.reloadData()
        }
        
    }
    
    func reloadDataforImageMessage(isMine : Bool = false, showUnpin: Bool = false){
        self.dataArray.removeAll()
        dataArray = [
//               EditOptionsObject(name: "Edit".localized(), id: 1, image: "Chatedit"  , sImage:"Chatedit" ,isselected: false),
//               EditOptionsObject(name: "Share".localized(), id: 2, image: "Chatshare" , sImage:"Chatshare" ,isselected: true),
//               EditOptionsObject(name: "Copy".localized(), id: 3, image: "ChatCopy" , sImage: "ChatCopy",isselected: true),
//               EditOptionsObject(name: "Reply".localized(), id: 4, image: "Chatreply" , sImage: "Chatreply",isselected: true),
//               EditOptionsObject(name: "Delete".localized(), id: 5, image:"Chatdelete" , sImage: "Chatdelete",isselected: isMine),
//               EditOptionsObject(name: "Forward".localized(), id: 6, image: "ChatForward", sImage: "ChatForward",isselected: true),
//               EditOptionsObject(name: showUnpin ? "Unpin".localized() : "Pin".localized(), id: 7, image: "ic_pin", sImage: "ic_pin",isselected: true)
            
            EditOptionsObject(name: "Edit".localized(), id: 1, image: "ChatEdit"  , sImage:"ChatEditS" ,isselected: false),
            EditOptionsObject(name: "Share".localized(), id: 2, image: "ChatShare" , sImage:"ChatShareS" ,isselected: true),
            EditOptionsObject(name: "Copy".localized(), id: 3, image: "ChatCopyN" , sImage: "ChatCopyNS",isselected: true),
            EditOptionsObject(name: "Reply".localized(), id: 4, image: "ChatReply" , sImage: "ChatReplyS",isselected: true),
            EditOptionsObject(name: "Delete".localized(), id: 5, image:"ChatDelete" , sImage: "ChatDeleteS",isselected: isMine),
            EditOptionsObject(name: "Forward".localized(), id: 6, image: "ChatForwardN", sImage: "ChatForwardNS",isselected: true),
            EditOptionsObject(name: showUnpin ? "Unpin".localized() : "Pin".localized(), id: 7, image: "ChatPin", sImage: "ChatPinS",isselected: true)
           ]
        if self.collectionView != nil {
            self.collectionView.reloadData()
        }
        
    }
    
    
    func reloadDatawithDefaultValue(){
        self.dataArray.removeAll()
        dataArray = [
//               EditOptionsObject(name: "Edit".localized(), id: 1, image: "Chatedit"  , sImage:"Chatedit" ,isselected: false),
//               EditOptionsObject(name: "Share".localized(), id: 2, image: "Chatshare" , sImage:"Chatshare" ,isselected: false),
//               EditOptionsObject(name: "Copy".localized(), id: 3, image: "ChatCopy" , sImage: "ChatCopy",isselected: false),
//               EditOptionsObject(name: "Reply".localized(), id: 4, image: "Chatreply" , sImage: "Chatreply",isselected: false),
//               EditOptionsObject(name: "Delete".localized(), id: 5, image:"Chatdelete" , sImage: "Chatdelete",isselected: false),
//               EditOptionsObject(name: "Forward".localized(), id: 6, image: "ChatForward", sImage: "ChatForward",isselected: false),
//               EditOptionsObject(name: "Pin".localized(), id: 7, image: "ic_pin", sImage: "ic_pin",isselected: false),
            
            EditOptionsObject(name: "Edit".localized(), id: 1, image: "ChatEdit"  , sImage:"ChatEditS" ,isselected: false),
            EditOptionsObject(name: "Share".localized(), id: 2, image: "ChatShare" , sImage:"ChatShareS" ,isselected: false),
            EditOptionsObject(name: "Copy".localized(), id: 3, image: "ChatCopyN" , sImage: "ChatCopyNS",isselected: false),
            EditOptionsObject(name: "Reply".localized(), id: 4, image: "ChatReply" , sImage: "ChatReplyS",isselected: false),
            EditOptionsObject(name: "Delete".localized(), id: 5, image:"ChatDelete" , sImage: "ChatDeleteS",isselected: false),
            EditOptionsObject(name: "Forward".localized(), id: 6, image: "ChatForwardN", sImage: "ChatForwardNS",isselected: false),
            EditOptionsObject(name: "Pin".localized(), id: 7, image: "ChatPin", sImage: "ChatPinS",isselected: false),
           ]

        if self.collectionView != nil {
            self.collectionView.reloadData()
        }
        
    }
}

extension OptionsPopover: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OptionsCell", for: indexPath) as? OptionsCell else {
           return UICollectionViewCell()
        }

        cell.lblName.text = dataArray[indexPath.row].name
        cell.containerView.backgroundColor = UIColor.white
        if dataArray[indexPath.row].isSelected {
            cell.imgIcon.image = UIImage.init(named: dataArray[indexPath.row].SImage)
            
        }else {
            cell.containerView.backgroundColor = UIColor.init(red: (154/255), green: (154/255), blue: (154/255), alpha: 0.25)
            cell.imgIcon.image = UIImage.init(named: dataArray[indexPath.row].image)
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if dataArray[indexPath.row].isSelected {
            delegate?.selectedActionAtIndex(actionIndex: dataArray[indexPath.row].id)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width/7, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

class OptionsCell: UICollectionViewCell {
    
    //MARK:- Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    //MARK:- Properties
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    //MARK:- Custom
    func setupView() {
        lblName.textColor = UIColor.themeBlueChatToolBarColor //themeBlueColor
    }
}


struct EditOptionsObject {
    var name: String
    var id: Int
    var image: String
    var SImage: String
    var isSelected: Bool
        
    init(name: String, id: Int, image: String , sImage: String , isselected: Bool) {
        self.name = name
        self.isSelected = isselected
        self.id = id
        self.image = image
        self.SImage = sImage
    }
}
