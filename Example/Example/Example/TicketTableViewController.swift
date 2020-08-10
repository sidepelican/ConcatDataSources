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
        var score: Int

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
            return cell
        }

        let ticketSectionDataSource = TableViewItemSelectableSectionDataSource<Ticket> { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = item.name
            cell.detailTextLabel?.text = "\(item.point)"
            return cell
        }

        ticketSectionDataSource.didSelectItem = { selectedItem in
            var snapshot = playerSectionDataSource.snapshot()
            let newItems = snapshot.items.map { item -> Player in
                if item.name == selectedItem.name {
                    var item = item
                    item.score += selectedItem.point
                    snapshot.reloadItems([item])
                    return item
                }

                return item
            }
            snapshot.deleteAll()
            snapshot.append(newItems.sorted(by: { $0.score > $1.score }))
            playerSectionDataSource.apply(snapshot)
        }

        var ticketsSnapshot = ticketSectionDataSource.emptySnapshot()
        ticketsSnapshot.append([
            Ticket(name: "A", point: Int.random(in: 0...10)),
            Ticket(name: "B", point: Int.random(in: 0...10)),
            Ticket(name: "C", point: Int.random(in: 0...10)),
            Ticket(name: "D", point: Int.random(in: 0...10)),
        ])
        ticketSectionDataSource.apply(ticketsSnapshot)

        var playersSnapshot = playerSectionDataSource.emptySnapshot()
        playersSnapshot.append([
            Player(name: "A", score: 0),
            Player(name: "B", score: 0),
            Player(name: "C", score: 0),
            Player(name: "D", score: 0),
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
