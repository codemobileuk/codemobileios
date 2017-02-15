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
    
    private var sessions: [NSManagedObject] = []
    
    func recieveCoreData(entityNamed: String) -> [NSManagedObject]{
        
        sessions.removeAll()
        let managedContext = getContext()
    
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityNamed)
        
        // Sort items by ___
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
                // Store each item in entity searched for
                sessions.append(item)
            }
        } catch let error as NSError {
            print("Failed: Could not fetch. \(error), \(error.userInfo)")
        }
        
        return sessions
    }
    
    private func getContext() -> NSManagedObjectContext {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
        
    }
    
}



