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
        
        var error: NSError? = nil
        
        if (!fetchedResultsController.performFetch(&error)) {
            println("\(error?.localizedDescription)")
        }
        
    
        
        //Sign up for NSManagedObjectContextDidSaveNotification 
        //To know when other Controllers make changes to the NSPersistentStore
        //This way we can keep the TableView updated with the latest info
        var center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "refreshData:", name: NSManagedObjectContextDidSaveNotification, object: nil)
    }
    
    //Refresh Data for table
    func refreshData(notification: NSNotification){
        //Merges any data that was created with other instances of the managedObjectContext
        //Data that was added in EditMemeController is Merged
        self.managedContext.mergeChangesFromContextDidSaveNotification(notification)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        //Present EditMemeController if first Launch && if no data in Sore
        var delegate = UIApplication.sharedApplication().delegate as AppDelegate

        if (delegate.isFirstLaunch == true)  {
            let emptyStore:Bool = self.tableView.numberOfRowsInSection(0) > 0 ? false : true
            if (emptyStore == true) {
                var storyboard = UIStoryboard(name: "Main", bundle: nil)
                var editMeme = storyboard.instantiateViewControllerWithIdentifier("EditMemeController") as EditMemeController
                self.presentViewController(editMeme, animated: true, completion: nil)
                delegate.isFirstLaunch = false
            }
        }
    }
    
    
    //# MARK: - Actions
    
    @IBAction func didPressAdd(sender: AnyObject) {
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        var editMeme = storyboard.instantiateViewControllerWithIdentifier("EditMemeController") as UIViewController
        self.presentViewController(editMeme, animated: true, completion: nil)
    }
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return fetchedResultsController.sections!.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionInfo =
            fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        
        return sectionInfo.numberOfObjects
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("memeCell", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell and return it
        configureCell(cell, index: indexPath)
        return cell
    }
    
    func configureCell(cell: UITableViewCell , index: NSIndexPath ) {
        
        let meme = fetchedResultsController.objectAtIndexPath(index) as Meme
        
        cell.textLabel!.text = String("\(meme.topString) \(meme.bottomString)")
        
        let dirPath = directoryPath()
        var getImagePath = dirPath.stringByAppendingPathComponent(meme.memedImage)
        cell.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        cell.imageView?.image = UIImage(contentsOfFile: getImagePath)
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        cell.detailTextLabel!.text = formatter.stringFromDate(meme.date)

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
    
    //#MARK: - TableView Deleting 

    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }
    
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            let memeToDelete =
            fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
            
            self.managedContext.deleteObject(memeToDelete)
            
            var error: NSError?
            
            if !managedContext.save(&error) {
                println("\(error?.localizedDescription)")
            }
        }
        
    }

    


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "showMeme"{
            
            var detailMemeController = segue.destinationViewController as MemeDetailController
            
            if let indexPath = self.tableView.indexPathForSelectedRow(){
                let meme = self.fetchedResultsController.objectAtIndexPath(indexPath) as Meme
                
                detailMemeController.managedContext = self.managedContext
                detailMemeController.selectedImageName = meme.memedImage
            }
        }
    }
    

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        performSegueWithIdentifier("showMeme", sender: self)
    }
    
    
    
    //#MARK: - Helper Methods 
    
    func directoryPath() ->String {
        let fileManager = NSFileManager.defaultManager()
        let documentsDirectory =
        NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let dirPath = documentsDirectory[0] as String
        
        return dirPath
    }
    
    
    //#MARK: - NSFetchedResultsControllerDelegate Methods
    
    func controllerWillChangeContent(controller: NSFetchedResultsController!) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath!,
        forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath!) {
            
            switch type {
                case .Insert:
                    tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
                case .Delete:
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                case .Update:
                    let cellToUpdate =
                        self.tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell!
                    configureCell(cellToUpdate, index: indexPath)
                case .Move:
                    tableView.deleteRowsAtIndexPaths([indexPath],
                        withRowAnimation: .Automatic)
                    tableView.insertRowsAtIndexPaths([newIndexPath],
                        withRowAnimation: .Automatic)
                default:
                    break
            }
    }
    

    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int,
        forChangeType type: NSFetchedResultsChangeType) {
            
            let indexSet = NSIndexSet(index: sectionIndex)
            
            switch type {
                case .Insert:
                    tableView.insertSections(indexSet, withRowAnimation: .Automatic)
                case .Delete:
                    tableView.deleteSections(indexSet, withRowAnimation: .Automatic)
                default :
                    break
            }
    }

    
    
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    

}
