import UIKit

public final class CollectionViewStaticSectionDataSource: CollectionViewSectionDataSource {
    public typealias CellProvider = (UICollectionView, IndexPath) -> UICollectionViewCell?
    public typealias SupplementaryViewProvider = (UICollectionView, String, IndexPath) -> UICollectionReusableView?
    
    private let numberOfItems: Int
    private let cellProvider: CellProvider
    public var supplementaryViewProvider: SupplementaryViewProvider?

    public init(
        numberOfItems: Int = 1,
        supplementaryViewProvider: SupplementaryViewProvider? = nil,
        cellProvider: @escaping CellProvider
    ) {
        self.numberOfItems = numberOfItems
        self.cellProvider = cellProvider
        self.supplementaryViewProvider = supplementaryViewProvider
    }

    public init(supplementaryViewProvider: @escaping SupplementaryViewProvider) {
        numberOfItems = 0
        cellProvider = { _, _ in nil }
        self.supplementaryViewProvider = supplementaryViewProvider
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        numberOfItems
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = cellProvider(collectionView, indexPath) else {
            fatalError("UICollectionView dataSource returned a nil cell for item at index path: \(indexPath), collectionView: \(collectionView)")
        }
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView? {
        supplementaryViewProvider?(collectionView, kind, indexPath)
    }
}
