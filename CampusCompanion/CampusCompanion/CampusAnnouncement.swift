import Foundation

struct CampusAnnouncement {
    let title: String
    let date: String
    let category: String
    let priority: String
    let postedBy: String
}

extension CampusAnnouncement {
    static let sampleAnnouncements: [CampusAnnouncement] = [
        CampusAnnouncement(
            title: "Enrollment Period Extended",
            date: "August 3, 2026",
            category: "Registrar",
            priority: "Urgent",
            postedBy: "Registrar"
        ),
        CampusAnnouncement(
            title: "Campus Wi-Fi Maintenance",
            date: "August 8, 2026",
            category: "Technology",
            priority: "Normal",
            postedBy: "IT Services"
        ),
        CampusAnnouncement(
            title: "University Foundation Day",
            date: "August 15, 2026",
            category: "Campus Life",
            priority: "Normal",
            postedBy: "Student Affairs"
        ),
        CampusAnnouncement(
            title: "Scholarship Application Deadline",
            date: "August 20, 2026",
            category: "Scholarships",
            priority: "Urgent",
            postedBy: "Financial Aid Office"
        ),
        CampusAnnouncement(
            title: "Library Hours Updated",
            date: "August 24, 2026",
            category: "Library",
            priority: "Normal",
            postedBy: "University Library"
        ),
        CampusAnnouncement(
            title: "Emergency Preparedness Drill",
            date: "August 28, 2026",
            category: "Safety",
            priority: "Urgent",
            postedBy: "Campus Security"
        )
    ]
}
