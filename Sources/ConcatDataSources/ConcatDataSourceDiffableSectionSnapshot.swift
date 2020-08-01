import Foundation

public struct ConcatDataSourceDiffableSectionSnapshot<ItemIdentifierType: Hashable> {
    var reloadItems: Set<ItemIdentifierType> = []
    var elements: [ItemIdentifierType]

    public init() {
        elements = []
    }

    public init(_ snapshot: ConcatDataSourceDiffableSectionSnapshot<ItemIdentifierType>) {
        elements = snapshot.elements
    }

    public mutating func append(_ items: [ItemIdentifierType]) {
        if elements.isEmpty {
            elements = items
        } else {
            elements.append(contentsOf: items)
        }
    }

    public mutating func insert(_ items: [ItemIdentifierType], after item: ItemIdentifierType) {
        guard let afterIndex = elements.firstIndex(of: item) else {
            fatalError()
        }
        elements.insert(contentsOf: items, at: afterIndex + 1)
    }

    public mutating func insert(_ items: [ItemIdentifierType], before item: ItemIdentifierType) {
        guard let beforeIndex = elements.firstIndex(of: item) else {
            fatalError()
        }
        elements.insert(contentsOf: items, at: beforeIndex)
    }

    public mutating func delete(_ items: [ItemIdentifierType]) {
        elements.removeAll(where: { items.contains($0) })
    }

    public mutating func deleteAll() {
        elements.removeAll()
    }

    public mutating func moveItem(_ item: ItemIdentifierType, afterItem: ItemIdentifierType) {
        elements.removeAll { $0 == item }
        guard let afterIndex = elements.firstIndex(of: item) else {
            fatalError()
        }
        elements.insert(item, at: afterIndex + 1)
    }

    public mutating func moveItem(_ item: ItemIdentifierType, beforeItem: ItemIdentifierType) {
        elements.removeAll { $0 == item }
        guard let beforeIndex = elements.firstIndex(of: item) else {
            fatalError()
        }
        elements.insert(item, at: beforeIndex)
    }

    public mutating func reloadItems(_ items: [ItemIdentifierType]) {
        reloadItems.formUnion(items)
    }

    public func contains(_ item: ItemIdentifierType) -> Bool {
        elements.contains(item)
    }

    public func index(of item: ItemIdentifierType) -> Int? {
        elements.firstIndex(of: item)
    }

    public var items: [ItemIdentifierType] {
        elements
    }
}

public struct ConcatDataSourceDataSourceSnapshot {
    public typealias ItemIdentifierType = CollectionViewSectionDataSource

    var reloadItems: [ItemIdentifierType] = []
    var elements: [ItemIdentifierType]

    public init() {
        elements = []
    }

    public init(_ snapshot: ConcatDataSourceDataSourceSnapshot) {
        elements = snapshot.elements
    }


    public mutating func append(_ items: [ItemIdentifierType]) {
        if elements.isEmpty {
            elements = items
        } else {
            elements.append(contentsOf: items)
        }
    }

    public mutating func insert(_ items: [ItemIdentifierType], after item: ItemIdentifierType) {
        guard let afterIndex = elements.firstIndex(where: { $0 === item }) else {
            fatalError()
        }
        elements.insert(contentsOf: items, at: afterIndex + 1)
    }

    public mutating func insert(_ items: [ItemIdentifierType], before item: ItemIdentifierType) {
        guard let beforeIndex = elements.firstIndex(where: { $0 === item }) else {
            fatalError()
        }
        elements.insert(contentsOf: items, at: beforeIndex)
    }

    public mutating func delete(_ items: [ItemIdentifierType]) {
        elements.removeAll(where: { element in items.contains(where: { $0 === element }) })
    }

    public mutating func deleteAll() {
        elements.removeAll()
    }

    public mutating func moveItem(_ item: ItemIdentifierType, afterItem: ItemIdentifierType) {
        elements.removeAll { $0 === item }
        guard let afterIndex = elements.firstIndex(where: { $0 === item }) else {
            fatalError()
        }
        elements.insert(item, at: afterIndex + 1)
    }

    public mutating func moveItem(_ item: ItemIdentifierType, beforeItem: ItemIdentifierType) {
        elements.removeAll { $0 === item }
        guard let beforeIndex = elements.firstIndex(where: { $0 === item }) else {
            fatalError()
        }
        elements.insert(item, at: beforeIndex)
    }

    public mutating func reloadItems(_ items: [ItemIdentifierType]) {
        reloadItems.append(contentsOf: items)
    }

    public func contains(_ item: ItemIdentifierType) -> Bool {
        elements.contains { $0 === item }
    }

    public func index(of item: ItemIdentifierType) -> Int? {
        elements.firstIndex(where: { $0 === item })
    }

    public var items: [ItemIdentifierType] {
        elements
    }
}
