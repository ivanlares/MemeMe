//
//  TableController.swift
//  MemeMe
//
//  Created by ivan lares on 3/14/15.
//  Copyright (c) 2015 Ivan Lares. All rights reserved.
//

import UIKit
import CoreData

class TableController: UITableViewController, NSFetchedResultsControllerDelegate {
  
  var managedContext: NSManagedObjectContext!
  var fetchedResultsController: NSFetchedResultsController!
  /* NSFetchedResultsController
  "Its purpose is to make developers’ lives easier by abstracting away much of the code needed to synchronize a table view with a data source backed by Core Data." - Core Data by tutorial
  */
  
  //#MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let fetchRequest = NSFetchRequest(entityName: "Meme")
    let dateSort =
    NSSortDescriptor(key: "memedImage", ascending: false)
    fetchRequest.sortDescriptors = [dateSort]
    fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
      managedObjectContext: managedContext, sectionNameKeyPath: nil,
      cacheName: nil)
    fetchedResultsController.delegate = self
    do{
      try fetchedResultsController.performFetch()
    }catch let error as NSError {
      print("\(error.localizedDescription)")
    }
    let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
    center.addObserver(self, selector: "refreshData:", name: NSManagedObjectContextDidSaveNotification, object: nil)
  }
  
  //Refresh Data for table
  func refreshData(notification: NSNotification){
    self.managedContext.mergeChangesFromContextDidSaveNotification(notification)
  }
  
  override func viewDidAppear(animated: Bool) {
    
    //Present EditMemeController if (is first Launch) && if (no data in Sore)
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    if (delegate.isFirstLaunch == true)  {
      let emptyStore:Bool = self.tableView.numberOfRowsInSection(0) > 0 ? false : true
      if (emptyStore == true) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let editMeme = storyboard.instantiateViewControllerWithIdentifier("EditMemeController") as! EditMemeController
        delegate.isFirstLaunch = false
        self.presentViewController(editMeme, animated: true, completion: nil)
      }
    }
  }
  
  //# MARK: - Actions
  
  @IBAction func didPressAdd(sender: AnyObject) {
    //Grab an instance of EditMemeController and present it modally
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let editMeme = storyboard.instantiateViewControllerWithIdentifier("EditMemeController")
    self.presentViewController(editMeme, animated: true, completion: nil)
  }
  
  @IBAction func ToggleEditMode(sender: UIBarButtonItem) {
    if self.tableView.editing == true {
      self.tableView.setEditing(false, animated: true)
      sender.title = "Edit"
    } else  {
      self.tableView.setEditing(true, animated: true)
      sender.title = "Done"
    }
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return fetchedResultsController.sections!.count
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let sectionInfo =
    fetchedResultsController.sections![section]
    return sectionInfo.numberOfObjects
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("memeCell", forIndexPath: indexPath)
    // Configure the cell and return it
    configureCell(cell, index: indexPath)
    return cell
  }
  
  func configureCell(cell: UITableViewCell , index: NSIndexPath ) {
    let meme = fetchedResultsController.objectAtIndexPath(index) as! Meme
    cell.textLabel!.text = String("\(meme.topString) \(meme.bottomString)")
    let dirPath = directoryPath()
    let getImagePath = dirPath.stringByAppendingString("/\(meme.memedImage)")
    cell.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
    cell.imageView?.image = UIImage(contentsOfFile: getImagePath)
    let formatter = NSDateFormatter()
    formatter.dateStyle = NSDateFormatterStyle.MediumStyle
    formatter.timeStyle = NSDateFormatterStyle.ShortStyle
    cell.detailTextLabel!.text = formatter.stringFromDate(meme.date)
  }
  
  //#MARK: - TableView Deleting
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
      let memeToDelete =
      fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
      self.managedContext.deleteObject(memeToDelete)
      var error: NSError?
      do {
        try managedContext.save()
      } catch let error1 as NSError {
        error = error1
        print("\(error?.localizedDescription)")
      }
    }
  }
  
  // MARK: - Navigation
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showMeme"{
      let detailMemeController = segue.destinationViewController as! MemeDetailController
      if let indexPath = self.tableView.indexPathForSelectedRow{
        let meme = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Meme
        detailMemeController.managedContext = self.managedContext
        detailMemeController.selectedMeme = meme
      }
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
    performSegueWithIdentifier("showMeme", sender: self)
  }
  
  //#MARK: - Helper Methods
  
  func directoryPath() ->String {
    let documentsDirectory =
    NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let dirPath = documentsDirectory[0]
    return dirPath
  }
  
  //#MARK: - NSFetchedResultsControllerDelegate Methods
  
  func controllerWillChangeContent(controller: NSFetchedResultsController) {
    tableView.beginUpdates()
  }
  
  //Manages changes in the fetchedResultsController
  
  func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
    switch type {
    case .Insert:
      tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
    case .Delete:
      tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
    case .Update:
      let cellToUpdate =
      self.tableView.cellForRowAtIndexPath(indexPath!) as UITableViewCell!
      configureCell(cellToUpdate, index: indexPath!)
    case .Move:
      tableView.deleteRowsAtIndexPaths([indexPath!],
        withRowAnimation: .Automatic)
      tableView.insertRowsAtIndexPaths([newIndexPath!],
        withRowAnimation: .Automatic)
    }
  }
  
  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    tableView.endUpdates()
  }
}
