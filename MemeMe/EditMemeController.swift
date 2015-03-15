//
//  EditMemeController.swift
//  MemeMe
//
//  Created by ivan lares on 3/14/15.
//  Copyright (c) 2015 Ivan Lares. All rights reserved.
//

import UIKit
import CoreData

class EditMemeController: UIViewController {


    @IBOutlet weak var topField: UITextField!
    
    @IBOutlet weak var bottomField: UITextField!
    
    //#MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    deinit{
        
    }

    //#MARK: - Actions

    @IBAction func didCancel(sender: AnyObject) {
        
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)

        
    }
    
    @IBAction func pickImageAlbum(sender: UIBarButtonItem) {
    }
    
    @IBAction func pickImageCamera(sender: UIBarButtonItem) {
    }
    
    //let nextController = UIImagePickerController()
    //self.presentViewController(nextController, animated: true, completion: nil )
    
    //#MARK: - View
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }


    
}
