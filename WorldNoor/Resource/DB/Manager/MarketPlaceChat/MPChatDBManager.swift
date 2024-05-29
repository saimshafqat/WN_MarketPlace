//
//  MPChatDBManager.swift
//  WorldNoor
//
//  Created by Awais on 21/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
import CoreData

enum MPCoreDataEntity: String {
    case chat = "MPChat"
    case message = "MPMessage"
    case messageFile = "MPMessageFile"
    case reaction = "MPMessageReaction"
    var entityName: String {
        return self.rawValue
    }
}

enum MPConversationType {
    case chat
    case archive
    
    var predicate: NSPredicate {
        switch self {
        case .chat:
            return NSPredicate(format: "isArchive == 0")
        case .archive:
            return NSPredicate(format: "isArchive == 1")
        }
    }
}

class MPChatDBManager: NSObject {
    
    func checkRecordExists(entity: String = "MPChat", value: Int) -> Bool {
        let context = CoreDbManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        fetchRequest.predicate = NSPredicate(format: "conversationId == %i", value)
        var results: [NSManagedObject] = []
        do {
            results = try context.fetch(fetchRequest)
        }
        catch {
            LogClass.debugLog("error executing fetch request: \(error)")
        }
        return results.count > 0
    }
    
    func getChatFromDb(conversationID:String) -> MPChat? {
        let context = CoreDbManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: MPCoreDataEntity.chat.entityName)
        fetchRequest.predicate = NSPredicate(format: "conversationId == %@", conversationID)
        var results: [NSManagedObject] = []
        do {
            results = try context.fetch(fetchRequest)
        }
        catch {
            LogClass.debugLog("error executing fetch request: \(error)")
        }
        if results.count > 0 {
            if let chatObj = results[0] as? MPChat {
                return chatObj
            }
        }
        return nil
    }
    
    func getChatSearchFromDb(conversationID:String, searchStr:String) -> MPChat? {
        let context = CoreDbManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: MPCoreDataEntity.chat.entityName)
        fetchRequest.predicate = NSPredicate(format: "conversationId == %@", conversationID, searchStr)
        var results: [NSManagedObject] = []
        do {
            results = try context.fetch(fetchRequest)
        }
        catch {
            LogClass.debugLog("error executing fetch request: \(error)")
        }
        if results.count > 0 {
            if let chatObj = results[0] as? MPChat {
                return chatObj
            }
        }
        return nil
    }
    
    func saveChatData(chatData:[MPConversation]) {
        let context = CoreDbManager.shared.persistentContainer.viewContext
        
        chatData.forEach { [weak self] obj in
            var chatObj:MPChat?
            guard self != nil else { return }
            if let chatListObj = self?.getChatFromDb(conversationID: SharedManager.shared.ReturnValueAsString(value: obj.conversationId ?? 0)) {
                chatObj = chatListObj
            }else {
                chatObj = MPChat(context: context)
            }
            
            guard chatObj != nil else { return }
            
            chatObj?.buyerName = obj.buyerName ?? .emptyString
            chatObj?.conversationId = SharedManager.shared.ReturnValueAsString(value: obj.conversationId ?? 0)
            chatObj?.conversationName = obj.conversationName ?? .emptyString
            chatObj?.createdAt = obj.createdAt ?? .emptyString
            chatObj?.deletedAt = obj.deletedAt ?? .emptyString
            chatObj?.deletedLastMessage = obj.deletedLastMessage ?? .emptyString
            chatObj?.groupImage = obj.groupImage ?? .emptyString
            chatObj?.isArchive = obj.isArchive == 1
            chatObj?.isGroupLeave = obj.isGroupLeave ?? false
            chatObj?.isOwner = obj.isOwner ?? false
            chatObj?.isRead = obj.isRead == 1
            chatObj?.label = obj.label ?? .emptyString
            chatObj?.lastMessage = obj.lastMessage ?? .emptyString
            chatObj?.lastMessageTime = obj.lastMessageTime ?? .emptyString
            chatObj?.lastMessageLabel = obj.lastMessageLabel ?? .emptyString
            chatObj?.lastMessengerId = SharedManager.shared.ReturnValueAsString(value: obj.lastMessengerId ?? 0)
            chatObj?.mutedAt = obj.mutedAt ?? .emptyString
            chatObj?.mutedTill = obj.mutedTill ?? .emptyString
            chatObj?.ownerId = SharedManager.shared.ReturnValueAsString(value: obj.ownerId ?? 0)
            chatObj?.productPrice = obj.productPrice ?? .emptyString
            chatObj?.offerStatus = obj.offerStatus ?? .emptyString
            
            if let chatMembers = obj.participants, chatMembers.count > 0 {
                if let members = chatObj?.toMember, members.allObjects.count > 0 {
                    for memberObj in chatObj?.toMember?.allObjects as? [MPMember] ?? [] {
                        chatObj?.removeFromToMember(memberObj)
                    }
                }
                if let self = self {
                    chatObj?.addToToMember(self.getMemberSet(arrayMember: chatMembers))
                }
            }
            chatObj?.nickname = self?.getMember(chat: chatObj!)?.nickname ?? .emptyString

            CoreDbManager.shared.saveContext()
        }
    }
    
    func getMember(chat: MPChat) -> MPMember? {
        if let members = chat.toMember as? Set<MPMember> {
            return members.first { $0.id == chat.ownerId }
        }
        return nil
    }
    
    func getMemberSet(arrayMember:[MPChatParticipant])->NSSet {
        let moc = CoreDbManager.shared.persistentContainer.viewContext
        let memberSet = NSMutableSet()
        for obj in arrayMember {
            let memberObj = MPMember.init(context: moc)
            memberObj.id = SharedManager.shared.ReturnValueAsString(value: obj.id ?? 0)
            memberObj.firstname = obj.firstname ?? .emptyString
            memberObj.lastname = obj.lastname ?? .emptyString
            memberObj.profileImage = obj.profileImage ?? .emptyString
            memberObj.username = obj.username ?? .emptyString
            memberObj.nickname = obj.nickname ?? .emptyString
            memberObj.worldnoorUserId = SharedManager.shared.ReturnValueAsString(value: obj.worldnoorUserId ?? 0)
            memberObj.leaveBy = obj.leaveBy ?? .emptyString
            memberObj.name = obj.name ?? .emptyString
            memberSet.add(memberObj)
        }
        return memberSet
    }
    
    static func getChatMember(id:String) -> MPMember? {
        let context = CoreDbManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntity.member.entityName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        var results: [NSManagedObject] = []
        do {
            results = try context.fetch(fetchRequest)
        }
        catch {
            LogClass.debugLog("error executing fetch request: \(error)")
        }
        if results.count > 0 {
            if let member = results[0] as? MPMember {
                return member
            }
        }
        return nil
    }
    
    func fetchAllChatFromDB(convType:MPConversationType = .chat)->[MPChat] {
        let moc = CoreDbManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: MPCoreDataEntity.chat.entityName)
        fetchRequest.predicate = convType.predicate
        do {
            let result = try moc.fetch(fetchRequest)
            if let objData: [MPChat] = result as? [MPChat] {
                return objData.sorted(by: {$0.lastMessageTime > $1.lastMessageTime})
            } else {
                LogClass.debugLog("Error in fetching data")
            }
        } catch {
            LogClass.debugLog("Error")
        }
        return []
    }
    
    static func deleteChatObj(chat_id: String) {
        let moc = CoreDbManager.shared.persistentContainer.viewContext
        let fetchResult = NSFetchRequest<NSFetchRequestResult>(entityName: MPCoreDataEntity.chat.entityName)
        fetchResult.predicate = NSPredicate(format: "conversationId = %@", chat_id)
        do {
            let objToDelete = try moc.fetch(fetchResult)
            if objToDelete.count > 0 {
                if let obj = objToDelete[0] as? MPChat {
                    moc.delete(obj)
                    CoreDbManager.shared.saveContext()
                }
            }
        }catch {
            fatalError(error.localizedDescription)
        }
    }
    
    static func deleteChat(){
        ChatDBManager.deleteAllData(entity: "MPMessage")
        ChatDBManager.deleteAllData(entity: "MPMessageFile")
        ChatDBManager.deleteAllData(entity: "MPChat")
        ChatDBManager.deleteAllData(entity: "MPMessageReaction")
    }
    
    static func deleteAllData(entity: String){
        
        let managedContext = CoreDbManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let arrObj = try managedContext.fetch(fetchRequest)
            for managedObj in arrObj as! [NSManagedObject] {
                managedContext.delete(managedObj)
            }
            try managedContext.save()
        } catch let error as NSError {
            print("delete fail--",error)
        }
    }
}
