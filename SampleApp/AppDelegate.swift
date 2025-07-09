import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
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
} 