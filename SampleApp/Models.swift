import Foundation
import UIKit

// MARK: - Achievement System
struct Achievement: Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let requirement: Int
    let category: AchievementCategory
    var isUnlocked: Bool = false
    var progress: Int = 0
    
    var progressPercentage: Double {
        return min(Double(progress) / Double(requirement), 1.0) * 100
    }
}

enum AchievementCategory: String, CaseIterable, Codable {
    case tapping = "Tapping Master"
    case social = "Social Butterfly" 
    case learning = "Knowledge Seeker"
    case engagement = "App Explorer"
    case premium = "Premium User"
}

// MARK: - User Progress Tracking
struct UserProgress: Codable {
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastVisitDate: Date?
    var totalSessions: Int = 0
    var totalTimeSpent: TimeInterval = 0
    var achievementsUnlocked: [String] = []
    var favoriteTopics: [String] = []
    var completedTopics: [String] = []
    var topicRatings: [String: Int] = [:]
    var dailyChallengeStreak: Int = 0
    var lastDailyChallengeDate: Date?
}

// MARK: - E-commerce Models
struct PremiumFeature {
    let id: String
    let title: String
    let description: String
    let icon: String
    let isLocked: Bool
    let requiredTier: SubscriptionTier
}

enum SubscriptionTier: String, CaseIterable, Codable {
    case free = "Free"
    case basic = "Basic"
    case premium = "Premium"
    case pro = "Pro"
    
    var price: String {
        switch self {
        case .free: return "Free"
        case .basic: return "$2.99/month"
        case .premium: return "$5.99/month" 
        case .pro: return "$9.99/month"
        }
    }
    
    var features: [String] {
        switch self {
        case .free: return ["Basic features", "Limited topics", "Ads included"]
        case .basic: return ["Ad-free experience", "All topics", "Basic analytics"]
        case .premium: return ["Everything in Basic", "Advanced analytics", "Priority support", "Offline mode"]
        case .pro: return ["Everything in Premium", "Custom themes", "Export data", "Team features"]
        }
    }
}

struct PurchaseItem {
    let id: String
    let title: String
    let price: String
    let description: String
    let type: PurchaseType
}

enum PurchaseType {
    case subscription(SubscriptionTier)
    case oneTime(String)
    case upgrade(String)
}

// MARK: - Analytics Models
struct AnalyticsEvent {
    let name: String
    let parameters: [String: Any]
    let timestamp: Date
    let userId: String?
    let sessionId: String
}

enum EventType: String {
    case screenView = "screen_view"
    case buttonTap = "button_tap"
    case featureUsed = "feature_used"
    case purchaseInitiated = "purchase_initiated"
    case purchaseCompleted = "purchase_completed"
    case achievementUnlocked = "achievement_unlocked"
    case errorOccurred = "error_occurred"
    case settingChanged = "setting_changed"
    case contentShared = "content_shared"
    case searchPerformed = "search_performed"
    case itemFavorited = "item_favorited"
    case ratingGiven = "rating_given"
    case profileUpdated = "profile_updated"
}

// MARK: - Topic Models
struct Topic: Codable {
    let id: String
    var title: String
    let category: TopicCategory
    var isFavorite: Bool = false
    var isCompleted: Bool = false
    var rating: Int? = nil
    var progressPercentage: Double = 0.0
    var estimatedTime: String = "5 min"
    var difficulty: Difficulty = .beginner
    
    enum Difficulty: String, CaseIterable, Codable {
        case beginner = "Beginner"
        case intermediate = "Intermediate" 
        case advanced = "Advanced"
        case expert = "Expert"
    }
    
    enum TopicCategory: String, CaseIterable, Codable {
        case development = "Development"
        case design = "Design"
        case testing = "Testing"
        case deployment = "Deployment"
        case architecture = "Architecture"
    }
}

// MARK: - User Preferences
struct UserPreferences: Codable {
    var notificationsEnabled: Bool = true
    var marketingEmailsEnabled: Bool = false
    var analyticsEnabled: Bool = true
    var crashReportingEnabled: Bool = true
    var autoSyncEnabled: Bool = true
    var darkModePreference: UIUserInterfaceStyle = .unspecified
    var fontSize: FontSize = .medium
    var hapticFeedbackEnabled: Bool = true
    var soundEffectsEnabled: Bool = true
    var dataUsageOptimized: Bool = false
    
    enum FontSize: String, CaseIterable, Codable {
        case small = "Small"
        case medium = "Medium"
        case large = "Large"
        case extraLarge = "Extra Large"
    }
    
    // Custom Codable implementation to handle UIUserInterfaceStyle
    private enum CodingKeys: String, CodingKey {
        case notificationsEnabled
        case marketingEmailsEnabled
        case analyticsEnabled
        case crashReportingEnabled
        case autoSyncEnabled
        case darkModePreference
        case fontSize
        case hapticFeedbackEnabled
        case soundEffectsEnabled
        case dataUsageOptimized
    }
    
    init() {}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        notificationsEnabled = try container.decodeIfPresent(Bool.self, forKey: .notificationsEnabled) ?? true
        marketingEmailsEnabled = try container.decodeIfPresent(Bool.self, forKey: .marketingEmailsEnabled) ?? false
        analyticsEnabled = try container.decodeIfPresent(Bool.self, forKey: .analyticsEnabled) ?? true
        crashReportingEnabled = try container.decodeIfPresent(Bool.self, forKey: .crashReportingEnabled) ?? true
        autoSyncEnabled = try container.decodeIfPresent(Bool.self, forKey: .autoSyncEnabled) ?? true
        fontSize = try container.decodeIfPresent(FontSize.self, forKey: .fontSize) ?? .medium
        hapticFeedbackEnabled = try container.decodeIfPresent(Bool.self, forKey: .hapticFeedbackEnabled) ?? true
        soundEffectsEnabled = try container.decodeIfPresent(Bool.self, forKey: .soundEffectsEnabled) ?? true
        dataUsageOptimized = try container.decodeIfPresent(Bool.self, forKey: .dataUsageOptimized) ?? false
        
        // Handle UIUserInterfaceStyle manually
        if let darkModeRawValue = try container.decodeIfPresent(Int.self, forKey: .darkModePreference) {
            darkModePreference = UIUserInterfaceStyle(rawValue: darkModeRawValue) ?? .unspecified
        } else {
            darkModePreference = .unspecified
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(notificationsEnabled, forKey: .notificationsEnabled)
        try container.encode(marketingEmailsEnabled, forKey: .marketingEmailsEnabled)
        try container.encode(analyticsEnabled, forKey: .analyticsEnabled)
        try container.encode(crashReportingEnabled, forKey: .crashReportingEnabled)
        try container.encode(autoSyncEnabled, forKey: .autoSyncEnabled)
        try container.encode(darkModePreference.rawValue, forKey: .darkModePreference)
        try container.encode(fontSize, forKey: .fontSize)
        try container.encode(hapticFeedbackEnabled, forKey: .hapticFeedbackEnabled)
        try container.encode(soundEffectsEnabled, forKey: .soundEffectsEnabled)
        try container.encode(dataUsageOptimized, forKey: .dataUsageOptimized)
    }
}

// MARK: - Error Models
struct AppError: Error, Codable {
    let id: String
    let type: ErrorType
    let message: String
    let timestamp: Date
    let context: [String: String] // Changed from [String: Any] to [String: String] for Codable
    let userId: String?
    
    enum ErrorType: String, Codable {
        case network = "network_error"
        case validation = "validation_error"
        case permission = "permission_error"
        case storage = "storage_error"
        case unknown = "unknown_error"
    }
    
    // Convenience initializer for backward compatibility
    init(id: String, type: ErrorType, message: String, timestamp: Date, context: [String: Any], userId: String?) {
        self.id = id
        self.type = type
        self.message = message
        self.timestamp = timestamp
        self.context = context.compactMapValues { "\($0)" } // Convert Any to String
        self.userId = userId
    }
}

// MARK: - Daily Challenge
struct DailyChallenge: Codable {
    let id: String
    let title: String
    let description: String
    let targetValue: Int
    let currentProgress: Int
    let date: Date
    let rewardPoints: Int
    let isCompleted: Bool
    
    var progressPercentage: Double {
        return min(Double(currentProgress) / Double(targetValue), 1.0) * 100
    }
} 