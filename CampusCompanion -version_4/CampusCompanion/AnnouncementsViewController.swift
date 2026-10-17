import CoreData
import UIKit

final class AnnouncementsViewController: UITableViewController {
    private var announcements: [CampusAnnouncement] = []
    private var selectedAnnouncement: CampusAnnouncement?

    private var context: NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Campus Announcements"
        tableView.rowHeight = 78
        tableView.estimatedRowHeight = 78

        seedInitialAnnouncementsIfNeeded()
        loadAnnouncements()
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

    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        guard editingStyle == .delete,
              announcements.indices.contains(indexPath.row),
              let context else {
            return
        }

        let announcement = announcements.remove(at: indexPath.row)
        context.delete(announcement)

        do {
            try context.save()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch {
            announcements.insert(announcement, at: indexPath.row)
            tableView.reloadData()
            print("Announcement deletion failed: \(error.localizedDescription)")
        }
    }

    @IBAction private func addAnnouncementTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(
            title: "New Announcement",
            message: "Enter a title and category.",
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.placeholder = "Title"
        }
        alert.addTextField { textField in
            textField.placeholder = "Category"
        }

        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self, weak alert] _ in
            guard let self,
                  let context = self.context,
                  let title = alert?.textFields?.first?.text?
                    .trimmingCharacters(in: .whitespacesAndNewlines),
                  !title.isEmpty,
                  let category = alert?.textFields?.dropFirst().first?.text?
                    .trimmingCharacters(in: .whitespacesAndNewlines),
                  !category.isEmpty else {
                return
            }

            let newAnnouncement = CampusAnnouncement(context: context)
            newAnnouncement.title = title
            newAnnouncement.category = category
            newAnnouncement.date = DateFormatter.localizedString(
                from: Date(),
                dateStyle: .long,
                timeStyle: .none
            )
            newAnnouncement.priority = "Normal"
            newAnnouncement.postedBy = "Campus Companion"

            do {
                try context.save()
                self.loadAnnouncements()
            } catch {
                context.delete(newAnnouncement)
                print("Announcement save failed: \(error.localizedDescription)")
            }
        }

        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowAnnouncementDetailSegue",
              let announcement = selectedAnnouncement,
              let destination = detailDestination(from: segue.destination) else {
            return
        }

        destination.announcement = announcement
    }

    private func seedInitialAnnouncementsIfNeeded() {
        guard let context else {
            return
        }

        let request = CampusAnnouncement.fetchRequest()
        let existingCount = (try? context.count(for: request)) ?? 0
        guard existingCount == 0 else {
            return
        }

        let seedData = [
            ("Enrollment Period Extended", "August 3, 2026", "Registrar", "Urgent", "Registrar"),
            ("Campus Wi-Fi Maintenance", "August 8, 2026", "Technology", "Normal", "IT Services"),
            ("University Foundation Day", "August 15, 2026", "Campus Life", "Normal", "Student Affairs"),
            ("Scholarship Application Deadline", "August 20, 2026", "Scholarships", "Urgent", "Financial Aid Office"),
            ("Library Hours Updated", "August 24, 2026", "Library", "Normal", "University Library"),
            ("Emergency Preparedness Drill", "August 28, 2026", "Safety", "Urgent", "Campus Security")
        ]

        for item in seedData {
            let announcement = CampusAnnouncement(context: context)
            announcement.title = item.0
            announcement.date = item.1
            announcement.category = item.2
            announcement.priority = item.3
            announcement.postedBy = item.4
        }

        do {
            try context.save()
        } catch {
            context.rollback()
            print("Announcement seeding failed: \(error.localizedDescription)")
        }
    }

    private func loadAnnouncements() {
        guard let context else {
            announcements = []
            tableView.reloadData()
            return
        }

        let request = CampusAnnouncement.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(CampusAnnouncement.date), ascending: true),
            NSSortDescriptor(key: #keyPath(CampusAnnouncement.title), ascending: true)
        ]

        do {
            announcements = try context.fetch(request)
        } catch {
            announcements = []
            print("Announcement fetch failed: \(error.localizedDescription)")
        }
        tableView.reloadData()
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
