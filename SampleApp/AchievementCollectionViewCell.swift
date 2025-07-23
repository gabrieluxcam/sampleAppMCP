import UIKit

class AchievementCollectionViewCell: UICollectionViewCell {
    
    private let iconLabel = UILabel()
    private let titleLabel = UILabel()
    private let progressBar = UIProgressView()
    private let lockOverlay = UIView()
    private let lockIcon = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 12
        layer.masksToBounds = true
        
        // Icon label
        iconLabel.font = UIFont.systemFont(ofSize: 24)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Title label
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Progress bar
        progressBar.progressTintColor = .systemGreen
        progressBar.trackTintColor = .systemGray5
        progressBar.layer.cornerRadius = 2
        progressBar.layer.masksToBounds = true
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        
        // Lock overlay
        lockOverlay.backgroundColor = .systemBackground.withAlphaComponent(0.8)
        lockOverlay.layer.cornerRadius = 12
        lockOverlay.translatesAutoresizingMaskIntoConstraints = false
        lockOverlay.isHidden = true
        
        // Lock icon
        lockIcon.image = UIImage(systemName: "lock.fill")
        lockIcon.tintColor = .systemGray
        lockIcon.contentMode = .scaleAspectFit
        lockIcon.translatesAutoresizingMaskIntoConstraints = false
        
        lockOverlay.addSubview(lockIcon)
        
        addSubview(iconLabel)
        addSubview(titleLabel)
        addSubview(progressBar)
        addSubview(lockOverlay)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            iconLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconLabel.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            
            progressBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            progressBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            progressBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            progressBar.heightAnchor.constraint(equalToConstant: 4),
            progressBar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            lockOverlay.topAnchor.constraint(equalTo: topAnchor),
            lockOverlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            lockOverlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            lockOverlay.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            lockIcon.centerXAnchor.constraint(equalTo: lockOverlay.centerXAnchor),
            lockIcon.centerYAnchor.constraint(equalTo: lockOverlay.centerYAnchor),
            lockIcon.widthAnchor.constraint(equalToConstant: 24),
            lockIcon.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(with achievement: Achievement) {
        iconLabel.text = achievement.icon
        titleLabel.text = achievement.title
        progressBar.progress = Float(achievement.progressPercentage / 100.0)
        
        if achievement.isUnlocked {
            lockOverlay.isHidden = true
            backgroundColor = .systemGreen.withAlphaComponent(0.2)
            layer.borderWidth = 2
            layer.borderColor = UIColor.systemGreen.cgColor
        } else {
            lockOverlay.isHidden = false
            backgroundColor = .secondarySystemBackground
            layer.borderWidth = 0
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        lockOverlay.isHidden = true
        backgroundColor = .secondarySystemBackground
        layer.borderWidth = 0
        layer.borderColor = UIColor.clear.cgColor
    }
} 