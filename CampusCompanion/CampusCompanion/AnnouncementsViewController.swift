import UIKit

final class AnnouncementsViewController: UITableViewController {
    private let announcements = CampusAnnouncement.sampleAnnouncements
    private var selectedAnnouncement: CampusAnnouncement?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Campus Announcements"
        tableView.rowHeight = 78
        tableView.estimatedRowHeight = 78
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        announcements.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard announcements.indices.contains(indexPath.row),
              let cell = tableView.dequeueReusableCell(
                withIdentifier: "AnnouncementCell",
                for: indexPath
              ) as? AnnouncementCell else {
            return UITableViewCell(style: .default, reuseIdentifier: nil)
        }

        cell.configure(with: announcements[indexPath.row])
        return cell
    }

    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard announcements.indices.contains(indexPath.row) else {
            return
        }

        selectedAnnouncement = announcements[indexPath.row]
        performSegue(
            withIdentifier: "ShowAnnouncementDetailSegue",
            sender: self
        )
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowAnnouncementDetailSegue",
              let announcement = selectedAnnouncement,
              let destination = detailDestination(from: segue.destination) else {
            return
        }

        destination.announcement = announcement
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
