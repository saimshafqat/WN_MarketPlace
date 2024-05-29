//
//  ChatSelectionController.swift
//  WorldNoor
//
//  Created by Awais on 23/02/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class ChatSelectionCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgView: UIImageView!
}

class ReactionChatCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
}

class ChatSelectionController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reactionCollectionView: UICollectionView!
    
    var didSelectReaction : ((IndexPath) -> Void)?
    var didSelectOption : ((Int) -> Void)?
    
    var postType = ""
    var isMine = false
    var isPinned = false
    var isShowCopy = false
    
    var selectionArray = [
        ChatSelectionModel(name: "Edit".localized(), id: 1, image: "ic_edit"),
        ChatSelectionModel(name: "Reply".localized(), id: 2, image: "ic_reply"),
        ChatSelectionModel(name: "Forward".localized(), id: 3, image: "ic_forward"),
        ChatSelectionModel(name: "Delete".localized(), id: 4, image:"ic_delete"),
        ChatSelectionModel(name: "Pin".localized(), id: 5, image: "ic_pin"),
        ChatSelectionModel(name: "Copy".localized(), id: 6, image: "ic_copy"),
        ChatSelectionModel(name: "Share".localized(), id: 7, image: "ic_share"),
        ChatSelectionModel(name: "Select Messages".localized(), id: 8, image: "ic_check")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(postType != FeedType.post.rawValue || isMine == false)
        {
            selectionArray = selectionArray.filter {$0.id != 1}
        }
        
        if !isShowCopy {
            selectionArray = selectionArray.filter {$0.id != 6}
        }
        
        if isPinned {
            if let index = selectionArray.firstIndex(where: { $0.id == 5 }) {
                selectionArray[index].name = "Unpin".localized()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reactionCollectionView.reloadData()
        tableView.reloadData()
    }
}

extension ChatSelectionController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatSelectionCell.className, for: indexPath) as! ChatSelectionCell
        
        cell.lblTitle.text = selectionArray[indexPath.row].name
        cell.imgView.image = UIImage(named: selectionArray[indexPath.row].image)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if let didSelectOption = didSelectOption {
            didSelectOption(selectionArray[indexPath.row].id)
            dismissVC(completion: nil)
        }
    }
}

extension ChatSelectionController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 50, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SharedManager.shared.arrayChatGif.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reactionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReactionChatCell", for: indexPath) as! ReactionChatCell
        reactionCell.imgView.loadGifImage(with: SharedManager.shared.arrayChatGif[indexPath.row])
        return reactionCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if let didSelectReaction = didSelectReaction {
            didSelectReaction(indexPath)
            dismissVC(completion: nil)
        }
    }
}
