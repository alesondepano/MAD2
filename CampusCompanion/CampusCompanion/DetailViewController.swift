import UIKit

final class DetailViewController: UIViewController {
    @IBOutlet private weak var messageLabel: UILabel!

    var studentName: String = "Student"
    var notificationsEnabled: Bool = false
    var selectedRole: String = "Student"
    var preferredEventDate: Date = Date()
    var guestCount: Int = 1
    var announcement: CampusAnnouncement?

    override func viewDidLoad() {
        super.viewDidLoad()
        messageLabel.numberOfLines = 0

        if let announcement {
            display(announcement)
        } else {
            displayStudentInformation()
        }
    }

    private func display(_ announcement: CampusAnnouncement) {
        title = announcement.category
        messageLabel.text = """
        \(announcement.title)

        Category: \(announcement.category)
        Date: \(announcement.date)
        Priority: \(announcement.priority)
        Posted By: \(announcement.postedBy)
        """
    }

    private func displayStudentInformation() {
        title = "Campus Events"

        let cleanName = studentName.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayName = cleanName.isEmpty ? "Student" : cleanName
        let notificationStatus = notificationsEnabled ? "On" : "Off"
        let safeGuestCount = max(1, guestCount)

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none

        messageLabel.text = """
        Welcome, \(displayName)!

        Role: \(selectedRole)
        Notifications: \(notificationStatus)
        Event Date: \(dateFormatter.string(from: preferredEventDate))
        Guests: \(safeGuestCount)
        """
    }
}
