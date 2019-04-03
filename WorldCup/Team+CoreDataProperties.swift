    //
    //  AppDelegate.swift
    //  Team+CoreDataProperties.swift
    //
    //  Created by Griffin Healy on 3/15/19.
    //  Copyright © 2019 Griffin Healy. All rights reserved.
    //

import Foundation
import CoreData

extension Team {

  @nonobjc public class func fetchRequest() -> NSFetchRequest<Team> {
    return NSFetchRequest<Team>(entityName: "Team")
  }

  @NSManaged public var imageName: String?
  @NSManaged public var losses: Int32
  @NSManaged public var qualifyingZone: String?
  @NSManaged public var teamName: String?
  @NSManaged public var wins: Int32
}
