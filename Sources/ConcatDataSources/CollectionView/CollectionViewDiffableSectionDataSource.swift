import UIKit

open class CollectionViewDiffableSectionDataSource<ItemIdentifierType: Hashable>: NSObject, CollectionViewSectionDataSource {
    public typealias ItemIdentifierType = ItemIdentifierType
    public typealias CellProvider = (UICollectionView, IndexPath, ItemIdentifierType) -> UICollectionViewCell?
    public typealias SupplementaryViewProvider = (UICollectionView, String, IndexPath) -> UICollectionReusableView?

    private var elements: [ItemIdentifierType] = []
    private let cellProvider: CellProvider
    public weak var parentDataSource: CollectionViewConcatDataSource?
    public var supplementaryViewProvider: SupplementaryViewProvider?

    public init(cellProvider: @escaping CellProvider) {
        self.cellProvider = cellProvider
    }

    open func apply(_ snapshot: ConcatDataSourceDiffableSectionSnapshot<ItemIdentifierType>,
               animatingDifferences: Bool = true,
               completion: (() -> Void)? = nil) {
        let newElements = snapshot.elements
        guard let parentDataSource = parentDataSource,
              let collectionView = parentDataSource.collectionView,
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
            collectionView.reloadData()
            return
        }

        let changeset = newElements.difference(from: elements)
        if !changeset.isEmpty {
            collectionView.performBatchUpdates({
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
                collectionView.insertItems(at: insertedItems.map { IndexPath(item: $0, section: sectionIndex) })
                collectionView.deleteItems(at: removedItems.map { IndexPath(item: $0, section: sectionIndex) })
                movedItems.forEach { from, to in
                    collectionView.moveItem(at: IndexPath(item: from, section: sectionIndex), to: IndexPath(item: to, section: sectionIndex))
                }
            })
        } else {
            elements = newElements
        }

        if !snapshot.reloadItems.isEmpty {
            let reloadedItems = snapshot.reloadItems.compactMap { elements.firstIndex(of: $0) }
            collectionView.performBatchUpdates({
                collectionView.reloadItems(at: reloadedItems.map { IndexPath(item: $0, section: sectionIndex) })
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

    // MARK: - CollectionViewSectionDataSource

    public func setParentDataSource(_ parent: CollectionViewConcatDataSource) {
        parentDataSource = parent
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        elements.count
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = elements[indexPath.item]
        guard let cell = cellProvider(collectionView, indexPath, item) else {
            fatalError("UICollectionView dataSource returned a nil cell for item at index path: \(indexPath), collectionView: \(collectionView), itemIdentifier: \(item)")
        }
        return cell
    }

    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView? {
        supplementaryViewProvider?(collectionView, kind, indexPath)
    }
}
