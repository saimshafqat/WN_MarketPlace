//
//  MPReactionDBManager.swift
//  WorldNoor
//
//  Created by Awais on 07/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import CoreData

class MPReactionDBManager: NSObject {
    
    public static func getMyReactionFromDb(reactedBy:String, msgID:String) -> MPMessageReaction? {
        let context = CoreDbManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: MPCoreDataEntity.reaction.entityName)
        fetchRequest.predicate = NSPredicate(format: "reactedBy == %@ AND messageId == %@", reactedBy, msgID)
        var results: [NSManagedObject] = []
        do {
            results = try context.fetch(fetchRequest)
        }
        catch {
            LogClass.debugLog("error executing fetch request: \(error)")
        }
        if results.count > 0 {
            if let reactionObj = results[0] as? MPMessageReaction {
                return reactionObj
            }
        }
        return nil
    }
    
    
    public static func mapReaction(reactionObj:MPMessageReaction, reaction:MPMessageReactionModel) -> MPMessageReaction {
        reactionObj.firstname = (reaction.firstname ?? .emptyString) + " " + (reaction.lastname ?? .emptyString)
        reactionObj.lastname = .emptyString
        reactionObj.profileImage = reaction.profileImage ?? .emptyString
        reactionObj.messageId = SharedManager.shared.ReturnValueAsString(value: reaction.messageId as Any)
        reactionObj.reactedBy = SharedManager.shared.ReturnValueAsString(value: reaction.reactedBy as Any)
        reactionObj.reaction = reaction.reaction ?? .emptyString
        return reactionObj
    }
    
    static func reactionHandling(action:String, selectedReaction:String, messageID:String, userID:String, name:String, profileImage:String) {
        if  let msgObj = MPMessageDBManager.getMessageFromDb(messageID: messageID) {
            if msgObj.toMessageReaction?.count ?? 0 > 0 {
                let reactionArr = Array(msgObj.toMessageReaction as! Set<MPMessageReaction>)
                if let myReaction = reactionArr.first(where: { $0.reactedBy == userID }) {
                    let reactionUpdate = myReaction
                    reactionUpdate.reaction = selectedReaction
                    CoreDbManager.shared.saveContext()
                }else {
                    createNewReaction(action: action, selectedReaction: selectedReaction, messageID: messageID, msgObj: msgObj, reactedBy: userID, name: name, profileImage: profileImage)
                }
            }else {
                createNewReaction(action: action, selectedReaction: selectedReaction, messageID: messageID, msgObj: msgObj, reactedBy: userID, name: name, profileImage: profileImage)
            }
        }
    }
    
    static func createNewReaction(action:String, selectedReaction:String, messageID:String, msgObj:MPMessage, reactedBy:String, name:String, profileImage:String)    {
        let context = CoreDbManager.shared.persistentContainer.viewContext
        let myReaction = MPMessageReaction(context: context)
        myReaction.firstname = name
        myReaction.lastname = ""
        myReaction.profileImage = profileImage
        myReaction.reactedBy = reactedBy
        myReaction.reaction = selectedReaction
        myReaction.messageId = messageID
        myReaction.toMessage = msgObj
        CoreDbManager.shared.saveContext()
    }
}
