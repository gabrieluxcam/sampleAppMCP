import UIKit
import UXCam

class SettingsViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var userPreferences = UserPreferences()
    
    private let settings = [
        ["Notifications", "Privacy & Security", "Analytics", "Account"],
        ["Dark Mode", "Font Size", "Haptic Feedback", "Sound Effects", "Data Usage"],
        ["Premium Features", "Export Data", "Reset Progress"],
        ["Help", "About", "Contact Us", "Rate App", "Debug Info"]
    ]
    
    private let sectionTitles = ["Privacy & Data", "Appearance & Controls", "Premium & Data", "Support & Info"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserPreferences()
        setupUI()
        setupConstraints()
        
        // Track screen view
        AnalyticsManager.shared.trackScreen("SettingsViewController", parameters: [
            "subscription_tier": PremiumManager.shared.getCurrentTier().rawValue,
            "notifications_enabled": userPreferences.notificationsEnabled,
            "analytics_enabled": userPreferences.analyticsEnabled
        ])
        
        // Update daily challenge
        DailyChallengeManager.shared.updateProgress(for: "settings", increment: 1)
        AchievementManager.shared.updateProgress(for: "settings_explorer", progress: 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Tag screen for UXCam when user actually sees it
        UXCamScreenNames.tagScreen(UXCamScreenNames.settings)
        
        // Apply privacy protection for settings
        setupPrivacyProtection()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove screen-level privacy protection when leaving
        removeUXCamPrivacyProtection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData() // Refresh data for premium status changes
    }
    
    private func loadUserPreferences() {
        if let data = UserDefaults.standard.data(forKey: "userPreferences"),
           let preferences = try? JSONDecoder().decode(UserPreferences.self, from: data) {
            userPreferences = preferences
        }
    }
    
    private func saveUserPreferences() {
        if let data = try? JSONEncoder().encode(userPreferences) {
            UserDefaults.standard.set(data, forKey: "userPreferences")
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Settings"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        let settingName = settings[indexPath.section][indexPath.row]
        
        cell.textLabel?.text = settingName
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default
        
        // Configure cell based on setting type
        configureCellAppearance(cell: cell, settingName: settingName)
        
        // Apply privacy protection to sensitive cells
        applyCellPrivacyProtection(cell, settingName: settingName)
        
        return cell
    }
    
    private func configureCellAppearance(cell: UITableViewCell, settingName: String) {
        // Reset cell state
        cell.accessoryView = nil
        cell.accessoryType = .disclosureIndicator
        cell.detailTextLabel?.text = nil
        cell.textLabel?.textColor = .label
        
        switch settingName {
        case "Notifications":
            cell.imageView?.image = UIImage(systemName: "bell.fill")
            cell.imageView?.tintColor = userPreferences.notificationsEnabled ? .systemBlue : .systemGray
            let toggle = UISwitch()
            toggle.isOn = userPreferences.notificationsEnabled
            toggle.addTarget(self, action: #selector(notificationsToggled(_:)), for: .valueChanged)
            cell.accessoryView = toggle
            cell.accessoryType = .none
            
        case "Privacy & Security":
            cell.imageView?.image = UIImage(systemName: "lock.shield")
            cell.imageView?.tintColor = .systemGreen
            
        case "Analytics":
            cell.imageView?.image = UIImage(systemName: "chart.line.uptrend.xyaxis")
            cell.imageView?.tintColor = userPreferences.analyticsEnabled ? .systemBlue : .systemGray
            let toggle = UISwitch()
            toggle.isOn = userPreferences.analyticsEnabled
            toggle.addTarget(self, action: #selector(analyticsToggled(_:)), for: .valueChanged)
            cell.accessoryView = toggle
            cell.accessoryType = .none
            
        case "Account":
            cell.imageView?.image = UIImage(systemName: "person.circle")
            cell.imageView?.tintColor = .systemBlue
            
        case "Dark Mode":
            cell.imageView?.image = UIImage(systemName: "moon.fill")
            cell.imageView?.tintColor = .systemIndigo
            
        case "Font Size":
            cell.imageView?.image = UIImage(systemName: "textformat.size")
            cell.imageView?.tintColor = .systemOrange
            cell.detailTextLabel?.text = userPreferences.fontSize.rawValue
            
        case "Haptic Feedback":
            cell.imageView?.image = UIImage(systemName: "iphone.radiowaves.left.and.right")
            cell.imageView?.tintColor = userPreferences.hapticFeedbackEnabled ? .systemBlue : .systemGray
            let toggle = UISwitch()
            toggle.isOn = userPreferences.hapticFeedbackEnabled
            toggle.addTarget(self, action: #selector(hapticToggled(_:)), for: .valueChanged)
            cell.accessoryView = toggle
            cell.accessoryType = .none
            
        case "Sound Effects":
            cell.imageView?.image = UIImage(systemName: "speaker.wave.2")
            cell.imageView?.tintColor = userPreferences.soundEffectsEnabled ? .systemBlue : .systemGray
            let toggle = UISwitch()
            toggle.isOn = userPreferences.soundEffectsEnabled
            toggle.addTarget(self, action: #selector(soundToggled(_:)), for: .valueChanged)
            cell.accessoryView = toggle
            cell.accessoryType = .none
            
        case "Data Usage":
            cell.imageView?.image = UIImage(systemName: "wifi")
            cell.imageView?.tintColor = .systemGreen
            cell.detailTextLabel?.text = userPreferences.dataUsageOptimized ? "Optimized" : "Standard"
            
        case "Premium Features":
            cell.imageView?.image = UIImage(systemName: "crown.fill")
            cell.imageView?.tintColor = .systemYellow
            cell.detailTextLabel?.text = PremiumManager.shared.getCurrentTier().rawValue
            
        case "Export Data":
            cell.imageView?.image = UIImage(systemName: "square.and.arrow.up")
            cell.imageView?.tintColor = .systemBlue
            if !PremiumManager.shared.isFeatureUnlocked("export_data") {
                cell.imageView?.tintColor = .systemGray
                cell.textLabel?.textColor = .systemGray
            }
            
        case "Reset Progress":
            cell.imageView?.image = UIImage(systemName: "arrow.clockwise")
            cell.imageView?.tintColor = .systemRed
            cell.textLabel?.textColor = .systemRed
            
        case "Help":
            cell.imageView?.image = UIImage(systemName: "questionmark.circle")
            cell.imageView?.tintColor = .systemBlue
            
        case "About":
            cell.imageView?.image = UIImage(systemName: "info.circle")
            cell.imageView?.tintColor = .systemBlue
            
        case "Contact Us":
            cell.imageView?.image = UIImage(systemName: "envelope")
            cell.imageView?.tintColor = .systemBlue
            
        case "Rate App":
            cell.imageView?.image = UIImage(systemName: "star.fill")
            cell.imageView?.tintColor = .systemYellow
            
        case "Debug Info":
            cell.imageView?.image = UIImage(systemName: "ladybug")
            cell.imageView?.tintColor = .systemRed
            if !PremiumManager.shared.isFeatureUnlocked("advanced_analytics") {
                cell.imageView?.tintColor = .systemGray
                cell.textLabel?.textColor = .systemGray
            }
            
        default:
            cell.imageView?.image = UIImage(systemName: "gear")
            cell.imageView?.tintColor = .systemGray
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedSetting = settings[indexPath.section][indexPath.row]
        
        // Track the setting selection
        AnalyticsManager.shared.trackEvent(.buttonTap, parameters: [
            "button": "setting",
            "setting_name": selectedSetting,
            "section": sectionTitles[indexPath.section]
        ])
        
        // Handle setting-specific actions
        handleSettingSelection(selectedSetting)
    }
    
    private func handleSettingSelection(_ setting: String) {
        // Update daily challenge for settings changes
        DailyChallengeManager.shared.updateProgress(for: "settings", increment: 1)
        
        switch setting {
        case "Privacy & Security":
            showPrivacySettings()
        case "Account":
            showAccountSettings()
        case "Dark Mode":
            showDarkModeSettings()
        case "Font Size":
            showFontSizeSettings()
        case "Data Usage":
            showDataUsageSettings()
        case "Premium Features":
            showPremiumFeatures()
        case "Export Data":
            exportUserData()
        case "Reset Progress":
            showResetProgressConfirmation()
        case "Help":
            showHelp()
        case "About":
            showAbout()
        case "Contact Us":
            showContactUs()
        case "Rate App":
            showRateApp()
        case "Debug Info":
            showDebugInfo()
        default:
            showGenericSetting(setting)
        }
    }
    
    // MARK: - Toggle Actions
    @objc private func notificationsToggled(_ sender: UISwitch) {
        userPreferences.notificationsEnabled = sender.isOn
        saveUserPreferences()
        
        AnalyticsManager.shared.trackEvent(.settingChanged, parameters: [
            "setting": "notifications",
            "enabled": sender.isOn
        ])
        
        if sender.isOn {
            showNotificationPermissionAlert()
        }
        
        tableView.reloadData()
    }
    
    @objc private func analyticsToggled(_ sender: UISwitch) {
        userPreferences.analyticsEnabled = sender.isOn
        saveUserPreferences()
        
        AnalyticsManager.shared.trackEvent(.settingChanged, parameters: [
            "setting": "analytics",
            "enabled": sender.isOn
        ])
        
        if !sender.isOn {
            showAnalyticsDisabledAlert()
        }
        
        tableView.reloadData()
    }
    
    @objc private func hapticToggled(_ sender: UISwitch) {
        userPreferences.hapticFeedbackEnabled = sender.isOn
        saveUserPreferences()
        
        if sender.isOn {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
        
        AnalyticsManager.shared.trackEvent(.settingChanged, parameters: [
            "setting": "haptic_feedback",
            "enabled": sender.isOn
        ])
        
        tableView.reloadData()
    }
    
    @objc private func soundToggled(_ sender: UISwitch) {
        userPreferences.soundEffectsEnabled = sender.isOn
        saveUserPreferences()
        
        AnalyticsManager.shared.trackEvent(.settingChanged, parameters: [
            "setting": "sound_effects",
            "enabled": sender.isOn
        ])
        
        tableView.reloadData()
    }
    
    // MARK: - Settings Handlers
    private func showPrivacySettings() {
        let message = """
        Privacy & Security Settings:
        
        📱 Data Collection: \(userPreferences.analyticsEnabled ? "Enabled" : "Disabled")
        🔒 Crash Reporting: \(userPreferences.crashReportingEnabled ? "Enabled" : "Disabled")
        📧 Marketing Emails: \(userPreferences.marketingEmailsEnabled ? "Enabled" : "Disabled")
        🔄 Auto Sync: \(userPreferences.autoSyncEnabled ? "Enabled" : "Disabled")
        """
        
        let alert = UIAlertController(title: "Privacy & Security", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Manage Privacy", style: .default) { _ in
            self.showDetailedPrivacySettings()
        })
        
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showAccountSettings() {
        let userName = UserDefaults.standard.string(forKey: "userName") ?? "Not set"
        let userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? "Not set"
        let currentTier = PremiumManager.shared.getCurrentTier().rawValue
        
        let message = """
        Account Information:
        
        👤 Name: \(userName)
        📧 Email: \(userEmail)
        👑 Subscription: \(currentTier)
        📅 Member since: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none))
        """
        
        let alert = UIAlertController(title: "Account", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Edit Profile", style: .default) { _ in
            if let tabBarController = self.tabBarController {
                tabBarController.selectedIndex = 2 // Profile tab
            }
        })
        
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { _ in
            self.showSignOutConfirmation()
        })
        
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showDarkModeSettings() {
        let alert = UIAlertController(title: "Appearance", message: "Choose your preferred appearance", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Light", style: .default) { _ in
            self.userPreferences.darkModePreference = .light
            self.saveUserPreferences()
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.first?.overrideUserInterfaceStyle = .light
            }
            AnalyticsManager.shared.trackEvent(.settingChanged, parameters: ["setting": "dark_mode", "value": "light"])
        })
        
        alert.addAction(UIAlertAction(title: "Dark", style: .default) { _ in
            self.userPreferences.darkModePreference = .dark
            self.saveUserPreferences()
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.first?.overrideUserInterfaceStyle = .dark
            }
            AnalyticsManager.shared.trackEvent(.settingChanged, parameters: ["setting": "dark_mode", "value": "dark"])
        })
        
        alert.addAction(UIAlertAction(title: "System", style: .default) { _ in
            self.userPreferences.darkModePreference = .unspecified
            self.saveUserPreferences()
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.first?.overrideUserInterfaceStyle = .unspecified
            }
            AnalyticsManager.shared.trackEvent(.settingChanged, parameters: ["setting": "dark_mode", "value": "system"])
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = tableView
            popover.sourceRect = CGRect(x: tableView.bounds.midX, y: tableView.bounds.midY, width: 0, height: 0)
        }
        
        present(alert, animated: true)
    }
    
    private func showFontSizeSettings() {
        let alert = UIAlertController(title: "Font Size", message: "Choose your preferred text size", preferredStyle: .actionSheet)
        
        for fontSize in UserPreferences.FontSize.allCases {
            let action = UIAlertAction(title: fontSize.rawValue, style: .default) { _ in
                self.userPreferences.fontSize = fontSize
                self.saveUserPreferences()
                self.tableView.reloadData()
                
                AnalyticsManager.shared.trackEvent(.settingChanged, parameters: [
                    "setting": "font_size",
                    "value": fontSize.rawValue
                ])
            }
            
            if fontSize == userPreferences.fontSize {
                action.setValue(true, forKey: "checked")
            }
            
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = tableView
            popover.sourceRect = CGRect(x: tableView.bounds.midX, y: tableView.bounds.midY, width: 0, height: 0)
        }
        
        present(alert, animated: true)
    }
    
    private func showDataUsageSettings() {
        let alert = UIAlertController(
            title: "Data Usage",
            message: "Choose how the app uses your cellular data",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Standard Quality", style: .default) { _ in
            self.userPreferences.dataUsageOptimized = false
            self.saveUserPreferences()
            self.tableView.reloadData()
            
            AnalyticsManager.shared.trackEvent(.settingChanged, parameters: [
                "setting": "data_usage",
                "value": "standard"
            ])
        })
        
        alert.addAction(UIAlertAction(title: "Data Saver", style: .default) { _ in
            self.userPreferences.dataUsageOptimized = true
            self.saveUserPreferences()
            self.tableView.reloadData()
            
            AnalyticsManager.shared.trackEvent(.settingChanged, parameters: [
                "setting": "data_usage",
                "value": "optimized"
            ])
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = tableView
            popover.sourceRect = CGRect(x: tableView.bounds.midX, y: tableView.bounds.midY, width: 0, height: 0)
        }
        
        present(alert, animated: true)
    }
    
    private func showPremiumFeatures() {
        PremiumManager.shared.showSubscriptionOptions(from: self)
    }
    
    private func exportUserData() {
        if !PremiumManager.shared.isFeatureUnlocked("export_data") {
            // Track premium feature gate hit
            UXCamEventManager.shared.trackPremiumFeatureGated(
                featureId: "export_data",
                userIntent: "high", // User actively tried to access
                gateResponse: "upgrade_prompt_shown"
            )
            
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
            popover.sourceView = tableView
            popover.sourceRect = CGRect(x: tableView.bounds.midX, y: tableView.bounds.midY, width: 0, height: 0)
        }
        
        present(activityVC, animated: true)
    }
    
    private func showResetProgressConfirmation() {
        let alert = UIAlertController(
            title: "⚠️ Reset All Progress",
            message: "This will permanently delete all your progress, achievements, preferences, and data. This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Reset Everything", style: .destructive) { _ in
            self.performFullReset()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showHelp() {
        let message = """
        📱 Sample App Help
        
        🏠 Home: Tap to increase your counter and complete daily challenges
        📚 Topics: Learn iOS development concepts with ratings and progress tracking
        👤 Profile: Customize your profile and track achievements
        ⚙️ Settings: Manage your preferences and app behavior
        
        💡 Tips:
        • Favorite topics you want to revisit
        • Complete daily challenges for rewards
        • Rate topics to help improve content
        • Upgrade to premium for exclusive features
        """
        
        let alert = UIAlertController(title: "Help", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Contact Support", style: .default) { _ in
            self.showContactUs()
        })
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showAbout() {
        let achievements = AchievementManager.shared.getUnlockedAchievements().count
        let totalAchievements = AchievementManager.shared.getAchievements().count
        
        let message = """
        📱 Sample App v1.0
        
        A comprehensive iOS development learning app with:
        
        ✨ Features:
        • Interactive tap counter with milestones
        • Learning topics with progress tracking
        • Achievement system (\(achievements)/\(totalAchievements) unlocked)
        • Daily challenges and streaks
        • Profile customization
        • Premium subscription tiers
        • Advanced analytics
        
        🎯 Perfect for showcasing analytics integration and user engagement patterns.
        
        Built with ❤️ for analytics demonstration
        """
        
        let alert = UIAlertController(title: "About", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showContactUs() {
        let alert = UIAlertController(title: "Contact Us", message: "How would you like to get in touch?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "📧 Email Support", style: .default) { _ in
            AnalyticsManager.shared.trackEvent(.featureUsed, parameters: ["action": "contact_email"])
            // In a real app, this would open mail composer
            self.showSimulatedContact("Email")
        })
        
        alert.addAction(UIAlertAction(title: "💬 Live Chat", style: .default) { _ in
            AnalyticsManager.shared.trackEvent(.featureUsed, parameters: ["action": "contact_chat"])
            self.showSimulatedContact("Chat")
        })
        
        alert.addAction(UIAlertAction(title: "📞 Call Support", style: .default) { _ in
            AnalyticsManager.shared.trackEvent(.featureUsed, parameters: ["action": "contact_phone"])
            self.showSimulatedContact("Phone")
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = tableView
            popover.sourceRect = CGRect(x: tableView.bounds.midX, y: tableView.bounds.midY, width: 0, height: 0)
        }
        
        present(alert, animated: true)
    }
    
    private func showRateApp() {
        let alert = UIAlertController(title: "⭐ Rate Sample App", message: "Enjoying the app? Please rate us on the App Store!", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "⭐⭐⭐⭐⭐ Rate 5 Stars", style: .default) { _ in
            AnalyticsManager.shared.trackEvent(.featureUsed, parameters: ["action": "rate_app", "rating": 5])
            self.showRateThankYou()
        })
        
        alert.addAction(UIAlertAction(title: "Send Feedback", style: .default) { _ in
            AnalyticsManager.shared.trackEvent(.featureUsed, parameters: ["action": "send_feedback"])
            self.showContactUs()
        })
        
        alert.addAction(UIAlertAction(title: "Maybe Later", style: .cancel) { _ in
            AnalyticsManager.shared.trackEvent(.featureUsed, parameters: ["action": "rate_app_dismissed"])
        })
        
        present(alert, animated: true)
    }
    
    private func showDebugInfo() {
        if !PremiumManager.shared.isFeatureUnlocked("advanced_analytics") {
            // Track premium feature gate hit
            UXCamEventManager.shared.trackPremiumFeatureGated(
                featureId: "advanced_analytics",
                userIntent: "medium", // Technical feature, less critical
                gateResponse: "upgrade_prompt_shown"
            )
            
            let feature = PremiumManager.shared.getPremiumFeatures().first { $0.id == "advanced_analytics" }!
            PremiumManager.shared.showUpgradePrompt(for: feature, from: self)
            return
        }
        
        let events = AnalyticsManager.shared.getAllEvents()
        let eventsSummary = AnalyticsManager.shared.getEventsSummary()
        
        var message = "🐛 Debug Information\n\n"
        message += "📊 Total Events: \(events.count)\n"
        message += "📱 App Version: 1.0\n"
        message += "🔧 Build: Debug\n\n"
        message += "Event Summary:\n"
        
        for (eventType, count) in eventsSummary.prefix(5) {
            message += "• \(eventType): \(count)\n"
        }
        
        let alert = UIAlertController(title: "Debug Info", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Export Debug Data", style: .default) { _ in
            self.exportUserData()
        })
        
        alert.addAction(UIAlertAction(title: "Clear Events", style: .destructive) { _ in
            AnalyticsManager.shared.clearEvents()
            let clearAlert = UIAlertController(title: "Cleared", message: "Debug events have been cleared.", preferredStyle: .alert)
            clearAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(clearAlert, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: - Helper Methods
    private func showGenericSetting(_ setting: String) {
        let alert = UIAlertController(
            title: setting,
            message: "This setting is not implemented yet in the demo.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showNotificationPermissionAlert() {
        let alert = UIAlertController(
            title: "Enable Notifications",
            message: "To receive important updates and reminders, please allow notifications in your device settings.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            AnalyticsManager.shared.trackEvent(.featureUsed, parameters: ["action": "notification_settings_opened"])
            // In a real app, this would open Settings app
        })
        
        alert.addAction(UIAlertAction(title: "Not Now", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showAnalyticsDisabledAlert() {
        let alert = UIAlertController(
            title: "Analytics Disabled",
            message: "Analytics help us improve the app experience. You can re-enable this anytime in settings.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showDetailedPrivacySettings() {
        let alert = UIAlertController(title: "Privacy Settings", message: "Manage your privacy preferences", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Marketing Emails", style: .default) { _ in
            self.userPreferences.marketingEmailsEnabled.toggle()
            self.saveUserPreferences()
            AnalyticsManager.shared.trackEvent(.settingChanged, parameters: [
                "setting": "marketing_emails",
                "enabled": self.userPreferences.marketingEmailsEnabled
            ])
        })
        
        alert.addAction(UIAlertAction(title: "Crash Reporting", style: .default) { _ in
            self.userPreferences.crashReportingEnabled.toggle()
            self.saveUserPreferences()
            AnalyticsManager.shared.trackEvent(.settingChanged, parameters: [
                "setting": "crash_reporting",
                "enabled": self.userPreferences.crashReportingEnabled
            ])
        })
        
        alert.addAction(UIAlertAction(title: "Done", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showSignOutConfirmation() {
        let alert = UIAlertController(
            title: "Sign Out",
            message: "Are you sure you want to sign out? Your data will be saved locally.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { _ in
            // Simulate sign out
            AnalyticsManager.shared.trackEvent(.featureUsed, parameters: ["action": "user_signed_out"])
            let signOutAlert = UIAlertController(title: "Signed Out", message: "You have been signed out successfully.", preferredStyle: .alert)
            signOutAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(signOutAlert, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showSimulatedContact(_ method: String) {
        let alert = UIAlertController(
            title: "\(method) Support",
            message: "In a real app, this would open the \(method.lowercased()) interface. For this demo, contact functionality is simulated.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showRateThankYou() {
        let alert = UIAlertController(
            title: "Thank You! ⭐",
            message: "Thanks for rating Sample App! Your feedback helps us improve.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "You're Welcome!", style: .default))
        present(alert, animated: true)
    }
    
    private func performFullReset() {
        // Clear all user defaults
        let defaults = UserDefaults.standard
        let keys = ["tapCount", "userName", "userEmail", "userLocation", "profileImage", "topics", "userPreferences", "userProgress", "analyticsEvents", "subscriptionTier", "unlockedFeatures"]
        
        for key in keys {
            defaults.removeObject(forKey: key)
        }
        
        // Reset managers
        userPreferences = UserPreferences()
        saveUserPreferences()
        
        AnalyticsManager.shared.trackEvent(.featureUsed, parameters: ["action": "full_reset_performed"])
        AnalyticsManager.shared.clearEvents()
        
        // Show completion
        let alert = UIAlertController(
            title: "✅ Reset Complete",
            message: "All data has been cleared. The app will now restart with default settings.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            // Refresh the interface
            self.tableView.reloadData()
            if let tabBarController = self.tabBarController {
                tabBarController.selectedIndex = 0
            }
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Privacy Protection
    
    private func setupPrivacyProtection() {
        // Configure settings-specific privacy protection
        UXCamPrivacyManager.shared.configureSettingsScreenPrivacy(for: tableView)
        
        // Apply general screen-level protection if needed
        applyUXCamPrivacyProtection()
        
        #if DEBUG
        print("🔒 Settings privacy protection configured")
        #endif
    }
    
    private func applyCellPrivacyProtection(_ cell: UITableViewCell, settingName: String) {
        // Apply privacy protection to specific settings cells
        if UXCamPrivacyManager.shared.shouldOccludeSettingsCell(withTitle: settingName) {
            // For sensitive settings, occlude the detail text which may contain personal info
            if let detailLabel = cell.detailTextLabel {
                UXCam.occludeSensitiveView(detailLabel)
            }
            
            // For account-related settings, occlude the entire cell content area
            if settingName == "Account" {
                UXCam.occludeSensitiveView(cell.contentView)
            }
            
            #if DEBUG
            print("🔒 Settings cell privacy applied: \(settingName)")
            #endif
        }
    }
} 
