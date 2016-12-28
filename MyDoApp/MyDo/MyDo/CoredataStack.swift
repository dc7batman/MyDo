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
    
    override init() {
        super.init()
        setupManagedObjectModel()
        setupStoreCoordinator()
        setupStore()
    }
    
    func setupManagedObjectModel() {
        let modelurl = Bundle.main.url(forResource: "Model", withExtension: "momd")
        managedObjectModel = NSManagedObjectModel.init(contentsOf: modelurl!)
    }
    
    func setupStoreCoordinator() {
        storeCoordinator = NSPersistentStoreCoordinator.init(managedObjectModel: managedObjectModel!)
    }
    
    func setupStore() {
        let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                       NSInferMappingModelAutomaticallyOption: true]
        
        let storeUrl : URL = databaseFilePath() as! URL
        
        do {
            store = try storeCoordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: "ModelConfig", at: storeUrl, options: options)
        }
        catch {
            assert(false, "Store creation failed")
        }
    }
    
    func databaseFilePath() -> NSURL? {
        
        let libraryUrl = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
        let fileUrl = libraryUrl?.appendingPathComponent("AppLibrary")
        if !FileManager.default.fileExists(atPath: (fileUrl?.path)!) {
            do {
                try FileManager.default.createDirectory(at: fileUrl!, withIntermediateDirectories: false, attributes: nil)
            } catch {
                assert(false, "Creating database directory failed")
            }
        }
        return fileUrl?.appendingPathComponent("itemsdatbase.sqlite") as NSURL?
    }
}
