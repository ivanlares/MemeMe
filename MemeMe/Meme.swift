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

}
