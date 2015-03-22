//
//  MemeDetailController.swift
//  MemeMe
//
//  Created by ivan lares on 3/17/15.
//  Copyright (c) 2015 Ivan Lares. All rights reserved.
//

import UIKit
import CoreData

class MemeDetailController: UIViewController {
    var managedContext: NSManagedObjectContext!
    var selectedMeme: Meme!
    
    @IBOutlet weak var memeImageView: UIImageView!

    override func viewDidLoad() {
        //Grab selectedMeme from documents directory
        let documentsDirectory =
            NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let dirPath = documentsDirectory[0] as String
        var getImagePath = dirPath.stringByAppendingPathComponent(selectedMeme.memedImage)
        
        //Show selected Meme
        memeImageView.contentMode  = UIViewContentMode.ScaleAspectFit
        memeImageView.image = UIImage(contentsOfFile: getImagePath)
    }
    

}
