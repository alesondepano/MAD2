import UIKit

final class ViewController: UIViewController {
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var notifySwitch: UISwitch!
    @IBOutlet private weak var roleSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var preferredEventDatePicker: UIDatePicker!
    @IBOutlet private weak var guestStepper: UIStepper!
    @IBOutlet private weak var guestCountLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Campus Companion"

        nameTextField.delegate = self
        let dismissKeyboardTap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        dismissKeyboardTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissKeyboardTap)

        roleSegmentedControl.selectedSegmentIndex = 0
        preferredEventDatePicker.minimumDate = Calendar.current.startOfDay(for: Date())
        guestStepper.minimumValue = 1
        guestStepper.maximumValue = 10
        guestStepper.stepValue = 1

        if guestStepper.value < guestStepper.minimumValue {
            guestStepper.value = guestStepper.minimumValue
        }
        updateGuestCountLabel()
    }

    @IBAction private func getStartedButtonTapped(_ sender: UIButton) {
        subtitleLabel.text = "Let's get started!"
    }

    @IBAction private func guestStepperChanged(_ sender: UIStepper) {
        updateGuestCountLabel()
    }

    @IBAction private func exploreButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        performSegue(withIdentifier: "ShowDetailSegue", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowDetailSegue",
              let destination = detailDestination(from: segue.destination) else {
            return
        }

        let enteredName = nameTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        destination.studentName = enteredName.isEmpty ? "Student" : enteredName
        destination.notificationsEnabled = notifySwitch.isOn
        destination.selectedRole = roleSegmentedControl.selectedSegmentIndex == 1
            ? "Faculty"
            : "Student"
        destination.preferredEventDate = preferredEventDatePicker.date
        destination.guestCount = max(1, Int(guestStepper.value))
        destination.announcement = nil
    }

    private func updateGuestCountLabel() {
        guestCountLabel.text = "Number of Guests: \(max(1, Int(guestStepper.value)))"
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func detailDestination(from destination: UIViewController) -> DetailViewController? {
        if let detailViewController = destination as? DetailViewController {
            return detailViewController
        }

        if let navigationController = destination as? UINavigationController {
            return navigationController.topViewController as? DetailViewController
        }

        return nil
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
