import UIKit

final class AnnouncementCell: UITableViewCell {
    @IBOutlet private weak var categoryIconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!

    func configure(with announcement: CampusAnnouncement) {
        titleLabel.text = announcement.title
        dateLabel.text = "\(announcement.category) • \(announcement.date)"

        let isUrgent = announcement.priority.caseInsensitiveCompare("Urgent") == .orderedSame
        categoryIconImageView.image = UIImage(
            systemName: isUrgent ? "exclamationmark.triangle.fill" : "megaphone.fill"
        )
        categoryIconImageView.tintColor = isUrgent ? .systemRed : .systemBlue
        titleLabel.textColor = isUrgent ? .systemRed : .label
        dateLabel.textColor = .secondaryLabel
        accessoryType = .disclosureIndicator
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        categoryIconImageView.image = nil
        categoryIconImageView.tintColor = .systemBlue
        titleLabel.text = nil
        titleLabel.textColor = .label
        dateLabel.text = nil
        dateLabel.textColor = .secondaryLabel
        accessoryType = .none
    }
}
