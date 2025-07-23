import UIKit

class ListViewController: UIViewController {
    
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    private let filterSegmentedControl = UISegmentedControl(items: ["All", "Favorites", "Completed", "In Progress"])
    
    private var allTopics: [Topic] = []
    private var filteredTopics: [Topic] = []
    private var currentFilter: TopicFilter = .all
    
    private var isSearching: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    enum TopicFilter: Int, CaseIterable {
        case all = 0
        case favorites = 1
        case completed = 2
        case inProgress = 3
        
        var title: String {
            switch self {
            case .all: return "All"
            case .favorites: return "Favorites"
            case .completed: return "Completed"
            case .inProgress: return "In Progress"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTopics()
        setupSearchController()
        setupUI()
        setupConstraints()
        applyFilter()
        
        // Track screen view
        AnalyticsManager.shared.trackScreen("ListViewController", parameters: [
            "total_topics": allTopics.count,
            "favorite_topics": allTopics.filter { $0.isFavorite }.count,
            "completed_topics": allTopics.filter { $0.isCompleted }.count
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Tag screen for UXCam when user actually sees it
        UXCamScreenNames.tagScreen(UXCamScreenNames.topicsList)
        
        // Apply privacy protection for user-generated content
        setupPrivacyProtection()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove screen-level privacy protection when leaving
        removeUXCamPrivacyProtection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTopics() // Refresh data
        applyFilter()
        
        // Update daily challenge progress
        DailyChallengeManager.shared.updateProgress(for: "explorer", increment: 1)
    }
    
    private func loadTopics() {
        // Load saved topics or create default ones
        if let data = UserDefaults.standard.data(forKey: "topics"),
           let savedTopics = try? JSONDecoder().decode([Topic].self, from: data) {
            allTopics = savedTopics
        } else {
            createDefaultTopics()
            saveTopics()
        }
    }
    
    private func createDefaultTopics() {
        allTopics = [
            Topic(id: "ios_dev", title: "📱 iPhone Development", category: .development, estimatedTime: "10 min", difficulty: .beginner),
            Topic(id: "design_guidelines", title: "🍎 Apple Design Guidelines", category: .design, estimatedTime: "15 min", difficulty: .intermediate),
            Topic(id: "uikit", title: "🔧 UIKit Framework", category: .development, estimatedTime: "20 min", difficulty: .intermediate),
            Topic(id: "interface_builder", title: "🎨 Interface Builder", category: .design, estimatedTime: "12 min", difficulty: .beginner),
            Topic(id: "core_data", title: "📊 Core Data", category: .architecture, estimatedTime: "25 min", difficulty: .advanced),
            Topic(id: "networking", title: "🌐 Networking", category: .development, estimatedTime: "18 min", difficulty: .intermediate),
            Topic(id: "push_notifications", title: "🔔 Push Notifications", category: .development, estimatedTime: "15 min", difficulty: .intermediate),
            Topic(id: "camera", title: "📷 Camera Integration", category: .development, estimatedTime: "20 min", difficulty: .intermediate),
            Topic(id: "mapkit", title: "🗺️ MapKit", category: .development, estimatedTime: "22 min", difficulty: .intermediate),
            Topic(id: "performance", title: "⚡ Performance Optimization", category: .architecture, estimatedTime: "30 min", difficulty: .advanced),
            Topic(id: "testing", title: "🧪 Unit Testing", category: .testing, estimatedTime: "25 min", difficulty: .intermediate),
            Topic(id: "app_store", title: "🚀 App Store Submission", category: .deployment, estimatedTime: "35 min", difficulty: .advanced),
            Topic(id: "security", title: "🔒 Security Best Practices", category: .architecture, estimatedTime: "40 min", difficulty: .expert),
            Topic(id: "analytics", title: "📈 Analytics Integration", category: .development, estimatedTime: "15 min", difficulty: .intermediate),
            Topic(id: "ux_design", title: "🎯 User Experience Design", category: .design, estimatedTime: "30 min", difficulty: .intermediate)
        ]
    }
    
    private func saveTopics() {
        if let data = try? JSONEncoder().encode(allTopics) {
            UserDefaults.standard.set(data, forKey: "topics")
        }
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
            action: #selector(addTopicTapped)
        )
        
        let moreButton = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"),
            style: .plain,
            target: self,
            action: #selector(moreOptionsTapped)
        )
        navigationItem.leftBarButtonItem = moreButton
        
        // Setup filter segmented control
        filterSegmentedControl.selectedSegmentIndex = 0
        filterSegmentedControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        filterSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TopicTableViewCell.self, forCellReuseIdentifier: "TopicCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add empty state label
        tableView.backgroundView = createEmptyStateView()
        
        view.addSubview(filterSegmentedControl)
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
            // Filter segmented control
            filterSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            filterSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filterSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filterSegmentedControl.heightAnchor.constraint(equalToConstant: 32),
            
            // Table view
            tableView.topAnchor.constraint(equalTo: filterSegmentedControl.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        let baseTopics = getTopicsForCurrentFilter()
        
        if searchText.isEmpty {
            filteredTopics = baseTopics
        } else {
            filteredTopics = baseTopics.filter { topic in
                return topic.title.lowercased().contains(searchText.lowercased()) ||
                       topic.category.rawValue.lowercased().contains(searchText.lowercased())
            }
        }
        
        // Show/hide empty state
        tableView.backgroundView?.isHidden = !filteredTopics.isEmpty
        tableView.reloadData()
        
        // Track search
        if !searchText.isEmpty {
            AnalyticsManager.shared.trackEvent(.searchPerformed, parameters: [
                "search_term": searchText,
                "results_count": filteredTopics.count,
                "filter": currentFilter.title
            ])
            
            // Track UXCam search performed
            trackSearchPerformed(query: searchText, resultsCount: filteredTopics.count)
        }
    }
    
    private func applyFilter() {
        if isSearching {
            filterContentForSearchText(searchController.searchBar.text ?? "")
        } else {
            filteredTopics = getTopicsForCurrentFilter()
            tableView.backgroundView?.isHidden = !filteredTopics.isEmpty
            tableView.reloadData()
        }
    }
    
    private func getTopicsForCurrentFilter() -> [Topic] {
        switch currentFilter {
        case .all:
            return allTopics
        case .favorites:
            return allTopics.filter { $0.isFavorite }
        case .completed:
            return allTopics.filter { $0.isCompleted }
        case .inProgress:
            return allTopics.filter { $0.progressPercentage > 0 && !$0.isCompleted }
        }
    }
    
    @objc private func addTopicTapped() {
        AnalyticsManager.shared.trackEvent(.buttonTap, parameters: ["button": "add_topic"])
        
        let alert = UIAlertController(title: "Add New Topic", message: "Create a custom learning topic", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Topic title..."
            textField.autocapitalizationType = .words
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Estimated time (e.g., 15 min)"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let titleField = alert.textFields?[0],
                  let timeField = alert.textFields?[1],
                  let title = titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !title.isEmpty else { return }
            
            let estimatedTime = timeField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "10 min"
            
            let newTopic = Topic(
                id: "custom_\(UUID().uuidString.prefix(8))",
                title: "📝 \(title)",
                category: .development,
                estimatedTime: estimatedTime,
                difficulty: .beginner
            )
            
            self?.allTopics.append(newTopic)
            self?.saveTopics()
            self?.applyFilter()
            
            // Track the addition
            AnalyticsManager.shared.trackEvent(.featureUsed, parameters: [
                "action": "topic_added",
                "topic_title": title,
                "estimated_time": estimatedTime
            ])
            
            // Show success feedback
            let successAlert = UIAlertController(title: "Added!", message: "'\(title)' has been added to your topics.", preferredStyle: .alert)
            successAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(successAlert, animated: true)
        }
        
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func moreOptionsTapped() {
        AnalyticsManager.shared.trackEvent(.buttonTap, parameters: ["button": "more_options"])
        
        let alert = UIAlertController(title: "More Options", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "📊 Analytics Dashboard", style: .default) { _ in
            self.showAnalyticsDashboard()
        })
        
        alert.addAction(UIAlertAction(title: "🔄 Reset All Progress", style: .destructive) { _ in
            self.showResetConfirmation()
        })
        
        alert.addAction(UIAlertAction(title: "📤 Export Topics", style: .default) { _ in
            self.exportTopics()
        })
        
        alert.addAction(UIAlertAction(title: "🎯 Mark All as Completed", style: .default) { _ in
            self.markAllAsCompleted()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.leftBarButtonItem
        }
        
        present(alert, animated: true)
    }
    
    @objc private func filterChanged() {
        let selectedIndex = filterSegmentedControl.selectedSegmentIndex
        currentFilter = TopicFilter(rawValue: selectedIndex) ?? .all
        
        AnalyticsManager.shared.trackEvent(.featureUsed, parameters: [
            "action": "filter_changed",
            "filter": currentFilter.title
        ])
        
        applyFilter()
    }

    // MARK: - Helper Methods
    private func showAnalyticsDashboard() {
        if !PremiumManager.shared.isFeatureUnlocked("advanced_analytics") {
            let feature = PremiumManager.shared.getPremiumFeatures().first { $0.id == "advanced_analytics" }!
            PremiumManager.shared.showUpgradePrompt(for: feature, from: self)
            return
        }
        
        let totalTopics = allTopics.count
        let completedTopics = allTopics.filter { $0.isCompleted }.count
        let favoriteTopics = allTopics.filter { $0.isFavorite }.count
        let ratedTopics = allTopics.filter { $0.rating != nil }.count
        let averageRating = allTopics.compactMap { $0.rating }.reduce(0, +) / max(ratedTopics, 1)
        
        let message = """
        📊 Your Learning Analytics
        
        📚 Topics: \(completedTopics)/\(totalTopics) completed
        ❤️ Favorites: \(favoriteTopics)
        ⭐ Average Rating: \(averageRating)/5 stars
        📈 Progress: \(Int(Double(completedTopics)/Double(totalTopics) * 100))%
        """
        
        let alert = UIAlertController(title: "Analytics Dashboard", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Export Data", style: .default) { _ in
            self.exportTopics()
        })
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
        
        AnalyticsManager.shared.trackEvent(.featureUsed, parameters: [
            "action": "analytics_dashboard_viewed",
            "completed_topics": completedTopics,
            "total_topics": totalTopics,
            "favorite_topics": favoriteTopics
        ])
    }
    
    private func showResetConfirmation() {
        let alert = UIAlertController(
            title: "Reset All Progress",
            message: "This will reset all topic progress, ratings, and favorites. This cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { _ in
            for i in 0..<self.allTopics.count {
                self.allTopics[i].isCompleted = false
                self.allTopics[i].isFavorite = false
                self.allTopics[i].rating = nil
                self.allTopics[i].progressPercentage = 0.0
            }
            self.saveTopics()
            self.applyFilter()
            
            AnalyticsManager.shared.trackEvent(.featureUsed, parameters: ["action": "progress_reset"])
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func exportTopics() {
        if !PremiumManager.shared.isFeatureUnlocked("export_data") {
            let feature = PremiumManager.shared.getPremiumFeatures().first { $0.id == "export_data" }!
            PremiumManager.shared.showUpgradePrompt(for: feature, from: self)
            return
        }
        
        var exportText = "Topic,Category,Difficulty,Time,Progress,Favorite,Rating,Completed\n"
        
        for topic in allTopics {
            exportText += "\"\(topic.title)\",\(topic.category.rawValue),\(topic.difficulty.rawValue),\(topic.estimatedTime),\(topic.progressPercentage)%,\(topic.isFavorite),\(topic.rating ?? 0),\(topic.isCompleted)\n"
        }
        
        let activityVC = UIActivityViewController(activityItems: [exportText], applicationActivities: nil)
        
        activityVC.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            AnalyticsManager.shared.trackEvent(.contentShared, parameters: [
                "content_type": "topics_export",
                "completed": completed,
                "activity_type": activityType?.rawValue ?? "unknown"
            ])
        }
        
        if let popover = activityVC.popoverPresentationController {
            popover.barButtonItem = navigationItem.leftBarButtonItem
        }
        
        present(activityVC, animated: true)
    }
    
    private func markAllAsCompleted() {
        let incompleteTopics = allTopics.filter { !$0.isCompleted }.count
        
        let alert = UIAlertController(
            title: "Mark All as Completed",
            message: "This will mark \(incompleteTopics) topics as completed. Continue?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Complete All", style: .default) { _ in
            for i in 0..<self.allTopics.count {
                if !self.allTopics[i].isCompleted {
                    self.allTopics[i].isCompleted = true
                    self.allTopics[i].progressPercentage = 100.0
                }
            }
            self.saveTopics()
            self.applyFilter()
            
            // Update achievements
            AchievementManager.shared.updateProgress(for: "all_topics", progress: self.allTopics.filter { $0.isCompleted }.count)
            
            AnalyticsManager.shared.trackEvent(.featureUsed, parameters: [
                "action": "mark_all_completed",
                "topics_completed": incompleteTopics
            ])
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showTopicDetail(_ topic: Topic) {
        let message = """
        Category: \(topic.category.rawValue)
        Difficulty: \(topic.difficulty.rawValue)
        Estimated Time: \(topic.estimatedTime)
        Progress: \(Int(topic.progressPercentage))%
        Rating: \(topic.rating != nil ? String(topic.rating!) + "/5 stars" : "Not rated")
        Status: \(topic.isCompleted ? "✅ Completed" : "📚 In Progress")
        """
        
        let alert = UIAlertController(title: topic.title, message: message, preferredStyle: .alert)
        
        if !topic.isCompleted {
            alert.addAction(UIAlertAction(title: "Mark as Completed", style: .default) { _ in
                self.updateTopic(topic.id) { updatedTopic in
                    updatedTopic.isCompleted = true
                    updatedTopic.progressPercentage = 100.0
                }
            })
        }
        
        alert.addAction(UIAlertAction(title: "Share Topic", style: .default) { _ in
            self.shareTopic(topic)
        })
        
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
        
        // Track topic view
        AnalyticsManager.shared.trackEvent(.featureUsed, parameters: [
            "action": "topic_detail_viewed",
            "topic_id": topic.id,
            "topic_category": topic.category.rawValue
        ])
        
        // Track UXCam topic completion
        if topic.isCompleted {
            UXCamEventManager.shared.trackTopicCompleted(
                topicId: topic.id,
                category: topic.category.rawValue,
                completionTime: 0, // Calculate actual time
                userRating: topic.rating
            )
        }
        
        // Update daily challenge progress
        DailyChallengeManager.shared.updateProgress(for: "knowledge", increment: 1)
        AchievementManager.shared.updateProgress(for: "first_topic", progress: 1)
    }
    
    private func updateTopic(_ topicId: String, update: (inout Topic) -> Void) {
        guard let index = allTopics.firstIndex(where: { $0.id == topicId }) else { return }
        update(&allTopics[index])
        saveTopics()
        applyFilter()
    }
    
    private func shareTopic(_ topic: Topic) {
        let shareText = "Check out this iOS development topic: \(topic.title)\n\nCategory: \(topic.category.rawValue)\nDifficulty: \(topic.difficulty.rawValue)\nTime: \(topic.estimatedTime)"
        
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        activityVC.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            AnalyticsManager.shared.trackEvent(.contentShared, parameters: [
                "content_type": "topic",
                "topic_id": topic.id,
                "completed": completed,
                "activity_type": activityType?.rawValue ?? "unknown"
            ])
        }
        
        present(activityVC, animated: true)
    }
    
    // MARK: - Privacy Protection
    
    private func setupPrivacyProtection() {
        // Configure list-specific privacy protection for user-generated content
        UXCamPrivacyManager.shared.configureListScreenPrivacy(
            searchBar: searchController.searchBar,
            customTopicCells: getCustomTopicCells()
        )
        
        // Apply general screen-level protection if needed
        applyUXCamPrivacyProtection()
        
        #if DEBUG
        print("🔒 Topics list privacy protection configured")
        #endif
    }
    
    private func getCustomTopicCells() -> [UITableViewCell] {
        // Return cells for custom (user-generated) topics that need privacy protection
        var customCells: [UITableViewCell] = []
        
        for indexPath in tableView.indexPathsForVisibleRows ?? [] {
            let topic = filteredTopics[indexPath.row]
            if topic.id.hasPrefix("custom_") {
                if let cell = tableView.cellForRow(at: indexPath) {
                    customCells.append(cell)
                }
            }
        }
        
        return customCells
    }
    
    // MARK: - UXCam Event Tracking
    
    private func trackSearchPerformed(query: String, resultsCount: Int) {
        // Track search with privacy-conscious approach
        let sanitizedQuery = query.count > 50 ? String(query.prefix(50)) : query
        
        UXCamEventManager.shared.trackFeatureUsage(
            feature: "topic_search",
            success: resultsCount > 0,
            context: [
                "search_query_length": query.count,
                "results_found": resultsCount,
                "filter_applied": currentFilter.title,
                "search_success": resultsCount > 0 ? "true" : "false"
            ]
        )
        
        // Track feature discovery if this is first search
        let searchCount = UserDefaults.standard.integer(forKey: "search_count")
        if searchCount == 0 {
            UXCamEventManager.shared.trackFeatureDiscovered(
                featureName: "topic_search",
                discoveryMethod: "exploration",
                timeToDiscovery: 0 // Calculate actual time from first app launch
            )
        }
        
        UserDefaults.standard.set(searchCount + 1, forKey: "search_count")
    }
    
    private func trackTopicInteraction(topic: Topic, interactionType: String) {
        UXCamEventManager.shared.trackFeatureUsage(
            feature: "topic_interaction",
            success: true,
            context: [
                "topic_id": topic.id,
                "topic_category": topic.category.rawValue,
                "interaction_type": interactionType,
                "topic_difficulty": topic.difficulty.rawValue,
                "topic_completed": topic.isCompleted ? "true" : "false"
            ]
        )
    }
}

// MARK: - Table View Data Source & Delegate
extension ListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = filteredTopics.count
        tableView.backgroundView?.isHidden = count > 0
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCell", for: indexPath) as! TopicTableViewCell
        let topic = filteredTopics[indexPath.row]
        
        cell.configure(with: topic)
        cell.delegate = self
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedTopic = filteredTopics[indexPath.row]
        showTopicDetail(selectedTopic)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let topicToDelete = filteredTopics[indexPath.row]
            
            // Remove from main array
            if let mainIndex = allTopics.firstIndex(where: { $0.id == topicToDelete.id }) {
                allTopics.remove(at: mainIndex)
                saveTopics()
            }
            
            // Remove from filtered array
            filteredTopics.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            AnalyticsManager.shared.trackEvent(.featureUsed, parameters: [
                "action": "topic_deleted",
                "topic_id": topicToDelete.id
            ])
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Only allow deleting custom topics
        let topic = filteredTopics[indexPath.row]
        return topic.id.hasPrefix("custom_")
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Remove"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

// MARK: - Topic Cell Delegate
extension ListViewController: TopicCellDelegate {
    
    func topicCellDidToggleFavorite(_ topic: Topic) {
        updateTopic(topic.id) { updatedTopic in
            updatedTopic.isFavorite = topic.isFavorite
        }
        
        AnalyticsManager.shared.trackEvent(.itemFavorited, parameters: [
            "topic_id": topic.id,
            "is_favorite": topic.isFavorite
        ])
        
        // Update daily challenge
        if topic.isFavorite {
            DailyChallengeManager.shared.updateProgress(for: "favorite", increment: 1)
        }
    }
    
    func topicCellDidRate(_ topic: Topic, rating: Int?) {
        updateTopic(topic.id) { updatedTopic in
            updatedTopic.rating = rating
        }
        
        AnalyticsManager.shared.trackEvent(.ratingGiven, parameters: [
            "topic_id": topic.id,
            "rating": rating ?? 0,
            "has_rating": rating != nil
        ])
        
        // Update daily challenge
        if rating != nil {
            DailyChallengeManager.shared.updateProgress(for: "rating", increment: 1)
        }
    }
}

extension ListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        filterContentForSearchText(searchText)
    }
} 