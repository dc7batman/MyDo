//
//  CoredataStack.swift
//  MyDo
//
//  Created by Mohan on 28/12/16.
//  Copyright © 2016 eventfy. All rights reserved.
//

import UIKit
import CoreData

class CoredataStack: NSObject {
    
    var managedObjectModel : NSManagedObjectModel?
    var storeCoordinator : NSPersistentStoreCoordinator?
    var store : NSPersistentStore?
    var mainMoc : NSManagedObjectContext?
    var rootMoc : NSManagedObjectContext?
    var backgroundMoc : NSManagedObjectContext?
    
    
    override init() {
        super.init()
        setupManagedObjectModel()
        setupStoreCoordinator()
        setupStore()
        setupRootContext()
        setupMainContext()
        setupBackgroundContext()
    }
    
    func databaseFilePath() -> NSURL? {
        
        let libraryUrl = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
        let fileUrl = libraryUrl?.appendingPathComponent("MyDoData")
        if !FileManager.default.fileExists(atPath: (fileUrl?.path)!) {
            do {
                try FileManager.default.createDirectory(at: fileUrl!, withIntermediateDirectories: false, attributes: nil)
            } catch {
                assert(false, "Creating database directory failed")
            }
        }
        return fileUrl?.appendingPathComponent("itemsdatbase.sqlite") as NSURL?
    }
    
    func setupManagedObjectModel() {
        guard let modelurl = Bundle.main.url(forResource: "Model", withExtension: "momd") else {
            assert(false, "Uncable to find model url")
        }
        managedObjectModel = NSManagedObjectModel.init(contentsOf: modelurl)
    }
    
    func setupStoreCoordinator() {
        storeCoordinator = NSPersistentStoreCoordinator.init(managedObjectModel: managedObjectModel!)
    }
    
    func setupStore() {
        let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                       NSInferMappingModelAutomaticallyOption: true]
        
        let storeUrl : URL = databaseFilePath() as! URL
        
        do {
            store = try storeCoordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeUrl, options: options)
        }
        catch {
            assert(false, "Store creation failed")
        }
    }
    
    func setupRootContext() {
        rootMoc = NSManagedObjectContext.init(concurrencyType: .privateQueueConcurrencyType)
        rootMoc?.persistentStoreCoordinator = storeCoordinator
        rootMoc?.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func setupMainContext() {
        mainMoc = NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType)
        mainMoc?.parent = rootMoc
    }
    
    func setupBackgroundContext() {
        backgroundMoc = NSManagedObjectContext.init(concurrencyType: .privateQueueConcurrencyType)
        backgroundMoc?.parent = mainMoc
    }
    
    func doSaveMoc(moc: NSManagedObjectContext) {
        
        do {
            try moc.obtainPermanentIDs(for: Array(moc.insertedObjects))
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        do {
            try moc.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        if let parentMoc = moc.parent {
            doSaveMoc(moc: parentMoc)
        }
    }
}
