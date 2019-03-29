//
//  ApiHandler.swift
//  CodeMobile
//
//  Created by Louis Woods on 19/01/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreData

class ApiHandler {
    
    // SESSIONS
    func storeSchedule(updateData: @escaping () -> Void) {
        let managedContext = getContext()
        
        Alamofire.request(Commands.API_URL + Commands.SCHEDULE).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                
                let swiftyJsonVar = JSON(responseData.result.value!)
                let entity = NSEntityDescription.entity(forEntityName: "Schedule", in: managedContext)!
                
                for item in swiftyJsonVar {
                    let session = NSManagedObject(entity: entity, insertInto: managedContext)
                    session.setValue(item.1["SessionId"].int, forKeyPath: "sessionId")
                    session.setValue(item.1["SessionTitle"].string, forKeyPath: "sessionTitle")
                    session.setValue(item.1["SessionDescription"].string, forKeyPath: "sessionDescription")
                    session.setValue(item.1["SessionStartDateTime"].string, forKeyPath: "sessionStartDateTime")
                    session.setValue(item.1["SessionEndDateTime"].string, forKeyPath: "sessionEndDateTime")
                    session.setValue(item.1["Speaker"]["SpeakerId"].int, forKeyPath: "speakerId")
                    session.setValue(item.1["SessionLocation"]["LocationName"].string, forKeyPath: "sessionLocationName")
                }
                
                do {
                    // Delete any data schedule may have within, to avoid possible duplicated data
                    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Schedule")
                    let request = NSBatchDeleteRequest(fetchRequest: fetch)
                    try managedContext.execute(request)
                    print("Deleted any current schedule data!")
                    // Get current database version, so may check if it is out of date
                    let currentModifiedDate = UserDefaults.standard.value(forKeyPath: "ModifiedDate")
                    UserDefaults.standard.set(currentModifiedDate, forKey: "ModifiedScheduleDate")
                    print("The schedule version is : \(UserDefaults.standard.value(forKeyPath: "ModifiedScheduleDate")!)")
                    // Save new data
                    print("Saved schedule data!")
                    try managedContext.save()
                    
                    updateData()
                } catch let error as NSError {
                    print("Failed: Could not save. \(error), \(error.userInfo)")
                }
            }
        }
    }
    
    // SPEAKERS
    func storeSpeakers(updateData: @escaping () -> Void) {
        let managedContext = getContext()
        
        Alamofire.request(Commands.API_URL + Commands.SPEAKERS).responseJSON { (responseData) -> Void in
            if responseData.result.value != nil {
                let swiftyJsonVar = JSON(responseData.result.value!)
                let entity = NSEntityDescription.entity(forEntityName: "Speaker", in: managedContext)!
                
                for item in swiftyJsonVar {
                    let speaker = NSManagedObject(entity: entity, insertInto: managedContext)
                    speaker.setValue(item.1["SpeakerId"].int, forKeyPath: "speakerId")
                    speaker.setValue(item.1["Firstname"].string, forKeyPath: "firstname")
                    speaker.setValue(item.1["Surname"].string, forKeyPath: "surname")
                    speaker.setValue(item.1["Twitter"].string, forKeyPath: "twitter")
                    speaker.setValue(item.1["Organisation"].string, forKeyPath: "organisation")
                    speaker.setValue(item.1["Profile"].string, forKeyPath: "profile")
                    speaker.setValue(item.1["PhotoURL"].string, forKeyPath: "photoURL")
                    speaker.setValue(item.1["FullName"].string, forKeyPath: "fullName")
                }
                
                do {
                    // Delete any data speakers may have within, to avoid possible duplicated data
                    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Speaker")
                    let request = NSBatchDeleteRequest(fetchRequest: fetch)
                    try managedContext.execute(request)
                    print("Deleted any current speakers data!")
                    // Get current database version, so may check if it is out of date
                    let currentModifiedDate = UserDefaults.standard.value(forKeyPath: "ModifiedDate")
                    UserDefaults.standard.set(currentModifiedDate, forKey: "ModifiedSpeakersDate")
                    print("The speakers version is : \(UserDefaults.standard.value(forKeyPath: "ModifiedSpeakersDate")!)")
                    // Save new data
                    try managedContext.save()
                    print("Saved speakers data!")
                    
                    updateData()
                } catch let error as NSError {
                    print("Failed: Could not save. \(error), \(error.userInfo)")
                }
            }
        }
    }
    
    // LOCATIONS
    func storeLocations(updateData: @escaping () -> Void) {
        let managedContext = getContext()
        
        Alamofire.request(Commands.API_URL + Commands.LOCATIONS).responseJSON { (responseData) in
            if responseData.result.value != nil {
                let swiftyJsonVar = JSON(responseData.result.value!)
                let entity = NSEntityDescription.entity(forEntityName: "SessionLocation", in: managedContext)!
                
                for item in swiftyJsonVar {
                    let location = NSManagedObject(entity: entity, insertInto: managedContext)
                    location.setValue(item.1["LocationName"].string, forKeyPath: "locationName")
                    location.setValue(item.1["Longitude"].double, forKeyPath: "longitude")
                    location.setValue(item.1["Latitude"].double, forKeyPath: "latitude")
                    location.setValue(item.1["Description"].string, forKeyPath: "locationDescription")
                    location.setValue(item.1["Type"].string, forKeyPath: "type")
                    
                    if let image = item.1["Image"].string {
                        location.setValue("\(Commands.SITE_URL)/\(image)", forKeyPath: "imageURL")
                    }
                }

                do {
                    // Delete any data locations may have within, to avoid possible duplicated data
                    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "SessionLocation")
                    let request = NSBatchDeleteRequest(fetchRequest: fetch)
                    try managedContext.execute(request)
                    print("Deleted any current locations data!")
                    // Get current database version, so may check if it is out of date
                    let currentModifiedDate = UserDefaults.standard.value(forKeyPath: "ModifiedDate")
                    UserDefaults.standard.set(currentModifiedDate, forKey: "ModifiedLocationsDate")
                    print("The locations version is : \(UserDefaults.standard.value(forKeyPath: "ModifiedLocationsDate")!)")
                    // Save new data
                    try managedContext.save()
                    print("Saved location data!")
                    
                    updateData()
                } catch let error as NSError {
                    print("Failed: Could not save. \(error), \(error.userInfo)")
                }
            }
        }
    }
    
    // TAGS
    func storeTags(updateData: @escaping () -> Void) {
        let managedContext = getContext()
        
        Alamofire.request(Commands.API_URL + Commands.TAGS).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                
                let swiftyJsonVar = JSON(responseData.result.value!)
                let entity = NSEntityDescription.entity(forEntityName: "Tags", in: managedContext)!
                
                
                for item in swiftyJsonVar {
                    
                    let tag = NSManagedObject(entity: entity, insertInto: managedContext)
                    tag.setValue(item.1["TagId"].int, forKeyPath: "tagId")
                    tag.setValue(item.1["Tag"].string, forKeyPath: "tag")
                    tag.setValue(item.1["SessionId"].int, forKeyPath: "sessionId")
                }
                
                do {
                     // Delete any data speakers may have within, to avoid possible duplicated data
                    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Tags")
                    let request = NSBatchDeleteRequest(fetchRequest: fetch)
                    try managedContext.execute(request)
                    print("Deleted any current tags data!")
                    // Get current database version, so may check if it is out of date
                    let currentModifiedDate = UserDefaults.standard.value(forKeyPath: "ModifiedDate")
                    UserDefaults.standard.set(currentModifiedDate, forKey: "ModifiedTagsDate")
                    print("The tags version is : \(UserDefaults.standard.value(forKeyPath: "ModifiedTagsDate")!)")
                    // Save new data
                    try managedContext.save()
                    print("Saved tags data!")
                    
                    updateData()
                } catch let error as NSError {
                    print("Failed: Could not save. \(error), \(error.userInfo)")
                }
            }
        }
    }
    
    // MODIFIED
    func getLatestApiVersion(updateData: @escaping () -> Void) {
        if Reachability.isConnectedToNetwork() {
            // If internet access is avaliable, check latest database version
            print("Connected")
            Alamofire.request(Commands.API_URL + Commands.MODIFIED).responseJSON { (responseData) -> Void in
                if((responseData.result.value) != nil) {
                    let swiftyJsonVar = JSON(responseData.result.value!)
                    
                    if let modifiedDate = swiftyJsonVar["ModifiedDate"].string {
                        UserDefaults.standard.set(modifiedDate, forKey: "ModifiedDate")
                    }
                    
                    print("The api version is : \(UserDefaults.standard.value(forKeyPath: "ModifiedDate")!)")
                    
                    updateData()
                }
            }
        } else {
            // If no internet access, will just load any current data of the app stored
            print("Not connected")
            updateData()
        }
    }
    
    private func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if #available(iOS 10.0, *) {
            return appDelegate.persistentContainer.viewContext
        } else { // Fallback on previous iOS versions
            return appDelegate.managedObjectContext
        }
    }
}
