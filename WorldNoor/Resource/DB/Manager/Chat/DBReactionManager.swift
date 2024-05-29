//
//  ReactionManager.swift
//  kalam
//
//  Created by HAwais on 16/12/2023.
//  Copyright © 2023 apple. All rights reserved.
//

import UIKit
import CoreData
class DBReactionManager: NSObject {

    public static func getReactionFromDb(reactionID:String) -> Reaction? {
        let context = CoreDbManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntity.reaction.entityName)
        fetchRequest.predicate = NSPredicate(format: "reactionID == %@", reactionID)
        var results: [NSManagedObject] = []
        do {
            results = try context.fetch(fetchRequest)
        }
        catch {
            LogClass.debugLog("error executing fetch request: \(error)")
        }
        if results.count > 0 {
            let reactionObj = results[0] as! Reaction
            return reactionObj
        }
        return nil
    }
    
    public static func getMyReactionFromDb(reactedBy:String, msgID:String) -> Reaction? {
        let context = CoreDbManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntity.reaction.entityName)
        fetchRequest.predicate = NSPredicate(format: "reactedBy == %@ AND messageID == %@", reactedBy, msgID)
        var results: [NSManagedObject] = []
        do {
            results = try context.fetch(fetchRequest)
        }
        catch {
            LogClass.debugLog("error executing fetch request: \(error)")
        }
        if results.count > 0 {
            let reactionObj = results[0] as! Reaction
            return reactionObj
        }
        return nil
    }
    
    
    public static func mapReaction(reactionObj:Reaction, reaction:UserReaction) -> Reaction {
        reactionObj.firstName = reaction.firstname + " " + reaction.lastname
        reactionObj.lastName = ""
        reactionObj.profileImage = reaction.profileImage
        reactionObj.messageID = reaction.messageID
        reactionObj.reactedBy = reaction.reactedBy
        reactionObj.reaction = reaction.reaction
        reactionObj.reactionID = reaction.reactionID
        return reactionObj
    }
    
    static func reactionHandling(action:String, selectedReaction:String, messageID:String, userID:String, name:String, profileImage:String)    {
        if  let msgObj = DBMessageManager.getMessageFromDb(messageID: messageID) {
            if msgObj.toReaction.count > 0 {
                let reactionArr = Array(msgObj.toReaction as! Set<Reaction>)
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
    
    static func createNewReaction(action:String, selectedReaction:String, messageID:String, msgObj:Message, reactedBy:String, name:String, profileImage:String)    {
        let context = CoreDbManager.shared.persistentContainer.viewContext
        let myReaction = Reaction(context: context)
        myReaction.firstName = name
        myReaction.lastName = ""
        myReaction.profileImage = profileImage
        myReaction.reactedBy = reactedBy
        myReaction.reaction = selectedReaction
        myReaction.messageID = messageID
        myReaction.toMessage = msgObj
        CoreDbManager.shared.saveContext()
    }
}
