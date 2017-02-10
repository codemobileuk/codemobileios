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
// TODO: Comment class
class CoreDataHandler {
    
    var sessions: [NSManagedObject] = []
    
    func recieveCoreData(entityNamed: String) -> [NSManagedObject]{
        
        sessions.removeAll()
        let managedContext = getContext()
    
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityNamed)
        
        // Sort items
        if entityNamed == Entities.SCHEDULE{
            let sortorder = NSSortDescriptor(key: "sessionStartDateTime", ascending: true)
            fetchRequest.sortDescriptors=[sortorder]
        }
        if entityNamed == Entities.SPEAKERS{
            let sortorder = NSSortDescriptor(key: "firstname", ascending: true)
            fetchRequest.sortDescriptors=[sortorder]
            
        }
    
        do {
            
            let searchResults = try managedContext.fetch(fetchRequest)
            print("...Retrieved \(searchResults.count) tables for \(entityNamed) from Core Data!")
            for item in searchResults as [NSManagedObject] {
                
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
                print("Data deleted \(sessions) for \(entityNamed)")
            }
            
            do {
                try managedContext.save()
                print("Saved \(entityNamed) data!")
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



