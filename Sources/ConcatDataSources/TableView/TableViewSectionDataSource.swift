import UIKit

@MainActor public protocol TableViewSectionDataSource: AnyObject {
    func setParentDataSource(_ parent: TableViewConcatDataSource)

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String?
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
}

public extension TableViewSectionDataSource {
    func setParentDataSource(_ parent: TableViewConcatDataSource) {}
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { nil }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? { nil }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { false }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool { false }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {}
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {}
}
