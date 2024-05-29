//
//  CoreDbManager.swift
//  WorldNoor
//
//  Created by Awais on 17/10/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import CoreData


class CoreDbManager {
    
    static let shared = CoreDbManager()
    
    private init() {
        let moc = persistentContainer.viewContext
        moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        LogClass.debugLog("dbdebug merge policy applied")
        
    }
    
    func deleteAllEntities() {
        let entities = CoreDbManager.shared.persistentContainer.managedObjectModel.entities
        for entitie in entities {
            delete(entityName: entitie.name!)
        }
    }
    
    func delete(entityName: String) {
        let moc = CoreDbManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.includesPropertyValues = false
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try moc.execute(deleteRequest)
            LogClass.debugLog("Deleted Entitie - \(entityName)")
        } catch let error as NSError {
            LogClass.debugLog("Delete ERROR \(entityName)")
            LogClass.debugLog(error)
        }
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        // Change from NSPersistentContainer to your custom class
        let container = NSCustomPersistentContainer(name: "Worldnoor")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = CoreDbManager.shared.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                LogClass.debugLog("dbdebug \(error.localizedDescription)")
            }
        }
    }
    
    func deleteEverything(){
        let storeContainer =
        persistentContainer.persistentStoreCoordinator
        
        // Delete each existing persistent store
        for store in storeContainer.persistentStores {
            do {
                try storeContainer.destroyPersistentStore(
                    at: store.url!,
                    ofType: store.type,
                    options: nil
                )
            }
            catch{
              
            }
        }
        
        // Re-create the persistent container
        persistentContainer = NSPersistentContainer(
            name: "Worldnoor" // the name of
            // a .xcdatamodeld file
        )
        
        // Calling loadPersistentStores will re-create the
        // persistent stores
        persistentContainer.loadPersistentStores {
            (store, error) in
            // Handle errors
        }
    }
}


