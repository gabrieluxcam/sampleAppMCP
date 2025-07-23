# 📱 SampleApp - iOS Analytics Integration Showcase

A comprehensive iOS application demonstrating advanced analytics integration, user engagement features, and UXCam implementation best practices.

## 🚀 Features

### 📊 Analytics Integration

- **Event Tracking**: Comprehensive user interaction analytics
- **Screen Analytics**: Automatic screen tagging and navigation tracking
- **User Analytics**: Identity management and user properties
- **Privacy Protection**: GDPR/CCPA compliant PII occlusion
- **Error Tracking**: Robust error monitoring and reporting
- **Data Export**: Analytics data export in multiple formats

### 🎯 User Engagement

- **Achievement System**: Gamified progress tracking with unlockable achievements
- **Daily Challenges**: Dynamic daily tasks with rewards and streaks
- **Premium Features**: Subscription tiers with feature gating
- **Progress Tracking**: Visual progress indicators and milestone celebrations
- **Social Features**: Share functionality and social engagement

### 🎨 User Interface

- **Modern UI**: Clean, intuitive interface with smooth animations
- **Tab Navigation**: Organized content with tab bar navigation
- **Custom Cells**: Enhanced table and collection view cells
- **Settings Panel**: Comprehensive app configuration options
- **Profile Management**: User profile with photo picker and customization

## 🛠️ Technical Stack

- **Language**: Swift 5.0+
- **Framework**: UIKit
- **Architecture**: MVC with Singleton patterns
- **Data Persistence**: UserDefaults with Codable
- **Analytics**: Custom AnalyticsManager with UXCam integration
- **Minimum iOS Version**: iOS 13.0+

## 📁 Project Structure

```
SampleApp/
├── SampleApp/
│   ├── AppDelegate.swift              # App lifecycle management
│   ├── SceneDelegate.swift            # Scene-based app lifecycle
│   ├── MainViewController.swift       # Main dashboard with analytics
│   ├── ListViewController.swift       # Topic list with filtering
│   ├── ProfileViewController.swift    # User profile management
│   ├── SettingsViewController.swift   # App settings and configuration
│   ├── AnalyticsManager.swift         # Analytics tracking system
│   ├── PremiumManager.swift           # Subscription and feature management
│   ├── Models.swift                   # Data models and Codable support
│   ├── TopicTableViewCell.swift       # Custom table view cell
│   └── AchievementCollectionViewCell.swift # Custom collection view cell
├── SampleAppTests/                    # Unit tests
└── SampleAppUITests/                  # UI tests
```

## 🚀 Getting Started

### Prerequisites

- Xcode 12.0 or later
- iOS 13.0+ deployment target
- macOS 10.15+ (for development)

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/gabrieluxcam/sampleAppMCP.git
   cd sampleAppMCP
   ```

2. **Open in Xcode**

   ```bash
   open SampleApp.xcodeproj
   ```

3. **Build and Run**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run

### Configuration

#### Analytics Setup

The app includes a comprehensive analytics system that can be easily integrated with UXCam:

```swift
// Initialize analytics
AnalyticsManager.shared.initialize()

// Track events
AnalyticsManager.shared.trackEvent(.featureUsed, parameters: [
    "action": "button_tapped",
    "screen": "main_view"
])

// Set user properties
AnalyticsManager.shared.setUserProperty("user_id", value: "12345")
```

#### Premium Features

Configure subscription tiers and feature gating:

```swift
// Check feature access
if PremiumManager.shared.isFeatureUnlocked("advanced_analytics") {
    // Show premium feature
}

// Simulate purchase
PremiumManager.shared.simulatePurchase(purchaseItem) { success in
    // Handle purchase result
}
```

## 📊 Analytics Features

### Event Tracking

- **User Interactions**: Button taps, gestures, and navigation
- **Feature Usage**: Premium feature access and usage patterns
- **Error Monitoring**: App crashes and error tracking
- **Performance Metrics**: App performance and response times

### Screen Analytics

- **Automatic Tagging**: Screen identification and navigation flow
- **Session Tracking**: User session duration and engagement
- **Navigation Patterns**: User journey analysis and optimization

### Privacy Protection

- **PII Occlusion**: Automatic sensitive data masking
- **GDPR Compliance**: User consent and data handling
- **Data Export**: User data export capabilities

## 🎯 User Engagement Features

### Achievement System

- **Progress Tracking**: Visual progress indicators
- **Milestone Celebrations**: Achievement unlock notifications
- **Streak Tracking**: Daily challenge completion streaks
- **Social Sharing**: Achievement sharing capabilities

### Daily Challenges

- **Dynamic Tasks**: Daily changing challenges
- **Reward System**: Point-based reward system
- **Streak Maintenance**: Daily engagement tracking
- **Progress Visualization**: Challenge completion indicators

### Premium Features

- **Subscription Tiers**: Free, Basic, Premium, Pro
- **Feature Gating**: Tier-based feature access
- **Trial Management**: Free trial implementation
- **Upgrade Prompts**: Strategic upgrade suggestions

## 🔧 Customization

### Adding New Analytics Events

```swift
// Define custom event types
enum CustomEventType: String, CaseIterable {
    case customAction = "custom_action"
}

// Track custom events
AnalyticsManager.shared.trackEvent(.customAction, parameters: [
    "custom_parameter": "value"
])
```

### Implementing New Premium Features

```swift
// Add feature to PremiumManager
let newFeature = PremiumFeature(
    id: "new_feature",
    title: "New Feature",
    description: "Description of new feature",
    icon: "🌟",
    isLocked: true,
    requiredTier: .premium
)
```

### Creating Custom Achievements

```swift
// Define achievement in AchievementManager
let achievement = Achievement(
    id: "custom_achievement",
    title: "Custom Achievement",
    description: "Complete custom task",
    icon: "🏆",
    requiredProgress: 10,
    rewardPoints: 50
)
```

## 🧪 Testing

### Unit Tests

```bash
# Run unit tests
xcodebuild test -scheme SampleApp -destination 'platform=iOS Simulator,name=iPhone 14'
```

### UI Tests

```bash
# Run UI tests
xcodebuild test -scheme SampleApp -destination 'platform=iOS Simulator,name=iPhone 14' -only-testing:SampleAppUITests
```

## 📈 Performance Considerations

### Analytics Optimization

- **Batch Processing**: Events are batched for efficient transmission
- **Offline Support**: Analytics data cached when offline
- **Memory Management**: Efficient data structures and cleanup
- **Background Processing**: Analytics processing in background

### UI Performance

- **Lazy Loading**: Content loaded on demand
- **Image Caching**: Efficient image loading and caching
- **Smooth Animations**: Optimized animation performance
- **Memory Efficient**: Proper memory management and cleanup

## 🔒 Security & Privacy

### Data Protection

- **Encryption**: Sensitive data encrypted at rest
- **Secure Storage**: UserDefaults with additional encryption
- **API Security**: Secure API key management
- **Privacy Compliance**: GDPR and CCPA compliance

### User Privacy

- **Consent Management**: User consent for data collection
- **Data Minimization**: Only necessary data collected
- **User Control**: Users can export and delete their data
- **Transparency**: Clear privacy policy and data usage

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **UXCam**: For analytics integration inspiration
- **iOS Community**: For best practices and patterns
- **Open Source Contributors**: For various libraries and tools

## 📞 Support

For support and questions:

- Create an issue in this repository
- Contact the development team
- Check the documentation for common solutions

---

**Built with ❤️ for the iOS development community**
