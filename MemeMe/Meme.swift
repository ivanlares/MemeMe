//
//  Meme.swift
//  MemeMe
//
//  Created by ivan lares on 3/14/15.
//  Copyright (c) 2015 Ivan Lares. All rights reserved.
//

import Foundation
import CoreData

class Meme: NSManagedObject {

    @NSManaged var topString: String
    @NSManaged var bottomString: String
    @NSManaged var originalImage: String
    @NSManaged var memedImage: String
    @NSManaged var date: NSDate
    
    
    
    
    func filePath()-> NSURL? {
        
        let documentsDirectory =
        NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let dirPath = documentsDirectory[0] as String
        
        let pathArray = [dirPath, memedImage]
        
        return NSURL.fileURLWithPathComponents(pathArray)
        
    }
    
    override func prepareForDeletion() {
        
        let fileManager = NSFileManager.defaultManager()
        
        let documentsDirectory =
        NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let dirPath = documentsDirectory[0] as String
        
        fileManager.removeItemAtPath("\(dirPath)/\(memedImage)", error: nil)
    }
    
    
}
