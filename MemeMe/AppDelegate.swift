//
//  AppDelegate.swift
//  MemeMe
//
//  Created by ivan lares on 3/14/15.
//  Copyright (c) 2015 Ivan Lares. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  lazy var coreDataStack = CoreDataStack()
  
  var isFirstLaunch: Bool?
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    isFirstLaunch = true
    
    let tabBarController = self.window!.rootViewController as! UITabBarController
    //Give a refrence to the managedObjectContext to the Table and Collection Views
    if let tabItems = tabBarController.viewControllers {
      //first tab item
      var navigationController = tabItems[0] as! UINavigationController
      let tableViewController =
      navigationController.topViewController as! TableController
      tableViewController.managedContext = coreDataStack.context
      //second tab item
      var navigationControllerCollection = tabItems[1] as! UINavigationController
      let collectionViewController =
      navigationControllerCollection.topViewController as! CollectionController
      collectionViewController.managedContext = coreDataStack.context
    }
    
    return true
  }
  
  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    coreDataStack.saveContext()
  }
  
  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    coreDataStack.saveContext()
  }
  
  
}

