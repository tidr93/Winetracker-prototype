//
//  WineTableViewController.swift
//  WineTracker
//
//  Created by
//  Samuel Benoit, 101007189
//  Thomas Del Rosario, 101017215
//

import UIKit
import CoreData

class WineTableViewController: UITableViewController {
    
    // Results controller used to hold the wines stored in the sqlite database
    var resultsController: NSFetchedResultsController<Wine>!
    // handler class to handle wine CRUD operations through core data
    let coreDataStack = CoreDataStack()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request: NSFetchRequest<Wine> = Wine.fetchRequest()
        // sort retrieved wines by creation date
        let sortDescriptors = NSSortDescriptor(key: "created_on", ascending: true)
        
        request.sortDescriptors = [sortDescriptors]
        
        resultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: coreDataStack.managedContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        // make delegate WineTableViewController instance
        resultsController.delegate = self
        
        do {
            // fetch existing wines
            try resultsController.performFetch()
        } catch {
            print(">>> Error: \(error)")
        }
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of wines found
        // if none found return 0
        return resultsController.sections?[section].numberOfObjects ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // get cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "WineCell", for: indexPath)

        // Configure the cell...
        let wine = resultsController.object(at: indexPath)
        
        // set cell title to wine name
        cell.textLabel?.text = wine.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // create swipe action
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            
            let wine = self.resultsController.object(at: indexPath)
            // create delete request
            self.resultsController.managedObjectContext.delete(wine)
            
            do {
                // attempt to delete wine instance
                try self.resultsController.managedObjectContext.save()
            } catch {
                print(">>> Wine Deletion Failed: \(error)")
            }
            
            completion(true)
        }
        
        //action.image = trash
        
        action.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // On selection perform segue to wine form view
        // For more details on preparation check the prepare method of this class
        performSegue(withIdentifier: "ShowWineForm", sender: tableView.cellForRow(at: indexPath))
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // if segue is called by the add bar button item
        if let _ = sender as? UIBarButtonItem, let vc = segue.destination as? WineViewController {
            vc.managedContext = resultsController.managedObjectContext
        }
        
        // If the segue is called by a wine cell
        if let cell = sender as? UITableViewCell, let vc = segue.destination as? WineViewController {
            vc.managedContext = resultsController.managedObjectContext
            // pass wine
            if let indexPath = tableView.indexPath(for: cell) {
                let wine = resultsController.object(at: indexPath)
                vc.wine = wine
            }
            // end pass wine
        }
    }
}

// For updating the table view with new data, updated data, and deleting data.
extension WineTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        // on certain actions. perform certain actions on the table view
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = newIndexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = newIndexPath, let cell = tableView.cellForRow(at: indexPath) {
                let wine = resultsController.object(at: indexPath)
                cell.textLabel?.text = wine.name
            }
        default:
            break
        }
        
    }
}
