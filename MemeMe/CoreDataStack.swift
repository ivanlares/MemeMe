//
//  CoreDataStack.swift
//  MemeMe
//
//  Created by ivan lares on 3/14/15.
//  Copyright (c) 2015 Ivan Lares. All rights reserved.
//

import CoreData

class CoreDataStack {
    
    
    let context:NSManagedObjectContext
    
    let psc:NSPersistentStoreCoordinator
    
    let model:NSManagedObjectModel
    
    let store:NSPersistentStore?
    
    
    
    init(){
        
        let bundle = NSBundle.mainBundle()
        let modelURL = bundle.URLForResource("MemeMe", withExtension:"momd")
        model = NSManagedObjectModel(contentsOfURL: modelURL!)!
        
        psc = NSPersistentStoreCoordinator(managedObjectModel:model)
        
        context = NSManagedObjectContext()
        context.persistentStoreCoordinator = psc
        
        
        let documentsURL = applicationDocumentsDirectory()
        let storeURL = documentsURL.URLByAppendingPathComponent("MemeMe")
        let options = [NSMigratePersistentStoresAutomaticallyOption: true]
        var error: NSError? = nil
        store = psc.addPersistentStoreWithType(NSSQLiteStoreType,
            configuration: nil, URL: storeURL, options: options, error:&error)
        
    }
    
    
    
    
    func saveContext() {
        var error: NSError? = nil
        
        context.save(&error)
        
        
    }
    
    
    
    func applicationDocumentsDirectory() -> NSURL {
        
        let fileManager = NSFileManager.defaultManager()
        
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask) as [NSURL]
        println(urls[0]) 
        
        return urls[0]
    }
    
    
    
}

