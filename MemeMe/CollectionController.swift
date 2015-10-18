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
    memes = (try? managedContext.executeFetchRequest(fetchRequest)) as? [Meme]
    let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
    center.addObserver(self, selector: "refreshData:", name: NSManagedObjectContextDidSaveNotification, object: nil)
  }
  
  @IBAction func didPressAdd(sender: UIBarButtonItem) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let editMeme = storyboard.instantiateViewControllerWithIdentifier("EditMemeController")
    self.presentViewController(editMeme, animated: true, completion: nil)
  }
  
  func refreshData(notification: NSNotification){
    self.managedContext.mergeChangesFromContextDidSaveNotification(notification)
    let fetchRequest = NSFetchRequest(entityName: "Meme")
    let dateSort =
    NSSortDescriptor(key: "date", ascending: false)
    fetchRequest.sortDescriptors = [dateSort]
    memes = (try? managedContext.executeFetchRequest(fetchRequest))as? [Meme]
    self.collectionView?.reloadData()
  }
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.memes!.count
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath) as! CollectionCell
    let formatter = NSDateFormatter()
    formatter.dateStyle = NSDateFormatterStyle.MediumStyle
    cell.dateLabel.text  = formatter.stringFromDate(memes![indexPath.row].date)
    let dirPath = directoryPath()
    let getImagePath =
    dirPath.stringByAppendingString("/\(memes![indexPath.row].memedImage)")
    cell.memedCellImage?.contentMode = UIViewContentMode.ScaleAspectFit
    cell.memedCellImage?.image = UIImage(contentsOfFile: getImagePath)
    
    return cell
  }
  
  // MARK: - Navigation
  
  //Present MemeDetailController
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showMeme"{
      let detailMemeController = segue.destinationViewController as! MemeDetailController
      if let indexPath = self.collectionView?.indexPathsForSelectedItems()![0]{
        let meme = self.memes![indexPath.row]
        detailMemeController.managedContext = self.managedContext
        detailMemeController.selectedMeme = meme
      }
    }
  }
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath) {
    performSegueWithIdentifier("showMeme", sender: self)
  }
  
  //#MARK: - convenience
  
  func directoryPath() ->String {
    let documentsDirectory =
    NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let dirPath = documentsDirectory[0]
    return dirPath
  }
}
