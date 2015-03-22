//
//  EditMemeController.swift
//  MemeMe
//
//  Created by ivan lares on 3/14/15.
//  Copyright (c) 2015 Ivan Lares. All rights reserved.
//

import UIKit
import CoreData

class EditMemeController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var topField: UITextField!
    
    @IBOutlet weak var bottomField: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
  
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    @IBOutlet weak var topToolbar: UIToolbar!

  
    
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
        topField.text = "TOP"
        
        bottomField.defaultTextAttributes = memeTextAttributes
        bottomField.textAlignment = NSTextAlignment.Center
        bottomField.text = "BOTTOM"
        
    }
    
    override func viewWillAppear(animated: Bool) {
        configureTopToolbar()
        configureBottomToolBar()
        signUpForNotifications()
        
    }
    
    deinit{
        removeNotifications()
    }

    //#MARK: - Actions

    @IBAction func didCancel(sender: AnyObject) {
        
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func shareButtonPressed(sender: UIBarButtonItem) {
        //generateMemedImage returns a memedImage
        let memedImage = generateMemedImage()
        
        //UIActivityViewController is created here
        var controller = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        //Closure will be executed when (controller: UIActivitViewController) is done
        controller.completionWithItemsHandler = {(type: String!,completed: Bool, returnedItems: [AnyObject]!, error: NSError!) -> Void in
            //saves Meme If cancel button is not pressed
            //Array with activity types that shouldnt be saved: like printing
            var notSentTypes = [UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList] as [String]
            //Save only if activity type is not in array
            if (contains(notSentTypes, type ) == false ){
                self.saveSentMeme(completed, memedImage: memedImage)
                    }
        }
        //Presents the activityController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func pickImageAlbum(sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickImageCamera(sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    

    @IBAction func toggleBackground(sender: UIBarButtonItem) {
        if self.view.backgroundColor == UIColor.blackColor(){
            self.view.backgroundColor = UIColor.whiteColor()
            sender.image = UIImage(named: "lightOff")
        } else {
            self.view.backgroundColor = UIColor.blackColor()
            sender.image = UIImage(named: "light")
        }
    }

    @IBAction func toggleContentMode(sender: UIBarButtonItem) {
        if self.imageView.contentMode == UIViewContentMode.ScaleAspectFit{
            self.imageView.contentMode  = UIViewContentMode.ScaleAspectFill
            sender.image = UIImage(named: "fill")
            
        } else {
            self.imageView.contentMode  = UIViewContentMode.ScaleAspectFit
            sender.image = UIImage(named: "fit")
        }
    }
    
    //#MARK: - View
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        topField.resignFirstResponder()
        bottomField.resignFirstResponder()
        
    }
    
    func configureBottomToolBar(){
        
        if imageView.image == nil {
            (bottomToolbar.items![7] as UIBarButtonItem).enabled = false
            (bottomToolbar.items![5] as UIBarButtonItem).enabled = false
        } else {
            (bottomToolbar.items![7] as UIBarButtonItem).enabled = true
            (bottomToolbar.items![5] as UIBarButtonItem).enabled = true
        }
        
        (bottomToolbar.items![1] as UIBarButtonItem).enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
    }
    
    func configureTopToolbar(){
        
        if imageView.image == nil {
            (self.topToolbar.items![0] as UIBarButtonItem).enabled = false
        } else {
            (self.topToolbar.items![0] as UIBarButtonItem).enabled = true
        }
    }
    
    
    //#MARK: - Persistence Methods 
    
    func saveSentMeme(sent: Bool, memedImage: UIImage) {
        if sent {
            //Get Documents Directory File Path
            let dirPath = directoryPath()
            
            //Current Date to create unique file name
            let currentDateTime = NSDate()
            
            //Create name for Images
            var memedImageName = nameForImage(currentDateTime, memed: true)
            var originalImageName = nameForImage(currentDateTime, memed: false)
            
            //Create NSURl for memed Image
            let memePathArray = [dirPath, memedImageName]
            let memeFilePath = NSURL.fileURLWithPathComponents(memePathArray)
            //Create NSURL for original Image
            let originalPathArray = [dirPath, originalImageName]
            let originalFilePath = NSURL.fileURLWithPathComponents(originalPathArray)
            
            //Save memed image to documents directory
            let memedImageData:NSData = UIImagePNGRepresentation(memedImage)
            memedImageData.writeToURL(memeFilePath!, atomically: true)
            //Save original image to documents directory 
            let originalImageData:NSData = UIImagePNGRepresentation(self.imageView.image!)
            originalImageData.writeToURL(originalFilePath!, atomically: true)
            
            //Get refrence to ManagedObjectContext & Create a ManagedObject
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let managedObjectContext = appDelegate.coreDataStack.context as NSManagedObjectContext
            let memeEntity =
            NSEntityDescription.entityForName("Meme", inManagedObjectContext: managedObjectContext)
            let meme = Meme(entity: memeEntity! , insertIntoManagedObjectContext: managedObjectContext)
            //set the values for the managedObject
            meme.originalImage = originalImageName
            meme.memedImage = memedImageName
            meme.topString = self.topField.text
            meme.bottomString = self.bottomField.text
            meme.date = currentDateTime
            //Save to coreData
            var error: NSError?
            if !managedObjectContext.save(&error) {
                println("\(error?.localizedDescription)")
            }
        }
    }
    
    
    //#MARK: - Helper Methods
    
    func directoryPath() ->String {
        let fileManager = NSFileManager.defaultManager()
        let documentsDirectory =
        NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let dirPath = documentsDirectory[0] as String
        
        return dirPath
    }
    
    func generateMemedImage() -> UIImage
    {
        //Hide topToolbar and bottomToolbar
        self.bottomToolbar.hidden = true
        self.topToolbar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame,
            afterScreenUpdates: true)
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Displays topToolbar and bottomToolbar
        self.bottomToolbar.hidden = false
        self.topToolbar.hidden = false
        
        return memedImage
    }
    
    func nameForImage(date: NSDate, memed: Bool) -> String{
        
        let currentDateTime = date
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        var pictureName: String!
        
        if (memed == true) {
             pictureName = formatter.stringFromDate(currentDateTime) + "memed" + ".png"
        } else {
             pictureName = formatter.stringFromDate(currentDateTime) + ".png"
        }
        
        return pictureName
        
    }
    
    
    
    //#MARK: - Notification Methods
    
    func signUpForNotifications() {
        
        var center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        center.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        center.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
    }

    func removeNotifications(){
        
        var center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        center.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        center.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }

    //#MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imageView.contentMode  = UIViewContentMode.ScaleAspectFit
            self.imageView.image = image
        }
        
        configureBottomToolBar()
        configureTopToolbar()
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    //#MARK: - UITextFieldDelgate Methods
    
    func keyboardWillHide(notification: NSNotification){
        //Move view back in position
        self.view.frame.origin.y = 0.0
    }
    
    func keyboardWillShow(notification: NSNotification){
        //Move view up when keyboard blocks bottomTextField
        if let info:NSDictionary = notification.userInfo {
            let keyboardSize =
            (info[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
            let keyboardHeight = keyboardSize.height
            
            if self.bottomField.isFirstResponder() == true {
                self.view.frame.origin.y = -(keyboardHeight)
            }
        }
    }
    

    
    
}
