import UIKit

public final class CollectionViewItemSelectableSectionDataSource<ItemIdentifierType: Hashable>: CollectionViewDiffableSectionDataSource<ItemIdentifierType>, UICollectionViewDelegate {
    public var didSelectItem: ((ItemIdentifierType) -> ())?

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        didSelectItem?(itemIdentifier(for: indexPath))
    }
}
