//
//  BaseMPChatCell+Reactions.swift
//  WorldNoor
//
//  Created by Awais on 08/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

extension BaseMPChatCell
{
    func initializeReactionView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(reactionViewTapped))
        self.addedReactionView?.addGestureRecognizer(tap)
    }
    
    @objc func reactionViewTapped() {
        self.reactionDelegate?.showReactionListDelegate(messageID: self.chatObj.id, messageObj: chatObj)
    }
    
    func manageReactionData(objData: MPMessage) {
        
        if objData.toMessageReaction?.count ?? 0 > 0 {
            
            self.addedReactionView?.isHidden = false
            self.addedReactionView?.isUserInteractionEnabled = true
            
            let reactionArr = Array(objData.toMessageReaction as! Set<MPMessageReaction>)
            //            if let myReaction = reactionArr.first(where: { $0.reactedBy == String(SharedManager.shared.getUserID()) }) {
            //                let name = myReaction.reaction
            //                let img = UIImage.init(named: name)
            //                self.reactionBtn.setImage(img, for: .normal)
            //            }
            addedReactionView?.manageReactionStack(reactionArr: reactionArr.map {$0.reaction}, count: reactionArr.count)
            
        }else{
            
            addedReactionView?.hideStack()
            self.addedReactionView?.isHidden = true
            
        }
    }
}
