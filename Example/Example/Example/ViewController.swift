import ConcatDataSources
import UIKit

class ViewController: UIViewController, UITableViewDelegate {
    private let tableView = UITableView()

    private lazy var examplesSection = makeExamplesSectionDataSource()
    private var dataSource: TableViewConcatDataSource!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        dataSource = TableViewConcatDataSource(tableView: tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.dataSource = dataSource
        tableView.delegate = self

        var examplesSnapshot = ConcatDataSourceDiffableSectionSnapshot<Example>()
        examplesSnapshot.append(Example.allCases)
        examplesSection.apply(examplesSnapshot, animatingDifferences: false)

        var sectionsSnapshot = ConcatDataSourceTableSectionsSnapshot()
        sectionsSnapshot.append([examplesSection])
        dataSource.apply(sectionsSnapshot, animatingDifferences: false)
    }

    enum Example: String, Hashable, CaseIterable {
        case emojisCollection
    }

    private func makeExamplesSectionDataSource() -> TableViewDiffableSectionDataSource<Example> {
        let dataSource = TableViewItemSelectableSectionDataSource<Example> { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
            cell.textLabel?.text = item.rawValue
            return cell
        }
        dataSource.didSelectItem = { [weak self] item in
            switch item {
            case .emojisCollection:
                let vc = EmojisCollectionViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }

        return dataSource
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionDataSource = dataSource.dataSource(forSection: indexPath.section)
        (sectionDataSource as? UITableViewDelegate)?.tableView?(tableView, didSelectRowAt: indexPath)
    }
}

