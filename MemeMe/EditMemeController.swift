//
//  EditMemeController.swift
//  MemeMe
//
//  Created by ivan lares on 3/14/15.
//  Copyright (c) 2015 Ivan Lares. All rights reserved.
//

import UIKit
import CoreData

class EditMemeController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {


    @IBOutlet weak var topField: UITextField!
    
    @IBOutlet weak var bottomField: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    
    //#MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -5.0
        ]
        
        topField.defaultTextAttributes = memeTextAttributes
        topField.textAlignment = NSTextAlignment.Center
        
        
        bottomField.defaultTextAttributes = memeTextAttributes
        bottomField.textAlignment = NSTextAlignment.Center
    }
    
    deinit{
        
    }

    //#MARK: - Actions

    @IBAction func didCancel(sender: AnyObject) {
        
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)

        
    }
    
    @IBAction func pickImageAlbum(sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickImageCamera(sender: UIBarButtonItem) {
    }
    

    
    //#MARK: - View
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    //#MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imageView.contentMode  = UIViewContentMode.ScaleAspectFit
            self.imageView.image = image
            
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
}
