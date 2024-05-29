//
//  MPMessageDBManager.swift
//  WorldNoor
//
//  Created by Awais on 04/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import CoreData

class MPMessageDBManager: NSObject {
    
    func checkRecordExists(entity: String, value: Int) -> Bool {
        let context = CoreDbManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        fetchRequest.predicate = NSPredicate(format: "conversationId == %@", value)
        var results: [NSManagedObject] = []
        do {
            results = try context.fetch(fetchRequest)
        }
        catch {
            LogClass.debugLog("error executing fetch request: \(error)")
        }
        return results.count > 0
    }
    
    public static func checkMessageExists(identifierString: String, messageID:String) -> Bool {
        let context = CoreDbManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: MPCoreDataEntity.message.entityName)
        if !identifierString.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifierString)
        } else {
            fetchRequest.predicate = NSPredicate(format: "id == %@", messageID)
        }
        var results: [NSManagedObject] = []
        do {
            results = try context.fetch(fetchRequest)
        }
        catch {
            LogClass.debugLog("error executing fetch request: \(error)")
        }
        return results.count > 0
    }
    
    public static func updateMessage(identifierString: String, chatData:MPMessageModel, messageID:String) {
        let context = CoreDbManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: MPCoreDataEntity.message.entityName)
        if !identifierString.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifierString)
        } else {
            fetchRequest.predicate = NSPredicate(format: "id == %@", messageID)
        }
        var results: [NSManagedObject] = []
        do {
            results = try context.fetch(fetchRequest)
            if results.count > 0 {
                guard let msgObj = results[0] as? MPMessage else { return }
                
                let messageObject = mapMessageObj(msgObj: msgObj, msgModelObj: chatData)
                
//                msgObj.id = SharedManager.shared.ReturnValueAsString(value: chatData.id ?? 0)
//                msgObj.content = chatData.content ?? .emptyString
////                if msgObj.status == "" {
////                    if chatData.seenBy != "" {
////                        let seenArr = chatData.seenBy.components(separatedBy: ",")
////                        let isSeenByOthers = seenArr.filter({$0 != chatData.author_id})
////                        let isSeenByMe = seenArr.filter({$0 == chatData.author_id})
////                        msgObj.status = isSeenByOthers.count > 0 ? MessageStatus.seen.rawValue : isSeenByMe.count > 0 ? MessageStatus.delivered.rawValue : ""
////                    }
////                    else {
////                        msgObj.status = MessageStatus.delivered.rawValue
////                    }
////                }
                if let msgFile = messageObject.toMessageFile, msgFile.allObjects.count > 0 {
                    messageObject.removeFromToMessageFile(msgFile)
                    CoreDbManager.shared.saveContext()
                }
                if chatData.files?.count ?? 0 > 0 {
                    self.mapMessageFile(msgObj: messageObject, msgFiles: chatData.files ?? [])
                }
                CoreDbManager.shared.saveContext()
            }
        }
        catch {
            LogClass.debugLog("error executing fetch request: \(error)")
        }
    }
    
    public static func getMessageFileFromDb(messageID:String) -> MPMessageFile? {
        let context = CoreDbManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: MPCoreDataEntity.messageFile.entityName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", messageID)
        var results: [NSManagedObject] = []
        do {
            results = try context.fetch(fetchRequest)
        }
        catch {
            LogClass.debugLog("error executing fetch request: \(error)")
        }
        if results.count > 0 {
            if let fileObj = results[0] as? MPMessageFile {
                return fileObj
            }
        }
        return nil
    }
    
    public static func getMessageFromDb(messageID:String) -> MPMessage? {
        let context = CoreDbManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: MPCoreDataEntity.message.entityName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", messageID)
        var results: [NSManagedObject] = []
        do {
            results = try context.fetch(fetchRequest)
        }
        catch {
            LogClass.debugLog("error executing fetch request: \(error)")
        }
        if results.count > 0 {
            if let msgObj = results[0] as? MPMessage {
                return msgObj
            }
        }
        return nil
    }
    
    public static func saveMessageData(messageArr:[MPMessageModel], chatListObj:MPChat) {
        let context = CoreDbManager.shared.persistentContainer.viewContext
        messageArr.forEach { obj in
            var messageObject: MPMessage?
            guard let id = obj.id else { return }

            if let messageExist = getMessageFromDb(messageID: SharedManager.shared.ReturnValueAsString(value: id)) {
                messageObject = mapMessageObj(msgObj: messageExist, msgModelObj: obj)
//                if obj.repliedToMessageId ?? 0 > 0 {
//                    messageObject!.replyTo = mapMessageObj(msgObj: messageExist.replyTo ?? MPMessage.init(context: context), msgModelObj: obj.replied_to.first!)
//                }
                messageObject?.toChat = chatListObj
                CoreDbManager.shared.saveContext()
            }else {
                messageObject = MPMessage(context: context)
//                if obj.repliedToMessageId ?? 0 > 0 {
//                    messageObject!.replyTo = mapMessageObj(msgObj:MPMessage.init(context: context), userObj: obj.replied_to.first!)
//                }
                messageObject!.toChat = chatListObj
                let msgSET = mapMessageObj(msgObj: messageObject!, msgModelObj: obj)
                chatListObj.addToToMessage(msgSET)
                CoreDbManager.shared.saveContext()
            }
        }
    }
    
    func fetchAllChatFromDB()->[MPChat] {
        let moc = CoreDbManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: MPCoreDataEntity.message.entityName)
        
        do {
            let result = try moc.fetch(fetchRequest)
            if let objData: [MPChat] = result as? [MPChat] {
                //LogClass.debugLog("dbdebug chats \(objData.count)")
                return objData
            } else {
                LogClass.debugLog("Error in fetching data")
            }
        } catch {
            LogClass.debugLog("Error")
        }
        return []
    }
    
    public static func mapMessageObj(msgObj:MPMessage, msgModelObj:MPMessageModel)->MPMessage {
        let moc = CoreDbManager.shared.persistentContainer.viewContext
        msgObj.id = SharedManager.shared.ReturnValueAsString(value: msgModelObj.id as Any)
//        if msgObj.id == "" {
//            msgObj.id = userObj.message_id
//        }
//        if userObj.seenBy != "" {
//            let seenArr = userObj.seenBy.components(separatedBy: ",")
//            let isSeenByOthers = seenArr.filter({$0 != userObj.author_id})
//            let isSeenByMe = seenArr.filter({$0 == userObj.author_id})
//            msgObj.status = isSeenByOthers.count > 0 ? MessageStatus.seen.rawValue : isSeenByMe.count > 0 ? MessageStatus.delivered.rawValue : ""
//        }
        msgObj.conversationId = SharedManager.shared.ReturnValueAsString(value: msgModelObj.conversationId as Any)
        msgObj.conversationName = msgModelObj.conversationName ?? .emptyString
        msgObj.content = msgModelObj.content ?? .emptyString
        msgObj.senderName = msgModelObj.senderName ?? .emptyString
        msgObj.groupImage = msgModelObj.groupImage ?? .emptyString
        msgObj.senderId = SharedManager.shared.ReturnValueAsString(value: msgModelObj.senderId as Any)
        msgObj.conversationCreatedAt = msgModelObj.conversationCreatedAt ?? .emptyString
        msgObj.messageLabel = msgModelObj.messageLabel ?? .emptyString
        msgObj.messageType = SharedManager.shared.ReturnValueAsString(value: msgModelObj.messageType as Any)
        msgObj.reaction = msgModelObj.reaction ?? .emptyString
        msgObj.receiverId = SharedManager.shared.ReturnValueAsString(value: msgModelObj.receiverId as Any)
        msgObj.repliedToMessageId = SharedManager.shared.ReturnValueAsString(value: msgModelObj.repliedToMessageId as Any)
        msgObj.repliedToContent = msgModelObj.repliedToContent ?? .emptyString
        msgObj.senderImage = msgModelObj.senderImage ?? .emptyString
        msgObj.createdAt = msgModelObj.createdAt ?? .emptyString
        msgObj.identifier = SharedManager.shared.ReturnValueAsString(value: msgModelObj.identifier as Any)
        
        if let msgOfferInfo = msgModelObj.offerInfo {
            msgObj.toOfferInfo = self.mapOfferInfo(msgOfferInfo: msgOfferInfo)
        }
        
        if let msgBuyerInfo = msgModelObj.buyerInfo {
            msgObj.toBuyerInfo = self.mapBuyerInfo(msgBuyerInfo: msgBuyerInfo)
        }

        msgObj.isPinned = "0"
        if let pinnedBy = msgModelObj.pinnedBy, pinnedBy > 0 {
            msgObj.isPinned = "1"
            msgObj.pinnedBy = String(pinnedBy)
        }
        
        if let messageFiles = msgModelObj.files {
            for messageFile in messageFiles {
                var msgFile:MPMessageFile?
                if let messageExist = getMessageFileFromDb(messageID: messageFile.id ?? .emptyString) {
                    msgFile = mapMessageFile(messageFileObj:messageExist, messageFile: messageFile)
                    if msgFile != nil {
                        CoreDbManager.shared.saveContext()
                    }
                }else{
                    let newMessage = MPMessageFile(context: moc)
                    msgFile = mapMessageFile(messageFileObj:newMessage, messageFile: messageFile)
                }
                if msgFile != nil {
                    msgObj.addToToMessageFile(msgFile!)
                }
            }
        }
        
        if let msgReactions = msgModelObj.messageReaction {
            for reactionObj in msgReactions {
                var reaction:MPMessageReaction?
                if let reactionExist = MPReactionDBManager.getMyReactionFromDb(reactedBy: String(reactionObj.reactedBy ?? 0), msgID: msgObj.id) {
                    reaction = MPReactionDBManager.mapReaction(reactionObj: reactionExist, reaction: reactionObj)
                    CoreDbManager.shared.saveContext()
                }else {
                    let newMessage = MPMessageReaction(context: moc)
                    reaction = MPReactionDBManager.mapReaction(reactionObj: newMessage, reaction: reactionObj)
                }
                msgObj.addToToMessageReaction(reaction!)
            }
        }

        return msgObj
    }
    
    public static func mapMessageFile(msgObj:MPMessage, msgFiles:[MPMessageFileModel]) {
        let moc = CoreDbManager.shared.persistentContainer.viewContext
        
        for messageFile in msgFiles {
            var msgFile: MPMessageFile?
            if let messageExist = getMessageFileFromDb(messageID: messageFile.id ?? .emptyString) {
                msgFile = mapMessageFile(messageFileObj:messageExist, messageFile: messageFile)
                CoreDbManager.shared.saveContext()
            }else{
                let newMessage = MPMessageFile(context: moc)
                msgFile = mapMessageFile(messageFileObj:newMessage, messageFile: messageFile)
            }
            if msgFile != nil {
                msgObj.addToToMessageFile(msgFile!)
            }
        }
    }
    
    public static func mapMessageFile(messageFileObj:MPMessageFile, messageFile:MPMessageFileModel, isSaveLocal:Bool = false, useContext:Bool = true)->MPMessageFile
    {
        messageFileObj.id = messageFile.id ?? .emptyString
        messageFileObj.size = messageFile.size ?? .emptyString
        messageFileObj.name = messageFile.name ?? .emptyString
        messageFileObj.type = messageFile.type ?? .emptyString
        messageFileObj.url = messageFile.url ?? .emptyString
        messageFileObj.thumbnailUrl = messageFile.thumbnailUrl ?? .emptyString
        
        if(isSaveLocal)
        {
            messageFileObj.localFileURL = messageFile.url ?? .emptyString
            messageFileObj.localthumbnailimage = messageFile.thumbnailUrl ?? .emptyString
        }
        
        return messageFileObj
    }
    
    public static func mapOfferInfo(msgOfferInfo:MPChatOfferInfoModel) -> MPChatOfferInfo {
        
        let moc = CoreDbManager.shared.persistentContainer.viewContext
        let offerInfo = MPChatOfferInfo(context: moc)
        
        offerInfo.offerId = SharedManager.shared.ReturnValueAsString(value: msgOfferInfo.offerId as Any)
        offerInfo.offerInfo = SharedManager.shared.ReturnValueAsString(value: msgOfferInfo.offerInfo as Any)
        offerInfo.offerDescription = SharedManager.shared.ReturnValueAsString(value: msgOfferInfo.offerDescription as Any)
        offerInfo.price = SharedManager.shared.ReturnValueAsString(value: msgOfferInfo.price as Any)
        
        return offerInfo
    }
    
    public static func mapBuyerInfo(msgBuyerInfo:MPChatBuyerInfoModel) -> MPChatBuyerInfo {
        
        let moc = CoreDbManager.shared.persistentContainer.viewContext
        let buyerInfo = MPChatBuyerInfo(context: moc)
        
        buyerInfo.name = SharedManager.shared.ReturnValueAsString(value: msgBuyerInfo.name as Any)
        buyerInfo.title = SharedManager.shared.ReturnValueAsString(value: msgBuyerInfo.title as Any)
        buyerInfo.buttonText = SharedManager.shared.ReturnValueAsString(value: msgBuyerInfo.buttonText as Any)
        buyerInfo.id = SharedManager.shared.ReturnValueAsString(value: msgBuyerInfo.id as Any)
        buyerInfo.token = SharedManager.shared.ReturnValueAsString(value: msgBuyerInfo.token as Any)
        buyerInfo.worldnoorUserId = SharedManager.shared.ReturnValueAsString(value: msgBuyerInfo.worldnoorUserId as Any)
        
        return buyerInfo
    }
    
    static func deleteMessageObj(identifierString: String, messageID:String) {
        let moc = CoreDbManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: MPCoreDataEntity.message.entityName)
        if !identifierString.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifierString)
        } else {
            fetchRequest.predicate = NSPredicate(format: "id == %@", messageID)
        }
        do {
            let objToDelete = try moc.fetch(fetchRequest)
            if objToDelete.count > 0 {
                if let obj = objToDelete[0] as? MPMessage {
                    moc.delete(obj)
                    CoreDbManager.shared.saveContext()
                }
            }
        }catch {
            fatalError(error.localizedDescription)
        }
    }
    
    static func updateSeenStatus(messageID:String, userID:String) {
        let moc = CoreDbManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: MPCoreDataEntity.message.entityName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", messageID)
        do {
            let obj = try moc.fetch(fetchRequest)
            if obj.count > 0 {
                if let obj = obj[0] as? MPMessage {
//                    if obj.author_id != userID {
//                        obj.status = MessageStatus.seen.rawValue
//                        CoreDbManager.shared.saveContext()
//                    }
                }
            }
        }catch {
            fatalError(error.localizedDescription)
        }
    }
}
