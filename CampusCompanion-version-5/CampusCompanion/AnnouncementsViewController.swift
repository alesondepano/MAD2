import CoreData
import UIKit

private enum RemoteEndpoint {
    static let announcements = URL(string: "https://raw.githubusercontent.com/vohn-dev/campus-companion-api/refs/heads/main/announcements.json?fbclid=IwY2xjawVJMMhleHRuA2FlbQIxMABwZG9mBWJyaWQRMWpIMFBYbXZ6Q2dMRlZVaXZzcnRjBmFwcF9pZBAyMjIwMzkxNzg4MjAwODkyAAEeuoY8BXhja0TpRTt3FZ1LBs6-CWlnf1YISF60qfrxFpAuJlVpCpD4NA0yZrE_aem_AzIl3VGgYJ0nqVbtidGXyg")
}

final class AnnouncementsViewController: UITableViewController {
    @IBOutlet private weak var addAnnouncementButton: UIBarButtonItem!

    private var announcements: [CampusAnnouncement] = []
    private var selectedAnnouncement: CampusAnnouncement?
    private weak var refreshButton: UIBarButtonItem?

    private var context: NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Campus Announcements"

        let refreshButton = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshTapped(_:))
        )
        self.refreshButton = refreshButton
        if let addAnnouncementButton {
            navigationItem.rightBarButtonItems = [refreshButton, addAnnouncementButton]
        } else {
            navigationItem.rightBarButtonItem = refreshButton
        }

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
            message: "Enter a title, category, and date.",
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.placeholder = "Title"
        }
        alert.addTextField { textField in
            textField.placeholder = "Category"
        }
        alert.addTextField { textField in
            textField.placeholder = "Date"
        }

        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self, weak alert] _ in
            guard let self,
                  let context = self.context,
                  let title = alert?.textFields?[0].text?
                    .trimmingCharacters(in: .whitespacesAndNewlines),
                  !title.isEmpty,
                  let category = alert?.textFields?[1].text?
                    .trimmingCharacters(in: .whitespacesAndNewlines),
                  !category.isEmpty,
                  let date = alert?.textFields?[2].text?
                    .trimmingCharacters(in: .whitespacesAndNewlines),
                  !date.isEmpty else {
                return
            }

            let newAnnouncement = CampusAnnouncement(context: context)
            newAnnouncement.title = title
            newAnnouncement.category = category
            newAnnouncement.date = date
            newAnnouncement.location = "Main Campus"
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

    @IBAction private func refreshTapped(_ sender: UIBarButtonItem) {
        sender.isEnabled = false
        fetchAnnouncementsFromServer()
    }

    private func fetchAnnouncementsFromServer() {
        guard let endpoint = RemoteEndpoint.announcements else {
            print("Invalid announcements endpoint.")
            finishRefresh()
            return
        }

        let task = URLSession.shared.dataTask(with: endpoint) { [weak self] data, response, error in
            if let error {
                print("Network error: \(error.localizedDescription)")
                self?.finishRefresh()
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Unexpected server response.")
                self?.finishRefresh()
                return
            }

            guard let data else {
                print("The announcements response contained no data.")
                self?.finishRefresh()
                return
            }

            if let rawJSON = String(data: data, encoding: .utf8) {
                print(rawJSON)
            }

            do {
                let decodedAnnouncements = try JSONDecoder().decode(
                    [AnnouncementDTO].self,
                    from: data
                )

                DispatchQueue.main.async { [weak self] in
                    guard let self else {
                        return
                    }
                    self.replaceAnnouncements(with: decodedAnnouncements)
                    self.showNetworkConfirmationAlert(byteCount: data.count)
                    self.finishRefresh()
                }
            } catch {
                print("Decoding error: \(error)")
                self?.finishRefresh()
            }
        }
        task.resume()
    }

    private func finishRefresh() {
        if Thread.isMainThread {
            refreshButton?.isEnabled = true
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.refreshButton?.isEnabled = true
            }
        }
    }

    private func replaceAnnouncements(with dtos: [AnnouncementDTO]) {
        guard let context else {
            return
        }

        let request = CampusAnnouncement.fetchRequest()

        do {
            let existing = try context.fetch(request)
            existing.forEach(context.delete)

            for dto in dtos {
                let announcement = CampusAnnouncement(context: context)
                announcement.title = dto.title
                announcement.date = dto.date
                announcement.category = dto.category
                announcement.location = dto.location
                announcement.priority = dto.priority
                announcement.postedBy = "Campus Companion"
            }

            try context.save()
            loadAnnouncements()
        } catch {
            context.rollback()
            print("Announcement replacement failed: \(error.localizedDescription)")
            loadAnnouncements()
        }
    }

    private func showNetworkConfirmationAlert(byteCount: Int) {
        let alert = UIAlertController(
            title: "Server Reached",
            message: "Received \(byteCount) bytes from the announcements endpoint.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
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
            ("Enrollment Period Extended", "August 3, 2026", "Registrar", "Main Campus", "Urgent", "Registrar"),
            ("Campus Wi-Fi Maintenance", "August 8, 2026", "Technology", "Main Campus", "Normal", "IT Services"),
            ("University Foundation Day", "August 15, 2026", "Campus Life", "Main Campus", "Normal", "Student Affairs"),
            ("Scholarship Application Deadline", "August 20, 2026", "Scholarships", "Main Campus", "Urgent", "Financial Aid Office"),
            ("Library Hours Updated", "August 24, 2026", "Library", "Main Campus", "Normal", "University Library"),
            ("Emergency Preparedness Drill", "August 28, 2026", "Safety", "Main Campus", "Urgent", "Campus Security")
        ]

        for item in seedData {
            let announcement = CampusAnnouncement(context: context)
            announcement.title = item.0
            announcement.date = item.1
            announcement.category = item.2
            announcement.location = item.3
            announcement.priority = item.4
            announcement.postedBy = item.5
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
