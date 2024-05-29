//
//  MPChatBuyerInfo+CoreDataProperties.swift
//  WorldNoor
//
//  Created by Awais on 03/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//
//

import Foundation
import CoreData


extension MPChatBuyerInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MPChatBuyerInfo> {
        return NSFetchRequest<MPChatBuyerInfo>(entityName: "MPChatBuyerInfo")
    }

    @NSManaged public var name: String
    @NSManaged public var title: String
    @NSManaged public var buttonText: String
    @NSManaged public var id: String
    @NSManaged public var token: String
    @NSManaged public var worldnoorUserId: String
    @NSManaged public var toMessage: MPMessage?

}

extension MPChatBuyerInfo : Identifiable {

}
