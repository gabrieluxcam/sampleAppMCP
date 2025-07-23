import UIKit

class MainViewController: UIViewController {
    
    private let titleLabel = UILabel()
    private let counterButton = UIButton(type: .system)
    private let resetButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)
    private let achievementsButton = UIButton(type: .system)
    private let dailyChallengeView = UIView()
    private let challengeTitleLabel = UILabel()
    private let challengeProgressLabel = UILabel()
    private let challengeProgressBar = UIProgressView()
    private let upgradePromptView = UIView()
    private let upgradeLabel = UILabel()
    private let upgradeButton = UIButton(type: .system)
    
    private var tapCount = 0 {
        didSet {
            tapCountLabel.text = "Taps: \(tapCount)"
            // Save to UserDefaults
            UserDefaults.standard.set(tapCount, forKey: "tapCount")
            
            // Update achievements
            AchievementManager.shared.checkForNewAchievements()
            
            // Update daily challenge
            DailyChallengeManager.shared.updateProgress(for: "tap", increment: 1)
            updateDailyChallengeDisplay()
            
            // Track analytics
            AnalyticsManager.shared.trackEvent(.featureUsed, parameters: [
                "action": "tap_counter",
                "tap_count": tapCount,
                "milestone": tapCount % 10 == 0 ? tapCount : nil ?? 0
            ])
        }
    }
    private let tapCountLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTapCount()
        setupUI()
        setupConstraints()
        updateDailyChallengeDisplay()
        updateUpgradePrompt()
        
        // Track screen view
        AnalyticsManager.shared.trackScreen("MainViewController", parameters: [
            "current_tap_count": tapCount,
            "subscription_tier": PremiumManager.shared.getCurrentTier().rawValue
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDailyChallengeDisplay()
        updateUpgradePrompt()
        AchievementManager.shared.checkForNewAchievements()
    }
    
    private func loadTapCount() {
        tapCount = UserDefaults.standard.integer(forKey: "tapCount")
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Sample App"
        
        // Configure navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "🏆",
            style: .plain,
            target: self,
            action: #selector(achievementsTapped)
        )
        
        // Configure title label
        titleLabel.text = "Welcome to Sample App!"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure tap count label
        tapCountLabel.text = "Taps: \(tapCount)"
        tapCountLabel.font = UIFont.systemFont(ofSize: 18)
        tapCountLabel.textAlignment = .center
        tapCountLabel.textColor = .secondaryLabel
        tapCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure daily challenge view
        setupDailyChallengeView()
        
        // Configure upgrade prompt view
        setupUpgradePromptView()
        
        // Configure buttons
        configureButton(counterButton, title: "Tap Me! 👆", color: .systemBlue)
        configureButton(resetButton, title: "Reset Counter", color: .systemRed)
        configureButton(shareButton, title: "Share Progress 📤", color: .systemGreen)
        configureButton(achievementsButton, title: "View Achievements 🏆", color: .systemPurple)
        
        // Add targets
        counterButton.addTarget(self, action: #selector(counterTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        achievementsButton.addTarget(self, action: #selector(achievementsTapped), for: .touchUpInside)
        
        // Add views
        view.addSubview(titleLabel)
        view.addSubview(tapCountLabel)
        view.addSubview(dailyChallengeView)
        view.addSubview(counterButton)
        view.addSubview(shareButton)
        view.addSubview(resetButton)
        view.addSubview(achievementsButton)
        view.addSubview(upgradePromptView)
    }
    
    private func configureButton(_ button: UIButton, title: String, color: UIColor) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupDailyChallengeView() {
        dailyChallengeView.backgroundColor = .secondarySystemBackground
        dailyChallengeView.layer.cornerRadius = 12
        dailyChallengeView.translatesAutoresizingMaskIntoConstraints = false
        
        challengeTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        challengeTitleLabel.textColor = .label
        challengeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        challengeProgressLabel.font = UIFont.systemFont(ofSize: 14)
        challengeProgressLabel.textColor = .secondaryLabel
        challengeProgressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        challengeProgressBar.progressTintColor = .systemBlue
        challengeProgressBar.trackTintColor = .systemGray5
        challengeProgressBar.translatesAutoresizingMaskIntoConstraints = false
        
        dailyChallengeView.addSubview(challengeTitleLabel)
        dailyChallengeView.addSubview(challengeProgressLabel)
        dailyChallengeView.addSubview(challengeProgressBar)
        
        NSLayoutConstraint.activate([
            challengeTitleLabel.topAnchor.constraint(equalTo: dailyChallengeView.topAnchor, constant: 12),
            challengeTitleLabel.leadingAnchor.constraint(equalTo: dailyChallengeView.leadingAnchor, constant: 16),
            challengeTitleLabel.trailingAnchor.constraint(equalTo: dailyChallengeView.trailingAnchor, constant: -16),
            
            challengeProgressLabel.topAnchor.constraint(equalTo: challengeTitleLabel.bottomAnchor, constant: 4),
            challengeProgressLabel.leadingAnchor.constraint(equalTo: dailyChallengeView.leadingAnchor, constant: 16),
            challengeProgressLabel.trailingAnchor.constraint(equalTo: dailyChallengeView.trailingAnchor, constant: -16),
            
            challengeProgressBar.topAnchor.constraint(equalTo: challengeProgressLabel.bottomAnchor, constant: 8),
            challengeProgressBar.leadingAnchor.constraint(equalTo: dailyChallengeView.leadingAnchor, constant: 16),
            challengeProgressBar.trailingAnchor.constraint(equalTo: dailyChallengeView.trailingAnchor, constant: -16),
            challengeProgressBar.bottomAnchor.constraint(equalTo: dailyChallengeView.bottomAnchor, constant: -12),
            challengeProgressBar.heightAnchor.constraint(equalToConstant: 8)
        ])
    }
    
    private func setupUpgradePromptView() {
        upgradePromptView.backgroundColor = .systemIndigo
        upgradePromptView.layer.cornerRadius = 12
        upgradePromptView.translatesAutoresizingMaskIntoConstraints = false
        upgradePromptView.isHidden = true
        
        upgradeLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        upgradeLabel.textColor = .white
        upgradeLabel.textAlignment = .center
        upgradeLabel.numberOfLines = 2
        upgradeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        upgradeButton.setTitle("Upgrade Now", for: .normal)
        upgradeButton.setTitleColor(.white, for: .normal)
        upgradeButton.backgroundColor = .white.withAlphaComponent(0.2)
        upgradeButton.layer.cornerRadius = 8
        upgradeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        upgradeButton.translatesAutoresizingMaskIntoConstraints = false
        upgradeButton.addTarget(self, action: #selector(upgradePromptTapped), for: .touchUpInside)
        
        upgradePromptView.addSubview(upgradeLabel)
        upgradePromptView.addSubview(upgradeButton)
        
        NSLayoutConstraint.activate([
            upgradeLabel.topAnchor.constraint(equalTo: upgradePromptView.topAnchor, constant: 12),
            upgradeLabel.leadingAnchor.constraint(equalTo: upgradePromptView.leadingAnchor, constant: 16),
            upgradeLabel.trailingAnchor.constraint(equalTo: upgradePromptView.trailingAnchor, constant: -16),
            
            upgradeButton.topAnchor.constraint(equalTo: upgradeLabel.bottomAnchor, constant: 8),
            upgradeButton.centerXAnchor.constraint(equalTo: upgradePromptView.centerXAnchor),
            upgradeButton.widthAnchor.constraint(equalToConstant: 120),
            upgradeButton.heightAnchor.constraint(equalToConstant: 32),
            upgradeButton.bottomAnchor.constraint(equalTo: upgradePromptView.bottomAnchor, constant: -12)
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Title label
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Daily challenge view
            dailyChallengeView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            dailyChallengeView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dailyChallengeView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Tap count label
            tapCountLabel.topAnchor.constraint(equalTo: dailyChallengeView.bottomAnchor, constant: 30),
            tapCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Counter button
            counterButton.topAnchor.constraint(equalTo: tapCountLabel.bottomAnchor, constant: 30),
            counterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            counterButton.widthAnchor.constraint(equalToConstant: 200),
            counterButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Share button
            shareButton.topAnchor.constraint(equalTo: counterButton.bottomAnchor, constant: 15),
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shareButton.widthAnchor.constraint(equalToConstant: 200),
            shareButton.heightAnchor.constraint(equalToConstant: 45),
            
            // Reset button
            resetButton.topAnchor.constraint(equalTo: shareButton.bottomAnchor, constant: 15),
            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetButton.widthAnchor.constraint(equalToConstant: 200),
            resetButton.heightAnchor.constraint(equalToConstant: 45),
            
            // Achievements button
            achievementsButton.topAnchor.constraint(equalTo: resetButton.bottomAnchor, constant: 15),
            achievementsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            achievementsButton.widthAnchor.constraint(equalToConstant: 200),
            achievementsButton.heightAnchor.constraint(equalToConstant: 45),
            
            // Upgrade prompt view
            upgradePromptView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            upgradePromptView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            upgradePromptView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func counterTapped() {
        tapCount += 1
        
        // Add some animation
        UIView.animate(withDuration: 0.1, animations: {
            self.counterButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.counterButton.transform = CGAffineTransform.identity
            }
        }
        
        // Add celebratory animation for milestones
        if tapCount % 10 == 0 {
            showCelebration()
        }
        
        // Show upgrade prompt occasionally for free users
        if tapCount % 25 == 0 && PremiumManager.shared.getCurrentTier() == .free {
            showUpgradePromptAlert()
        }
    }
    
    @objc private func resetTapped() {
        AnalyticsManager.shared.trackEvent(.buttonTap, parameters: ["button": "reset", "current_count": tapCount])
        
        let alert = UIAlertController(title: "Reset Counter", message: "Are you sure you want to reset the tap counter?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { _ in
            AnalyticsManager.shared.trackEvent(.featureUsed, parameters: ["action": "reset_counter", "previous_count": self.tapCount])
            self.tapCount = 0
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            AnalyticsManager.shared.trackEvent(.featureUsed, parameters: ["action": "reset_cancelled"])
        })
        
        present(alert, animated: true)
    }
    
    @objc private func shareTapped() {
        AnalyticsManager.shared.trackEvent(.buttonTap, parameters: ["button": "share"])
        
        let shareText = "I've reached \(tapCount) taps in the Sample App! 🎉 Can you beat my score?"
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            AnalyticsManager.shared.trackEvent(.contentShared, parameters: [
                "content_type": "tap_score",
                "tap_count": self.tapCount,
                "completed": completed,
                "activity_type": activityType?.rawValue ?? "unknown"
            ])
            
            if completed {
                // Update achievement
                AchievementManager.shared.updateProgress(for: "first_share", progress: 1)
            }
        }
        
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = shareButton
            popover.sourceRect = shareButton.bounds
        }
        
        present(activityViewController, animated: true)
    }
    
    @objc private func achievementsTapped() {
        AnalyticsManager.shared.trackEvent(.buttonTap, parameters: ["button": "achievements"])
        showAchievementsScreen()
    }
    
    @objc private func upgradePromptTapped() {
        AnalyticsManager.shared.trackEvent(.buttonTap, parameters: ["button": "upgrade_prompt"])
        PremiumManager.shared.showSubscriptionOptions(from: self)
    }
    
    private func showCelebration() {
        let alert = UIAlertController(title: "🎉 Milestone!", message: "You've reached \(tapCount) taps!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Awesome!", style: .default))
        present(alert, animated: true)
    }
    
    private func showAchievementsScreen() {
        let achievements = AchievementManager.shared.getAchievements()
        let unlockedCount = achievements.filter { $0.isUnlocked }.count
        
        let alert = UIAlertController(
            title: "🏆 Achievements (\(unlockedCount)/\(achievements.count))",
            message: "Your progress so far:",
            preferredStyle: .alert
        )
        
        // Show recent achievements
        let recentUnlocked = achievements.filter { $0.isUnlocked }.prefix(3)
        if !recentUnlocked.isEmpty {
            for achievement in recentUnlocked {
                alert.addAction(UIAlertAction(title: "\(achievement.icon) \(achievement.title)", style: .default) { _ in
                    self.showAchievementDetail(achievement)
                })
            }
        }
        
        alert.addAction(UIAlertAction(title: "View All", style: .default) { _ in
            self.showAllAchievements()
        })
        
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showAchievementDetail(_ achievement: Achievement) {
        let alert = UIAlertController(
            title: "\(achievement.icon) \(achievement.title)",
            message: "\(achievement.description)\n\nProgress: \(achievement.progress)/\(achievement.requirement)\nCategory: \(achievement.category.rawValue)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showAllAchievements() {
        let achievements = AchievementManager.shared.getAchievements()
        let alert = UIAlertController(title: "🏆 All Achievements", message: nil, preferredStyle: .alert)
        
        for category in AchievementCategory.allCases {
            let categoryAchievements = achievements.filter { $0.category == category }
            let unlockedInCategory = categoryAchievements.filter { $0.isUnlocked }.count
            
            alert.addAction(UIAlertAction(title: "\(category.rawValue) (\(unlockedInCategory)/\(categoryAchievements.count))", style: .default) { _ in
                self.showCategoryAchievements(category)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
        
        AnalyticsManager.shared.trackEvent(.featureUsed, parameters: ["action": "view_all_achievements"])
    }
    
    private func showCategoryAchievements(_ category: AchievementCategory) {
        let achievements = AchievementManager.shared.getAchievements(for: category)
        var message = ""
        
        for achievement in achievements {
            let status = achievement.isUnlocked ? "✅" : "🔒"
            let progress = achievement.isUnlocked ? "\(achievement.requirement)" : "\(achievement.progress)"
            message += "\(status) \(achievement.icon) \(achievement.title) (\(progress)/\(achievement.requirement))\n"
        }
        
        let alert = UIAlertController(title: category.rawValue, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func updateDailyChallengeDisplay() {
        guard let challenge = DailyChallengeManager.shared.getCurrentChallenge() else {
            dailyChallengeView.isHidden = true
            return
        }
        
        dailyChallengeView.isHidden = false
        challengeTitleLabel.text = "🎯 Daily Challenge: \(challenge.title)"
        challengeProgressLabel.text = "\(challenge.description) (\(challenge.currentProgress)/\(challenge.targetValue))"
        challengeProgressBar.progress = Float(challenge.progressPercentage / 100.0)
        
        if challenge.isCompleted {
            challengeTitleLabel.text = "✅ \(challenge.title) - Complete!"
            challengeProgressLabel.text = "🏆 Earned \(challenge.rewardPoints) points!"
        }
    }
    
    private func updateUpgradePrompt() {
        let currentTier = PremiumManager.shared.getCurrentTier()
        
        if currentTier == .free && tapCount > 50 {
            upgradePromptView.isHidden = false
            upgradeLabel.text = "🚀 Unlock premium features!\nRemove ads & get exclusive content"
        } else if PremiumManager.shared.isTrialActive() {
            upgradePromptView.isHidden = false
            if let timeRemaining = PremiumManager.shared.getTrialTimeRemaining() {
                let daysRemaining = Int(timeRemaining / (24 * 60 * 60))
                upgradeLabel.text = "⭐ \(currentTier.rawValue) Trial Active\n\(daysRemaining) days remaining"
                upgradeButton.setTitle("Keep Premium", for: .normal)
            }
        } else {
            upgradePromptView.isHidden = true
        }
    }
    
    private func showUpgradePromptAlert() {
        let lockedFeatures = PremiumManager.shared.getLockedFeatures()
        guard let randomFeature = lockedFeatures.randomElement() else { return }
        
        PremiumManager.shared.showUpgradePrompt(for: randomFeature, from: self)
    }
} 
