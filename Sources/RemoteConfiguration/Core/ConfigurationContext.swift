import Foundation

struct ConfigurationContext: Codable {

    var lastDiscardedVersion: String?

    private enum CodingKeys: String, CodingKey {
        case lastDiscardedVersion
    }
}
