import UIKit

final class WelcomeViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var roleSegmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        // The title is supplied in code to meet the assignment requirement.
        titleLabel.text = "Campus Club Connect"
        roleSegmentedControl.selectedSegmentIndex = 0
    }

    @IBAction func joinButtonTapped(_ sender: UIButton) {
        nameTextField.resignFirstResponder()
        performSegue(withIdentifier: "ShowConfirmationSegue", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            segue.identifier == "ShowConfirmationSegue",
            let destination = segue.destination as? ConfirmationViewController
        else {
            return
        }

        let enteredName = nameTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        // A default keeps the confirmation valid for empty or whitespace-only input.
        destination.name = enteredName.isEmpty ? "Club Member" : enteredName
        destination.wantsReminders = reminderSwitch.isOn

        switch roleSegmentedControl.selectedSegmentIndex {
        case 1:
            destination.role = "Officer"
        default:
            // Member is also the safe fallback for an unexpected index.
            destination.role = "Member"
        }
    }
}
