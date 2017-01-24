//
//  Speaker+CoreDataProperties.swift
//  
//
//  Created by Louis Woods on 24/01/2017.
//
//

import Foundation
import CoreData


extension Speaker {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Speaker> {
        return NSFetchRequest<Speaker>(entityName: "Speaker");
    }

    @NSManaged public var firstname: String?
    @NSManaged public var fullName: String?
    @NSManaged public var organisation: String?
    @NSManaged public var photoURL: String?
    @NSManaged public var profile: String?
    @NSManaged public var speakerId: Int32
    @NSManaged public var surname: String?
    @NSManaged public var twitter: String?

}
