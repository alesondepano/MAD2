import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var messageLabel: UILabel!

    var studentName = "Student"
    var notificationsEnabled = false
    var selectedRole = "Student"
    var preferredEventDate = Date()
    var numberOfGuests = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Campus Events"
        updateMessage()
    }

    private func updateMessage() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let notificationStatus = notificationsEnabled ? "on" : "off"
        let dateText = formatter.string(from: preferredEventDate)

        messageLabel.text = """
        Welcome, \(studentName)! (\(selectedRole))
        Notifications: \(notificationStatus)
        Event date: \(dateText)
        Guests: \(numberOfGuests)
        """
    }
}
