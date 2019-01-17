import Foundation

/// Enumeration defining the different update types.
///
/// - ignore: Defines an optional, i.e. ignored update. No update alert necessary (Default).
/// - recommended: Defines a recommended update. Update Alert should be displayed, may be skipped though.
/// - mandatory: Defines a mandatory update. Update Alert must be displayed and must not be skipped.
/// - discarded: Defines a recommended update which has already been discarded by the user. Value is computed usgin lastDiscardedVersion.
public enum UpdateType: String, Codable {
    case ignore
    case recommended
    case mandatory
    case discarded
}
