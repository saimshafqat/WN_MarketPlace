//
//  MPChatOfferInfo+CoreDataProperties.swift
//  WorldNoor
//
//  Created by Awais on 03/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//
//

import Foundation
import CoreData


extension MPChatOfferInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MPChatOfferInfo> {
        return NSFetchRequest<MPChatOfferInfo>(entityName: "MPChatOfferInfo")
    }

    @NSManaged public var offerInfo: String
    @NSManaged public var offerDescription: String
    @NSManaged public var offerId: String
    @NSManaged public var price: String
    @NSManaged public var toMessage: MPMessage?

}

extension MPChatOfferInfo : Identifiable {

}
