import UIKit

public final class TableViewItemSelectableSectionDataSource<ItemIdentifierType: Hashable>: TableViewDiffableSectionDataSource<ItemIdentifierType>, UITableViewDelegate {
    public var didSelectItem: ((ItemIdentifierType) -> ())?

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        didSelectItem?(itemIdentifier(for: indexPath))
    }
}
