//
//  AppDelegate.swift
//  Karaoke
//
//  Created by Anh Phung on 2/25/19.
//  Copyright © 2019 TPham. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let defaults = UserDefaults.standard
        let isPreloaded = defaults.bool(forKey: "isPreloaded")
        if !isPreloaded {
            preloadData()
            defaults.set(true, forKey: "isPreloaded")
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "tpham.Karaoke_Songs" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Karaoke", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("Karaoke.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: nil)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(String(describing: error)), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(String(describing: error)), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
    
    // MARK: - Parsing Csv file
    func parseCSV (contentsOfURL: NSURL, encoding: String.Encoding, error: NSErrorPointer) -> [(number:String, title:String, artists: String)]? {
        // Load the CSV file and parse it
        let delimiter = ","
        var items:[(number:String, title:String, artists:String)]?
        var content = ""
        do {
            content = try NSString(contentsOf: contentsOfURL as URL, encoding: String.Encoding.utf8.rawValue) as String
        } catch {}
        
        items = []
        let lines:[String] = content.components(separatedBy: NSCharacterSet.newlines) as [String]
        
        for line in lines {
            var values:[String] = []
            if line != "" {
                
                values = line.components(separatedBy: delimiter)
                
                // Put the values into the tuple and add it to the items array
                let artistsArray = values[2].components(separatedBy: ";")
                let artistsTrimmed = artistsArray.map { $0.trimmingCharacters(in: .whitespaces) }
                let artistsJoined = artistsTrimmed.joined(separator: ", ")
                
                let item = (number: values[0].trimmingCharacters(in: .whitespaces), title: values[1].trimmingCharacters(in: .whitespaces), artists: artistsJoined)
                items?.append(item)
            }
        }
        
        return items
    }
    
    func preloadData () {
        // Retrieve data from the source file
        if let contentsOfURL = Bundle.main.url(forResource: "SongList", withExtension: "csv") {
            
            // Remove all the menu items before preloading
            removeData()
            
            var error : NSError?
            if let items = parseCSV(contentsOfURL: contentsOfURL as NSURL, encoding: String.Encoding.utf8, error: &error) {
                // Preload the menu items
                if let managedObjectContext = self.managedObjectContext {
                    for item in items {
                        let song = NSEntityDescription.insertNewObject(forEntityName: "Song", into: managedObjectContext) as! Song
                        
                        song.number = item.number
                        song.title = item.title
                        song.artists = item.artists
                        
                        do { try managedObjectContext.save() } catch {}
                    }
                }
            }
        }
    }
    
    func removeData () {
        // Remove the existing items
        if let managedObjectContext = self.managedObjectContext {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Song")
            
            do {
                // Execute the fetch request, and cast the results to an array of LogItem objects
                if let fetchResults = try managedObjectContext.fetch(fetchRequest) as? [Song] {
                    for song in fetchResults {
                        managedObjectContext.delete(song)
                    }
                }
            } catch {}
        }
    }
}

