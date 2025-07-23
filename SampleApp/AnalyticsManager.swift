import Foundation
import UIKit

// MARK: - Analytics Manager
class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private var sessionId: String = UUID().uuidString
    private var userId: String?
    private var events: [AnalyticsEvent] = []
    private var sessionStartTime: Date = Date()
    
    private init() {
        setupSession()
    }
    
    // MARK: - Session Management
    private func setupSession() {
        sessionId = UUID().uuidString
        sessionStartTime = Date()
        userId = UserDefaults.standard.string(forKey: "userId") ?? generateUserId()
        
        // Track session start
        trackEvent(.screenView, parameters: ["session_id": sessionId, "session_start": true])
    }
    
    private func generateUserId() -> String {
        let newUserId = "user_\(UUID().uuidString.prefix(8))"
        UserDefaults.standard.set(newUserId, forKey: "userId")
        return newUserId
    }
    
    // MARK: - Event Tracking
    func trackEvent(_ type: EventType, parameters: [String: Any] = [:]) {
        var enrichedParameters = parameters
        enrichedParameters["timestamp"] = ISO8601DateFormatter().string(from: Date())
        enrichedParameters["user_id"] = userId
        enrichedParameters["session_id"] = sessionId
        enrichedParameters["session_duration"] = Date().timeIntervalSince(sessionStartTime)
        
        let event = AnalyticsEvent(
            name: type.rawValue,
            parameters: enrichedParameters,
            timestamp: Date(),
            userId: userId,
            sessionId: sessionId
        )
        
        events.append(event)
        
        // Simulate real analytics by printing to console
        print("📊 Analytics Event: \(type.rawValue)")
        print("   Parameters: \(enrichedParameters)")
        print("   Session: \(sessionId)")
        print("   ---")
        
        // Save events to UserDefaults for debugging
        saveEventsToStorage()
    }
    
    // MARK: - Screen Tracking
    func trackScreen(_ screenName: String, parameters: [String: Any] = [:]) {
        var screenParameters = parameters
        screenParameters["screen_name"] = screenName
        screenParameters["previous_screen"] = UserDefaults.standard.string(forKey: "lastScreen")
        
        UserDefaults.standard.set(screenName, forKey: "lastScreen")
        trackEvent(.screenView, parameters: screenParameters)
    }
    
    // MARK: - User Properties
    func setUserProperty(_ key: String, value: Any) {
        var userProperties = UserDefaults.standard.dictionary(forKey: "userProperties") ?? [:]
        userProperties[key] = value
        UserDefaults.standard.set(userProperties, forKey: "userProperties")
        
        trackEvent(.featureUsed, parameters: ["action": "user_property_set", "property": key, "value": String(describing: value)])
    }
    
    func getUserProperty(_ key: String) -> Any? {
        let userProperties = UserDefaults.standard.dictionary(forKey: "userProperties") ?? [:]
        return userProperties[key]
    }
    
    // MARK: - Conversion Tracking
    func trackPurchase(item: PurchaseItem, success: Bool) {
        let eventType: EventType = success ? .purchaseCompleted : .purchaseInitiated
        trackEvent(eventType, parameters: [
            "item_id": item.id,
            "item_title": item.title,
            "price": item.price,
            "success": success,
            "purchase_type": String(describing: item.type)
        ])
    }
    
    func trackAchievement(_ achievement: Achievement) {
        trackEvent(.achievementUnlocked, parameters: [
            "achievement_id": achievement.id,
            "achievement_title": achievement.title,
            "category": achievement.category.rawValue,
            "progress": achievement.progress,
            "requirement": achievement.requirement
        ])
    }
    
    // MARK: - Error Tracking
    func trackError(_ error: AppError) {
        trackEvent(.errorOccurred, parameters: [
            "error_id": error.id,
            "error_type": error.type.rawValue,
            "error_message": error.message,
            "context": error.context
        ])
    }
    
    // MARK: - Engagement Metrics
    func trackEngagement(action: String, target: String, value: Any? = nil) {
        var parameters: [String: Any] = [
            "action": action,
            "target": target
        ]
        
        if let value = value {
            parameters["value"] = value
        }
        
        trackEvent(.featureUsed, parameters: parameters)
    }
    
    // MARK: - Debugging & Export
    func getAllEvents() -> [AnalyticsEvent] {
        return events
    }
    
    func getEventsSummary() -> [String: Int] {
        var summary: [String: Int] = [:]
        for event in events {
            summary[event.name, default: 0] += 1
        }
        return summary
    }
    
    func exportEventsToString() -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        var exportData: [[String: Any]] = []
        for event in events {
            var eventDict: [String: Any] = [
                "name": event.name,
                "timestamp": ISO8601DateFormatter().string(from: event.timestamp),
                "user_id": event.userId ?? "unknown",
                "session_id": event.sessionId
            ]
            eventDict.merge(event.parameters) { (_, new) in new }
            exportData.append(eventDict)
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
            return String(data: data, encoding: .utf8) ?? "Export failed"
        } catch {
            return "Export error: \(error.localizedDescription)"
        }
    }
    
    func clearEvents() {
        events.removeAll()
        UserDefaults.standard.removeObject(forKey: "analyticsEvents")
        trackEvent(.featureUsed, parameters: ["action": "events_cleared"])
    }
    
    private func saveEventsToStorage() {
        // Keep only last 100 events to prevent excessive storage
        if events.count > 100 {
            events = Array(events.suffix(100))
        }
        
        // Simple storage - in real app would use more sophisticated approach
        let eventCount = events.count
        UserDefaults.standard.set(eventCount, forKey: "totalEvents")
    }
}

// MARK: - Achievement Manager
class AchievementManager {
    static let shared = AchievementManager()
    
    private var achievements: [Achievement] = []
    private var userProgress: UserProgress
    
    private init() {
        userProgress = Self.loadUserProgress()
        setupAchievements()
        checkForNewAchievements()
    }
    
    private func setupAchievements() {
        achievements = [
            // Tapping achievements
            Achievement(id: "first_tap", title: "First Tap", description: "Tap the button for the first time", icon: "👆", requirement: 1, category: .tapping),
            Achievement(id: "tap_10", title: "Getting Started", description: "Reach 10 taps", icon: "🔥", requirement: 10, category: .tapping),
            Achievement(id: "tap_50", title: "Tap Enthusiast", description: "Reach 50 taps", icon: "⚡", requirement: 50, category: .tapping),
            Achievement(id: "tap_100", title: "Century Club", description: "Reach 100 taps", icon: "💯", requirement: 100, category: .tapping),
            Achievement(id: "tap_500", title: "Tap Master", description: "Reach 500 taps", icon: "🏆", requirement: 500, category: .tapping),
            
            // Social achievements
            Achievement(id: "first_share", title: "Sharing is Caring", description: "Share content for the first time", icon: "📤", requirement: 1, category: .social),
            Achievement(id: "profile_complete", title: "Profile Pro", description: "Complete your profile", icon: "👤", requirement: 1, category: .social),
            Achievement(id: "photo_upload", title: "Picture Perfect", description: "Upload a profile photo", icon: "📸", requirement: 1, category: .social),
            
            // Learning achievements
            Achievement(id: "first_topic", title: "Curious Mind", description: "View your first topic", icon: "🤔", requirement: 1, category: .learning),
            Achievement(id: "topic_5", title: "Knowledge Seeker", description: "Complete 5 topics", icon: "📚", requirement: 5, category: .learning),
            Achievement(id: "topic_10", title: "Study Buddy", description: "Complete 10 topics", icon: "🎓", requirement: 10, category: .learning),
            Achievement(id: "all_topics", title: "Topic Master", description: "Complete all available topics", icon: "🏅", requirement: 15, category: .learning),
            
            // Engagement achievements
            Achievement(id: "daily_streak_3", title: "Committed", description: "Use the app 3 days in a row", icon: "📅", requirement: 3, category: .engagement),
            Achievement(id: "daily_streak_7", title: "Weekly Warrior", description: "Use the app 7 days in a row", icon: "🗓️", requirement: 7, category: .engagement),
            Achievement(id: "settings_explorer", title: "Settings Explorer", description: "Visit the settings screen", icon: "⚙️", requirement: 1, category: .engagement),
            
            // Premium achievements
            Achievement(id: "premium_trial", title: "Trial Run", description: "Start a premium trial", icon: "⭐", requirement: 1, category: .premium),
            Achievement(id: "premium_user", title: "Premium Member", description: "Upgrade to premium", icon: "👑", requirement: 1, category: .premium)
        ]
        
        // Load achievement progress
        loadAchievementProgress()
    }
    
    func updateProgress(for achievementId: String, progress: Int) {
        guard let index = achievements.firstIndex(where: { $0.id == achievementId }) else { return }
        
        achievements[index].progress = max(achievements[index].progress, progress)
        
        if achievements[index].progress >= achievements[index].requirement && !achievements[index].isUnlocked {
            unlockAchievement(achievementId)
        }
        
        saveAchievementProgress()
    }
    
    func unlockAchievement(_ achievementId: String) {
        guard let index = achievements.firstIndex(where: { $0.id == achievementId }),
              !achievements[index].isUnlocked else { return }
        
        achievements[index].isUnlocked = true
        userProgress.achievementsUnlocked.append(achievementId)
        
        AnalyticsManager.shared.trackAchievement(achievements[index])
        saveAchievementProgress()
        saveUserProgress()
        
        // Show achievement notification
        showAchievementNotification(achievements[index])
    }
    
    private func showAchievementNotification(_ achievement: Achievement) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "🎉 Achievement Unlocked!",
                message: "\(achievement.icon) \(achievement.title)\n\n\(achievement.description)",
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
    
    func getAchievements() -> [Achievement] {
        return achievements
    }
    
    func getAchievements(for category: AchievementCategory) -> [Achievement] {
        return achievements.filter { $0.category == category }
    }
    
    func getUnlockedAchievements() -> [Achievement] {
        return achievements.filter { $0.isUnlocked }
    }
    
    func checkForNewAchievements() {
        // Check tap count achievements
        let tapCount = UserDefaults.standard.integer(forKey: "tapCount")
        updateProgress(for: "first_tap", progress: tapCount > 0 ? 1 : 0)
        updateProgress(for: "tap_10", progress: tapCount)
        updateProgress(for: "tap_50", progress: tapCount)
        updateProgress(for: "tap_100", progress: tapCount)
        updateProgress(for: "tap_500", progress: tapCount)
        
        // Check profile achievements
        let hasName = !(UserDefaults.standard.string(forKey: "userName")?.isEmpty ?? true)
        let hasEmail = !(UserDefaults.standard.string(forKey: "userEmail")?.isEmpty ?? true)
        let hasLocation = !(UserDefaults.standard.string(forKey: "userLocation")?.isEmpty ?? true)
        let hasPhoto = UserDefaults.standard.data(forKey: "profileImage") != nil
        
        if hasName && hasEmail && hasLocation {
            updateProgress(for: "profile_complete", progress: 1)
        }
        
        if hasPhoto {
            updateProgress(for: "photo_upload", progress: 1)
        }
        
        // Check topic achievements
        let completedTopics = userProgress.completedTopics.count
        updateProgress(for: "first_topic", progress: completedTopics > 0 ? 1 : 0)
        updateProgress(for: "topic_5", progress: completedTopics)
        updateProgress(for: "topic_10", progress: completedTopics)
        updateProgress(for: "all_topics", progress: completedTopics)
        
        // Check streak achievements
        updateProgress(for: "daily_streak_3", progress: userProgress.currentStreak)
        updateProgress(for: "daily_streak_7", progress: userProgress.currentStreak)
    }
    
    private static func loadUserProgress() -> UserProgress {
        if let data = UserDefaults.standard.data(forKey: "userProgress"),
           let progress = try? JSONDecoder().decode(UserProgress.self, from: data) {
            return progress
        }
        return UserProgress()
    }
    
    private func saveUserProgress() {
        if let data = try? JSONEncoder().encode(userProgress) {
            UserDefaults.standard.set(data, forKey: "userProgress")
        }
    }
    
    private func loadAchievementProgress() {
        let unlockedIds = userProgress.achievementsUnlocked
        for i in 0..<achievements.count {
            if unlockedIds.contains(achievements[i].id) {
                achievements[i].isUnlocked = true
                achievements[i].progress = achievements[i].requirement
            }
        }
    }
    
    private func saveAchievementProgress() {
        // Achievement progress is saved as part of user progress
        saveUserProgress()
    }
    
    // MARK: - Public User Progress Access
    func getUserProgress() -> UserProgress {
        return userProgress
    }
    
    func updateDailyChallengeStreak() {
        userProgress.dailyChallengeStreak += 1
        userProgress.lastDailyChallengeDate = Date()
        saveUserProgress()
    }
    
    func getDailyChallengeStreak() -> Int {
        return userProgress.dailyChallengeStreak
    }
}

// MARK: - Network Simulation Manager
class NetworkManager {
    static let shared = NetworkManager()
    
    private var isNetworkAvailable: Bool = true
    private var simulatedLatency: TimeInterval = 0.5
    
    private init() {}
    
    func setNetworkAvailable(_ available: Bool) {
        isNetworkAvailable = available
        AnalyticsManager.shared.trackEvent(.featureUsed, parameters: ["action": "network_simulation", "available": available])
    }
    
    func setSimulatedLatency(_ latency: TimeInterval) {
        simulatedLatency = latency
    }
    
    func simulateAPICall<T>(
        endpoint: String,
        responseData: T,
        completion: @escaping (Result<T, AppError>) -> Void
    ) {
        AnalyticsManager.shared.trackEvent(.featureUsed, parameters: ["action": "api_call", "endpoint": endpoint])
        
        DispatchQueue.global().asyncAfter(deadline: .now() + simulatedLatency) {
            if self.isNetworkAvailable && Int.random(in: 1...10) > 2 { // 80% success rate
                DispatchQueue.main.async {
                    completion(.success(responseData))
                }
            } else {
                let error = AppError(
                    id: UUID().uuidString,
                    type: .network,
                    message: self.isNetworkAvailable ? "Request timeout" : "No internet connection",
                    timestamp: Date(),
                    context: ["endpoint": endpoint],
                    userId: AnalyticsManager.shared.getUserProperty("user_id") as? String
                )
                
                AnalyticsManager.shared.trackError(error)
                
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
} 