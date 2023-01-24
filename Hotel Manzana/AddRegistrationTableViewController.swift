//
//  AddRegistrationTableViewController.swift
//  Hotel Manzana
//
//  Created by Nikolai Eremenko on 1/7/23.
//

import UIKit


class AddRegistrationTableViewController: UITableViewController, SelectRoomTypeTableViewControllerDelegate {
    
    @IBOutlet var saveButton: UIBarButtonItem!
    
    // Section 0
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    
    // Section 1
    @IBOutlet var checkInDateLabel: UILabel!
    @IBOutlet var checkInDatePicker: UIDatePicker!
    
    @IBOutlet var checkOutDateLabel: UILabel!
    @IBOutlet var checkOutDatePicker: UIDatePicker!
    
    // Section 2
    @IBOutlet var numberOfAdultsLabel: UILabel!
    @IBOutlet var numberOfAdultsStepper: UIStepper!
    
    @IBOutlet var numberOfChildrenLabel: UILabel!
    @IBOutlet var numberOfChildrenStepper: UIStepper!
    
    // Section 3
    @IBOutlet var wifiSwitch: UISwitch!
    
    // Section 4
    @IBOutlet var roomTypeLabel: UILabel!
    
    // Section 5 Charges
    @IBOutlet var numberOfNightsLabel: UILabel!
    @IBOutlet var checkInCheckOutDateLabel: UILabel!
    
    @IBOutlet var roomTotalPriceLabel: UILabel!
    @IBOutlet var selectedRoomDetail: UILabel!
    
    @IBOutlet var wifiPriceLabel: UILabel!
    @IBOutlet var wifiToogLabel: UILabel!
    
    @IBOutlet var totalPriceLabel: UILabel!
    
    
    // property to hold the selected room type
    var roomType: RoomType?
    
    // A computed property that returns a Registration?.
    var registration: Registration? /*{
        // If the roomType isn't set, return nil; otherwise, return a valid Registration object.
        guard let roomType = roomType else { return nil }

        let firstName = firstNameTextField.text ?? ""
        let lastName = lastNameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let checkInDate = checkInDatePicker.date
        let checkOutDate = checkOutDatePicker.date
        let numberOfAdults = Int(numberOfAdultsStepper.value)
        let numberOfChildren = Int(numberOfChildrenStepper.value)
        let hasWifi = wifiSwitch.isOn

        return Registration(firstName: firstName,
                            lastName: lastName,
                            emailAddress: email,
                            checkInDate: checkInDate,
                            checkOutDate: checkOutDate,
                            numberOfAdults: numberOfAdults,
                            numberOfChildren: numberOfChildren,
                            wifi: hasWifi,
                            roomType: roomType)
    } */
    

    // “create a custom initializer, as you'll be using @IBSegueAction to pass an Registration when editing.
    
    init?(coder: NSCoder, registration: Registration?) {
        self.registration = registration
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let registration = registration {
            firstNameTextField.text = registration.firstName
            lastNameTextField.text = registration.lastName
            emailTextField.text = registration.emailAddress
            checkInDatePicker.date = registration.checkInDate
            checkOutDatePicker.date = registration.checkOutDate
            numberOfAdultsStepper.value = Double(registration.numberOfAdults)
            numberOfChildrenStepper.value = Double(registration.numberOfChildren)
            wifiSwitch.isOn = registration.wifi
            roomType = registration.roomType
            title = "Edit Guest Registration"
        } else {
            title = "New Guest Registration"
        }
        
        /* The check-in minimum date doesn't change—it's always today—so you can set it in viewDidLoad(). You'll also initialize the check-in date in viewDidLoad(). However, the check-out minimumDate will change based on the check-in date. You'll set its minimumDate and date in the updateDateViews() method. */
        let midnightToday = Calendar.current.startOfDay(for: Date())
        checkInDatePicker.minimumDate = midnightToday
        checkInDatePicker.date = midnightToday
        
        // Because your static table view doesn't rely on a data source, it won't “load” when it's first displayed. So it's a good idea to also call the updateDateViews() method in viewDidLoad().
        updateDateViews()
        // to set up the views correctly on the first load
        updateNumberOfGuests()
        updateRoomType()
        updateSaveButtonState()
        updateWifiState()
//        updateTotalCharges()
    }
    
    func updateDateViews() {
        /* Configure date pickers to only allow valid input and to initialize the date property when the view loads. Date pickers have a minimumDate property and a maximumDate property, which work together to prevent the user from selecting a date outside the range. In the Hotel Manzana app, it would make sense to set a minimum date for both pickers: the current day for the check-in date, and one day ahead of the check-in date picker's date for the check-out date. */
        checkOutDatePicker.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: checkInDatePicker.date)
        /* Using Date's formatted method, you can create string representations of dates. The way the formatted string will read is controlled by the parameters that you pass to the formatted method. The formatted method with no arguments will produce a date in a default format. You can supply additional arguments to show only the date or time and to adjust the style (such as displaying the month using a number or a spelled-out name, or omitting seconds from the time display). */
        checkInDateLabel.text = checkInDatePicker.date.formatted(date: .abbreviated, time: .omitted)
        checkOutDateLabel.text = checkOutDatePicker.date.formatted(date: .abbreviated, time: .omitted)
        updateNumberOfNights()
        updateRoomType()
        updateWifiState()
    }
    
    /* Collect Predefined Options
     “In this case, you'll use an additional table view to present the options and a custom protocol to communicate the user's choice(s). To make it easier to change the displayed choices, programmers will often use dynamic table views for these selection table views.

    // function to update the room type labels */
    
    var roomTotalPrice = 0
    
    func updateRoomType() {
        if let roomType = roomType {
            roomTypeLabel.text = roomType.name
            let nights = Int(numberOfNightsLabel.text ?? "1") ?? 1
            roomTotalPrice = roomType.price * nights
            roomTotalPriceLabel.text = "$ \(roomTotalPrice)"
            selectedRoomDetail.text = "\(roomType.name) @ $\(String(roomType.price))/night"
        } else {
            roomTypeLabel.text = "Not Set"
            selectedRoomDetail.text = "Not Set"
            roomTotalPrice = 0
        }
        updateTotalCharges()
    }
    
    // set the roomType property of the AddRegistrationTableViewController and update the room type labels
    func selectRoomTypeTableViewController(_ controller: SelectRoomTypeTableViewController, didSelect roomType: RoomType) {
        self.roomType = roomType
        updateRoomType()
    }
    
    /*
     Date picker cells take up a significant portion of an iPhone screen. Date pickers can make it difficult to scroll a table view. Since swiping up on the date picker scrolls the picker wheel, it won't scroll the table view. While this is expected if the user intentionally swipes up on the date picker, it's a large enough control that a user may intend to scroll the table view and inadvertently scroll the picker.
     How do other apps handle this problem? In Calendar, the date pickers are hidden until the user selects the label row. Plus, the date picker appears right below the labels. When one date picker is shown, any others collapse—so you'll see only one date picker at a time.
     A similar interface implemented here, using the table view delegate methods.
    */
    
    // variables to track the state of your views.
    // store the index path of the date pickers for easy comparison in the delegate methods.
    let checkInDatePickerCellIndexPath = IndexPath(row: 1, section: 1)
    let checkOutDatePickerCellIndexPath = IndexPath(row: 3, section: 1)
    
    // Properties store whether or not the date pickers will be shown and then appropriately show or hide them when the properties are set. (They don't adjust the cell height, though. That's coming next.) Both date pickers start as not shown.
    var isCheckInDatePickerVisible: Bool = false {
        didSet { checkInDatePicker.isHidden = !isCheckInDatePickerVisible }
    }
    var isCheckOutDatePickerVisible: Bool = false {
        didSet { checkOutDatePicker.isHidden = !isCheckOutDatePickerVisible }
    }
    
    /* Method to adjust the height.
     Now that you have variables to track the visibility of your date pickers, you can implement the tableView(_:heightForRowAt:) method. This table view delegate method queries for the row's height when your table view rows are displayed. As the developer, your job is to return the height based on the index path.
     By using a switch on indexPath, you can include cases for the two date picker rows with a where clause for each to further define when the case is matched. (A where clause works like an if clause.) Specifically, you'll want to return a height of 0 for the date picker cells when they are not shown. Then you'll use the default for all other situations to let the cells determine their height automatically. */
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case checkInDatePickerCellIndexPath where isCheckInDatePickerVisible == false:
            return 0
        case checkOutDatePickerCellIndexPath where isCheckOutDatePickerVisible == false:
            return 0
        default:
            return UITableView.automaticDimension
        }
    }
    
    /* The rows with the date pickers also need to have a specific estimated row height and can't use UITableView.automaticDimension. You can return the correct estimated row height for each row using the tableView(_:estimatedHeightForRowAt:) method. The exact value returned for the date cell rows isn't important (as long as it's not 0), because Auto Layout will ensure the correct height is used. A quick check of the Size inspector for the date pickers' cells shows that 190 is a good estimate for the row height when the cells are visible. Notice that you don't want to use the where clause in this case: */
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case checkInDatePickerCellIndexPath:
            return 190
        case checkOutDatePickerCellIndexPath:
            return 190
        default:
            return UITableView.automaticDimension
        }
    }
    
    /* Method to respond to user interaction and dynamically modify the row's height at runtime.
     Because the default value of the visibility variables for the date picker is false, you'll no see the date pickers. To show them, you'll need to respond to the user tapping the date label cell. You can respond to a user's cell selection with the delegate method tableView(_:didSelectRowAt:).
     When the user taps a cell in the Hotel Manzana app, you'll first need to deselect the cell—that is, remove its gray highlight. This is a common pattern in the tableView(_:didSelectRowAt:) method when tapping the cell performs an action rather than a navigational push/modal, because it wouldn't make sense for the cell to remain highlighted after the action is performed. In the case of a navigation event, it's nice to leave the cell highlighted so when the user returns to the list they'll briefly see the highlighted cell to remind them what they had selected. UITableViewController subclasses handle this automatically for you, and you can see the subtle effect in apps like Settings. In the case of an app that allows multiple cell selection, that indication should be managed through accessory views, not the highlighted state of the cell.
     It may be helpful to create properties for checkInDateLabelCellIndexPath and checkOutDateLabelCellIndexPath to compare with the selected IndexPath. If the index path corresponds to one of the date label cells, you'll toggle the appropriate date picker and update the table view. The requirements of this feature boil down to the following:
     - When both pickers are not visible, selecting a label toggles the visibility of the corresponding picker.
     - When one picker is visible, selecting its own label toggles its visibility; selecting the other label toggles the visibility of both pickers.
     This can be represented by a relatively concise if/else if statement.
     */
    
    let checkInDateLabelCellIndexPath = IndexPath(row: 0, section: 1)
    let checkOutDateLabelCellIndexPath = IndexPath(row: 2, section: 1)
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // deselect the selected row (regardless of the row)
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath == checkInDateLabelCellIndexPath && isCheckOutDatePickerVisible == false {
            // Check-in label selected, check-out picker is not visible, toggle check-in picker
            isCheckInDatePickerVisible.toggle()
        } else if indexPath == checkOutDateLabelCellIndexPath && isCheckInDatePickerVisible == false {
            // Check-out label selected, check-in picker is not visible, toggle check-out picker
            isCheckOutDatePickerVisible.toggle()
        } else if indexPath == checkInDateLabelCellIndexPath || indexPath == checkOutDateLabelCellIndexPath {
            // Either label was selected, previous conditions failed meaning at least one picker is visible, toggle both
            isCheckInDatePickerVisible.toggle()
            isCheckOutDatePickerVisible.toggle()
        } else { return }
        
        // When the visibility of a picker is toggled, you must instruct the table view to update itself so that the height for each row is recalculated.
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    // This method will be called initially to synchronize the views and again any time the stepper value changes.
    func updateNumberOfGuests() {
        numberOfAdultsLabel.text = "\(Int(numberOfAdultsStepper.value))"
        numberOfChildrenLabel.text = "\(Int(numberOfChildrenStepper.value))"
    }
    
    // calculate number of nights
    func updateNumberOfNights() {
        let numberOfNights = Calendar.current.dateComponents([.day], from: checkInDatePicker.date, to: checkOutDatePicker.date).day
        numberOfNightsLabel.text = String(numberOfNights ?? 1)
        checkInCheckOutDateLabel.text = (checkInDateLabel.text ?? "") + " - " + (checkOutDateLabel.text ?? "")
    }
    
    var wifiTotalPrice = 0
    
    func updateWifiState() {
        let wifiPrice = 10
        if wifiSwitch.isOn == true {
            let price = wifiPrice * (Int(numberOfNightsLabel.text ?? "1") ?? 1)
            wifiTotalPrice = price
            wifiPriceLabel.text = "$ \(price)"
            wifiToogLabel.text = "Yes"
        } else {
            wifiTotalPrice = 0
            wifiPriceLabel.text = "0"
            wifiToogLabel.text = "No"
        }
        updateTotalCharges()
    }
    
    func updateTotalCharges() {
        totalPriceLabel.text = "$ \(wifiTotalPrice + roomTotalPrice)"
    }
    
    /* The Save button should only be enabled if some field contains a value. The simplest way to enable and disable the button is to have a single method that checks that field for a value and enables the button only if all of fields are not empty. You should call this method in viewDidLoad() so that the button is disabled after being modally presented or enabled if you pushed to this view controller.
     */
    func updateSaveButtonState() {
        let firstName = firstNameTextField.text ?? ""
        let lastName = lastNameTextField.text ?? ""

        saveButton.isEnabled = !firstName.isEmpty && !lastName.isEmpty // && registration != nil
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        updateNumberOfGuests()
    }
    
    /* In the storyboard, hook the unwind segue to the Done button by Control-dragging from the button to the Exit icon of the view controller and choosing unwindFromAddRegistrationWithUnwindSegue.  */
    
//    The purpose of this method is to allow you to test your input screen as you were building it.
//    @IBAction func doneBarButtonTapped(_ sender: UIBarButtonItem) {
//        let firstName = firstNameTextField.text ?? ""
//        let lastName = lastNameTextField.text ?? ""
//        let email = emailTextField.text ?? ""
//        let checkInDate = checkInDatePicker.date
//        let checkOutDate = checkOutDatePicker.date
//        let numberOfAdults = Int(numberOfAdultsStepper.value)
//        let numberOfChildren = Int(numberOfChildrenStepper.value)
//        let hasWifi = wifiSwitch.isOn
//        let roomChoice = roomType?.name ?? "Not Set"
//
//        print("DONE TAPPED")
//        print("firstName: \(firstName)")
//        print("lastName: \(lastName)")
//        print("email: \(email)")
//        print("checkIn: \(checkInDate)")
//        print("checkOut: \(checkOutDate)")
//        print("numberOfAdults: \(numberOfAdults)")
//        print("numberOfChildren: \(numberOfChildren)")
//        print("wifi: \(hasWifi)")
//        print("roomType: \(roomChoice)")
//    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        updateDateViews()
    }
    
    @IBAction func wifiSwitchChanged(_ sender: UISwitch) {
        updateWifiState()
        updateTotalCharges()
    }
    
    // set the delegate property and the roomType property of the SelectRoomTypeTableViewController if a selection has already been made
    
    @IBSegueAction func selectRoomType(_ coder: NSCoder) -> SelectRoomTypeTableViewController? {
        let selectRoomTypeController = SelectRoomTypeTableViewController(coder: coder)
        selectRoomTypeController?.delegate = self
        selectRoomTypeController?.roomType = roomType
        
        return selectRoomTypeController
    }

    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    /* How do you continually check to see if the Save button should be enabled or disabled? You can call updateSaveButtonState after each key press. Create an @IBAction in code that will call the method.
     Next, open your storyboard and the assistant editor. Select a text field in the static table view and open the Connections inspector. Drag from the Editing Changed event to the textEditingChanged(_:) method */
    @IBAction func textEditingChanged(_ sender: UITextField) {
        updateSaveButtonState()
    }
    
    /* Save Registration
     When the Save button is pressed, the saveUnwind segue is performed. Before the segue is triggered, you should use the text field values to construct a new Registration instance and set it to your registration property. In the unwind segue, the property can be used to update the registrations collection.
     Ensure that the saveUnwind segue is being performed (you don't want to do any work when Cancel is pressed), then update the registration property. */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "saveUnwind",
        let roomType = roomType else { return }
        
        let firstName = firstNameTextField.text ?? ""
        let lastName = lastNameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let checkInDate = checkInDatePicker.date
        let checkOutDate = checkOutDatePicker.date
        let numberOfAdults = Int(numberOfAdultsStepper.value)
        let numberOfChildren = Int(numberOfChildrenStepper.value)
        let hasWifi = wifiSwitch.isOn

        registration = Registration(
            firstName: firstName,
            lastName: lastName,
            emailAddress: email,
            checkInDate: checkInDate,
            checkOutDate: checkOutDate,
            numberOfAdults: numberOfAdults,
            numberOfChildren: numberOfChildren,
            wifi: hasWifi,
            roomType: roomType
        )
    }
}
