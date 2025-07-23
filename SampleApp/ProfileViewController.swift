import UIKit

class ProfileViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let editButton = UIButton(type: .system)
    private let changePhotoButton = UIButton(type: .system)
    private let subscriptionBadge = UIView()
    private let subscriptionLabel = UILabel()
    private let statsContainerView = UIView()
    private let achievementsTitleLabel = UILabel()
    private let achievementsCollectionView: UICollectionView
    private let streakView = UIView()
    private let streakLabel = UILabel()
    private let upgradePromptView = UIView()
    private let shareProfileButton = UIButton(type: .system)
    private let exportDataButton = UIButton(type: .system)
    private let infoStackView = UIStackView()
    
    private var achievements: [Achievement] = []
    private var userProgress = UserProgress()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 100)
        layout.minimumInteritemSpacing = 8
        achievementsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 100)
        layout.minimumInteritemSpacing = 8
        achievementsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadProfileData()
        loadUserProgress()
        setupUI()
        setupConstraints()
        
        // Track screen view
        AnalyticsManager.shared.trackScreen("ProfileViewController", parameters: [
            "has_profile_photo": profileImageView.image != nil,
            "subscription_tier": PremiumManager.shared.getCurrentTier().rawValue,
            "achievements_unlocked": achievements.filter { $0.isUnlocked }.count
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProfileData()
        refreshAchievements()
        updateSubscriptionBadge()
        updateUserStats()
        
        // Update daily challenge
        DailyChallengeManager.shared.updateProgress(for: "explorer", increment: 1)
    }
    
    private func loadProfileData() {
        // Load saved profile image if exists
        if let imageData = UserDefaults.standard.data(forKey: "profileImage"),
           let image = UIImage(data: imageData) {
            profileImageView.image = image
        }
        
        // Update labels with saved data
        nameLabel.text = UserDefaults.standard.string(forKey: "userName") ?? "John Doe"
        emailLabel.text = UserDefaults.standard.string(forKey: "userEmail") ?? "john.doe@example.com"
    }
    
    private func loadUserProgress() {
        if let data = UserDefaults.standard.data(forKey: "userProgress"),
           let progress = try? JSONDecoder().decode(UserProgress.self, from: data) {
            userProgress = progress
        }
    }
    
    private func refreshAchievements() {
        achievements = AchievementManager.shared.getAchievements()
        achievementsCollectionView.reloadData()
    }
    
    private func updateSubscriptionBadge() {
        let currentTier = PremiumManager.shared.getCurrentTier()
        subscriptionLabel.text = currentTier.rawValue
        
        switch currentTier {
        case .free:
            subscriptionBadge.backgroundColor = .systemGray
        case .basic:
            subscriptionBadge.backgroundColor = .systemBlue
        case .premium:
            subscriptionBadge.backgroundColor = .systemYellow
        case .pro:
            subscriptionBadge.backgroundColor = .systemPurple
        }
        
        // Show upgrade prompt for free users
        upgradePromptView.isHidden = currentTier != .free
    }
    
    private func updateUserStats() {
        // Update streak display
        streakLabel.text = "🔥 \(userProgress.currentStreak) day streak"
        
        // Update info rows with dynamic data
        updateInfoRowsWithCurrentData()
    }
    
    private func updateInfoRowsWithCurrentData() {
        // Clear existing info rows and rebuild with fresh data
        let arrangedSubviews = infoStackView.arrangedSubviews
        for i in 2..<arrangedSubviews.count { // Keep name and email labels
            infoStackView.removeArrangedSubview(arrangedSubviews[i])
            arrangedSubviews[i].removeFromSuperview()
        }
        
        // Add updated info rows
        let tapCount = UserDefaults.standard.integer(forKey: "tapCount")
        let unlockedAchievements = achievements.filter { $0.isUnlocked }.count
        let totalAchievements = achievements.count
        
        addInfoRow(title: "Location", value: UserDefaults.standard.string(forKey: "userLocation") ?? "San Francisco, CA")
        addInfoRow(title: "Member Since", value: "January 2024")
        addInfoRow(title: "Total Taps", value: "\(tapCount)")
        addInfoRow(title: "Achievements", value: "\(unlockedAchievements)/\(totalAchievements)")
        addInfoRow(title: "Current Streak", value: "\(userProgress.currentStreak) days")
        addInfoRow(title: "Longest Streak", value: "\(userProgress.longestStreak) days")
        addInfoRow(title: "Subscription", value: PremiumManager.shared.getCurrentTier().rawValue)
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Profile"
        
        // Add share button to navigation
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(shareProfileTapped)
        )
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure profile image
        profileImageView.image = profileImageView.image ?? UIImage(systemName: "person.circle.fill")
        profileImageView.tintColor = .systemBlue
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 60
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.borderColor = UIColor.systemBlue.cgColor
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add tap gesture to profile image
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGesture)
        
        // Configure subscription badge
        subscriptionBadge.layer.cornerRadius = 12
        subscriptionBadge.translatesAutoresizingMaskIntoConstraints = false
        
        subscriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        subscriptionLabel.textColor = .white
        subscriptionLabel.textAlignment = .center
        subscriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        subscriptionBadge.addSubview(subscriptionLabel)
        
        // Configure name label
        nameLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        nameLabel.textAlignment = .center
        nameLabel.textColor = .label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure email label
        emailLabel.font = UIFont.systemFont(ofSize: 16)
        emailLabel.textAlignment = .center
        emailLabel.textColor = .secondaryLabel
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure streak view
        streakView.backgroundColor = .systemOrange.withAlphaComponent(0.2)
        streakView.layer.cornerRadius = 12
        streakView.translatesAutoresizingMaskIntoConstraints = false
        
        streakLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        streakLabel.textColor = .systemOrange
        streakLabel.textAlignment = .center
        streakLabel.translatesAutoresizingMaskIntoConstraints = false
        
        streakView.addSubview(streakLabel)
        
        // Configure achievements section
        achievementsTitleLabel.text = "🏆 Achievements"
        achievementsTitleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        achievementsTitleLabel.textColor = .label
        achievementsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        achievementsCollectionView.backgroundColor = .clear
        achievementsCollectionView.delegate = self
        achievementsCollectionView.dataSource = self
        achievementsCollectionView.register(AchievementCollectionViewCell.self, forCellWithReuseIdentifier: "AchievementCell")
        achievementsCollectionView.showsHorizontalScrollIndicator = false
        achievementsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure change photo button
        changePhotoButton.setTitle("Change Photo", for: .normal)
        changePhotoButton.backgroundColor = .systemGreen
        changePhotoButton.setTitleColor(.white, for: .normal)
        changePhotoButton.layer.cornerRadius = 8
        changePhotoButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        changePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        changePhotoButton.addTarget(self, action: #selector(changePhotoTapped), for: .touchUpInside)
        
        // Configure info stack view
        infoStackView.axis = .vertical
        infoStackView.spacing = 12
        infoStackView.alignment = .center
        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        
        infoStackView.addArrangedSubview(nameLabel)
        infoStackView.addArrangedSubview(emailLabel)
        
        // Configure upgrade prompt
        upgradePromptView.backgroundColor = .systemYellow.withAlphaComponent(0.2)
        upgradePromptView.layer.cornerRadius = 12
        upgradePromptView.layer.borderWidth = 1
        upgradePromptView.layer.borderColor = UIColor.systemYellow.cgColor
        upgradePromptView.translatesAutoresizingMaskIntoConstraints = false
        
        let upgradeLabel = UILabel()
        upgradeLabel.text = "✨ Upgrade to Premium for exclusive features!"
        upgradeLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        upgradeLabel.textColor = .systemOrange
        upgradeLabel.textAlignment = .center
        upgradeLabel.numberOfLines = 2
        upgradeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let upgradeButton = UIButton(type: .system)
        upgradeButton.setTitle("Upgrade Now", for: .normal)
        upgradeButton.backgroundColor = .systemYellow
        upgradeButton.setTitleColor(.white, for: .normal)
        upgradeButton.layer.cornerRadius = 8
        upgradeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        upgradeButton.translatesAutoresizingMaskIntoConstraints = false
        upgradeButton.addTarget(self, action: #selector(upgradeTapped), for: .touchUpInside)
        
        upgradePromptView.addSubview(upgradeLabel)
        upgradePromptView.addSubview(upgradeButton)
        
        // Configure action buttons
        shareProfileButton.setTitle("📤 Share Profile", for: .normal)
        shareProfileButton.backgroundColor = .systemBlue
        shareProfileButton.setTitleColor(.white, for: .normal)
        shareProfileButton.layer.cornerRadius = 10
        shareProfileButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        shareProfileButton.translatesAutoresizingMaskIntoConstraints = false
        shareProfileButton.addTarget(self, action: #selector(shareProfileTapped), for: .touchUpInside)
        
        exportDataButton.setTitle("📊 Export Data", for: .normal)
        exportDataButton.backgroundColor = .systemGreen
        exportDataButton.setTitleColor(.white, for: .normal)
        exportDataButton.layer.cornerRadius = 10
        exportDataButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        exportDataButton.translatesAutoresizingMaskIntoConstraints = false
        exportDataButton.addTarget(self, action: #selector(exportDataTapped), for: .touchUpInside)
        
        // Configure edit button
        editButton.setTitle("✏️ Edit Profile", for: .normal)
        editButton.backgroundColor = .systemPurple
        editButton.setTitleColor(.white, for: .normal)
        editButton.layer.cornerRadius = 12
        editButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        
        // Setup view hierarchy
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(subscriptionBadge)
        contentView.addSubview(changePhotoButton)
        contentView.addSubview(streakView)
        contentView.addSubview(infoStackView)
        contentView.addSubview(achievementsTitleLabel)
        contentView.addSubview(achievementsCollectionView)
        contentView.addSubview(upgradePromptView)
        contentView.addSubview(shareProfileButton)
        contentView.addSubview(exportDataButton)
        contentView.addSubview(editButton)
        
        // Setup constraints for internal elements
        NSLayoutConstraint.activate([
            upgradeLabel.topAnchor.constraint(equalTo: upgradePromptView.topAnchor, constant: 12),
            upgradeLabel.leadingAnchor.constraint(equalTo: upgradePromptView.leadingAnchor, constant: 16),
            upgradeLabel.trailingAnchor.constraint(equalTo: upgradePromptView.trailingAnchor, constant: -16),
            
            upgradeButton.topAnchor.constraint(equalTo: upgradeLabel.bottomAnchor, constant: 8),
            upgradeButton.centerXAnchor.constraint(equalTo: upgradePromptView.centerXAnchor),
            upgradeButton.bottomAnchor.constraint(equalTo: upgradePromptView.bottomAnchor, constant: -12),
            upgradeButton.widthAnchor.constraint(equalToConstant: 120),
            upgradeButton.heightAnchor.constraint(equalToConstant: 32),
            
            subscriptionLabel.centerXAnchor.constraint(equalTo: subscriptionBadge.centerXAnchor),
            subscriptionLabel.centerYAnchor.constraint(equalTo: subscriptionBadge.centerYAnchor),
            
            streakLabel.centerXAnchor.constraint(equalTo: streakView.centerXAnchor),
            streakLabel.centerYAnchor.constraint(equalTo: streakView.centerYAnchor)
        ])
        
        // Load initial data
        refreshAchievements()
        updateSubscriptionBadge()
        updateUserStats()
    }
    
    private func addInfoRow(title: String, value: String) {
        let containerView = UIView()
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 8
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 16)
        valueLabel.textColor = .secondaryLabel
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalToConstant: 280),
            containerView.heightAnchor.constraint(equalToConstant: 50),
            
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            valueLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        infoStackView.addArrangedSubview(containerView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Profile image
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // Subscription badge
            subscriptionBadge.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: -8),
            subscriptionBadge.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            subscriptionBadge.widthAnchor.constraint(equalToConstant: 60),
            subscriptionBadge.heightAnchor.constraint(equalToConstant: 24),
            
            // Change photo button
            changePhotoButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 12),
            changePhotoButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            changePhotoButton.widthAnchor.constraint(equalToConstant: 120),
            changePhotoButton.heightAnchor.constraint(equalToConstant: 32),
            
            // Streak view
            streakView.topAnchor.constraint(equalTo: changePhotoButton.bottomAnchor, constant: 16),
            streakView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            streakView.widthAnchor.constraint(equalToConstant: 200),
            streakView.heightAnchor.constraint(equalToConstant: 40),
            
            // Info stack view
            infoStackView.topAnchor.constraint(equalTo: streakView.bottomAnchor, constant: 20),
            infoStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Achievements title
            achievementsTitleLabel.topAnchor.constraint(equalTo: infoStackView.bottomAnchor, constant: 24),
            achievementsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            achievementsTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Achievements collection view
            achievementsCollectionView.topAnchor.constraint(equalTo: achievementsTitleLabel.bottomAnchor, constant: 12),
            achievementsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            achievementsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            achievementsCollectionView.heightAnchor.constraint(equalToConstant: 100),
            
            // Upgrade prompt
            upgradePromptView.topAnchor.constraint(equalTo: achievementsCollectionView.bottomAnchor, constant: 20),
            upgradePromptView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            upgradePromptView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            upgradePromptView.heightAnchor.constraint(equalToConstant: 80),
            
            // Action buttons
            shareProfileButton.topAnchor.constraint(equalTo: upgradePromptView.bottomAnchor, constant: 20),
            shareProfileButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            shareProfileButton.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -8),
            shareProfileButton.heightAnchor.constraint(equalToConstant: 44),
            
            exportDataButton.topAnchor.constraint(equalTo: upgradePromptView.bottomAnchor, constant: 20),
            exportDataButton.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 8),
            exportDataButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            exportDataButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Edit button
            editButton.topAnchor.constraint(equalTo: shareProfileButton.bottomAnchor, constant: 20),
            editButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            editButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            editButton.heightAnchor.constraint(equalToConstant: 50),
            editButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    @objc private func profileImageTapped() {
        changePhotoTapped()
    }
    
    @objc private func changePhotoTapped() {
        let alert = UIAlertController(title: "Change Profile Photo", message: "Choose an option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
            self.presentImagePicker(sourceType: .camera)
        })
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.presentImagePicker(sourceType: .photoLibrary)
        })
        
        alert.addAction(UIAlertAction(title: "Remove Photo", style: .destructive) { _ in
            self.profileImageView.image = UIImage(systemName: "person.circle.fill")
            UserDefaults.standard.removeObject(forKey: "profileImage")
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = changePhotoButton
            popover.sourceRect = changePhotoButton.bounds
        }
        
        present(alert, animated: true)
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            let alert = UIAlertController(title: "Not Available", message: "The selected source is not available on this device.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @objc private func editTapped() {
        AnalyticsManager.shared.trackEvent(.buttonTap, parameters: ["button": "edit_profile"])
        
        let alert = UIAlertController(title: "Edit Profile", message: "Update your information", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Name"
            textField.text = self.nameLabel.text
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Email"
            textField.text = self.emailLabel.text
            textField.keyboardType = .emailAddress
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Location"
            textField.text = UserDefaults.standard.string(forKey: "userLocation") ?? "San Francisco, CA"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            var changes: [String: String] = [:]
            
            if let name = alert.textFields?[0].text, !name.isEmpty, name != self.nameLabel.text {
                self.nameLabel.text = name
                UserDefaults.standard.set(name, forKey: "userName")
                changes["name"] = name
            }
            
            if let email = alert.textFields?[1].text, !email.isEmpty, email != self.emailLabel.text {
                self.emailLabel.text = email
                UserDefaults.standard.set(email, forKey: "userEmail")
                changes["email"] = email
            }
            
            if let location = alert.textFields?[2].text, !location.isEmpty {
                UserDefaults.standard.set(location, forKey: "userLocation")
                changes["location"] = location
            }
            
            // Update info rows and track changes
            self.updateInfoRowsWithCurrentData()
            
            if !changes.isEmpty {
                AnalyticsManager.shared.trackEvent(.profileUpdated, parameters: [
                    "changes_count": changes.count,
                    "fields_changed": Array(changes.keys).joined(separator: ",")
                ])
                
                // Update daily challenge
                DailyChallengeManager.shared.updateProgress(for: "customization", increment: 1)
                AchievementManager.shared.updateProgress(for: "profile_master", progress: 1)
            }
        }
        
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func shareProfileTapped() {
        AnalyticsManager.shared.trackEvent(.buttonTap, parameters: ["button": "share_profile"])
        
        let unlockedAchievements = achievements.filter { $0.isUnlocked }.count
        let totalAchievements = achievements.count
        let tapCount = UserDefaults.standard.integer(forKey: "tapCount")
        let streak = userProgress.currentStreak
        
        let shareText = """
        Check out my Sample App profile! 📱
        
        👤 \(nameLabel.text ?? "User")
        🏆 Achievements: \(unlockedAchievements)/\(totalAchievements)
        🔥 Current Streak: \(streak) days
        👆 Total Taps: \(tapCount)
        👑 Status: \(PremiumManager.shared.getCurrentTier().rawValue)
        
        Join me on this amazing iOS learning journey!
        """
        
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        activityVC.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            AnalyticsManager.shared.trackEvent(.contentShared, parameters: [
                "content_type": "profile",
                "completed": completed,
                "activity_type": activityType?.rawValue ?? "unknown",
                "achievements_count": unlockedAchievements,
                "current_streak": streak
            ])
            
            if completed {
                // Update daily challenge and achievements
                DailyChallengeManager.shared.updateProgress(for: "social", increment: 1)
                AchievementManager.shared.updateProgress(for: "social_butterfly", progress: 1)
            }
        }
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = shareProfileButton
            popover.sourceRect = shareProfileButton.bounds
        }
        
        present(activityVC, animated: true)
    }
    
    @objc private func exportDataTapped() {
        AnalyticsManager.shared.trackEvent(.buttonTap, parameters: ["button": "export_data"])
        
        if !PremiumManager.shared.isFeatureUnlocked("export_data") {
            let feature = PremiumManager.shared.getPremiumFeatures().first { $0.id == "export_data" }!
            PremiumManager.shared.showUpgradePrompt(for: feature, from: self)
            return
        }
        
        let exportData = AnalyticsManager.shared.exportEventsToString()
        let activityVC = UIActivityViewController(activityItems: [exportData], applicationActivities: nil)
        
        activityVC.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            AnalyticsManager.shared.trackEvent(.contentShared, parameters: [
                "content_type": "user_data_export",
                "completed": completed,
                "activity_type": activityType?.rawValue ?? "unknown"
            ])
        }
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = exportDataButton
            popover.sourceRect = exportDataButton.bounds
        }
        
        present(activityVC, animated: true)
    }
    
    @objc private func upgradeTapped() {
        AnalyticsManager.shared.trackEvent(.buttonTap, parameters: ["button": "upgrade_from_profile"])
        PremiumManager.shared.showSubscriptionOptions(from: self)
    }
}

// MARK: - Collection View Data Source & Delegate
extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return achievements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AchievementCell", for: indexPath) as! AchievementCollectionViewCell
        let achievement = achievements[indexPath.item]
        cell.configure(with: achievement)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let achievement = achievements[indexPath.item]
        
        AnalyticsManager.shared.trackEvent(.buttonTap, parameters: [
            "button": "achievement",
            "achievement_id": achievement.id,
            "is_unlocked": achievement.isUnlocked
        ])
        
        let statusText = achievement.isUnlocked ? "🎉 Unlocked!" : "🔒 Locked"
        let progressText = achievement.isUnlocked ? "Complete!" : "\(achievement.progress)/\(achievement.requirement)"
        
        let message = """
        \(achievement.description)
        
        Category: \(achievement.category.rawValue)
        Progress: \(progressText)
        Status: \(statusText)
        """
        
        let alert = UIAlertController(title: "\(achievement.icon) \(achievement.title)", message: message, preferredStyle: .alert)
        
        if !achievement.isUnlocked && achievement.progress > 0 {
            alert.addAction(UIAlertAction(title: "Keep Going!", style: .default))
        } else {
            alert.addAction(UIAlertAction(title: "OK", style: .default))
        }
        
        present(alert, animated: true)
    }
}

// MARK: - Image Picker Delegate
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        var selectedImage: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        guard let image = selectedImage else { return }
        
        profileImageView.image = image
        
        // Save image to UserDefaults
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(imageData, forKey: "profileImage")
        }
        
        // Track photo change
        AnalyticsManager.shared.trackEvent(.profileUpdated, parameters: [
            "changes_count": 1,
            "fields_changed": "profile_photo"
        ])
        
        // Update daily challenge and achievements
        DailyChallengeManager.shared.updateProgress(for: "customization", increment: 1)
        AchievementManager.shared.updateProgress(for: "profile_master", progress: 1)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
} 