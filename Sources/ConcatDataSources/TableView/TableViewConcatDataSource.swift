import UIKit

open class TableViewConcatDataSource: NSObject, UITableViewDataSource {
    private var children: [TableViewSectionDataSource] = []
    public weak var tableView: UITableView?

    public var defaultRowAnimation: UITableView.RowAnimation = .automatic

    public init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        tableView.dataSource = self
    }

    open func apply(
        _ snapshot: ConcatDataSourceTableSectionsSnapshot,
        animatingDifferences: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        let newElements = snapshot.elements
        newElements.forEach { $0.setParentDataSource(self) }

        guard let tableView = tableView else {
            children = newElements
            return
        }

        CATransaction.begin()
        CATransaction.setDisableActions(!animatingDifferences)
        CATransaction.setCompletionBlock(completion)
        defer {
            CATransaction.commit()
        }

        guard #available(iOS 13, *), let _ = tableView.window else {
            // diffing not supported.
            children = newElements
            tableView.reloadData()
            return
        }

        if !snapshot.reloadItems.isEmpty {
            let reloadedSections = IndexSet(snapshot.reloadItems.compactMap { item in children.firstIndex(where: { $0 === item }) })
            tableView.performBatchUpdates({
                tableView.reloadSections(reloadedSections, with: defaultRowAnimation)
            })
        }

        let changeset = newElements.map(ObjectIdentifier.init).difference(from: children.map(ObjectIdentifier.init))
        if !changeset.isEmpty {
            tableView.performBatchUpdates({
                children = newElements
                var insertedSections: IndexSet = []
                var removedSections: IndexSet = []
                var movedSections: [(from: Int, to: Int)] = []
                for change in changeset.inferringMoves() {
                    switch change {
                    case let .insert(offset, _, from):
                        if let from = from {
                            movedSections.append((from, offset))
                        } else {
                            insertedSections.insert(offset)
                        }
                    case let .remove(offset, _, to):
                        if to == nil {
                            removedSections.insert(offset)
                        }
                    }
                }
                tableView.insertSections(insertedSections, with: defaultRowAnimation)
                tableView.deleteSections(removedSections, with: defaultRowAnimation)
                movedSections.forEach { from, to in
                    tableView.moveSection(from, toSection: to)
                }
            })
        }
    }

    public func snapshot() -> ConcatDataSourceTableSectionsSnapshot {
        var snapshot = ConcatDataSourceTableSectionsSnapshot()
        snapshot.append(children)
        return snapshot
    }

    public func emptySnapshot() -> ConcatDataSourceTableSectionsSnapshot {
        .init()
    }

    public func sectionIndex(of sectionDataSource: TableViewSectionDataSource) -> Int? {
        children.firstIndex(where: { $0 === sectionDataSource })
    }

    public func dataSource(forSection section: Int) -> TableViewSectionDataSource {
        children[section]
    }

    // MARK: - UITableViewDataSource

    public func numberOfSections(in tableView: UITableView) -> Int {
        children.count
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let childDataSource = dataSource(forSection: section)
        return childDataSource.tableView(tableView, numberOfRowsInSection: 0)
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let childDataSource = dataSource(forSection: indexPath.section)
        let childIndexPath = IndexPath(row: indexPath.row, section: 0)
        return childDataSource.tableView(tableView, cellForRowAt: childIndexPath)
    }

    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let childDataSource = dataSource(forSection: section)
        return childDataSource.tableView(tableView, titleForHeaderInSection: 0)
    }

    open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let childDataSource = dataSource(forSection: section)
        return childDataSource.tableView(tableView, titleForFooterInSection: 0)
    }

    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let childDataSource = dataSource(forSection: indexPath.section)
        let childIndexPath = IndexPath(row: indexPath.row, section: 0)
        return childDataSource.tableView(tableView, canEditRowAt: childIndexPath)
    }

    open func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        let childDataSource = dataSource(forSection: indexPath.section)
        let childIndexPath = IndexPath(row: indexPath.row, section: 0)
        return childDataSource.tableView(tableView, canMoveRowAt: childIndexPath)
    }

    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let childDataSource = dataSource(forSection: indexPath.section)
        let childIndexPath = IndexPath(row: indexPath.row, section: 0)
        return childDataSource.tableView(tableView, commit: editingStyle, forRowAt: childIndexPath)
    }

    open func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceChildDataSource = dataSource(forSection: sourceIndexPath.section)
        let dstChildDataSource = dataSource(forSection: destinationIndexPath.section)
        guard sourceChildDataSource === dstChildDataSource else { return }

        sourceChildDataSource.tableView(
            tableView,
            moveRowAt: IndexPath(row: sourceIndexPath.row, section: 0),
            to: IndexPath(row: destinationIndexPath.row, section: 0)
        )
    }
}
