//
//  BaseMPChatCell+BuyerDetailsView.swift
//  WorldNoor
//
//  Created by Awais on 18/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

extension BaseMPChatCell
{
    func setBuyerDetailsView()
    {
        self.buyerDetailsBubbleView.isHidden = false
        self.lblBuyerName.text = self.chatObj.toBuyerInfo?.name.count ?? 0 > 0 ? self.chatObj.toBuyerInfo?.name : "Buyer Name"
        self.lblBuyerDesc.text = self.chatObj.toBuyerInfo?.title.count ?? 0 > 0 ? self.chatObj.toBuyerInfo?.title : "Learn more about this buyer."
    }
}
