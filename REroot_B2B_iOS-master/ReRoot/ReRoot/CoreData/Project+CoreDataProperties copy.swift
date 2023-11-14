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
    @NSManaged public var sanctions: NSArray?
    @NSManaged public var segment: String?
    @NSManaged public var short_name: String?
    @NSManaged public var state: String?
    @NSManaged public var stats: NSArray?
    @NSManaged public var status: Int16
    @NSManaged public var superBuiltUpArea: NSDictionary?
    @NSManaged public var updateBy: NSArray?
    @NSManaged public var builtUpArea: NSDictionary?

}
