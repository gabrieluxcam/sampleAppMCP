import UIKit
import UXCam

/// Centralized privacy protection manager for UXCam integration
/// Provides granular control over sensitive data occlusion while maximizing screen visibility
class UXCamPrivacyManager {
    static let shared = UXCamPrivacyManager()
    
    private init() {}
    
    // MARK: - Privacy Levels
    
    enum PrivacyLevel {
        case maximum    // Hide all personal data
        case standard   // Hide critical data only
        case minimal    // Hide passwords and financial data only
        case off        // No additional occlusion (automatic only)
    }
    
    private var currentPrivacyLevel: PrivacyLevel = .standard
    
    // MARK: - Configuration
    
    func configurePrivacyLevel(_ level: PrivacyLevel) {
        currentPrivacyLevel = level
        
        #if DEBUG
        print("🔒 UXCam Privacy Level set to: \(level)")
        #endif
    }
    
    // MARK: - View-Level Occlusion
    
    /// Occlude critical personal information (always hidden regardless of privacy level)
    func occludeCriticalViews(_ views: [UIView]) {
        views.forEach { view in
            UXCam.occludeSensitiveView(view)
            #if DEBUG
            print("🔒 Critical view occluded: \(type(of: view))")
            #endif
        }
    }
    
    /// Occlude personal information based on current privacy level
    func occluePersonalViews(_ views: [UIView]) {
        guard shouldOccludePersonalData() else { return }
        
        views.forEach { view in
            UXCam.occludeSensitiveView(view)
            #if DEBUG
            print("🔒 Personal view occluded: \(type(of: view))")
            #endif
        }
    }
    
    /// Occlude user-generated content conditionally
    func occlueUserGeneratedViews(_ views: [UIView]) {
        guard shouldOccludeUserGeneratedData() else { return }
        
        views.forEach { view in
            UXCam.occludeSensitiveView(view)
            #if DEBUG
            print("🔒 User-generated view occluded: \(type(of: view))")
            #endif
        }
    }
    
    // MARK: - Profile Screen Privacy
    
    func configureProfileScreenPrivacy(
        profileImage: UIImageView,
        nameLabel: UILabel,
        emailLabel: UILabel,
        personalInfoViews: [UIView] = []
    ) {
        // Always occlude email (critical)
        occludeCriticalViews([emailLabel])
        
        // Conditionally occlude personal data
        var personalViews = [nameLabel] + personalInfoViews
        
        // Profile image is considered personal data
        if shouldOccludePersonalData() {
            personalViews.append(profileImage)
        }
        
        occluePersonalViews(personalViews)
    }
    
    // MARK: - Settings Screen Privacy
    
    func configureSettingsScreenPrivacy(for tableView: UITableView) {
        // Settings screens may contain account info - apply general protection
        // Individual cells will be handled based on content
        
        #if DEBUG
        print("🔒 Settings screen privacy configured")
        #endif
    }
    
    func shouldOccludeSettingsCell(withTitle title: String) -> Bool {
        let criticalSettings = [
            "Account",
            "Export Data", 
            "Debug Info",
            "Privacy & Security"
        ]
        
        return criticalSettings.contains(title) || shouldOccludePersonalData()
    }
    
    // MARK: - List Screen Privacy
    
    func configureListScreenPrivacy(searchBar: UISearchBar?, customTopicCells: [UITableViewCell] = []) {
        // Only occlude user-generated content if privacy level requires it
        guard shouldOccludeUserGeneratedData() else { return }
        
        // Occlude search bar content
        if let searchBar = searchBar {
            UXCam.occludeSensitiveView(searchBar)
        }
        
        // Occlude custom topic cells
        customTopicCells.forEach { cell in
            UXCam.occludeSensitiveView(cell)
        }
    }
    
    // MARK: - Dynamic Content Occlusion
    
    func shouldOccludeTextInput(_ textField: UITextField) -> Bool {
        guard let placeholder = textField.placeholder?.lowercased() else { return false }
        
        // Critical keywords that should always be occluded
        let criticalKeywords = [
            "email", "password", "ssn", "social", "credit", "card", 
            "bank", "account", "phone", "address"
        ]
        
        // Personal keywords based on privacy level
        let personalKeywords = [
            "name", "location", "bio", "about"
        ]
        
        // Check critical keywords (always occlude)
        if criticalKeywords.contains(where: { placeholder.contains($0) }) {
            return true
        }
        
        // Check personal keywords (based on privacy level)
        if shouldOccludePersonalData() {
            return personalKeywords.contains(where: { placeholder.contains($0) })
        }
        
        return false
    }
    
    // MARK: - Screen-Level Protection
    
    func applyScreenLevelProtection(for screenName: String) {
        switch screenName {
        case UXCamScreenNames.userProfile:
            // No screen-level protection - use view-level for granular control
            break
            
        case UXCamScreenNames.settings:
            // Conditional screen-level protection for maximum privacy
            if currentPrivacyLevel == .maximum {
                let blurSetting = UXCamBlurSetting(radius: 8)
                UXCam.applyOcclusion(blurSetting)
            }
            
        default:
            break
        }
    }
    
    func removeScreenLevelProtection() {
        UXCam.removeOcclusion()
    }
    
    // MARK: - Helper Methods
    
    private func shouldOccludePersonalData() -> Bool {
        switch currentPrivacyLevel {
        case .maximum, .standard:
            return true
        case .minimal, .off:
            return false
        }
    }
    
    private func shouldOccludeUserGeneratedData() -> Bool {
        switch currentPrivacyLevel {
        case .maximum:
            return true
        case .standard, .minimal, .off:
            return false
        }
    }
    
    // MARK: - Debug Helpers
    
    #if DEBUG
    func logPrivacyStatus() {
        print("🔒 UXCam Privacy Status:")
        print("  Level: \(currentPrivacyLevel)")
        print("  Personal Data: \(shouldOccludePersonalData() ? "Hidden" : "Visible")")
        print("  User Generated: \(shouldOccludeUserGeneratedData() ? "Hidden" : "Visible")")
    }
    
    func validatePrivacyImplementation(in viewController: UIViewController) {
        let className = String(describing: type(of: viewController))
        print("🔒 Privacy validation for: \(className)")
        
        // Count potentially sensitive views
        var sensitiveViewCount = 0
        
        func scanView(_ view: UIView) {
            if view is UITextField || view is UITextView || view is UILabel {
                sensitiveViewCount += 1
            }
            
            view.subviews.forEach(scanView)
        }
        
        scanView(viewController.view)
        
        print("  Found \(sensitiveViewCount) potentially sensitive views")
        print("  Privacy level: \(currentPrivacyLevel)")
    }
    #endif
}

// MARK: - Extensions for Easy Integration

extension UIViewController {
    
    /// Apply privacy protection when view appears
    func applyUXCamPrivacyProtection() {
        let screenName = getCurrentScreenName()
        UXCamPrivacyManager.shared.applyScreenLevelProtection(for: screenName)
        
        #if DEBUG
        UXCamPrivacyManager.shared.validatePrivacyImplementation(in: self)
        #endif
    }
    
    /// Remove privacy protection when view disappears
    func removeUXCamPrivacyProtection() {
        UXCamPrivacyManager.shared.removeScreenLevelProtection()
    }
    
    private func getCurrentScreenName() -> String {
        switch self {
        case is MainViewController:
            return UXCamScreenNames.home
        case is ProfileViewController:
            return UXCamScreenNames.userProfile
        case is ListViewController:
            return UXCamScreenNames.topicsList
        case is SettingsViewController:
            return UXCamScreenNames.settings
        default:
            return "Unknown"
        }
    }
}

// MARK: - UITextField Extension for Smart Occlusion

extension UITextField {
    
    /// Automatically apply occlusion based on content and privacy settings
    func applySmartOcclusion() {
        if UXCamPrivacyManager.shared.shouldOccludeTextInput(self) {
            UXCam.occludeSensitiveView(self)
            
            #if DEBUG
            print("🔒 Smart occlusion applied to text field: \(placeholder ?? "unknown")")
            #endif
        }
    }
}
