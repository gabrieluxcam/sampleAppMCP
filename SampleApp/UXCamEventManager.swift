import UIKit
import UXCam

/// Strategic UXCam event tracking manager focused on business-critical user interactions
/// Works alongside existing AnalyticsManager to provide UXCam-specific insights
class UXCamEventManager {
    static let shared = UXCamEventManager()
    
    private init() {}
    
    // MARK: - Event Names Constants
    
    struct EventNames {
        // Conversion Events (Highest Priority)
        static let premiumUpgradeStarted = "Premium_Upgrade_Started"
        static let premiumUpgradeCompleted = "Premium_Upgrade_Completed"
        static let premiumFeatureGated = "Premium_Feature_Gated"
        static let trialStarted = "Trial_Started"
        static let purchaseFailed = "Purchase_Failed"
        
        // Feature Adoption (High Priority)
        static let milestoneReached = "Milestone_Reached"
        static let achievementUnlocked = "Achievement_Unlocked"
        static let topicCompleted = "Topic_Completed"
        static let dailyChallengeCompleted = "Daily_Challenge_Completed"
        static let featureDiscovered = "Feature_Discovered"
        
        // Engagement (Medium Priority)
        static let contentShared = "Content_Shared"
        static let profileCustomized = "Profile_Customized"
        static let searchPerformed = "Search_Performed"
        static let deepEngagement = "Deep_Engagement"
        
        // Friction Points (High Priority)
        static let errorEncountered = "Error_Encountered"
        static let helpRequested = "Help_Requested"
        static let retryAttempted = "Retry_Attempted"
        
        // Funnel Milestones
        static let onboardingCompleted = "Onboarding_Completed"
        static let firstValueReceived = "First_Value_Received"
        static let habitFormed = "Habit_Formed"
    }
    
    // MARK: - Conversion Events
    
    func trackPremiumUpgradeStarted(
        tier: String,
        triggerSource: String,
        userContext: [String: Any] = [:]
    ) {
        var properties = userContext
        properties["subscription_tier"] = tier
        properties["trigger_source"] = triggerSource
        properties["user_tier_current"] = getCurrentUserTier()
        properties["tap_count"] = getCurrentTapCount()
        properties["days_since_install"] = getDaysSinceInstall()
        properties["conversion_funnel_step"] = "upgrade_initiated"
        
        UXCam.logEvent(EventNames.premiumUpgradeStarted, withProperties: properties)
        
        #if DEBUG
        print("🎯 Conversion Event: Premium upgrade started from \(triggerSource)")
        #endif
    }
    
    func trackPremiumUpgradeCompleted(
        tier: String,
        paymentMethod: String,
        isTrial: Bool,
        conversionTime: TimeInterval
    ) {
        let properties: [String: Any] = [
            "subscription_tier": tier,
            "payment_method": paymentMethod,
            "is_trial": isTrial ? "true" : "false",
            "conversion_time_seconds": Int(conversionTime),
            "conversion_funnel_step": "subscription_success",
            "user_lifetime_value": calculateLifetimeValue(tier: tier)
        ]
        
        UXCam.logEvent(EventNames.premiumUpgradeCompleted, withProperties: properties)
        
        #if DEBUG
        print("🎉 Conversion Success: Premium upgrade completed - \(tier)")
        #endif
    }
    
    func trackPremiumFeatureGated(
        featureId: String,
        userIntent: String,
        gateResponse: String
    ) {
        let properties: [String: Any] = [
            "blocked_feature": featureId,
            "user_intent": userIntent,
            "gate_response": gateResponse,
            "user_tier": getCurrentUserTier(),
            "conversion_opportunity": "high"
        ]
        
        UXCam.logEvent(EventNames.premiumFeatureGated, withProperties: properties)
        
        #if DEBUG
        print("🚪 Feature Gate: \(featureId) - \(gateResponse)")
        #endif
    }
    
    func trackPurchaseFailed(
        tier: String,
        failureReason: String,
        retryAvailable: Bool
    ) {
        let properties: [String: Any] = [
            "attempted_tier": tier,
            "failure_reason": failureReason,
            "retry_available": retryAvailable ? "true" : "false",
            "conversion_friction": "payment_failure",
            "user_frustration_level": calculateFrustrationLevel()
        ]
        
        UXCam.logEvent(EventNames.purchaseFailed, withProperties: properties)
        
        #if DEBUG
        print("❌ Purchase Failed: \(tier) - \(failureReason)")
        #endif
    }
    
    // MARK: - Feature Adoption Events
    
    func trackMilestoneReached(
        milestoneValue: Int,
        milestoneType: String,
        celebrationShown: Bool,
        timeToMilestone: TimeInterval
    ) {
        let properties: [String: Any] = [
            "milestone_value": milestoneValue,
            "milestone_type": milestoneType,
            "celebration_shown": celebrationShown ? "true" : "false",
            "time_to_milestone_seconds": Int(timeToMilestone),
            "engagement_indicator": "high",
            "milestone_rarity": calculateMilestoneRarity(milestoneValue)
        ]
        
        UXCam.logEvent(EventNames.milestoneReached, withProperties: properties)
        
        #if DEBUG
        print("🏆 Milestone: \(milestoneValue) \(milestoneType)")
        #endif
    }
    
    func trackAchievementUnlocked(
        achievementId: String,
        category: String,
        totalUnlocked: Int,
        rarityLevel: String
    ) {
        let properties: [String: Any] = [
            "achievement_id": achievementId,
            "achievement_category": category,
            "total_achievements_unlocked": totalUnlocked,
            "achievement_rarity": rarityLevel,
            "gamification_success": "true",
            "user_engagement": "high"
        ]
        
        UXCam.logEvent(EventNames.achievementUnlocked, withProperties: properties)
        
        #if DEBUG
        print("🏅 Achievement: \(achievementId) (\(rarityLevel))")
        #endif
    }
    
    func trackTopicCompleted(
        topicId: String,
        category: String,
        completionTime: TimeInterval,
        userRating: Int?
    ) {
        let properties: [String: Any] = [
            "topic_id": topicId,
            "topic_category": category,
            "completion_time_seconds": Int(completionTime),
            "user_rating": userRating ?? 0,
            "learning_engagement": "completed",
            "content_effectiveness": userRating ?? 0 > 3 ? "high" : "medium"
        ]
        
        UXCam.logEvent(EventNames.topicCompleted, withProperties: properties)
        
        #if DEBUG
        print("📚 Topic Completed: \(topicId) - Rating: \(userRating ?? 0)")
        #endif
    }
    
    func trackFeatureDiscovered(
        featureName: String,
        discoveryMethod: String,
        timeToDiscovery: TimeInterval
    ) {
        let properties: [String: Any] = [
            "discovered_feature": featureName,
            "discovery_method": discoveryMethod,
            "time_to_discovery_seconds": Int(timeToDiscovery),
            "feature_adoption": "initial",
            "user_curiosity": discoveryMethod == "exploration" ? "high" : "medium"
        ]
        
        UXCam.logEvent(EventNames.featureDiscovered, withProperties: properties)
        
        #if DEBUG
        print("🔍 Feature Discovered: \(featureName) via \(discoveryMethod)")
        #endif
    }
    
    // MARK: - Engagement Events
    
    func trackDeepEngagement(
        sessionDuration: TimeInterval,
        featuresUsed: Int,
        engagementScore: Double
    ) {
        let properties: [String: Any] = [
            "session_duration_seconds": Int(sessionDuration),
            "features_used_count": featuresUsed,
            "engagement_score": engagementScore,
            "engagement_level": engagementScore > 0.7 ? "high" : "medium",
            "retention_likelihood": predictReturnLikelihood(engagementScore: engagementScore)
        ]
        
        UXCam.logEvent(EventNames.deepEngagement, withProperties: properties)
        
        #if DEBUG
        print("💎 Deep Engagement: Score \(engagementScore) - \(featuresUsed) features")
        #endif
    }
    
    func trackContentShared(
        contentType: String,
        shareChannel: String,
        contentValue: [String: Any] = [:]
    ) {
        var properties = contentValue
        properties["content_type"] = contentType
        properties["share_channel"] = shareChannel
        properties["viral_potential"] = calculateViralPotential(contentType: contentType)
        properties["user_advocacy"] = "high"
        
        UXCam.logEvent(EventNames.contentShared, withProperties: properties)
        
        #if DEBUG
        print("🚀 Content Shared: \(contentType) via \(shareChannel)")
        #endif
    }
    
    // MARK: - Friction & Error Events
    
    func trackErrorEncountered(
        errorType: String,
        errorContext: String,
        recoveryAvailable: Bool,
        userImpact: String
    ) {
        let properties: [String: Any] = [
            "error_type": errorType,
            "error_context": errorContext,
            "recovery_available": recoveryAvailable ? "true" : "false",
            "user_impact": userImpact,
            "friction_point": "true",
            "improvement_opportunity": "high"
        ]
        
        UXCam.logEvent(EventNames.errorEncountered, withProperties: properties)
        
        #if DEBUG
        print("⚠️ Error: \(errorType) in \(errorContext)")
        #endif
    }
    
    func trackHelpRequested(
        helpType: String,
        userContext: String,
        frustrationLevel: String
    ) {
        let properties: [String: Any] = [
            "help_type": helpType,
            "user_context": userContext,
            "frustration_level": frustrationLevel,
            "ux_friction": "help_needed",
            "improvement_signal": "true"
        ]
        
        UXCam.logEvent(EventNames.helpRequested, withProperties: properties)
        
        #if DEBUG
        print("❓ Help Requested: \(helpType) - Frustration: \(frustrationLevel)")
        #endif
    }
    
    // MARK: - Funnel Milestone Events
    
    func trackOnboardingCompleted(
        completionTime: TimeInterval,
        stepsCompleted: Int,
        dropOffPoints: [String]
    ) {
        let properties: [String: Any] = [
            "completion_time_seconds": Int(completionTime),
            "steps_completed": stepsCompleted,
            "drop_off_points": dropOffPoints.joined(separator: ","),
            "onboarding_success": "true",
            "user_activation": "completed"
        ]
        
        UXCam.logEvent(EventNames.onboardingCompleted, withProperties: properties)
        
        #if DEBUG
        print("✅ Onboarding Completed: \(stepsCompleted) steps in \(Int(completionTime))s")
        #endif
    }
    
    func trackFirstValueReceived(
        valueType: String,
        timeToValue: TimeInterval,
        valueContext: [String: Any] = [:]
    ) {
        var properties = valueContext
        properties["value_type"] = valueType
        properties["time_to_value_seconds"] = Int(timeToValue)
        properties["user_activation"] = "first_value"
        properties["retention_signal"] = "positive"
        
        UXCam.logEvent(EventNames.firstValueReceived, withProperties: properties)
        
        #if DEBUG
        print("💰 First Value: \(valueType) in \(Int(timeToValue))s")
        #endif
    }
    
    func trackHabitFormed(
        habitType: String,
        streakLength: Int,
        consistencyScore: Double
    ) {
        let properties: [String: Any] = [
            "habit_type": habitType,
            "streak_length": streakLength,
            "consistency_score": consistencyScore,
            "user_retention": "high",
            "habit_strength": consistencyScore > 0.8 ? "strong" : "forming"
        ]
        
        UXCam.logEvent(EventNames.habitFormed, withProperties: properties)
        
        #if DEBUG
        print("🔄 Habit Formed: \(habitType) - \(streakLength) day streak")
        #endif
    }
    
    // MARK: - Helper Methods
    
    private func getCurrentUserTier() -> String {
        // Integration with existing PremiumManager
        return "free" // Replace with actual tier from PremiumManager
    }
    
    private func getCurrentTapCount() -> Int {
        return UserDefaults.standard.integer(forKey: "tapCount")
    }
    
    private func getDaysSinceInstall() -> Int {
        // Calculate days since first app launch
        let installDate = UserDefaults.standard.object(forKey: "firstLaunchDate") as? Date ?? Date()
        return Calendar.current.dateComponents([.day], from: installDate, to: Date()).day ?? 0
    }
    
    private func calculateLifetimeValue(tier: String) -> String {
        // Calculate estimated LTV based on tier
        switch tier {
        case "premium": return "high"
        case "basic": return "medium"
        default: return "low"
        }
    }
    
    private func calculateFrustrationLevel() -> String {
        // Analyze user interaction patterns to estimate frustration
        let recentErrors = 0 // Get from analytics
        return recentErrors > 3 ? "high" : "medium"
    }
    
    private func calculateMilestoneRarity(_ value: Int) -> String {
        switch value {
        case 0..<10: return "common"
        case 10..<100: return "uncommon"
        case 100..<1000: return "rare"
        default: return "legendary"
        }
    }
    
    private func calculateViralPotential(contentType: String) -> String {
        // Assess viral potential based on content type and sharing patterns
        switch contentType {
        case "milestone_achievement": return "high"
        case "user_profile": return "medium"
        default: return "low"
        }
    }
    
    private func predictReturnLikelihood(engagementScore: Double) -> String {
        return engagementScore > 0.7 ? "high" : engagementScore > 0.4 ? "medium" : "low"
    }
    
    // MARK: - Event Validation
    
    #if DEBUG
    func validateEventProperties(_ properties: [String: Any], for eventName: String) {
        // Validate event structure
        if properties.count > 20 {
            print("⚠️ Event '\(eventName)' has \(properties.count) properties (max: 20)")
        }
        
        // Check for PII
        let piiKeys = ["email", "name", "phone", "address"]
        for key in properties.keys {
            if piiKeys.contains(where: { key.lowercased().contains($0) }) {
                print("🚨 Potential PII in event '\(eventName)' property: \(key)")
            }
        }
        
        // Verify property types
        for (key, value) in properties {
            if !(value is String) && !(value is NSNumber) {
                print("⚠️ Invalid property type in '\(eventName)'.\(key): \(type(of: value))")
            }
        }
    }
    #endif
}

// MARK: - Extension for Easy Integration

extension UXCamEventManager {
    
    /// Quick conversion tracking for premium features
    func trackConversionFunnel(step: String, context: [String: Any] = [:]) {
        var properties = context
        properties["funnel_step"] = step
        properties["conversion_timestamp"] = Date().timeIntervalSince1970
        
        UXCam.logEvent("Conversion_Funnel_\(step)", withProperties: properties)
    }
    
    /// Track feature usage with automatic context
    func trackFeatureUsage(feature: String, success: Bool, context: [String: Any] = [:]) {
        var properties = context
        properties["feature_name"] = feature
        properties["usage_result"] = success ? "success" : "failure"
        properties["user_tier"] = getCurrentUserTier()
        
        UXCam.logEvent("Feature_Usage", withProperties: properties)
    }
    
    /// Track user satisfaction signals
    func trackSatisfactionSignal(signal: String, intensity: String, context: [String: Any] = [:]) {
        var properties = context
        properties["satisfaction_signal"] = signal
        properties["signal_intensity"] = intensity
        properties["user_sentiment"] = intensity == "high" ? "positive" : "neutral"
        
        UXCam.logEvent("User_Satisfaction", withProperties: properties)
    }
}