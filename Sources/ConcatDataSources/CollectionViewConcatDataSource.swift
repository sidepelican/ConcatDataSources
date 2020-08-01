import UIKit

open class CollectionViewConcatDataSource: NSObject, UICollectionViewDataSource {
    private var children: [CollectionViewSectionDataSource] = []
    public weak var collectionView: UICollectionView?

    public init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        collectionView.dataSource = self
    }

    open func apply(
        _ snapshot: ConcatDataSourceDataSourceSnapshot,
        animatingDifferences: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        let newElements = snapshot.elements
        newElements.forEach { $0.setParentDataSource(self) }

        guard let collectionView = collectionView else {
            children = newElements
            return
        }

        CATransaction.begin()
        CATransaction.setDisableActions(!animatingDifferences)
        CATransaction.setCompletionBlock(completion)
        defer {
            CATransaction.commit()
        }

        guard #available(iOS 13, *) else {
            // diffing not supported.
            children = newElements
            collectionView.reloadData()
            return
        }

        if !snapshot.reloadItems.isEmpty {
            let reloadedSections = IndexSet(snapshot.reloadItems.compactMap { item in children.firstIndex(where: { $0 === item }) })
            collectionView.performBatchUpdates({
                collectionView.reloadSections(reloadedSections)
            })
        }

        let changeset = newElements.map(ObjectIdentifier.init).difference(from: children.map(ObjectIdentifier.init))
        if !changeset.isEmpty {
            collectionView.performBatchUpdates({
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
                collectionView.insertSections(insertedSections)
                collectionView.deleteSections(removedSections)
                movedSections.forEach { from, to in
                    collectionView.moveSection(from, toSection: to)
                }
            })
        }
    }

    public func snapshot() -> ConcatDataSourceDataSourceSnapshot {
        var snapshot = ConcatDataSourceDataSourceSnapshot()
        snapshot.append(children)
        return snapshot
    }

    public func emptySnapshot() -> ConcatDataSourceDataSourceSnapshot {
        .init()
    }

    public func sectionIndex(of sectionDataSource: CollectionViewSectionDataSource) -> Int? {
        children.firstIndex(where: { $0 === sectionDataSource })
    }

    public func dataSource(_ collectionView: UICollectionView, forSection section: Int) -> CollectionViewSectionDataSource {
        children[section]
    }

    // MARK: - UICollectionViewDataSource

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        children.count
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let childDataSource = dataSource(collectionView, forSection: section)
        return childDataSource.collectionView(collectionView, numberOfItemsInSection: 0)
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let childDataSource = dataSource(collectionView, forSection: indexPath.section)
        let childIndexPath = IndexPath(item: indexPath.item, section: 0)
        return childDataSource.collectionView(collectionView, cellForItemAt: childIndexPath)
    }

    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let childDataSource = dataSource(collectionView, forSection: indexPath.section)
        let childIndexPath = IndexPath(item: indexPath.item, section: 0)
        return childDataSource.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: childIndexPath) ?? { fatalError("TODO: error message") }()
    }

    open func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        let childDataSource = dataSource(collectionView, forSection: indexPath.section)
        let childIndexPath = IndexPath(item: indexPath.item, section: 0)
        return childDataSource.collectionView(collectionView, canMoveItemAt: childIndexPath) ?? false
    }

    open func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceChildDataSource = dataSource(collectionView, forSection: sourceIndexPath.section)
        let dstChildDataSource = dataSource(collectionView, forSection: destinationIndexPath.section)
        guard sourceChildDataSource === dstChildDataSource else { return }

        sourceChildDataSource.collectionView(
            collectionView,
            moveItemAt: IndexPath(item: sourceIndexPath.item, section: 0),
            to: IndexPath(item: destinationIndexPath.item, section: 0)
        )
    }
}
