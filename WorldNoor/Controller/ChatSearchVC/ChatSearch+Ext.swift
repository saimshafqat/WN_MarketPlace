
//
//  ChatSearch+Ext.swift
//  WorldNoor
//
//  Created by apple on 1/19/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit

//MARK:  Send Cells
extension ChatSearchVC
{
    func SenderChatCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dict = self.chatModelArray[indexPath.row]
        
        let sendCell = tableView.dequeueReusableCell(withIdentifier: "SenderChatCell", for: indexPath) as! SenderChatCell
        sendCell.loadData(dict: dict, index: indexPath)
        sendCell.isPinned = true
        
        sendCell.viewSelected.isHidden = true
        sendCell.viewUnSelectedTick.isHidden = true
        
        sendCell.selectionStyle = .none
        return sendCell
    }
}

//MARK:  Recive Cells
extension ChatSearchVC
{
    func ReceiverChatCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dict = self.chatModelArray[indexPath.row]
        
        let receiveCell = tableView.dequeueReusableCell(withIdentifier: "ReceiverChatCell", for: indexPath) as! ReceiverChatCell
        receiveCell.loadData(dict: dict, index: indexPath)
        receiveCell.isPinned = true
        
        receiveCell.viewSelected.isHidden = true
        receiveCell.viewUnSelectedTick.isHidden = true
        
        receiveCell.selectionStyle = .none
        return receiveCell
    }
}
