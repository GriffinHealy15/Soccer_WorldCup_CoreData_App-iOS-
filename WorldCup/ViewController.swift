   //
   //  ViewController.swift
   //  PestControl
   //
   //  Created by Griffin Healy on 3/15/19.
   //  Copyright © 2019 Griffin Healy. All rights reserved.
   //


import UIKit
import CoreData

class ViewController: UIViewController {

  // MARK: - Properties
  fileprivate let teamCellIdentifier = "teamCellReuseIdentifier"
  var coreDataStack: CoreDataStack!
  
  // lazy property to hold your fetched results controller
  lazy var fetchedResultsController:
    NSFetchedResultsController<Team> = {
      // 1 // get NSFetchRequest directly from the Team class because you
      // want to fetch all Team objects.
      let fetchRequest: NSFetchRequest<Team> = Team.fetchRequest()
      // create sort desciptor to sort fetched objects my teamName attribute in ascending order
      let zoneSort = NSSortDescriptor( // sort by qualifyingZone
        key: #keyPath(Team.qualifyingZone), ascending: true)
      let scoreSort = NSSortDescriptor(
        key: #keyPath(Team.wins), ascending: false)
      let nameSort = NSSortDescriptor( key: #keyPath(Team.teamName), ascending: true)
      fetchRequest.sortDescriptors = [zoneSort, scoreSort, nameSort]
      
      // 2
      let fetchedResultsController = NSFetchedResultsController(
        fetchRequest: fetchRequest, // the fetch request
        managedObjectContext: coreDataStack.managedContext, // the context that will make the fetch
        sectionNameKeyPath: #keyPath(Team.qualifyingZone), // specify the attribute 'qualifyingZone' the fetched results controller should use to group the results and generate sections
        // each unique qualifyingZone becomes a section. ResultsController groups the fetches into each section
        cacheName: "worldCup") // specify a cache name to turn on NSFetchedResultsController’s on-disk section cache.
      
      fetchedResultsController.delegate = self //declare delegate to fetchResults controller as self
      return fetchedResultsController
  }()

  // MARK: - IBOutlets
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var addButton: UIBarButtonItem!

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    do {
      try fetchedResultsController.performFetch()
    } catch let error as NSError {
      print("Fetching error: \(error), \(error.userInfo)")
    }
  }
  // tell receiver motion event has ended
  override func motionEnded(_ motion: UIEvent.EventSubtype,
                            with event: UIEvent?) {
    if motion == .motionShake { // if device is shook, then addButton can be tapped
      addButton.isEnabled = true
    }
  }
}

// MARK: - IBActions
extension ViewController {
  // if add button is tapped, it informs this addTeam funcion of the tap, then the addTeam runs
  @IBAction func addTeam(_ sender: Any) {
    let alertController = UIAlertController(
      title: "Secret Team",
      message: "Add a new team",
      preferredStyle: .alert)
    alertController.addTextField { textField in
      textField.placeholder = "Team Name"
    }
    alertController.addTextField { textField in
      textField.placeholder = "Qualifying Zone"
    }
    let saveAction = UIAlertAction(title: "Save",
                                   style: .default) {
      [unowned self] action in
      guard
        let nameTextField = alertController.textFields?.first,
        let zoneTextField = alertController.textFields?.last
        else {
          return
      }
      // create a Team managed object
      let team = Team(
        context: self.coreDataStack.managedContext)
      team.teamName = nameTextField.text // give the team object attributes from the two textfields
      team.qualifyingZone = zoneTextField.text
      team.imageName = "wenderland-flag"
      self.coreDataStack.saveContext() // save the managed context
    }
    alertController.addAction(saveAction) // add the save action to the alert controller
    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel)) // add a cancel action
                                            present(alertController, animated: true)
  }
}

// MARK: - Internal
extension ViewController {

  func configure(cell: UITableViewCell,
                 for indexPath: IndexPath) {
    guard let cell = cell as? TeamCell else {
      return
    }
   // Teams objects all stored inside the fetched results controller, we access them via object(at:)
    let team = fetchedResultsController.object(at: indexPath) // get the corresponding Team object at that index
    cell.teamLabel.text = team.teamName // once we get the Team object we set the cell attributes with the object retrieved (i.e. configure row 2, get object at index 2, once we have the object at index 2, we get all the attributes and set the cell for them
    cell.scoreLabel.text = "Wins: \(team.wins)"
    if let imageName = team.imageName {
      cell.flagImageView.image = UIImage(named: imageName)
    } else {
      cell.flagImageView.image = nil
    }
  }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {

  func numberOfSections(in tableView: UITableView) -> Int {
    return fetchedResultsController.sections?.count ?? 0
  }
  // think of sections as when I retrieved the objects, I sorted them into sections. So each section is a qualifyingZone that contains all of the objects that have the name of qualifyingZone. i.e. 'Africa' is the 'qualifyingZone' which is the first section, and I then fetch all Team objects with a qualifyingZone 'Africa' and place them into the said first section
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int)
    -> Int {
      guard let sectionInfo =
        fetchedResultsController.sections?[section] else {
          return 0 }
      return sectionInfo.numberOfObjects
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: teamCellIdentifier, for: indexPath)
    configure(cell: cell, for: indexPath) // pass the cell and indexpath of current row were preparing for the tableView
    return cell
  }
  
  func tableView(_ tableView: UITableView,
                 titleForHeaderInSection section: Int)
    -> String? { // go into each section and get the name and give it to the tableView. i.e. sections with [1] means tableview wants section 1, so we get the name of section one in the fetchResultsController and give it to the tableView to display
      let sectionInfo = fetchedResultsController.sections?[section]
      return sectionInfo?.name
  }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
// tableView tells us when it is tapped(selected) becasue were its delegate. we run this func then
   func tableView(_ tableView: UITableView,
                 didSelectRowAt indexPath: IndexPath) {
    // get Team object that corresponds to the selected index
    let team = fetchedResultsController.object(at: indexPath)
    team.wins = team.wins + 1 // change attribute of team objects wins to +1
    coreDataStack.saveContext() // save managed context, which the ResultsController will monitor the context for changes, if changes occur it will inform the deleagte of it, in this case the delegate for the ResultsControllers is self(ViewController.swift)
    
  }
}

// MARK: - NSFetchedResultsControllerDelegate
extension ViewController: NSFetchedResultsControllerDelegate {
  // results controller saw context initialzed in it was changed/updated, so it informed us(Self) the delegate of this through the delegate function here
  // This delegate method notifies you that changes are about to occur. You ready your table view using beginUpdates()
  func controllerWillChangeContent(_ controller:
    NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }
  // tells you exactly which objects changed, what type of change occurred (insertion, deletion, update or reordering) and what the affected index paths are
  func controller(_ controller:
    NSFetchedResultsController<NSFetchRequestResult>,
                  didChange anObject: Any,
                  at indexPath: IndexPath?,
                  for type: NSFetchedResultsChangeType,
                  newIndexPath: IndexPath?) {
    switch type {
    case .insert:
      tableView.insertRows(at: [newIndexPath!], with: .automatic)
    case .delete:
      tableView.deleteRows(at: [indexPath!], with: .automatic)
    case .update:
      let cell = tableView.cellForRow(at: indexPath!) as! TeamCell
      configure(cell: cell, for: indexPath!)
    case .move:
      tableView.deleteRows(at: [indexPath!], with: .automatic)
      tableView.insertRows(at: [newIndexPath!], with: .automatic)
    }
  }
  func controllerDidChangeContent(_ controller:
    NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
  }
  func controller(_ controller:
    NSFetchedResultsController<NSFetchRequestResult>,
                  didChange sectionInfo: NSFetchedResultsSectionInfo,
                  atSectionIndex sectionIndex: Int,
                  for type: NSFetchedResultsChangeType) {
    let indexSet = IndexSet(integer: sectionIndex)
    switch type {
    case .insert:
      tableView.insertSections(indexSet, with: .automatic)
    case .delete:
      tableView.deleteSections(indexSet, with: .automatic)
    default: break
    }
  }
}
