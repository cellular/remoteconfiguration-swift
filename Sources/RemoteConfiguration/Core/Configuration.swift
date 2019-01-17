import Foundation

/// Protocol defining the required functions for a Configuration craeted by the ConfigurationManager.
public protocol Configuration {

    /// The Configurations UpdateContext providing information on the current and available version of the associated App.
    var appUpdate: UpdateContext { get }
}
