import UIKit

final class ConfirmationViewController: UIViewController {
    @IBOutlet weak var messageLabel: UILabel!

    var name: String = "Club Member"
    var wantsReminders: Bool = false
    var role: String = "Member"

    override func viewDidLoad() {
        super.viewDidLoad()

        let reminderStatus = wantsReminders ? "ON" : "OFF"
        let roleDescription = role == "Officer" ? "an Officer" : "a Member"

        messageLabel.numberOfLines = 0
        messageLabel.text = """
        Thanks, \(name)!
        You've signed up as \(roleDescription).
        Meeting reminders: \(reminderStatus)
        """
    }
}
