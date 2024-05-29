//
//  ChatDBManager.swift
//  WorldNoor
//
//  Created by Awais on 17/10/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit
import CoreData

enum CoreDataEntity: String {
    case chat = "Chat"
    case message = "Message"
    case member = "Member"
    case messageFile = "MessageFile"
    case reaction = "Reaction"
    var entityName: String {
        return self.rawValue
    }
}

enum ConversationType {
    case chat
    case archive
    case spam

    var predicate: NSPredicate {
        switch self {
        case .chat:
            return NSPredicate(format: "isArchive == 0 AND isSpam == 0")
        case .archive:
            return NSPredicate(format: "isArchive == 1")
        case .spam:
            return NSPredicate(format: "isSpam == 1")
        }
    }
}

class ChatDBManager: NSObject {
    
    // Chat List Functions.
    func checkRecordExists(entity: String = "Chat", value: Int) -> Bool {
        let context = CoreDbManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        fetchRequest.predicate = NSPredicate(format: "conversation_id == %i", value)
        var results: [NSManagedObject] = []
        do {
            results = try context.fetch(fetchRequest)
        }
        catch {
            LogClass.debugLog("error executing fetch request: \(error)")
        }
        return results.count > 0
    }
    
    func getChatFromDb(conversationID:String) -> Chat? {
        let context = CoreDbManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntity.chat.entityName)
        fetchRequest.predicate = NSPredicate(format: "conversation_id == %@", conversationID)
        var results: [NSManagedObject] = []
        do {
            results = try context.fetch(fetchRequest)
        }
        catch {
            LogClass.debugLog("error executing fetch request: \(error)")
        }
        if results.count > 0 {
            let chatObj = results[0] as! Chat
            return chatObj
        }
        return nil
    }
    
    func getChatSearchFromDb(conversationID:String, searchStr:String) -> Chat? {
        let context = CoreDbManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntity.chat.entityName)
        fetchRequest.predicate = NSPredicate(format: "conversation_id == %@", conversationID, searchStr)
        var results: [NSManagedObject] = []
        do {
            results = try context.fetch(fetchRequest)
        }
        catch {
            LogClass.debugLog("error executing fetch request: \(error)")
        }
        if results.count > 0 {
            let chatObj = results[0] as! Chat
            return chatObj
        }
        return nil
    }
    
    func saveChatData(chatData:[ConversationModel]) {
        let context = CoreDbManager.shared.persistentContainer.viewContext
        
        chatData.forEach { [weak self] obj in
            var chatObj:Chat?
            guard self != nil else { return }
            if let chatListObj = self?.getChatFromDb(conversationID: obj.conversation_id) {
                chatObj = chatListObj
            }else {
                chatObj = Chat(context: context)
            }
            chatObj!.name = obj.name
            chatObj!.author_id = obj.author_id
            chatObj!.has_blocked_me = obj.has_blocked_me
            chatObj!.conversation_id = obj.conversation_id
            chatObj!.conversation_type = obj.conversation_type
            chatObj!.group_image = obj.group_image
            chatObj!.is_mute = obj.is_mute
            chatObj!.is_online = obj.is_online
            chatObj!.is_unread = obj.is_unread
            chatObj!.latest_conversation_id = obj.latest_conversation_id
            chatObj!.latest_message = obj.latest_message
            chatObj!.latest_message_time = obj.latest_message_time
            chatObj!.last_updated = obj.last_updated
            chatObj!.member_id = obj.member_id
            chatObj!.profile_image = obj.profile_image
            chatObj!.unread_messages_count = obj.unread_messages_count
            chatObj!.arrayAdmin_ids = obj.arrayAdmin_ids
            chatObj!.isArchive = obj.isArchive == "1" ? "1" : "0"
            chatObj!.isSpam = obj.isSpam == "1" ? "1" : "0"
            chatObj!.is_blocked = obj.is_blocked == "1" ? "1" : "0"
            chatObj!.theme_color = obj.theme_color
            chatObj!.username = obj.username
            chatObj!.is_leave = obj.is_leave
            if obj.arrayMembers.count > 0 {
                if let members = chatObj!.toMember, members.allObjects.count > 0 {
                    for memberObj in chatObj!.toMember?.allObjects as? [Member] ?? [] {
                        chatObj!.removeFromToMember(memberObj)
                    }
                }
                if let self = self {
                    chatObj!.addToToMember(self.getMemberSet(arrayMember: obj.arrayMembers))
                }
            }
            chatObj!.nickname = self?.getMember(chat: chatObj!)?.nickname ?? ""
            CoreDbManager.shared.saveContext()
        }
    }
    
    func getMember(chat: Chat) -> Member? {
        if let members = chat.toMember as? Set<Member> {
            return members.first { $0.id == chat.member_id }
        }
        return nil
    }
    
    func fetchAllChatFromDB(convType:ConversationType = .chat)->[Chat] {
        let moc = CoreDbManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataEntity.chat.entityName)
        fetchRequest.predicate = convType.predicate
        do {
            let result = try moc.fetch(fetchRequest)
            if let objData: [Chat] = result as? [Chat] {
                //LogClass.debugLog("dbdebug chats \(objData.count)")
                return objData.sorted(by: {$0.last_updated > $1.last_updated})
            } else {
                LogClass.debugLog("Error in fetching data")
            }
        } catch {
            LogClass.debugLog("Error")
        }
        return []
    }
    
    func getMemberSet(arrayMember:[ConversationMemberModel])->NSSet {
        let moc = CoreDbManager.shared.persistentContainer.viewContext
        let memberSet = NSMutableSet()
        for obj in arrayMember {
            let memberObj = Member.init(context: moc)
            memberObj.firstName = obj.firstname
            memberObj.id = obj.id
            memberObj.is_admin = obj.is_admin
            memberObj.is_online = obj.is_online
            memberObj.lastname = obj.lastname
            memberObj.profile_image = obj.profile_image
            memberObj.username = obj.username
            memberObj.nickname = obj.nickname
            memberSet.add(memberObj)
        }
        return memberSet
    }
    
    static func getChatMember(id:String) -> Member? {
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
            let member = results[0] as! Member
            return member
        }
        return nil
    }
    
    static func deleteChatObj(chat_id: String) {
        let moc = CoreDbManager.shared.persistentContainer.viewContext
        let fetchResult = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataEntity.chat.entityName)
        fetchResult.predicate = NSPredicate(format: "conversation_id = %@", chat_id)
        do {
            let objToDelete = try moc.fetch(fetchResult)
            if objToDelete.count > 0 {
                let obj = objToDelete[0] as! Chat
                moc.delete(obj)
                CoreDbManager.shared.saveContext()
            }
        }catch {
            fatalError(error.localizedDescription)
        }
    }
    
    
    static func deleteChat(){
        ChatDBManager.deleteAllData(entity: "Message")
        ChatDBManager.deleteAllData(entity: "MessageFile")
        ChatDBManager.deleteAllData(entity: "Chat")
        ChatDBManager.deleteAllData(entity: "Reaction")
        ChatDBManager.deleteAllData(entity: "Member")
    }
    
    static func deleteAllData(entity: String){

    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let managedContext = CoreDbManager.shared.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
    fetchRequest.returnsObjectsAsFaults = false

    do {
        let arrUsrObj = try managedContext.fetch(fetchRequest)
        for usrObj in arrUsrObj as! [NSManagedObject] {
            managedContext.delete(usrObj)
        }
       try managedContext.save()
        } catch let error as NSError {
        print("delete fail--",error)
      }

    }
    
    static func updateChatTheme(chat_id: Int, colorCode:String) {
        let moc = CoreDbManager.shared.persistentContainer.viewContext
        let fetchResult = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataEntity.chat.entityName)
        fetchResult.predicate = NSPredicate(format: "conversation_id = %i", chat_id)
        do {
            let obj = try moc.fetch(fetchResult)
            if obj.count > 0 {
                let obj = obj[0] as! Chat
                obj.theme_color = colorCode
                CoreDbManager.shared.saveContext()
            }
        }catch {
            fatalError(error.localizedDescription)
        }
    }
}


