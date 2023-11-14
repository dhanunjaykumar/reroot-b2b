//
//  Project+CoreDataProperties.swift
//  ReRoot
//
//  Created by Dhanunjay on 13/07/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//
//

import Foundation
import CoreData


extension Project {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Project> {
        return NSFetchRequest<Project>(entityName: "Project")
    }

    @NSManaged public var address: String?
    @NSManaged public var builtUpArea: NSDictionary?
    @NSManaged public var city: String?
    @NSManaged public var company: String?
    @NSManaged public var company_group: String?
    @NSManaged public var far: Int64
    @NSManaged public var id: String?
    @NSManaged public var images: Array<String>?
    @NSManaged public var imagesTemp: Array<String>?
    @NSManaged public var incharge: String?
    @NSManaged public var landArea: NSDictionary?
    @NSManaged public var name: String?
    @NSManaged public var proj_code: String?
    @NSManaged public var proj_type: String?
    @NSManaged public var sanctions: NSObject?
    @NSManaged public var segment: String?
    @NSManaged public var short_name: String?
    @NSManaged public var state: String?
    @NSManaged public var stats: NSObject?
    @NSManaged public var status: Int16
    @NSManaged public var orderId: Int64
    @NSManaged public var superBuiltUpArea: NSDictionary?
    @NSManaged public var updateBy: NSObject?
    @NSManaged public var proStat: NSOrderedSet?

}

// MARK: Generated accessors for proStat
extension Project {

    @objc(insertObject:inProStatAtIndex:)
    @NSManaged public func insertIntoProStat(_ value: TempObj, at idx: Int)

    @objc(removeObjectFromProStatAtIndex:)
    @NSManaged public func removeFromProStat(at idx: Int)

    @objc(insertProStat:atIndexes:)
    @NSManaged public func insertIntoProStat(_ values: [TempObj], at indexes: NSIndexSet)

    @objc(removeProStatAtIndexes:)
    @NSManaged public func removeFromProStat(at indexes: NSIndexSet)

    @objc(replaceObjectInProStatAtIndex:withObject:)
    @NSManaged public func replaceProStat(at idx: Int, with value: TempObj)

    @objc(replaceProStatAtIndexes:withProStat:)
    @NSManaged public func replaceProStat(at indexes: NSIndexSet, with values: [TempObj])

    @objc(addProStatObject:)
    @NSManaged public func addToProStat(_ value: TempObj)

    @objc(removeProStatObject:)
    @NSManaged public func removeFromProStat(_ value: TempObj)

    @objc(addProStat:)
    @NSManaged public func addToProStat(_ values: NSOrderedSet)

    @objc(removeProStat:)
    @NSManaged public func removeFromProStat(_ values: NSOrderedSet)

}
