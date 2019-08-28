import UIKit

#if os(iOS)
/// Default Implementation to handle RemoteConfiguration updates.
///
/// INFO:
/// This class is intended to be a blueprint for custom update handler classes used in the concrete Applications.
/// To make use of this class, copy it to your project and customize it accordingly.
///
public final class DefaultUpdateHandler {

    /// The Manager instance used to load and process the remote configuration.
    private let manager: Manager

    /// Initializes the update handler using the specified remote configuration manager.
    ///
    /// - Parameter configManager: the remote configuration manager used to load and process the remote configuration
    public init(manager: Manager) {
        self.manager = manager
    }

    /// Handles the specified UpdateType and UpdateContext by displaying a UIAlertController containing UIButtons for each
    /// UpdateOption associated with the UpdateContext. Pressing the Button for the update action will trigger the iOS's
    /// URL handling mechanism.
    ///
    /// - Parameters:
    ///   - updateType: the associated UpdateType
    ///   - updateContext: the associated UpdateContext
    ///   - presentingViewController: the UIViewController on which to modally present the UIAlertController
    public func updateAvailable(updateType: UpdateType, updateContext: UpdateContext,
                                presentingViewController controller: UIViewController, completion: @escaping () -> Void) {

        // handle update depending on update type
        switch updateType {
        case .ignore, .discarded:
            return completion()
        case .recommended:
            handleRecommendedUpdate(updateContext: updateContext, presentingViewController: controller, completion: completion)
        case .mandatory:
            handleMandatoryUpdate(updateContext: updateContext, presentingViewController: controller)
        }
    }

    private func handleRecommendedUpdate(updateContext: UpdateContext, presentingViewController: UIViewController,
                                         completion: @escaping () -> Void) {

        // make sure at least one update option is defined
        guard let count = updateContext.localizedAlerts?.count, count > 0 else { return }

        // create alert controller
        let localizedAlert = updateContext.localizedAlerts?.option(forLocale: Locale.current)
        let title = localizedAlert?.title ?? "Update"
        let text = localizedAlert?.text ?? ""
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)

        // create alert action for each update option
        localizedAlert?.options.forEach { option in
            // determine alert action handler (i.e. dismiss alert or open update URL)
            let handler: ((UIAlertAction) -> Void)
            if option.isUpdateAction {
                handler = { [weak self] _ in
                    self?.executeUpdateAction(url: updateContext.updateUrl)
                }
            } else {
                handler = { [weak self] _ in
                    if updateContext.updateType == .recommended && updateContext.alertFrequency == .once {
                        self?.manager.discardRecommendedUpdate(for: updateContext)
                    }
                    completion()
                }
            }
            // add alert action
            let action = UIAlertAction(title: option.title, style: .default, handler: handler)
            alertController.addAction(action)
        }

        // present alert controller
        presentingViewController.present(alertController, animated: true, completion: nil)
    }

    private func handleMandatoryUpdate(updateContext: UpdateContext, presentingViewController: UIViewController) {

        let localizedAlert = updateContext.localizedAlerts?.option(forLocale: Locale.current)
        let title = localizedAlert?.title ?? "Update"
        let text = localizedAlert?.text ?? ""
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)

        // find the update option that is the update action and create alert action
        guard let updateOption = localizedAlert?.options.updateActionOption() else { return }

        // add alert action
        let action = UIAlertAction(title: updateOption.title, style: .default, handler: { [weak self] _ in
            self?.executeUpdateAction(url: updateContext.updateUrl)
        })

        alertController.addAction(action)

        // present alert controller
        presentingViewController.present(alertController, animated: true, completion: nil)
    }

    private func executeUpdateAction(url: String) {

        // the following asserts shoud never fail since config feed ensures non-nil iTunes update URL
        guard let url = URL(string: url) else {
            return
        }
        UIApplication.shared.open(url)
    }
}
#endif
