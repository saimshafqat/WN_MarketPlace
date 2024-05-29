//
//  MessageFile+CoreDataProperties.swift
//  
//
//  Created by Awais on 18/10/2023.
//
//

import Foundation
import CoreData


extension MessageFile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageFile> {
        return NSFetchRequest<MessageFile>(entityName: "MessageFile")
    }

    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var post_type: String
    @NSManaged public var size: String
    @NSManaged public var thumbnail_url: String
    @NSManaged public var url: String
    @NSManaged public var toMessage: Message?
    @NSManaged public var localthumbnailimage: String
    @NSManaged public var localimage: String
    @NSManaged public var localVideoURL: String
    @NSManaged public var convertedUrl: String
}
