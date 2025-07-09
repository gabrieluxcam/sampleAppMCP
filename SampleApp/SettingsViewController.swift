import UIKit

class SettingsViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let settings = [
        ["Notifications", "Privacy", "Security"],
        ["Dark Mode", "Language", "Font Size"],
        ["Help", "About", "Contact Us"]
    ]
    private let sectionTitles = ["Account", "Preferences", "Support"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
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
        cell.textLabel?.text = settings[indexPath.section][indexPath.row]
        cell.accessoryType = .disclosureIndicator
        
        // Add icons for some settings
        switch settings[indexPath.section][indexPath.row] {
        case "Notifications":
            cell.imageView?.image = UIImage(systemName: "bell")
        case "Privacy":
            cell.imageView?.image = UIImage(systemName: "lock")
        case "Security":
            cell.imageView?.image = UIImage(systemName: "shield")
        case "Dark Mode":
            cell.imageView?.image = UIImage(systemName: "moon")
        case "Language":
            cell.imageView?.image = UIImage(systemName: "globe")
        case "Font Size":
            cell.imageView?.image = UIImage(systemName: "textformat.size")
        case "Help":
            cell.imageView?.image = UIImage(systemName: "questionmark.circle")
        case "About":
            cell.imageView?.image = UIImage(systemName: "info.circle")
        case "Contact Us":
            cell.imageView?.image = UIImage(systemName: "envelope")
        default:
            cell.imageView?.image = UIImage(systemName: "gear")
        }
        
        cell.imageView?.tintColor = .systemBlue
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let settingName = settings[indexPath.section][indexPath.row]
        
        if settingName == "Dark Mode" {
            showDarkModeToggle()
        } else {
            let alert = UIAlertController(
                title: settingName,
                message: "This setting is not implemented yet.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    private func showDarkModeToggle() {
        let alert = UIAlertController(title: "Dark Mode", message: "Choose your preferred appearance", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Light", style: .default) { _ in
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.first?.overrideUserInterfaceStyle = .light
            }
        })
        
        alert.addAction(UIAlertAction(title: "Dark", style: .default) { _ in
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.first?.overrideUserInterfaceStyle = .dark
            }
        })
        
        alert.addAction(UIAlertAction(title: "System", style: .default) { _ in
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.first?.overrideUserInterfaceStyle = .unspecified
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = tableView
            popover.sourceRect = tableView.rectForRow(at: IndexPath(row: 0, section: 1))
        }
        
        present(alert, animated: true)
    }
} 