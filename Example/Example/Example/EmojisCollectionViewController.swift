import ConcatDataSources
import UIKit

class EmojisCollectionViewController: UIViewController {
    private let section1DataSource = SectionDataSource(cellProvider: EmojisCollectionViewController.provideCell) { _ in
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        item.contentInsets = .init(top: 5, leading: 5, bottom: 5, trailing: 5)
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(220), heightDimension: .absolute(160)),
            subitem: item,
            count: 1
        )
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets.leading = 5
        section.contentInsets.trailing = 5
        return section
    }

    private let section2DataSource = SectionDataSource(cellProvider: EmojisCollectionViewController.provideCell) { env in
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1 / 3)))
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .absolute(env.container.contentSize.width - 50),
                heightDimension: .absolute(220)
            ),
            subitem: item,
            count: 3
        )
        group.interItemSpacing = .fixed(10)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets = .init(top: 5, leading: 10, bottom: 5, trailing: 10)
        return section
    }

    private let section3DataSource = SectionDataSource(cellProvider: EmojisCollectionViewController.provideCell) { _ in
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        item.contentInsets = .init(top: 5, leading: 0, bottom: 5, trailing: 0)
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)),
            subitem: item,
            count: 1
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets.leading = 10
        section.contentInsets.trailing = 10
        return section
    }

    private var dataSource: CollectionViewConcatDataSource!
    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        let dataSource = CollectionViewConcatDataSource(collectionView: collectionView)
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout { section, env in
            (dataSource.dataSource(forSection: section) as? LayoutSectionProvider)?.layout(section: section, environment: env)
        }

        self.collectionView = collectionView
        self.dataSource = dataSource

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.register(Cell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.contentInset = .init(top: 5, left: 0, bottom: 5, right: 0)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "🔄", style: .plain, target: self, action: #selector(shuffle))

        var section1Snapshot = section1DataSource.emptySnapshot()
        section1Snapshot.append((0..<4).map { _ in emojis.randomElement()! })
        section1DataSource.apply(section1Snapshot)

        var section2Snapshot = section2DataSource.emptySnapshot()
        section2Snapshot.append((0..<8).map { _ in emojis.randomElement()! })
        section2DataSource.apply(section2Snapshot)

        var section3Snapshot = section3DataSource.emptySnapshot()
        section3Snapshot.append((0..<4).map { _ in emojis.randomElement()! })
        section3DataSource.apply(section3Snapshot)

        var snapshot = dataSource.emptySnapshot()
        snapshot.append([
            section1DataSource,
            section2DataSource,
            section3DataSource,
        ])
        dataSource.apply(snapshot)
    }

    @objc private func shuffle() {
        var section1Snapshot = section1DataSource.emptySnapshot()
        section1Snapshot.append((0..<4).map { _ in emojis.randomElement()! })
        section1DataSource.apply(section1Snapshot)

        var section2Snapshot = section2DataSource.snapshot()
        section2Snapshot.items.forEach {
            section2Snapshot.moveItem($0, beforeItem: section2Snapshot.items[0])
        }
        section2DataSource.apply(section2Snapshot)

        var section3Snapshot = section3DataSource.snapshot()
        section3Snapshot.delete(Array(section3Snapshot.items.prefix(section3Snapshot.items.count / 2)))
        section3Snapshot.append((0..<Int.random(in: 0...3)).map { _ in emojis.randomElement()! })
        section3DataSource.apply(section3Snapshot)

        var snapshot = dataSource.emptySnapshot()
        snapshot.append([
            section1DataSource,
            section2DataSource,
            section3DataSource,
        ].shuffled())
        dataSource.apply(snapshot)
    }

    private static func provideCell(_ collectionView: UICollectionView, indexPath: IndexPath, item: Character) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Cell
        cell.label.text = String(item)
        return cell
    }

    class SectionDataSource<ItemIdentifierType: Hashable>: CollectionViewDiffableSectionDataSource<ItemIdentifierType>, UICollectionViewDelegate, LayoutSectionProvider {
        var layoutSectionProvider: (NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection

        init(cellProvider: @escaping CellProvider,
             layoutSectionProvider: @escaping (NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection) {
            self.layoutSectionProvider = layoutSectionProvider
            super.init(cellProvider: cellProvider)
        }

        func layout(section: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
            layoutSectionProvider(environment)
        }
    }

    class Cell: UICollectionViewCell {
        let label = UILabel()
        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.backgroundColor = .white
            contentView.layer.cornerRadius = 6
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor = UIColor.gray.cgColor
            contentView.clipsToBounds = true
            contentView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

private protocol LayoutSectionProvider {
    func layout(section: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection
}

private let emojis = "😀😃😄😁😆😅😂🤣☺️😊😇🙂🙃😉😌😍🥰😘😗😙😚😋😛😝😜🤪🤨🧐🤓😎🤩🥳😏😒😞😔😟😕🙁☹️😣😖😫😩🥺😢😭😤😠😡🤬🤯😳🥵🥶😱😨😰😥😓🤗🤔🤭🤫🤥😶😐😑😬🙄😯😦😧😮😲🥱😴🤤😪😵🤐🥴🤢🤮🤧😷🤒🤕🤑🤠😈👿👹👺🤡💩👻💀☠️👽👾🤖🎃😺😸😹😻😼😽🙀😿😾👋🤚🖐✋🖖👌🤏✌️🤞🤟🤘🤙👈👉👆🖕👇☝️👍👎✊👊🤛🤜👏🙌👐🤲🤝🙏✍️💅🤳💪🦾🦵🦿🦶👂🦻👃🧠🦷🦴👀👁👅👄💋🩸👶🧒👦👧🧑👱👨🧔🐶🐱🐭🐹🐰🦊🐻🐼🐨🐯🦁🐮🐷🐽🐸🐵🙈🙉🙊🐒🐔🐧🐦🐤🐣🐥🦆🦅🦉🦇🐺🐗🐴🦄🐝🐛🦋🐌🐞🐜🦟🦗🕷🕸🦂🐢🐍🦎🦖🦕🐙🦑🦐🦞🦀🐡🐠🐟🐬🐳🐋🦈🐊🐅🐆🦓🦍🦧🐘🦛🦏🐪🐫🦒🦘🐃🐂🐄🐎🐖🐏🐑🦙🐐🦌🐕🐩🦮🐕‍🦺🐈🐓🦃🦚🦜🦢🦩🕊🐇🦝🦨🦡🦦🦥🐁🐀🐿🦔🐾🐉🐲🌵🎄🌲🌳🌴🌱🌿☘️🍀🎍🎋🍃🍂🍁🍄🐚🌾💐🌷🌹🥀🌺🌸🌼🌻🌞🌝🌛🌜🌚🌕🌖🌗🌘🌑🌒🌓🌔🌙🌎🌍🌏🪐💫⭐️🌟✨⚡️☄️💥🔥🌪🌈☀️🌤⛅️🌥☁️🌦🌧⛈🌩🌨❄️☃️⛄️🌬💨💧💦☔️☂️🌊🌫"
