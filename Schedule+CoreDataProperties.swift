//
//  Schedule+CoreDataProperties.swift
//  
//
//  Created by Louis Woods on 26/01/2017.
//
//

import Foundation
import CoreData


extension Schedule {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Schedule> {
        return NSFetchRequest<Schedule>(entityName: "Schedule");
    }

    @NSManaged public var sessionDescription: String?
    @NSManaged public var sessionEndDateTime: String?
    @NSManaged public var sessionId: Int32
    @NSManaged public var sessionLocationName: String?
    @NSManaged public var sessionStartDateTime: String?
    @NSManaged public var sessionTitle: String?
    @NSManaged public var speakerId: Int32

}
