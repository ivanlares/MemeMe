//
//  CollectionController.swift
//  MemeMe
//
//  Created by ivan lares on 3/20/15.
//  Copyright (c) 2015 Ivan Lares. All rights reserved.
//

import UIKit
import CoreData


class CollectionController: UICollectionViewController {

    var managedContext: NSManagedObjectContext!
    var memes: [Meme]?
    
    override func viewDidLoad() {
        
       
        
        
        
        
        let fetchRequest = NSFetchRequest(entityName: "Meme")
        
        let dateSort =
        NSSortDescriptor(key: "date", ascending: false)
        
        fetchRequest.sortDescriptors = [dateSort]
        
        memes = managedContext.executeFetchRequest(fetchRequest, error: nil) as [Meme]?
        
        
        
        
        //Sign up for NSManagedObjectContextDidSaveNotification
        //To know when other Controllers make changes to the NSPersistentStore
        //This way we can keep the TableView updated with the latest info
        var center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "refreshData:", name: NSManagedObjectContextDidSaveNotification, object: nil)
        
        
//        
//        var delegateApp = UIApplication.sharedApplication().delegate as AppDelegate
//        
//        self.managedContext = delegateApp.coreDataStack.context
//        //fetch
//        let fetchRequest = NSFetchRequest(entityName: "Meme")
//        
//        let dateSort =
//        NSSortDescriptor(key: "date", ascending: false)
//        
//        fetchRequest.sortDescriptors = [dateSort]
//        
//        memes = managedContext.executeFetchRequest(fetchRequest, error: nil) as [Meme]?
//        //reload
//        collectionView?.reloadData()
        
        
        
    }

    
    override func viewDidAppear(animated: Bool) {
      

    }
    
    
    //Refresh Data for table
    func refreshData(notification: NSNotification){
        //Merges any data that was created with other instances of the managedObjectContext
        //Data that was added in EditMemeController is Merged
        
        self.managedContext.mergeChangesFromContextDidSaveNotification(notification)
        
        let fetchRequest = NSFetchRequest(entityName: "Meme")
        let dateSort =
        NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        memes = managedContext.executeFetchRequest(fetchRequest, error: nil) as [Meme]?
        
        self.collectionView?.reloadData()
    }
    
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.memes!.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath) as CollectionCell

        
        // Set the name and image
        //cell.dateLabel.text = memes![indexPath.row].date
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        //formatter.timeStyle = NSDateFormatterStyle.NoStyle
        cell.dateLabel.text  = formatter.stringFromDate(memes![indexPath.row].date)
        
        
        let dirPath = directoryPath()
        var getImagePath = dirPath.stringByAppendingPathComponent(memes![indexPath.row].memedImage)
        cell.memedCellImage?.contentMode = UIViewContentMode.ScaleAspectFit
        cell.memedCellImage?.image = UIImage(contentsOfFile: getImagePath)
        
        
        return cell
    }
    
    
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showMeme"{
            
            var detailMemeController = segue.destinationViewController as MemeDetailController
            
            if let indexPath = self.collectionView?.indexPathsForSelectedItems()[0] as? NSIndexPath{
                let meme = self.memes![indexPath.row]
                
                detailMemeController.managedContext = self.managedContext
                detailMemeController.selectedImageName = meme.memedImage
            }
        }
    }
    
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath) {
        performSegueWithIdentifier("showMeme", sender: self)
    }
    

    func directoryPath() ->String {
        let fileManager = NSFileManager.defaultManager()
        let documentsDirectory =
        NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let dirPath = documentsDirectory[0] as String
        
        return dirPath
    }
    
}
