import Foundation
import UIKit

final class ToDoListViewController: UIViewController,
                              ToDoListViewInput,
                              UITableViewDataSource,
                              UITableViewDelegate,
                              UISearchResultsUpdating {
    
    var output: ToDoListViewOutput?
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    private let toolbarView = UIToolbar()
    private let counterLabel = UILabel()
    private var items: [ToDoItemViewModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Задачи"
        view.backgroundColor = .black
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let ap = UINavigationBarAppearance()
        ap.configureWithOpaqueBackground()
        ap.backgroundColor = .black
        ap.shadowColor = .clear
        navigationController?.navigationBar.standardAppearance = ap
        navigationController?.navigationBar.scrollEdgeAppearance = ap
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Таблица
        view.addSubview(tableView)
        tableView.backgroundColor = .black
        tableView.separatorColor = .darkGray
        tableView.dataSource = self
        tableView.delegate = self
        
        // Поиск
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        
        // Нижняя панель
        view.addSubview(toolbarView)
        toolbarView.barTintColor = .systemGray5
        toolbarView.isTranslucent = false
        toolbarView.tintColor = .systemYellow
        
        let compose = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"),
                                      style: .plain,
                                      target: self,
                                      action: #selector(addTapped))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarView.setItems([spacer, compose], animated: false)
        toolbarView.addSubview(counterLabel)
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            counterLabel.centerXAnchor.constraint(equalTo: toolbarView.centerXAnchor),
            counterLabel.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor)
        ])
        counterLabel.font = .systemFont(ofSize: 12)
        counterLabel.textColor = .secondaryLabel
        counterLabel.textAlignment = .center
        output?.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let toolbarH: CGFloat = 44
        toolbarView.frame = CGRect(x: 0,
                                   y: view.bounds.height - toolbarH - view.safeAreaInsets.bottom,
                                   width: view.bounds.width,
                                   height: toolbarH
        )
        
        let tableH = view.bounds.height - toolbarH - view.safeAreaInsets.bottom
        tableView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: tableH)
    }
    
    @objc private func addTapped() {
        output?.addTapped()
    }
    
    // MARK: - ToDoListViewInput
    
    func show(items: [ToDoItemViewModel]) {
        self.items = items
        counterLabel.text = "\(items.count) Задач"
        tableView.reloadData()
        counterLabel.sizeToFit()
    }
    
    func showEmpty() {
        self.items = []
        counterLabel.text = "0 Задач"
        tableView.reloadData()
        counterLabel.sizeToFit()
    }
    
    func showError(_ message: String) {
        let ac = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    @objc(tableView:cellForRowAtIndexPath:)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        let model = items[indexPath.row]
        
        if model.isCompleted {
            let attr = NSMutableAttributedString(string: model.title)
            attr.addAttribute(.strikethroughStyle,
                              value: NSUnderlineStyle.single.rawValue,
                              range: NSRange(location: 0, length: attr.length))
            cell.textLabel?.attributedText = attr
            cell.textLabel?.textColor = .secondaryLabel
        } else {
            cell.textLabel?.attributedText = nil
            cell.textLabel?.text = model.title
            cell.textLabel?.textColor = .label
        }
        cell.backgroundColor = .black
        cell.textLabel?.textColor = model.isCompleted ? .secondaryLabel : .label
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yy"
        
        cell.detailTextLabel?.text = df.string(from: model.createdAt)
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.detailTextLabel?.numberOfLines = 1
        
        let symbolName = model.isCompleted ? "checkmark.circle.fill" : "circle"
        let img = UIImage(systemName: symbolName)
        cell.imageView?.image = img
        cell.imageView?.tintColor = .systemYellow
        cell.imageView?.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        cell.accessoryType = .none
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        output?.toggleCompleted(at: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableVIew: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") {_, _, done in
            self.output?.delete(at: indexPath.row)
            done(true)
        }
        let editAction = UIContextualAction(style: .normal, title: "Редактировать") {_, _, done in
            self.output?.edit(at: indexPath.row)
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    // Контекстное меню по долгому тапу (редачить / удалить)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        
        let model = items[indexPath.row]
        
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: {
            return TaskPreviewViewController(model: model)
        }, actionProvider: { _ in
            let edit = UIAction(title: "Редактировать", image: UIImage(systemName: "square.and.pencil")) { _ in
                self.output?.edit(at: indexPath.row)
            }
            let delete = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.output?.delete(at: indexPath.row)
            }
            return UIMenu(children: [edit, delete])
        })
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        output?.searchChanged(text)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        output?.viewWillAppear()
    }
    
    private final class TaskPreviewViewController: UIViewController {
        private let model: ToDoItemViewModel
        private let titleLabel = UILabel()
        private let descLabel = UILabel()
        private let dateLabel = UILabel()
        private let stack = UIStackView()
        
        init(model: ToDoItemViewModel) {
            self.model = model
            super.init(nibName: nil, bundle: nil)
            modalPresentationStyle = .popover
            preferredContentSize = .zero
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .systemGray5
            view.layer.cornerRadius = 12
            view.layoutMargins = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
            
            titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
            titleLabel.textColor = .label
            titleLabel.numberOfLines = 0
            titleLabel.lineBreakMode = .byWordWrapping
            
            descLabel.font = .systemFont(ofSize: 14)
            descLabel.textColor = .secondaryLabel
            descLabel.numberOfLines = 2
            descLabel.lineBreakMode = .byTruncatingTail
            
            dateLabel.font = .systemFont(ofSize: 12)
            dateLabel.textColor = .secondaryLabel
            dateLabel.numberOfLines = 1
            
            let df = DateFormatter()
            df.dateFormat = "dd/MM/yy"
            titleLabel.text = model.title
            descLabel.text = model.desc
            descLabel.text = (model.desc?.isEmpty == false) ? model.desc : nil
            dateLabel.text = df.string(from: model.createdAt)
            descLabel.isHidden = (descLabel.text == nil)
            
            stack.axis = .vertical
            stack.alignment = .fill
            stack.distribution = .fill
            stack.spacing = 6
            stack.isLayoutMarginsRelativeArrangement = true
            stack.layoutMargins = .zero
            stack.addArrangedSubview(titleLabel)
            stack.addArrangedSubview(descLabel)
            stack.addArrangedSubview(dateLabel)
            
            view.addSubview(stack)
            stack.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
                stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
                stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
                stack.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
            ])
        }
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            let targetSize = CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height)
            let height = stack.systemLayoutSizeFitting(targetSize).height
            preferredContentSize = CGSize(width: view.bounds.width, height: ceil(height + view.layoutMargins.top + view.layoutMargins.bottom))
        }
    }
}
