//
//  ChatExtension.swift
//  WorldNoor
//
//  Created by apple on 1/19/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit

//MARK:  Send Cells
extension ChatViewController
{
    
    func SenderChatCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dict = self.chatModelArray[indexPath.row]
        
        let sendCell = tableView.dequeueReusableCell(withIdentifier: "SenderChatCell", for: indexPath) as! SenderChatCell
        sendCell.loadData(dict: dict, index: indexPath)
        sendCell.delegateTap = self
        sendCell.reactionDelegate = self
        
        sendCell.viewSelected.isHidden = true
        sendCell.viewUnSelectedTick.isHidden = true
        if self.isSelectionEnable {
            sendCell.viewSelected.isHidden = false
            sendCell.viewUnSelectedTick.isHidden = false
            sendCell.viewSelectedTick.isHidden = true
            if self.selectedRows.contains(dict.id) {
                sendCell.viewSelectedTick.isHidden = false
            }
        }
        
        sendCell.selectionStyle = .none
        
        sendCell.onSwipeToReply = {
            self.replyChatMessage(messageObj: dict)
        }
        
        sendCell.onScrollToReplyMessage = {
            self.scrollToReplyMessage(messageObj: dict)
        }
        
        return sendCell
    }
}

//MARK:  Recive Cells
extension ChatViewController
{
    func ReceiverChatCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dict = self.chatModelArray[indexPath.row]
        
        let receiveCell = tableView.dequeueReusableCell(withIdentifier: "ReceiverChatCell", for: indexPath) as! ReceiverChatCell
        receiveCell.loadData(dict: dict, index: indexPath)
        receiveCell.delegateTap = self
        receiveCell.reactionDelegate = self
        
        receiveCell.viewSelected.isHidden = true
        receiveCell.viewUnSelectedTick.isHidden = true
        if self.isSelectionEnable {
            receiveCell.viewSelected.isHidden = false
            receiveCell.viewUnSelectedTick.isHidden = false
            receiveCell.viewSelectedTick.isHidden = true
            if self.selectedRows.contains(dict.id) {
                receiveCell.viewSelectedTick.isHidden = false
            }
        }
        
        receiveCell.selectionStyle = .none
        
        receiveCell.onSwipeToReply = {
            self.replyChatMessage(messageObj: dict)
        }
        
        receiveCell.onScrollToReplyMessage = {
            self.scrollToReplyMessage(messageObj: dict)
        }
        
        return receiveCell
    }
}
