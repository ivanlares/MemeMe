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
  
  override func prepareForDeletion() {
    let fileManager = NSFileManager.defaultManager()
    let documentsDirectory =
    NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let dirPath = documentsDirectory[0]
    do {
      try fileManager.removeItemAtPath("\(dirPath)/\(memedImage)")
    } catch let error as NSError {
      print(error.localizedDescription)
    }
    do {
      try fileManager.removeItemAtPath("\(dirPath)/\(originalImage)")
    } catch let error as NSError {
      print(error.localizedDescription)
    }
  }
}
