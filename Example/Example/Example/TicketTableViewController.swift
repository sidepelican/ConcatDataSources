import ConcatDataSources
import UIKit

class TicketTableViewController: UIViewController, UITableViewDelegate {
    private var dataSource: TableViewConcatDataSource!

    struct Ticket: Hashable, Comparable {
        var name: String
        var point: Int

        static func < (lhs: Ticket, rhs: Ticket) -> Bool {
            if lhs.name == rhs.name {
                return lhs.point < rhs.point
            }

            return lhs.name < rhs.name
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(name)
        }

        static func == (lhs: Ticket, rhs: Ticket) -> Bool {
            lhs.name == rhs.name
        }
    }

    struct Player: Hashable {
        var name: String
        var score: Int = 0

        func hash(into hasher: inout Hasher) {
            hasher.combine(name)
        }

        static func == (lhs: Player, rhs: Player) -> Bool {
            lhs.name == rhs.name
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.register(Cell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self

        dataSource = TableViewConcatDataSource(tableView: tableView)

        let playerSectionDataSource = TableViewDiffableSectionDataSource<Player> { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = item.name
            cell.detailTextLabel?.text = "\(item.score)"
            cell.selectionStyle = .none
            return cell
        }
        playerSectionDataSource.titleForHeader = "Score"

        let ticketSectionDataSource = TableViewItemSelectableSectionDataSource<Ticket> { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = item.name
            cell.detailTextLabel?.text = "Add \(item.point)"
            cell.selectionStyle = .default
            return cell
        }
        ticketSectionDataSource.titleForHeader = "Action"

        ticketSectionDataSource.didSelectItem = { selectedItem in
            var newItems = playerSectionDataSource.snapshot().items
            if let index = newItems.firstIndex(where: { $0.name == selectedItem.name }) {
                newItems[index].score += selectedItem.point
            }

            var snapshot = playerSectionDataSource.emptySnapshot()
            snapshot.append(newItems.sorted(by: { $0.score > $1.score }))
            snapshot.reloadItems([.init(name: selectedItem.name)])
            playerSectionDataSource.apply(snapshot)
        }

        var ticketsSnapshot = ticketSectionDataSource.emptySnapshot()
        ticketsSnapshot.append([
            Ticket(name: "A", point: Int.random(in: 2...7)),
            Ticket(name: "B", point: Int.random(in: 2...7)),
            Ticket(name: "C", point: Int.random(in: 2...7)),
            Ticket(name: "D", point: Int.random(in: 2...7)),
        ])
        ticketSectionDataSource.apply(ticketsSnapshot)

        var playersSnapshot = playerSectionDataSource.emptySnapshot()
        playersSnapshot.append([
            Player(name: "A"),
            Player(name: "B"),
            Player(name: "C"),
            Player(name: "D"),
        ])
        playerSectionDataSource.apply(playersSnapshot)

        var snapshot = dataSource.emptySnapshot()
        snapshot.append([
            ticketSectionDataSource,
            playerSectionDataSource,
        ])
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    class Cell: UITableViewCell {
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionDataSource = dataSource.dataSource(forSection: indexPath.section)
        (sectionDataSource as? UITableViewDelegate)?.tableView?(tableView, didSelectRowAt: indexPath)
    }
}
