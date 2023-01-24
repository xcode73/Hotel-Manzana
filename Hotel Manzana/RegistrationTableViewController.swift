//
//  RegistrationTableViewController.swift
//  Hotel Manzana
//
//  Created by Nikolai Eremenko on 1/9/23.
//  To display each registration, select the prototype cell and set its Style to Subtitle and its identifier to RegistrationCell.

import UIKit

class RegistrationTableViewController: UITableViewController {
    
    // a property that holds an array of Registration objects and set its default value to be empty.
    
    var registrations: [Registration] = []

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return registrations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegistrationCell", for: indexPath)
        let registration = registrations[indexPath.row]
     
        var content = cell.defaultContentConfiguration()
        content.text = registration.firstName + " " + registration.lastName
        
        /* The assignment of the content.secondaryText is using the formatted method to format multiple dates. In this case, you're using a range to capture and format both checkInDate and checkOutDate. It's a bit cleaner than writing the same formatting code for both dates separately and concatenating the strings. */
        content.secondaryText = (registration.checkInDate..<registration.checkOutDate).formatted(date: .numeric, time: .omitted) + ": " + registration.roomType.name
        cell.contentConfiguration = content
        cell.showsReorderControl = true //
     
         return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            registrations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    // it should remove the data within registrations at fromIndexPath.row and add it back at to.row
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedRegistration = registrations.remove(at: sourceIndexPath.row)
        registrations.insert(movedRegistration, at: destinationIndexPath.row)
    }
    
    
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        let tableViewEditingMode = tableView.isEditing
        
        tableView.setEditing(!tableViewEditingMode, animated: true)
    }
    
    @IBSegueAction func addEditRegistration(_ coder: NSCoder, sender: Any?) -> AddRegistrationTableViewController? {
        if let cell = sender as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell) {
            // Editing Registration
            let registrationToEdit = registrations[indexPath.row]
            return AddRegistrationTableViewController(coder: coder, registration: registrationToEdit)
        } else {
            // Adding Registration
            return AddRegistrationTableViewController(coder: coder, registration: nil)
        }
    }
    
    
    /* An unwind segue method so that the AddRegistrationTableViewController can return to the RegistrationTableViewController. get the source view controller (AddRegistrationTableViewController) to access the registration property. If this property isn't nil, add it to the registrations array and reload the table view.
     Verify that the saveUnwind segue was triggered. If so, check whether the table view still has a selected row. If it does, then you're unwinding after editing a particular Registration. If it does not, then a new Registration is being created. To add a new entry into registrations, you'll need to calculate the index path for the new row and add the item to the end of the collection. Update the table view accordingly
     */
    
    @IBAction func unwindToRegistrationTableView(_ unwindSegue: UIStoryboardSegue) {
        guard unwindSegue.identifier == "saveUnwind",
                let sourceViewController = unwindSegue.source as? AddRegistrationTableViewController,
                let registration = sourceViewController.registration else { return }
        
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                registrations[selectedIndexPath.row] = registration
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                let newIndexPath = IndexPath(row: registrations.count, section: 0)
                registrations.append(registration)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
    }

//    @IBAction func unwindFromAddRegistration(unwindSegue: UIStoryboardSegue) {
//
//        guard let addRegistrationTableViewController = unwindSegue.source as? AddRegistrationTableViewController,
//              let registration = addRegistrationTableViewController.registration else { return }
//
//        registrations.append(registration)
//        tableView.reloadData()
//    }

}
