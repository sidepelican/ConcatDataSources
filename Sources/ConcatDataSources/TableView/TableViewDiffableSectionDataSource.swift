import UIKit

open class TableViewDiffableSectionDataSource<ItemIdentifierType: Hashable>: NSObject, TableViewSectionDataSource {
    public typealias ItemIdentifierType = ItemIdentifierType
    public typealias CellProvider = (UITableView, IndexPath, ItemIdentifierType) -> UITableViewCell?

    private var elements: [ItemIdentifierType] = []
    private let cellProvider: CellProvider
    public weak var parentDataSource: TableViewConcatDataSource?

    public var defaultRowAnimation: UITableView.RowAnimation = .automatic
    public var titleForHeader: String?
    public var titleForFooter: String?

    public init(cellProvider: @escaping CellProvider) {
        self.cellProvider = cellProvider
    }

    open func apply(_ snapshot: ConcatDataSourceDiffableSectionSnapshot<ItemIdentifierType>,
               animatingDifferences: Bool = true,
               completion: (() -> Void)? = nil) {
        let newElements = snapshot.elements
        guard let parentDataSource = parentDataSource,
              let tableView = parentDataSource.tableView,
              let sectionIndex = parentDataSource.sectionIndex(of: self) else {
            elements = newElements
            return
        }

        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        CATransaction.setDisableActions(!animatingDifferences)
        defer {
            CATransaction.commit()
        }

        guard #available(iOS 13, *) else {
            // diffing not supported.
            elements = newElements
            tableView.reloadData()
            return
        }

        let changeset = newElements.difference(from: elements)
        if !changeset.isEmpty {
            tableView.performBatchUpdates({
                elements = newElements
                var insertedItems: [Int] = []
                var removedItems: [Int] = []
                var movedItems: [(from: Int, to: Int)] = []
                for change in changeset.inferringMoves() {
                    switch change {
                    case let .insert(offset, _, from):
                        if let from = from {
                            movedItems.append((from, offset))
                        } else {
                            insertedItems.append(offset)
                        }
                    case let .remove(offset, _, to):
                        if to == nil {
                            removedItems.append(offset)
                        }
                    }
                }
                tableView.insertRows(at: insertedItems.map { IndexPath(item: $0, section: sectionIndex) }, with: defaultRowAnimation)
                tableView.deleteRows(at: removedItems.map { IndexPath(item: $0, section: sectionIndex) }, with: defaultRowAnimation)
                movedItems.forEach { from, to in
                    tableView.moveRow(at: IndexPath(item: from, section: sectionIndex), to: IndexPath(item: to, section: sectionIndex))
                }
            })
        } else {
            elements = newElements
        }

        if !snapshot.reloadItems.isEmpty {
            let reloadedItems = snapshot.reloadItems.compactMap { elements.firstIndex(of: $0) }
            tableView.performBatchUpdates({
                tableView.reloadRows(at: reloadedItems.map { IndexPath(item: $0, section: sectionIndex) }, with: defaultRowAnimation)
            })
        }
    }

    public func snapshot() -> ConcatDataSourceDiffableSectionSnapshot<ItemIdentifierType> {
        var snapshot = ConcatDataSourceDiffableSectionSnapshot<ItemIdentifierType>()
        snapshot.append(elements)
        return snapshot
    }

    public func emptySnapshot() -> ConcatDataSourceDiffableSectionSnapshot<ItemIdentifierType> {
        .init()
    }

    public func itemIdentifier(for indexPath: IndexPath) -> ItemIdentifierType {
        elements[indexPath.item]
    }

    // MARK: - TableViewSectionDataSource

    public func setParentDataSource(_ parent: TableViewConcatDataSource) {
        parentDataSource = parent
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = elements[indexPath.row]
        guard let cell = cellProvider(tableView, indexPath, item) else {
            fatalError("UITableView dataSource returned a nil cell for item at index path: \(indexPath), tableView: \(tableView), itemIdentifier: \(item)")
        }
        return cell
    }

    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleForHeader
    }

    open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return titleForFooter
    }
}
