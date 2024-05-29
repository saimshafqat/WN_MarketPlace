//
//  DBMessageManager.swift
//  WorldNoor
//
//  Created by Awais on 17/10/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit
import CoreData

class DBMessageManager: NSObject {
    
    func checkRecordExists(entity: String, value: Int) -> Bool {
        let context = CoreDbManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        fetchRequest.predicate = NSPredicate(format: "conversation_id == %@", value)
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
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntity.message.entityName)
        if !identifierString.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "identifierString == %@", identifierString)
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
    
    public static func updateMessage(identifierString: String, chatData:UserChatModel, messageID:String) {
        let context = CoreDbManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntity.message.entityName)
        if !identifierString.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "identifierString == %@", identifierString)
        } else {
            fetchRequest.predicate = NSPredicate(format: "id == %@", messageID)
        }
        var results: [NSManagedObject] = []
        do {
            results = try context.fetch(fetchRequest)
            if results.count > 0 {
                let msgObj = results[0] as! Message
                msgObj.id = chatData.message_id
                msgObj.body = chatData.body
                if msgObj.status == "" {
                    if chatData.seenBy != "" {
                        let seenArr = chatData.seenBy.components(separatedBy: ",")
                        let isSeenByOthers = seenArr.filter({$0 != chatData.author_id})
                        let isSeenByMe = seenArr.filter({$0 == chatData.author_id})
                        msgObj.status = isSeenByOthers.count > 0 ? MessageStatus.seen.rawValue : isSeenByMe.count > 0 ? MessageStatus.delivered.rawValue : ""
                    }
                    else {
                        msgObj.status = MessageStatus.delivered.rawValue
                    }
                }
                if let msgFile = msgObj.toMessageFile, msgFile.allObjects.count > 0 {
                    msgObj.removeFromToMessageFile(msgFile)
                    CoreDbManager.shared.saveContext()
                }
                if chatData.message_files.count > 0 {
                    self.mapMessageFile(msgObj: msgObj, msgFile: chatData.message_files)
                }
                CoreDbManager.shared.saveContext()
            }
        }
        catch {
            LogClass.debugLog("error executing fetch request: \(error)")
        }
    }
    
    public static func getMessageFileFromDb(messageID:String) -> MessageFile? {
        let context = CoreDbManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntity.messageFile.entityName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", messageID)
        var results: [NSManagedObject] = []
        do {
            results = try context.fetch(fetchRequest)
        }
        catch {
            LogClass.debugLog("error executing fetch request: \(error)")
        }
        if results.count > 0 {
            let fileObj = results[0] as! MessageFile
            return fileObj
        }
        return nil
    }
    
    public static func getMessageFromDb(messageID:String) -> Message? {
        let context = CoreDbManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntity.message.entityName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", messageID)
        var results: [NSManagedObject] = []
        do {
            results = try context.fetch(fetchRequest)
        }
        catch {
            LogClass.debugLog("error executing fetch request: \(error)")
        }
        if results.count > 0 {
            let msgObj = results[0] as! Message
            return msgObj
        }
        return nil
    }
    
    public static func saveMessageData(messageArr:[UserChatModel], chatListObj:Chat) {
        let context = CoreDbManager.shared.persistentContainer.viewContext
        messageArr.forEach { obj in
            var messageObject:Message?
            var id = obj.id
            if id == "" {
                id = obj.message_id
            }
            if let messageExist = getMessageFromDb(messageID: id) {
                messageObject = mapMessageObj(msgObj: messageExist, userObj: obj)
                if obj.replied_to.count > 0 {
                    messageObject!.reply_to = mapMessageObj(msgObj: messageExist.reply_to ?? Message.init(context: context), userObj: obj.replied_to.first!)
                }
                messageObject?.toChat = chatListObj
                CoreDbManager.shared.saveContext()
            }else {
                messageObject = Message(context: context)
                if obj.replied_to.count > 0 {
                    messageObject!.reply_to = mapMessageObj(msgObj:Message.init(context: context), userObj: obj.replied_to.first!)
                }
                messageObject!.toChat = chatListObj
                let msgSET = mapMessageObj(msgObj: messageObject!, userObj: obj)
                chatListObj.addToToMessage(msgSET)
                CoreDbManager.shared.saveContext()
            }
        }
    }
    
    func fetchAllChatFromDB()->[Chat] {
        let moc = CoreDbManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataEntity.message.entityName)
        
        do {
            let result = try moc.fetch(fetchRequest)
            if let objData: [Chat] = result as? [Chat] {
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
    
    public static func mapMessageObj(msgObj:Message, userObj:UserChatModel)->Message {
        let moc = CoreDbManager.shared.persistentContainer.viewContext
        msgObj.id = userObj.id
        if msgObj.id == "" {
            msgObj.id = userObj.message_id
        }
        if userObj.seenBy != "" {
            let seenArr = userObj.seenBy.components(separatedBy: ",")
            let isSeenByOthers = seenArr.filter({$0 != userObj.author_id})
            let isSeenByMe = seenArr.filter({$0 == userObj.author_id})
            msgObj.status = isSeenByOthers.count > 0 ? MessageStatus.seen.rawValue : isSeenByMe.count > 0 ? MessageStatus.delivered.rawValue : ""
        }
        msgObj.replied_to_message_id = userObj.replied_to_message_id
        msgObj.author_id = userObj.author_id
        msgObj.audio_file = userObj.audio_file
        msgObj.original_speech_to_text = userObj.original_speech_to_text
        msgObj.conversation_id = userObj.conversation_id
        msgObj.audio_msg_url = userObj.audio_msg_url
        msgObj.body = userObj.body
        msgObj.author_id = userObj.author_id
        msgObj.auto_translate = userObj.auto_translate
        msgObj.conversation_id = userObj.conversation_id
        msgObj.full_name = userObj.full_name
        msgObj.name = userObj.name
        msgObj.new_message_id = userObj.new_message_id
        msgObj.original_body = userObj.original_body
        msgObj.post_type = userObj.post_type
        msgObj.profile_image = userObj.profile_image
        msgObj.sender_id = userObj.sender_id
        msgObj.speech_to_text = userObj.speech_to_text
        msgObj.identifierString = userObj.identifierString
        msgObj.profile_image = userObj.profile_image
        msgObj.messageTime = userObj.messageTime
        msgObj.is_pinned = "0"
        if !userObj.pinnedBy.isEmpty {
            msgObj.is_pinned = "1"
            msgObj.pinnedBy = userObj.pinnedBy
        }
        
        //Handling message files data...
        for messageFil in userObj.message_files {
            var msgFile:MessageFile?
            if let messageExist = getMessageFileFromDb(messageID: messageFil.id) {
                msgFile = mapMessageFile(messageFileObj:messageExist, messageFile: messageFil)
                CoreDbManager.shared.saveContext()
            }else{
                let newMessage = MessageFile(context: moc)
                msgFile = mapMessageFile(messageFileObj:newMessage, messageFile: messageFil)
            }
            msgObj.addToToMessageFile(msgFile!)
        }
        
        for reactionObj in userObj.userReaction {
            var reaction:Reaction?
            if let reactionExist = DBReactionManager.getReactionFromDb(reactionID: reactionObj.reactionID) {
                reaction = DBReactionManager.mapReaction(reactionObj: reactionExist, reaction: reactionObj)
                CoreDbManager.shared.saveContext()
            }else {
                if let reactionExist = DBReactionManager.getMyReactionFromDb(reactedBy: reactionObj.reactedBy, msgID: msgObj.id) {
                    reaction = DBReactionManager.mapReaction(reactionObj: reactionExist, reaction: reactionObj)
                    CoreDbManager.shared.saveContext()
                }else {
                    let newMessage = Reaction(context: moc)
                    reaction = DBReactionManager.mapReaction(reactionObj: newMessage, reaction: reactionObj)
                }
            }
            msgObj.addToToReaction(reaction!)
        }
        return msgObj
    }
    
    public static func mapMessageFile(msgObj:Message, msgFile:[UserChatMessageFiles]) {
        let moc = CoreDbManager.shared.persistentContainer.viewContext
        //Handling message files data...
        for messageFil in msgFile {
            var msgFile:MessageFile?
            if let messageExist = getMessageFileFromDb(messageID: messageFil.id) {
                msgFile = mapMessageFile(messageFileObj:messageExist, messageFile: messageFil)
                CoreDbManager.shared.saveContext()
            }else{
                let newMessage = MessageFile(context: moc)
                msgFile = mapMessageFile(messageFileObj:newMessage, messageFile: messageFil)
            }
            msgObj.addToToMessageFile(msgFile!)
        }
    }
    
    public static func mapMessageFile(messageFileObj:MessageFile, messageFile:UserChatMessageFiles, useContext:Bool = true)->MessageFile
    {
        messageFileObj.id = messageFile.id
        messageFileObj.post_type = messageFile.post_type
        messageFileObj.url = messageFile.url
        messageFileObj.size = messageFile.size
        messageFileObj.name = messageFile.name
        messageFileObj.thumbnail_url = messageFile.thumbnail_url
        
        if messageFile.localVideoURL != "" {
            messageFileObj.localVideoURL = messageFile.localVideoURL
        }
        if messageFile.ConvertedUrl != "" {
            messageFileObj.convertedUrl = messageFile.ConvertedUrl
        }
        if let thumbFile = messageFile.localthumbnailimage {
            messageFileObj.localthumbnailimage = thumbFile
        }
        return messageFileObj
    }
    
    
    static func deleteMessageObj(identifierString: String, messageID:String) {
        let moc = CoreDbManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataEntity.message.entityName)
        if !identifierString.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "identifierString == %@", identifierString)
        } else {
            fetchRequest.predicate = NSPredicate(format: "id == %@", messageID)
        }
        do {
            let objToDelete = try moc.fetch(fetchRequest)
            if objToDelete.count > 0 {
                let obj = objToDelete[0] as! Message
                moc.delete(obj)
                CoreDbManager.shared.saveContext()
            }
        }catch {
            fatalError(error.localizedDescription)
        }
    }
    
    static func updateSeenStatus(messageID:String, userID:String) {
        let moc = CoreDbManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataEntity.message.entityName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", messageID)
        do {
            let obj = try moc.fetch(fetchRequest)
            if obj.count > 0 {
                let obj = obj[0] as! Message
                if obj.author_id != userID {
                    obj.status = MessageStatus.seen.rawValue
                    CoreDbManager.shared.saveContext()
                }
            }
        }catch {
            fatalError(error.localizedDescription)
        }
    }
}
