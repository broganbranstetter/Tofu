import UIKit

private let formatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .none
    return formatter
}()

class AccountCreationViewController: UITableViewController, AlgorithmSelectionDelegate {
    @IBOutlet weak var doneItem: UIBarButtonItem!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var issuerField: UITextField!
    @IBOutlet weak var secretField: UITextField!
    @IBOutlet weak var algorithmLabel: UILabel!
    @IBOutlet weak var eightDigitsSwitch: UISwitch!
    @IBOutlet weak var timeBasedSwitch: UISwitch!
    @IBOutlet weak var periodCounterCell: UITableViewCell!
    @IBOutlet weak var periodCounterLabel: UILabel!
    @IBOutlet weak var periodCounterField: UITextField!
    var delegate: AccountCreationDelegate?
    private var algorithm = Algorithm.sha1
    private var periodString: String?
    private var counterString: String?
    private var period: Int? {
        guard periodCounterField.text?.count ?? 0 > 0 else { return 30 }
        return formatter.number(from: periodCounterField.text!)?.intValue
    }
    private var counter: Int? {
        guard periodCounterField.text?.count ?? 0 > 0 else { return 0 }
        return formatter.number(from: periodCounterField.text!)?.intValue
    }

    @IBAction func didPressCancel(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func didPressDone(_ sender: UIBarButtonItem) {
        let password = Password()
        password.timeBased = timeBasedSwitch.isOn
        password.algorithm = algorithm
        password.digits = eightDigitsSwitch.isOn ? 8 : 6
        password.secret = Data(base32Encoded: secretField.text!)!

        if timeBasedSwitch.isOn {
            password.period = period!
        } else {
            password.counter = counter!
        }

        let account = Account()
        account.name = nameField.text
        account.issuer = issuerField.text
        account.password = password

        presentingViewController?.dismiss(animated: true) {
            self.delegate?.createAccount(account)
        }
    }

    @IBAction func editingChangedForTextField(_ textField: UITextField) {
        validate()
    }

    @IBAction func valueChangedForTimeBasedSwitch() {
        if self.timeBasedSwitch.isOn {
            counterString = periodCounterField.text
        } else {
            periodString = periodCounterField.text
        }
        UIView.transition(with: periodCounterCell,
                          duration: 0.2,
                          options: .transitionCrossDissolve,
                          animations: {
                            if self.timeBasedSwitch.isOn {
                                self.periodCounterLabel.text = "Period"
                                self.periodCounterField.placeholder = String(30)
                                self.periodCounterField.text = self.periodString
                            } else {
                                self.periodCounterLabel.text = "Counter"
                                self.periodCounterField.placeholder = String(0)
                                self.periodCounterField.text = self.counterString
                            }
        }, completion: { _ in
            self.validate()
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.becomeFirstResponder()
        algorithmLabel.text = algorithm.name
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let algorithmsController = segue.destination as? AlgorithmsViewController {
            algorithmsController.algorithms = [.sha1, .sha256, .sha512]
            algorithmsController.selected = algorithm
            algorithmsController.delegate = self
        }
    }

    private func validate() {
        doneItem.isEnabled = secretField.text?.count ?? 0 > 0 &&
            Data(base32Encoded: secretField.text!) != nil &&
            (timeBasedSwitch.isOn ? period != nil : counter != nil)
    }

    // MARK: AlgorithmSelectionDelegate

    func selectAlgorithm(_ algorithm: Algorithm) {
        self.algorithm = algorithm
        algorithmLabel.text = algorithm.name
    }
}
