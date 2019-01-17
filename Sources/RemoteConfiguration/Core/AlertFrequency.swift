import Foundation

/// Enumeration defining the frequency in which update alerts for recommended Updates should be presented for a given App version.
///
/// - always: The update dialog should always be presented after the UpdateContext has been processed and evaluated.
/// - once: The update dialog should only be presented once. If the user decides to discard the update, the dialog should not
///         be displayed again for the given update version.
public enum AlertFrequency: String, Codable {
    case always
    case once
}
