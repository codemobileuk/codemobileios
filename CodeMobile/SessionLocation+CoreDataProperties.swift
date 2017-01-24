//
//  SessionLocation+CoreDataProperties.swift
//  
//
//  Created by Louis Woods on 24/01/2017.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension SessionLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SessionLocation> {
        return NSFetchRequest<SessionLocation>(entityName: "SessionLocation");
    }

    @NSManaged public var latitude: Double
    @NSManaged public var locationDescription: String?
    @NSManaged public var locationName: String?
    @NSManaged public var longitude: Double

}
