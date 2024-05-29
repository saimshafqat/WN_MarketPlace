//
//  AllDelegate.swift
//  WorldNoor
//
//  Created by apple on 9/17/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit


protocol DelegateReturnData : NSObject {
    func delegateReturnFunction(dataMain:Any)
}


protocol DelegateAdData : NSObject {
    func delegateAdReturnFunction(dataMain:Any)
}


protocol DelegateTapCell: AnyObject {
    func delegateTapCellAction(chatObj: Message, indexRow: IndexPath)
    func delegateTapCellActionforCopy(chatObj: Message, indexRow: IndexPath)
    func delegateTapCellActionforImage(chatObj: Message, indexRow: IndexPath)
    func delegateOpenforImage(chatObj: Message, indexRow: IndexPath)
    
    func delegatRowValueChange(indexPath : IndexPath , selectecion : Bool)
    func delegatRowSelectedValueChange(indexPath : IndexPath)
}

protocol DelegateTapMPChatCell: AnyObject {
    func delegateTapCellAction(chatObj: MPMessage, indexRow: IndexPath)
    func delegateTapCellActionforCopy(chatObj: MPMessage, indexRow: IndexPath)
    func delegateTapCellActionforImage(chatObj: MPMessage, indexRow: IndexPath)
    func delegateOpenforImage(chatObj: MPMessage, indexRow: IndexPath)
    
    func delegatRowValueChange(indexPath : IndexPath , selectecion : Bool)
    func delegatRowSelectedValueChange(indexPath : IndexPath)
}

protocol DelegateRefresh: AnyObject {
    func delegateRefresh()
}


protocol DelegateChatPreview {
    func delegateRemoveView(dataMain : [String : Any] , isDelete : Bool)
    func delegateChooseLanguage(dataMain : [String : Any])
}

