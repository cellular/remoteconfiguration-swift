import UIKit
import RemoteConfiguration
import OHHTTPStubs

class ViewController: UIViewController {

    @IBOutlet weak var clearButton: UIButton?
    @IBOutlet weak var loadFeedButton: UIButton?
    @IBOutlet weak var loadFeedWithCustomMehtodsButton: UIButton?
    @IBOutlet weak var responseTextView: UITextView?
    @IBOutlet weak var serverSwitch: UISwitch?

    let client = Client()

    override func viewDidLoad() {
        super.viewDidLoad()
        addStubs()
    }

    func buttonsEnabled(_ enabled: Bool) {
        loadFeedButton?.isEnabled = enabled
        loadFeedWithCustomMehtodsButton?.isEnabled = enabled
        clearButton?.isEnabled = enabled
    }

    func showAlert() {
        let alertController = UIAlertController(title: "Error",
                                                message: "Could not load config",
                                                preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    func updateTextView(JSONObject: AnyObject) {
        self.responseTextView?.text = String.fromJSONObject(object: JSONObject)
    }

    func addStubs() {
        stub(condition: isHost("thisisatestdomain.de")) { _ in
            return OHHTTPStubsResponse(
                fileAtPath: OHPathForFile("test.json", type(of: self))!,
                statusCode: 200,
                headers: ["Content-Type": "application/json"]
            )
        }
    }

    @IBAction func loadFeedPressed(_ sender: Any) {
        buttonsEnabled(false)
        client.loadDefaultConfiguration { (error, data) in
            DispatchQueue.main.async {
                self.responseTextView?.text = data
                self.buttonsEnabled(true)
                if error != nil { self.showAlert() }
            }
        }
    }

    @IBAction func loadFeedWithCustomMethodsPressed(_ sender: Any) {
        buttonsEnabled(false)
        client.loadCustomConfiguration { (error, data) in
            DispatchQueue.main.async {
                self.responseTextView?.text = data
                self.buttonsEnabled(true)
                if error != nil { self.showAlert() }
            }
        }
    }

    @IBAction func clearButtonPressed(_ sender: Any) {
        client.clearCache()
    }

    @IBAction func ServerSwitchChanged(_ sender: Any) {
        if let isOn = serverSwitch?.isOn {
            isOn ? addStubs() : OHHTTPStubs.removeAllStubs()
        }
    }
}
