import UIKit
import UXCam

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize UXCam as early as possible
        initializeUXCam()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Create tab bar controller
        let tabBarController = UITabBarController()
        
        // Create view controllers with navigation controllers
        let mainVC = MainViewController()
        let mainNavController = UINavigationController(rootViewController: mainVC)
        mainNavController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        
        let profileVC = ProfileViewController()
        let profileNavController = UINavigationController(rootViewController: profileVC)
        profileNavController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 1)
        
        let listVC = ListViewController()
        let listNavController = UINavigationController(rootViewController: listVC)
        listNavController.tabBarItem = UITabBarItem(title: "Topics", image: UIImage(systemName: "list.bullet"), tag: 2)
        
        let settingsVC = SettingsViewController()
        let settingsNavController = UINavigationController(rootViewController: settingsVC)
        settingsNavController.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 3)
        
        // Set up tab bar
        tabBarController.viewControllers = [mainNavController, profileNavController, listNavController, settingsNavController]
        tabBarController.tabBar.tintColor = .systemBlue
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        return true
    }
    
    private func initializeUXCam() {
        let uxcamKey = getUXCamKeySecurely()
        
        // Create configuration object
        let config = UXCamConfiguration(appKey: uxcamKey)
        
        // Configure essential options
        config.enableAutomaticScreenNameTagging = true
        config.enableCrashHandling = true
        
        // Enable integration logging for debug builds
        #if DEBUG
        config.enableIntegrationLogging = true
        print("✅ UXCam debug logging enabled")
        #endif
        
        // Opt-in for wireframe screenshots (App Store review safe)
        UXCam.optIntoSchematicRecordings()
        
        // Start UXCam with configuration
        UXCam.start(with: config)
        
        // Configure privacy protection level
        setupPrivacyProtection()
        
        #if DEBUG
        print("✅ UXCam initialized successfully")
        #endif
    }
    
    private func getUXCamKeySecurely() -> String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "UXCamAppKey") as? String,
              !key.isEmpty && !key.hasPrefix("$(") else {
            fatalError("UXCam key not properly configured. Check your xcconfig setup and replace YOUR_DEBUG_KEY_HERE with your actual UXCam key.")
        }
        return key
    }
    
    private func setupPrivacyProtection() {
        // Configure the privacy protection level for the app
        // You can change this level based on your privacy requirements:
        // - .maximum: Hide all personal data (most private)
        // - .standard: Hide critical data (recommended for most apps)
        // - .minimal: Hide only passwords and financial data
        // - .off: No additional occlusion (rely on automatic protection only)
        
        #if DEBUG
        // Use standard privacy level for debug builds (good for testing)
        UXCamPrivacyManager.shared.configurePrivacyLevel(.standard)
        #else
        // Use maximum privacy level for release builds (most secure)
        UXCamPrivacyManager.shared.configurePrivacyLevel(.maximum)
        #endif
        
        #if DEBUG
        UXCamPrivacyManager.shared.logPrivacyStatus()
        #endif
    }
} 