import UIKit

class TopicTableViewCell: UITableViewCell {
    static let identifier = "TopicCell"
    
    private let titleLabel = UILabel()
    private let categoryLabel = UILabel()
    private let timeLabel = UILabel()
    private let difficultyLabel = UILabel()
    private let progressBar = UIProgressView()
    private let favoriteButton = UIButton(type: .system)
    private let ratingStackView = UIStackView()
    private let completedIcon = UIImageView()
    
    private var topic: Topic?
    weak var delegate: TopicCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Title label
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Category label
        categoryLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        categoryLabel.textColor = .systemBlue
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Time label
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = .secondaryLabel
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Difficulty label
        difficultyLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        difficultyLabel.layer.cornerRadius = 8
        difficultyLabel.layer.masksToBounds = true
        difficultyLabel.textAlignment = .center
        difficultyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Progress bar
        progressBar.progressTintColor = .systemGreen
        progressBar.trackTintColor = .systemGray5
        progressBar.layer.cornerRadius = 2
        progressBar.layer.masksToBounds = true
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        
        // Favorite button
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        favoriteButton.tintColor = .systemPink
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Rating stack view
        ratingStackView.axis = .horizontal
        ratingStackView.spacing = 2
        ratingStackView.distribution = .fillEqually
        ratingStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup rating stars
        for i in 1...5 {
            let starButton = UIButton(type: .system)
            starButton.setImage(UIImage(systemName: "star"), for: .normal)
            starButton.setImage(UIImage(systemName: "star.fill"), for: .selected)
            starButton.tintColor = .systemYellow
            starButton.tag = i
            starButton.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            ratingStackView.addArrangedSubview(starButton)
        }
        
        // Completed icon
        completedIcon.image = UIImage(systemName: "checkmark.circle.fill")
        completedIcon.tintColor = .systemGreen
        completedIcon.translatesAutoresizingMaskIntoConstraints = false
        completedIcon.isHidden = true
        
        // Add subviews
        contentView.addSubview(titleLabel)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(difficultyLabel)
        contentView.addSubview(progressBar)
        contentView.addSubview(favoriteButton)
        contentView.addSubview(ratingStackView)
        contentView.addSubview(completedIcon)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Title label
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -8),
            
            // Favorite button
            favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            favoriteButton.widthAnchor.constraint(equalToConstant: 30),
            favoriteButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Category and time labels
            categoryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: categoryLabel.trailingAnchor, constant: 8),
            
            // Difficulty label
            difficultyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            difficultyLabel.trailingAnchor.constraint(equalTo: completedIcon.leadingAnchor, constant: -8),
            difficultyLabel.widthAnchor.constraint(equalToConstant: 70),
            difficultyLabel.heightAnchor.constraint(equalToConstant: 20),
            
            // Completed icon
            completedIcon.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            completedIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            completedIcon.widthAnchor.constraint(equalToConstant: 20),
            completedIcon.heightAnchor.constraint(equalToConstant: 20),
            
            // Progress bar
            progressBar.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 8),
            progressBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            progressBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            progressBar.heightAnchor.constraint(equalToConstant: 4),
            
            // Rating stack view
            ratingStackView.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 8),
            ratingStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            ratingStackView.widthAnchor.constraint(equalToConstant: 120),
            ratingStackView.heightAnchor.constraint(equalToConstant: 20),
            ratingStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with topic: Topic) {
        self.topic = topic
        
        titleLabel.text = topic.title
        categoryLabel.text = topic.category.rawValue
        timeLabel.text = "⏱ \(topic.estimatedTime)"
        
        // Configure difficulty
        difficultyLabel.text = topic.difficulty.rawValue
        switch topic.difficulty {
        case .beginner:
            difficultyLabel.backgroundColor = .systemGreen.withAlphaComponent(0.2)
            difficultyLabel.textColor = .systemGreen
        case .intermediate:
            difficultyLabel.backgroundColor = .systemOrange.withAlphaComponent(0.2)
            difficultyLabel.textColor = .systemOrange
        case .advanced:
            difficultyLabel.backgroundColor = .systemRed.withAlphaComponent(0.2)
            difficultyLabel.textColor = .systemRed
        case .expert:
            difficultyLabel.backgroundColor = .systemPurple.withAlphaComponent(0.2)
            difficultyLabel.textColor = .systemPurple
        }
        
        // Configure progress
        progressBar.progress = Float(topic.progressPercentage / 100.0)
        
        // Configure favorite button
        favoriteButton.isSelected = topic.isFavorite
        
        // Configure completed state
        completedIcon.isHidden = !topic.isCompleted
        if topic.isCompleted {
            progressBar.progress = 1.0
            titleLabel.textColor = .secondaryLabel
        } else {
            titleLabel.textColor = .label
        }
        
        // Configure rating
        updateRatingDisplay(rating: topic.rating)
    }
    
    private func updateRatingDisplay(rating: Int?) {
        for (index, starView) in ratingStackView.arrangedSubviews.enumerated() {
            if let starButton = starView as? UIButton {
                starButton.isSelected = rating != nil && (index + 1) <= rating!
            }
        }
    }
    
    @objc private func favoriteButtonTapped() {
        guard var topic = topic else { return }
        topic.isFavorite.toggle()
        self.topic = topic
        
        favoriteButton.isSelected = topic.isFavorite
        delegate?.topicCellDidToggleFavorite(topic)
        
        // Animate the button
        UIView.animate(withDuration: 0.2, animations: {
            self.favoriteButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.favoriteButton.transform = .identity
            }
        }
    }
    
    @objc private func starTapped(_ sender: UIButton) {
        guard var topic = topic else { return }
        let rating = sender.tag
        
        topic.rating = topic.rating == rating ? nil : rating
        self.topic = topic
        
        updateRatingDisplay(rating: topic.rating)
        delegate?.topicCellDidRate(topic, rating: topic.rating)
    }
}

protocol TopicCellDelegate: AnyObject {
    func topicCellDidToggleFavorite(_ topic: Topic)
    func topicCellDidRate(_ topic: Topic, rating: Int?)
} 