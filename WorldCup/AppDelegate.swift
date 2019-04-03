    //
    //  AppDelegate.swift
    //  WorldCup
    //
    //  Created by Griffin Healy on 3/15/19.
    //  Copyright © 2019 Griffin Healy. All rights reserved.
    //

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  lazy var  coreDataStack = CoreDataStack(modelName: "WorldCup")
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    importJSONSeedDataIfNeeded()

    guard let navController = window?.rootViewController as? UINavigationController,
      let viewController = navController.topViewController as? ViewController else {
        return true
    }

    viewController.coreDataStack = coreDataStack

    return true
  }

  func applicationWillTerminate(_ application: UIApplication) {
    coreDataStack.saveContext()
  }
}

// MARK: - Helper methods
extension AppDelegate {

  func importJSONSeedDataIfNeeded() {

    let fetchRequest: NSFetchRequest<Team> = Team.fetchRequest()
    let count = try? coreDataStack.managedContext.count(for: fetchRequest)

    guard let teamCount = count,
      teamCount == 0 else {
        return
    }
    // if count is 0, no objects could be fetched, so we will create managed objects, put in store
    importJSONSeedData()
  }

  func importJSONSeedData() {

    let jsonURL = Bundle.main.url(forResource: "seed", withExtension: "json")!
    let jsonData = try! Data(contentsOf: jsonURL)

    do {
      let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: [.allowFragments]) as! [[String: Any]]

      for jsonDictionary in jsonArray {
        let teamName = jsonDictionary["teamName"] as! String
        let zone = jsonDictionary["qualifyingZone"] as! String
        let imageName = jsonDictionary["imageName"] as! String
        let wins = jsonDictionary["wins"] as! NSNumber

        let team = Team(context: coreDataStack.managedContext)
        team.teamName = teamName
        team.imageName = imageName
        team.qualifyingZone = zone
        team.wins = wins.int32Value
      }

      coreDataStack.saveContext()
      print("Imported \(jsonArray.count) teams")

    } catch let error as NSError {
      print("Error importing teams: \(error)")
    }
  }
}
