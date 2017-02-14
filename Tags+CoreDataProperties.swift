//
//  Tags+CoreDataProperties.swift
//  
//
//  Created by Louis Woods on 14/02/2017.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Tags {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tags> {
        return NSFetchRequest<Tags>(entityName: "Tags");
    }

    @NSManaged public var tagId: Int32
    @NSManaged public var tag: String?
    @NSManaged public var sessionId: Int32

}
