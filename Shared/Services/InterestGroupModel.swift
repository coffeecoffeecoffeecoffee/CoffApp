import CoffeeKit
import Foundation
import SwiftData

@Model
final class InterestGroupModel: Codable {
    var id: UUID? {
        get {
            interestGroupID
        }
        set {
            if let newValue {
                interestGroupID = newValue
            }
        }
    }
    @Attribute(.unique) var interestGroupID: UUID
    var name: String
    var imageURL: String?
    var isSubscribed: Bool
    var short: String
    var isArchived: Bool?
    
    @Relationship(deleteRule: .cascade, inverse: \EventModel.group)
    var events: [EventModel] = []

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case imageURL
        case isSubscribed
        case short
        case isArchived
        // Intentionally omit `events` from coding
    }
    
    init(id: UUID? = nil, name: String, imageURL: String? = nil, isSubscribed: Bool = false, short: String, isArchived: Bool? = nil) {
        self.interestGroupID = id ?? UUID()
        self.name = name
        self.imageURL = imageURL
        self.isSubscribed = isSubscribed
        self.short = short
    }
    
    // MARK: - Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.interestGroupID = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        self.isSubscribed = try container.decodeIfPresent(Bool.self, forKey: .isSubscribed) ?? false
        self.short = try container.decode(String.self, forKey: .short)
        self.isArchived = try container.decodeIfPresent(Bool.self, forKey: .isArchived)
        // Do not decode `events`; relationships are managed by SwiftData
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(imageURL, forKey: .imageURL)
        try container.encode(isSubscribed, forKey: .isSubscribed)
        // Do not encode `events`
    }
}

extension InterestGroupModel {
    convenience init?(from: InterestGroup) {
        guard let interestGroupID = from.id else {
            return nil
        }
        self.init(
            id: interestGroupID,
            name: from.name,
            imageURL: from.imageURL,
            short: from.short,
            isArchived: from.isArchived,
        )
    }
}

extension InterestGroupModel: InterestGroupRepresentable {
}
