//
//  WineViewController.swift
//  WineTracker
//
//  Created by
//  Samuel Benoit, 101007189
//  Thomas Del Rosario, 101017215
//

import UIKit
import CoreData

class WineViewController: UIViewController {
    
    // Controller properties
    var managedContext: NSManagedObjectContext!
    //  optional wine object. Populated if the sending view controller passes a wine object
    var wine: Wine?
    
    // Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var brandTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var bottomConstriant: NSLayoutConstraint!
    
    // Class Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add observer for notification sender to call keyboardWillShow method on keyboard show event
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(with: )),
                                               name: .UIKeyboardWillShow,
                                               object: nil)
        
        // Set the name textfield to be the first responder
        // When the view loads the name textfield will be the first responder
        nameTextField.becomeFirstResponder()
        
        // if wine is passed by the sender
        // populate the view with the wine data for editing
        if let wine = wine {
            nameTextField.text = wine.name
            brandTextField.text = wine.brand
            priceTextField.text = wine.price
            segmentedControl.selectedSegmentIndex = Int(wine.type)
        }
    
    }
    
    // Objective C function for moving the bottom constraint with the device keyboard.
    // the bottom constraint is the cancel & done buttons and the wine type selection.
    @objc func keyboardWillShow(with notification: Notification) {
        let key = "UIKeyboardFrameEndUserInfoKey"
        
        guard let keyboardFrame = notification.userInfo?[key] as? NSValue else { return }
        
        let keyboardHeight = keyboardFrame.cgRectValue.height + 16
        
        bottomConstriant.constant = keyboardHeight
        
        UIView.animate(withDuration: 0.3) { 
            self.view.layoutIfNeeded()
        }
        
    }
    
    // Action called when the cancel button is pressed.
    @IBAction func cancel(_ sender: Any) {
        // Dismiss view & resign first responder
        dismissAndResign()
    }
    
    // Action called when the done button is pressed.
    @IBAction func done(_ sender: Any) {
        
        // Verify that name has a value
        guard let name = nameTextField.text, !name.isEmpty else {
            return
        }
        
        // Verify that brand has a value
        guard let brand = brandTextField.text, !brand.isEmpty else {
            return
        }
        
        // Verify that price has a value
        guard let price = priceTextField.text, !price.isEmpty else {
            return
        }
        
        // Set values if wine was passed by sender
        if let wine = self.wine {
            wine.name = name
            wine.brand = brand
            wine.price = price
            wine.updated_on = Date() // Updated updated_on date to be current date
            wine.type = Int16(segmentedControl.selectedSegmentIndex)
        } else {
            // Create new wine if wine not passed by sender
            let wine = Wine(context: managedContext)
            wine.name = name
            wine.brand = brand
            wine.price = price
            wine.type = Int16(segmentedControl.selectedSegmentIndex)
            wine.created_on = Date()
        }
        
        
        do {
            // Save context
            try managedContext.save()
            dismissAndResign()
        } catch {
            print(">>> Error: \(error)")
        }
        
    }
    
    // Dismiss view & resign first responder
    fileprivate func dismissAndResign() {
        dismiss(animated: true)
        nameTextField.resignFirstResponder()
    }

}
