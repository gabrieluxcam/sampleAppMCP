import UIKit

class MainViewController: UIViewController {
    
    private let titleLabel = UILabel()
    private let counterButton = UIButton(type: .system)
    private let resetButton = UIButton(type: .system)
    
    private var tapCount = 0 {
        didSet {
            tapCountLabel.text = "Taps: \(tapCount)"
            // Save to UserDefaults
            UserDefaults.standard.set(tapCount, forKey: "tapCount")
        }
    }
    private let tapCountLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTapCount()
        setupUI()
        setupConstraints()
    }
    
    private func loadTapCount() {
        tapCount = UserDefaults.standard.integer(forKey: "tapCount")
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Sample App"
        
        // Configure title label
        titleLabel.text = "Welcome to Sample App!"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure tap count label
        tapCountLabel.text = "Taps: \(tapCount)"
        tapCountLabel.font = UIFont.systemFont(ofSize: 18)
        tapCountLabel.textAlignment = .center
        tapCountLabel.textColor = .secondaryLabel
        tapCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure buttons
        configureButton(counterButton, title: "Tap Me! 👆", color: .systemBlue)
        configureButton(resetButton, title: "Reset Counter", color: .systemRed)
        
        // Add targets
        counterButton.addTarget(self, action: #selector(counterTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        
        // Add views
        view.addSubview(titleLabel)
        view.addSubview(tapCountLabel)
        view.addSubview(counterButton)
        view.addSubview(resetButton)
    }
    
    private func configureButton(_ button: UIButton, title: String, color: UIColor) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Title label
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Tap count label
            tapCountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            tapCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Counter button
            counterButton.topAnchor.constraint(equalTo: tapCountLabel.bottomAnchor, constant: 40),
            counterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            counterButton.widthAnchor.constraint(equalToConstant: 200),
            counterButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Reset button
            resetButton.topAnchor.constraint(equalTo: counterButton.bottomAnchor, constant: 20),
            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetButton.widthAnchor.constraint(equalToConstant: 200),
            resetButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func counterTapped() {
        tapCount += 1
        
        // Add some animation
        UIView.animate(withDuration: 0.1, animations: {
            self.counterButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.counterButton.transform = CGAffineTransform.identity
            }
        }
        
        // Add celebratory animation for milestones
        if tapCount % 10 == 0 {
            showCelebration()
        }
    }
    
    @objc private func resetTapped() {
        let alert = UIAlertController(title: "Reset Counter", message: "Are you sure you want to reset the tap counter?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { _ in
            self.tapCount = 0
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showCelebration() {
        let alert = UIAlertController(title: "🎉 Milestone!", message: "You've reached \(tapCount) taps!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Awesome!", style: .default))
        present(alert, animated: true)
    }
} 