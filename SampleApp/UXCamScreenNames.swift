import Foundation
import UXCam

/// Screen name constants for UXCam analytics
/// These names are used consistently across the app for screen tagging
struct UXCamScreenNames {
    // Main screens
    static let home = "Home"
    static let userProfile = "UserProfile"
    static let topicsList = "TopicsList"
    static let settings = "Settings"
    
    // Additional screens (for future use)
    static let achievementDetail = "AchievementDetail"
    static let premiumUpgrade = "PremiumUpgrade"
    static let helpSupport = "HelpSupport"
    
    // Screen name validation helper
    static func validateScreenName(_ screenName: String) -> Bool {
        #if DEBUG
        if screenName.contains("Controller") || screenName.contains("ViewController") {
            print("⚠️ UXCam Warning: Screen name contains technical terms: \(screenName)")
            return false
        }
        
        if screenName.count > 50 {
            print("⚠️ UXCam Warning: Screen name too long: \(screenName)")
            return false
        }
        
        // Check for consistent PascalCase
        let hasConsistentCasing = screenName.range(of: "^[A-Z][a-zA-Z0-9_]*$", options: .regularExpression) != nil
        if !hasConsistentCasing {
            print("⚠️ UXCam Warning: Screen name doesn't follow PascalCase: \(screenName)")
            return false
        }
        #endif
        
        return true
    }
    
    /// Safe screen tagging with validation
    static func tagScreen(_ screenName: String) {
        #if DEBUG
        validateScreenName(screenName)
        print("📱 UXCam: Tagged screen '\(screenName)'")
        #endif
        
        UXCam.tagScreenName(screenName)
    }
}