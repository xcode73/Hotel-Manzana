//
//  SelectRoomTypeTableViewController.swift
//  Hotel Manzana
//
//  Created by Nikolai Eremenko on 1/8/23.
//

import UIKit

class SelectRoomTypeTableViewController: UITableViewController {
    
    //hold the currently selected room type
    var roomType: RoomType?
    
    // Since another class will implement the protocol, need to define a property to hold the reference to the implementing instance
    weak var delegate: SelectRoomTypeTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return RoomType.all.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomTypeCell", for: indexPath)
        let roomType = RoomType.all[indexPath.row]
        
        // logic to configure the cell's accessory type. If the room type for the row is equal to the selected room type, the accessory type is .checkmark. If not, the accessory type is .none.
        if roomType == self.roomType {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        var content = cell.defaultContentConfiguration()
        content.text = roomType.name
        content.secondaryText = "$ \(roomType.price)"
        cell.contentConfiguration = content
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let roomType = RoomType.all[indexPath.row]
        
        // when the user selects a room type, call delegate method
        self.roomType = roomType
        delegate?.selectRoomTypeTableViewController(self, didSelect: roomType)
        tableView.reloadData()
    }
    
}

// The function gives the main table view controller access to any of the parameters of the function—and it allows you write to custom code
protocol SelectRoomTypeTableViewControllerDelegate: AnyObject {
    func selectRoomTypeTableViewController(_ controller: SelectRoomTypeTableViewController, didSelect roomType:
       RoomType)
}
/* how protocol works to communicate the user's choice of room type:
The user taps a cell to make a selection, triggering didSelectRow.
The tableView(_:didSelectRowAt:) method calls the delegate method selectRoomTypeTableViewController(_:didSelect:), using two things: the receiver stored in the delegate property (your AddRegistrationTableViewController instance) and the index path to the selected room type (which will be used as the parameter of the selectRoomTypeTableViewController(_:didSelect:) method).
 In the AddRegistrationTableViewController, the selectRoomTypeTableViewController(_:didSelect:) method provides access to the room type parameter and updates the AddRegistrationTableViewController property that's holding the selected room type. This is the implementation of the method called in step 2. */
