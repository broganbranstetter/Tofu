import UIKit

private let accountCellIdentifier = "AccountCell"

class AccountSearchResultsViewController: UITableViewController, AccountUpdateDelegate {
    @IBOutlet var emptyView: UIView!
    var accounts: [Account]! {
        didSet {
            tableView.reloadData()
            tableView.backgroundView = accounts.count == 0 ? emptyView : nil
            tableView.separatorStyle = accounts.count == 0 ? .none : .singleLine
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let updater = AccountsTableViewUpdater(tableView: tableView)
        updater.startUpdating()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deselectSelectedTableViewRow),
            name: UIMenuController.willHideMenuNotification,
            object: nil)
    }

    @objc func deselectSelectedTableViewRow() {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // MARK: UITableViewDataSource

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            guard let cellSuperview = cell.superview else {
                assertionFailure("The cell does not seem to be in the view hierarchy. How is that even possible!?")
                return
            }

            let menuController = UIMenuController.shared

            // If you tap the same cell twice, this condition prevents the menu from being
            // hidden and then instantly shown again causing an unpleasant flash.
            //
            // Since the cell could already be the first responder (from previously showing
            // its menu and then scrolling the table view) and the menu could already be
            // visible for another cell, we make sure to check both values.
            if !(cell.isFirstResponder && menuController.isMenuVisible) {
                cell.becomeFirstResponder()

                menuController.showMenu(from: cellSuperview, rect: cell.frame)
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: accountCellIdentifier,
                                                 for: indexPath) as! AccountCell
        cell.account = accounts[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView,
                            shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canPerformAction action: Selector,
                            forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }
    
    override func tableView(_ tableView: UITableView, performAction action: Selector,
                            forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if action == #selector(copy(_:)) {
            let cell = tableView.cellForRow(at: indexPath) as! AccountCell
            cell.copy(self)
        }
    }
    
    // MARK: AccountUpdateDelegate
    
    func updateAccount(_ account: Account) {
        (presentingViewController as! AccountUpdateDelegate).updateAccount(account)
        let row = accounts.firstIndex { $0 === account }!
        let indexPath = IndexPath(row: row, section: 0)
        guard let cell = tableView.cellForRow(at: indexPath) as? AccountCell else { return }
        cell.updateWithDate(Date())
    }
}
