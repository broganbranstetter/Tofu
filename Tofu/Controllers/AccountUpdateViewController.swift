import UIKit

class AccountUpdateViewController: UITableViewController {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var issuerField: UITextField!
    var delegate: AccountUpdateDelegate?
    var account: Account!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        nameField.text = account.name
        issuerField.text = account.issuer
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        account.name = nameField.text
        account.issuer = issuerField.text
        delegate?.updateAccount(account)
    }
}
