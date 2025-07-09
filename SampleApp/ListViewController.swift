import UIKit

class ListViewController: UIViewController {
    
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var allItems = [
        "📱 iPhone Development",
        "🍎 Apple Design Guidelines",
        "🔧 UIKit Framework",
        "🎨 Interface Builder",
        "📊 Core Data",
        "🌐 Networking",
        "🔔 Push Notifications",
        "📷 Camera Integration",
        "🗺️ MapKit",
        "⚡ Performance Optimization",
        "🧪 Unit Testing",
        "🚀 App Store Submission",
        "🔒 Security Best Practices",
        "📈 Analytics Integration",
        "🎯 User Experience Design"
    ]
    
    private var filteredItems: [String] = []
    private var isSearching: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSavedItems()
        setupSearchController()
        setupUI()
        setupConstraints()
    }
    
    private func loadSavedItems() {
        if let savedItems = UserDefaults.standard.array(forKey: "listItems") as? [String] {
            allItems = savedItems
        }
    }
    
    private func saveItems() {
        UserDefaults.standard.set(allItems, forKey: "listItems")
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search topics..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // Style the search bar
        searchController.searchBar.tintColor = .systemBlue
        searchController.searchBar.searchBarStyle = .minimal
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "iOS Topics"
        
        // Add navigation bar buttons
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addItemTapped)
        )
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Reset",
            style: .plain,
            target: self,
            action: #selector(resetItemsTapped)
        )
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ItemCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add empty state label
        tableView.backgroundView = createEmptyStateView()
        
        view.addSubview(tableView)
    }
    
    private func createEmptyStateView() -> UIView {
        let containerView = UIView()
        
        let emptyLabel = UILabel()
        emptyLabel.text = "No topics found"
        emptyLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.textAlignment = .center
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(imageView)
        containerView.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -30),
            imageView.widthAnchor.constraint(equalToConstant: 50),
            imageView.heightAnchor.constraint(equalToConstant: 50),
            
            emptyLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            emptyLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        return containerView
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredItems = allItems.filter { item in
            return item.lowercased().contains(searchText.lowercased())
        }
        
        // Show/hide empty state
        tableView.backgroundView?.isHidden = !filteredItems.isEmpty || !isSearching
        tableView.reloadData()
    }
    
    @objc private func addItemTapped() {
        let alert = UIAlertController(title: "Add New Topic", message: "Enter a new iOS development topic", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Topic name..."
            textField.autocapitalizationType = .words
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let textField = alert.textFields?.first,
                  let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !text.isEmpty else { return }
            
            let newItem = "📝 \(text)"
            self?.allItems.append(newItem)
            self?.saveItems()
            self?.tableView.reloadData()
            
            // Show success feedback
            let successAlert = UIAlertController(title: "Added!", message: "'\(text)' has been added to your topics.", preferredStyle: .alert)
            successAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(successAlert, animated: true)
        }
        
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func resetItemsTapped() {
        let alert = UIAlertController(title: "Reset Topics", message: "This will restore the original list and remove any custom topics you've added. Continue?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { _ in
            self.allItems = [
                "📱 iPhone Development",
                "🍎 Apple Design Guidelines",
                "🔧 UIKit Framework",
                "🎨 Interface Builder",
                "📊 Core Data",
                "🌐 Networking",
                "🔔 Push Notifications",
                "📷 Camera Integration",
                "🗺️ MapKit",
                "⚡ Performance Optimization",
                "🧪 Unit Testing",
                "🚀 App Store Submission",
                "🔒 Security Best Practices",
                "📈 Analytics Integration",
                "🎯 User Experience Design"
            ]
            self.saveItems()
            self.tableView.reloadData()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
}

extension ListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = isSearching ? filteredItems.count : allItems.count
        tableView.backgroundView?.isHidden = count > 0
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let item = isSearching ? filteredItems[indexPath.row] : allItems[indexPath.row]
        
        cell.textLabel?.text = item
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedItem = isSearching ? filteredItems[indexPath.row] : allItems[indexPath.row]
        let alert = UIAlertController(
            title: "Selected Topic",
            message: "You selected: \(selectedItem)\n\nThis could open a detail view with more information about this topic.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let itemToDelete = isSearching ? filteredItems[indexPath.row] : allItems[indexPath.row]
            
            // Remove from main array
            if let mainIndex = allItems.firstIndex(of: itemToDelete) {
                allItems.remove(at: mainIndex)
                saveItems()
            }
            
            // Remove from filtered array if searching
            if isSearching {
                filteredItems.remove(at: indexPath.row)
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Remove"
    }
}

extension ListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        filterContentForSearchText(searchText)
    }
} 