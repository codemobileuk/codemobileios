//
//  CoreDataHandler.swift
//  CodeMobile
//
//  Created by Louis Woods on 19/01/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class CoreDataHandler {
    
    var sessions: [NSManagedObject] = []
    
    func recieveCoreData(entityNamed: String) -> [NSManagedObject]{
        
        sessions.removeAll()
        let managedContext = getContext()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityNamed)
        
        do {
            
            let searchResults = try managedContext.fetch(fetchRequest)
            
            print("Count of tables in \(entityNamed) is \(searchResults.count)")
            print("The titles of each table are: ")
            for item in searchResults as [NSManagedObject] {
                
                //print("\(item.value(forKey: "sessionTitle"))")
                sessions.append(item)
                
            }
            
        } catch let error as NSError {
            print("Failed: Could not fetch. \(error), \(error.userInfo)")
        }
        
        return sessions
        
    }
    
    func deleteAllData(entityNamed: String)
    {
        let managedContext = getContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityNamed)
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let results = try getContext().fetch(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject
                managedContext.delete(managedObjectData)
                sessions.removeAll()
                print("Data deleted \(sessions)")
                

            }
            
            do {
                try managedContext.save()
                print("Saved data!")
            } catch let error as NSError {
                print("Failed: Could not save. \(error), \(error.userInfo)")
            }

        } catch let error as NSError {
            print("Failed: Delete all data in \(entityNamed) error : \(error) \(error.userInfo)")
        }
    }
    
    
    func getContext() -> NSManagedObjectContext {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
        
    }
    
}

class Entities{
    // List of all entity names ()
    static let SCHEDULE = "Schedule"
    static let SPEAKERS = "Speaker"
    static let LOCATIONS = "SessionLocation"
}


