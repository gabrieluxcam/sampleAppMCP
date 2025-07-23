import Foundation
import UIKit

// MARK: - Premium Manager
class PremiumManager {
    static let shared = PremiumManager()
    
    private var currentTier: SubscriptionTier
    private var premiumFeatures: [PremiumFeature] = []
    private var trialEndDate: Date?
    
    private init() {
        currentTier = SubscriptionTier(rawValue: UserDefaults.standard.string(forKey: "subscriptionTier") ?? "Free") ?? .free
        setupPremiumFeatures()
        loadTrialStatus()
    }
    
    // MARK: - Setup
    private func setupPremiumFeatures() {
        premiumFeatures = [
            PremiumFeature(id: "remove_ads", title: "Remove Ads", description: "Enjoy an ad-free experience", icon: "🚫", isLocked: currentTier == .free, requiredTier: .basic),
            PremiumFeature(id: "advanced_analytics", title: "Advanced Analytics", description: "Detailed insights and reports", icon: "📊", isLocked: currentTier.rawValue < SubscriptionTier.premium.rawValue, requiredTier: .premium),
            PremiumFeature(id: "offline_mode", title: "Offline Mode", description: "Access content without internet", icon: "📱", isLocked: currentTier.rawValue < SubscriptionTier.premium.rawValue, requiredTier: .premium),
            PremiumFeature(id: "custom_themes", title: "Custom Themes", description: "Personalize your app appearance", icon: "🎨", isLocked: currentTier != .pro, requiredTier: .pro),
            PremiumFeature(id: "export_data", title: "Export Data", description: "Download your data as CSV/JSON", icon: "📁", isLocked: currentTier != .pro, requiredTier: .pro),
            PremiumFeature(id: "priority_support", title: "Priority Support", description: "Get help faster from our team", icon: "🎧", isLocked: currentTier.rawValue < SubscriptionTier.premium.rawValue, requiredTier: .premium),
            PremiumFeature(id: "team_features", title: "Team Features", description: "Collaboration and sharing tools", icon: "👥", isLocked: currentTier != .pro, requiredTier: .pro),
            PremiumFeature(id: "unlimited_topics", title: "Unlimited Topics", description: "Access to all learning content", icon: "♾️", isLocked: currentTier == .free, requiredTier: .basic)
        ]
    }
    
    private func loadTrialStatus() {
        if let trialEndData = UserDefaults.standard.object(forKey: "trialEndDate") as? Date {
            trialEndDate = trialEndData
            
            // Check if trial has expired
            if Date() > trialEndData && currentTier != .free {
                // Trial expired, revert to free
                setSubscriptionTier(.free)
            }
        }
    }
    
    // MARK: - Subscription Management
    func getCurrentTier() -> SubscriptionTier {
        return currentTier
    }
    
    func setSubscriptionTier(_ tier: SubscriptionTier) {
        let previousTier = currentTier
        currentTier = tier
        UserDefaults.standard.set(tier.rawValue, forKey: "subscriptionTier")
        
        // Update feature locks
        setupPremiumFeatures()
        
        // Track the change
        AnalyticsManager.shared.trackEvent(.featureUsed, parameters: [
            "action": "subscription_changed",
            "previous_tier": previousTier.rawValue,
            "new_tier": tier.rawValue,
            "is_trial": isTrialActive()
        ])
        
        // Achievement check
        if tier != .free {
            AchievementManager.shared.updateProgress(for: "premium_user", progress: 1)
        }
        
        // Show upgrade confirmation
        showTierChangeConfirmation(from: previousTier, to: tier)
    }
    
    func startTrial(for tier: SubscriptionTier, duration: TimeInterval = 7 * 24 * 60 * 60) { // 7 days default
        guard currentTier == .free else { return }
        
        trialEndDate = Date().addingTimeInterval(duration)
        UserDefaults.standard.set(trialEndDate, forKey: "trialEndDate")
        
        setSubscriptionTier(tier)
        
        AchievementManager.shared.updateProgress(for: "premium_trial", progress: 1)
        
        AnalyticsManager.shared.trackEvent(.featureUsed, parameters: [
            "action": "trial_started",
            "tier": tier.rawValue,
            "duration_days": duration / (24 * 60 * 60)
        ])
    }
    
    func isTrialActive() -> Bool {
        guard let trialEndDate = trialEndDate else { return false }
        return Date() < trialEndDate
    }
    
    func getTrialTimeRemaining() -> TimeInterval? {
        guard let trialEndDate = trialEndDate, isTrialActive() else { return nil }
        return trialEndDate.timeIntervalSince(Date())
    }
    
    // MARK: - Feature Access
    func isFeatureUnlocked(_ featureId: String) -> Bool {
        guard let feature = premiumFeatures.first(where: { $0.id == featureId }) else { return true }
        return !feature.isLocked
    }
    
    func getPremiumFeatures() -> [PremiumFeature] {
        return premiumFeatures
    }
    
    func getLockedFeatures() -> [PremiumFeature] {
        return premiumFeatures.filter { $0.isLocked }
    }
    
    func getUnlockedFeatures() -> [PremiumFeature] {
        return premiumFeatures.filter { !$0.isLocked }
    }
    
    // MARK: - Purchase Simulation
    func simulatePurchase(_ item: PurchaseItem, completion: @escaping (Bool) -> Void) {
        AnalyticsManager.shared.trackPurchase(item: item, success: false) // Track initiation
        
        // Simulate purchase flow with random delay
        let delay = Double.random(in: 1.0...3.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            
            // 85% success rate for simulation
            let success = Int.random(in: 1...100) <= 85
            
            if success {
                switch item.type {
                case .subscription(let tier):
                    if self.currentTier == .free {
                        self.startTrial(for: tier)
                    } else {
                        self.setSubscriptionTier(tier)
                    }
                case .oneTime(let featureId):
                    self.unlockFeature(featureId)
                case .upgrade(let featureId):
                    self.unlockFeature(featureId)
                }
            } else {
                // Simulate purchase failure
                let error = AppError(
                    id: UUID().uuidString,
                    type: .unknown,
                    message: "Purchase failed. Please try again.",
                    timestamp: Date(),
                    context: ["item_id": item.id, "purchase_type": String(describing: item.type)],
                    userId: AnalyticsManager.shared.getUserProperty("user_id") as? String
                )
                AnalyticsManager.shared.trackError(error)
            }
            
            AnalyticsManager.shared.trackPurchase(item: item, success: success) // Track completion
            completion(success)
        }
    }
    
    private func unlockFeature(_ featureId: String) {
        if let index = premiumFeatures.firstIndex(where: { $0.id == featureId }) {
            premiumFeatures[index] = PremiumFeature(
                id: premiumFeatures[index].id,
                title: premiumFeatures[index].title,
                description: premiumFeatures[index].description,
                icon: premiumFeatures[index].icon,
                isLocked: false,
                requiredTier: premiumFeatures[index].requiredTier
            )
            
            // Save unlocked features
            let unlockedFeatures = premiumFeatures.filter { !$0.isLocked }.map { $0.id }
            UserDefaults.standard.set(unlockedFeatures, forKey: "unlockedFeatures")
        }
    }
    
    // MARK: - UI Helpers
    func showUpgradePrompt(for feature: PremiumFeature, from viewController: UIViewController) {
        let alert = UIAlertController(
            title: "🔒 Premium Feature",
            message: "\(feature.icon) \(feature.title)\n\n\(feature.description)\n\nUpgrade to \(feature.requiredTier.rawValue) to unlock this feature.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Upgrade Now", style: .default) { _ in
            self.showSubscriptionOptions(from: viewController, highlightTier: feature.requiredTier)
        })
        
        alert.addAction(UIAlertAction(title: "Maybe Later", style: .cancel) { _ in
            AnalyticsManager.shared.trackEvent(.featureUsed, parameters: [
                "action": "upgrade_prompt_dismissed",
                "feature_id": feature.id,
                "required_tier": feature.requiredTier.rawValue
            ])
        })
        
        AnalyticsManager.shared.trackEvent(.featureUsed, parameters: [
            "action": "upgrade_prompt_shown",
            "feature_id": feature.id,
            "required_tier": feature.requiredTier.rawValue
        ])
        
        viewController.present(alert, animated: true)
    }
    
    func showSubscriptionOptions(from viewController: UIViewController, highlightTier: SubscriptionTier? = nil) {
        let alert = UIAlertController(title: "🚀 Choose Your Plan", message: "Unlock premium features", preferredStyle: .actionSheet)
        
        for tier in SubscriptionTier.allCases {
            if tier == .free { continue }
            
            let isHighlighted = tier == highlightTier
            let title = isHighlighted ? "⭐ \(tier.rawValue) - \(tier.price) (Recommended)" : "\(tier.rawValue) - \(tier.price)"
            
            alert.addAction(UIAlertAction(title: title, style: isHighlighted ? .destructive : .default) { _ in
                let purchaseItem = PurchaseItem(
                    id: "subscription_\(tier.rawValue.lowercased())",
                    title: "\(tier.rawValue) Subscription",
                    price: tier.price,
                    description: tier.features.joined(separator: ", "),
                    type: .subscription(tier)
                )
                
                self.simulatePurchase(purchaseItem) { success in
                    DispatchQueue.main.async {
                        if success {
                            let successAlert = UIAlertController(
                                title: "🎉 Welcome to \(tier.rawValue)!",
                                message: "Your upgrade was successful. Enjoy your new features!",
                                preferredStyle: .alert
                            )
                            successAlert.addAction(UIAlertAction(title: "Start Exploring", style: .default))
                            viewController.present(successAlert, animated: true)
                        } else {
                            let errorAlert = UIAlertController(
                                title: "Purchase Failed",
                                message: "We couldn't process your purchase. Please try again later.",
                                preferredStyle: .alert
                            )
                            errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                            viewController.present(errorAlert, animated: true)
                        }
                    }
                }
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        AnalyticsManager.shared.trackEvent(.featureUsed, parameters: [
            "action": "subscription_options_shown",
            "current_tier": currentTier.rawValue,
            "highlighted_tier": highlightTier?.rawValue ?? "none"
        ])
        
        viewController.present(alert, animated: true)
    }
    
    private func showTierChangeConfirmation(from previousTier: SubscriptionTier, to newTier: SubscriptionTier) {
        guard previousTier != newTier else { return }
        
        DispatchQueue.main.async {
            let message: String
            if newTier == .free {
                message = "Your subscription has ended. Some features are now locked."
            } else if self.isTrialActive() {
                let daysRemaining = Int((self.getTrialTimeRemaining() ?? 0) / (24 * 60 * 60))
                message = "Your \(newTier.rawValue) trial is active! \(daysRemaining) days remaining."
            } else {
                message = "Welcome to \(newTier.rawValue)! Your new features are now available."
            }
            
            let alert = UIAlertController(
                title: newTier == .free ? "Subscription Changed" : "🎉 Upgrade Successful!",
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                rootViewController.present(alert, animated: true)
            }
        }
    }
}

// MARK: - Daily Challenge Manager
class DailyChallengeManager {
    static let shared = DailyChallengeManager()
    
    private var currentChallenge: DailyChallenge?
    private let challengeTemplates = [
        ("Tap Master", "Reach 25 taps", 25, 10),
        ("Explorer", "Visit 3 different screens", 3, 15),
        ("Social Butterfly", "Update your profile", 1, 20),
        ("Knowledge Seeker", "View 5 topics", 5, 15),
        ("Settings Explorer", "Change 2 settings", 2, 10),
        ("Favorite Finder", "Favorite 3 topics", 3, 12),
        ("Rating Master", "Rate 2 topics", 2, 18),
        ("Search Specialist", "Perform 3 searches", 3, 8)
    ]
    
    private init() {
        loadOrCreateDailyChallenge()
    }
    
    private func loadOrCreateDailyChallenge() {
        // Load saved challenge
        if let data = UserDefaults.standard.data(forKey: "currentDailyChallenge"),
           let challenge = try? JSONDecoder().decode(DailyChallenge.self, from: data) {
            
            // Check if it's still valid (same day)
            if Calendar.current.isDateInToday(challenge.date) {
                currentChallenge = challenge
                return
            }
        }
        
        // Create new challenge for today
        createNewDailyChallenge()
    }
    
    private func createNewDailyChallenge() {
        let template = challengeTemplates.randomElement()!
        let challenge = DailyChallenge(
            id: "daily_\(DateFormatter().string(from: Date()))",
            title: template.0,
            description: template.1,
            targetValue: template.2,
            currentProgress: 0,
            date: Date(),
            rewardPoints: template.3,
            isCompleted: false
        )
        
        currentChallenge = challenge
        saveDailyChallenge()
        
        AnalyticsManager.shared.trackEvent(.featureUsed, parameters: [
            "action": "daily_challenge_created",
            "challenge_id": challenge.id,
            "challenge_type": challenge.title
        ])
    }
    
    func getCurrentChallenge() -> DailyChallenge? {
        return currentChallenge
    }
    
    func updateProgress(for challengeType: String, increment: Int = 1) {
      guard let challenge = currentChallenge,
              !challenge.isCompleted,
              challenge.title.lowercased().contains(challengeType.lowercased()) else { return }
        
        let newProgress = min(challenge.currentProgress + increment, challenge.targetValue)
        
        currentChallenge = DailyChallenge(
            id: challenge.id,
            title: challenge.title,
            description: challenge.description,
            targetValue: challenge.targetValue,
            currentProgress: newProgress,
            date: challenge.date,
            rewardPoints: challenge.rewardPoints,
            isCompleted: newProgress >= challenge.targetValue
        )
        
        if let updatedChallenge = currentChallenge, updatedChallenge.isCompleted && !challenge.isCompleted {
            // Challenge just completed!
            completeDailyChallenge()
        }
        
        saveDailyChallenge()
    }
    
    private func completeDailyChallenge() {
        guard let challenge = currentChallenge else { return }
        
        // Update user progress
        AchievementManager.shared.updateDailyChallengeStreak()
        let currentStreak = AchievementManager.shared.getDailyChallengeStreak()
        
        AnalyticsManager.shared.trackEvent(.featureUsed, parameters: [
            "action": "daily_challenge_completed",
            "challenge_id": challenge.id,
            "challenge_type": challenge.title,
            "reward_points": challenge.rewardPoints,
            "streak": currentStreak
        ])
        
        // Show completion notification
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "🎯 Challenge Complete!",
                message: "🏆 \(challenge.title)\n\nYou earned \(challenge.rewardPoints) points!\nDaily streak: \(currentStreak)",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Awesome!", style: .default))
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                rootViewController.present(alert, animated: true)
            }
        }
    }
    
    private func saveDailyChallenge() {
        guard let challenge = currentChallenge else { return }
        if let data = try? JSONEncoder().encode(challenge) {
            UserDefaults.standard.set(data, forKey: "currentDailyChallenge")
        }
    }
} 
