import UIKit

private let algorithmCellIdentifier = "AlgorithmCell"

class AlgorithmsViewController: UITableViewController {
    var algorithms = [Algorithm]()
    var selected: Algorithm!
    var delegate: AlgorithmSelectionDelegate?
    
    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return algorithms.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: algorithmCellIdentifier,
                                                 for: indexPath)
        let algorithm = algorithms[indexPath.row]
        cell.textLabel?.text = algorithm.name
        cell.accessoryType = selected == algorithm ? .checkmark : .none
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let previouslySelectedCell = tableView.cellForRow(
            at: IndexPath(row: algorithms.firstIndex(of: selected)!, section: 0))!
        previouslySelectedCell.accessoryType = .none
        let selectedCell = tableView.cellForRow(at: indexPath)!
        selectedCell.accessoryType = .checkmark
        selected = algorithms[indexPath.row]
        delegate?.selectAlgorithm(selected)
    }
}
