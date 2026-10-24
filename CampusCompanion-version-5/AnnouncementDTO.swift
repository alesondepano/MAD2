import Foundation

struct AnnouncementDTO: Codable {
    let title: String
    let date: String
    let category: String
    let location: String
    let priority: String

    private enum CodingKeys: String, CodingKey {
        case title
        case date
        case category
        case location
        case priority
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        date = try container.decode(String.self, forKey: .date)
        category = try container.decode(String.self, forKey: .category)
        location = try container.decodeIfPresent(String.self, forKey: .location) ?? "Main Campus"
        priority = try container.decodeIfPresent(String.self, forKey: .priority) ?? "Normal"
    }
}
