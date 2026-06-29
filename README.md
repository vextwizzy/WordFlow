# WordFlow - TikTok-Style English Learning App

Modern iOS application for learning English vocabulary with gamification, built with Swift 6, SwiftUI, and SwiftData.

## Features

### Core Features
- **TikTok-Style Card Swipes**: Learn words by swiping up/down/left/right
- **Gamification System**: XP, levels, daily streaks, and achievements
- **AI-Powered Learning**: OpenAI integration for smart explanations
- **Mini Quizzes**: Test knowledge every 20 words
- **Speech Synthesis**: Audio pronunciation for all words
- **Dark/Light Themes**: Beautiful glassmorphism design

### Swipe Gestures
- **Swipe Up**: Next word
- **Swipe Down**: Previous word
- **Swipe Right**: Know the word ✓
- **Swipe Left**: Don't know the word ✗

### Gamification
- XP system with levels
- Daily streak tracking
- 18+ achievements across 5 categories
- Progress visualization with charts

### Premium Features
- Unlimited daily words (free: 50/day)
- AI-generated explanations
- Advanced statistics
- Progress export

## Tech Stack

- **Swift 6**
- **SwiftUI** - Modern declarative UI
- **SwiftData** - Data persistence
- **Observation Framework** - State management
- **Charts** - Data visualization
- **AVSpeechSynthesizer** - Text-to-speech
- **StoreKit 2** - In-app purchases
- **UserNotifications** - Push notifications

## Architecture

```
WordFlow/
├── App/                    # App entry point
├── Core/
│   ├── Models/            # SwiftData models
│   ├── ViewModels/        # MVVM view models
│   └── Services/          # Business logic services
├── Features/              # Feature-based screens
│   ├── WordCards/        # TikTok-style cards
│   ├── Quiz/             # Quiz system
│   ├── Profile/          # User profile
│   ├── Statistics/       # Charts & stats
│   └── Premium/          # Subscription
├── UI/
│   ├── Components/       # Reusable components
│   ├── Theme/            # Colors, typography, animations
│   └── Navigation/       # Tab bar
└── Utilities/            # Extensions & constants
```

## Setup

### Prerequisites
- Xcode 15.0+
- iOS 17.0+
- OpenAI API Key (optional, for AI features)

### Installation

1. Clone the repository:
```bash
cd Desktop/ENGLISH
cd WordFlow
```

2. Configure API Keys:
Open `Utilities/Constants/APIKeys.swift` and add your keys:
```swift
static let openAI = "YOUR_OPENAI_API_KEY_HERE"
```

3. Open in Xcode:
```bash
open WordFlow.xcodeproj
```

4. Build and run on simulator or device

## Models

### Word
- English word, transcription, translation
- AI explanation, example, association
- Difficulty level (Beginner → Expert)
- Mastery tracking with spaced repetition

### UserProfile
- Level, XP, streak tracking
- Study time, words learned
- Premium status
- Relationships: achievements, sessions, daily streaks

### Achievement
- 18 predefined achievements
- Categories: Words, Streak, Quiz, Time, Level
- Progress tracking with XP rewards

### StudySession
- Session duration tracking
- Swipe accuracy (correct/wrong)
- XP earned per session

## Key Features Implementation

### TikTok-Style Swipes
`WordCardStackView.swift` implements:
- Vertical scrolling with gestures
- Card stack with 3 visible cards
- Drag gesture with threshold detection
- Smooth animations with haptic feedback

### Gamification System
`GamificationViewModel.swift` handles:
- XP calculation with difficulty multipliers
- Level-up detection and animations
- Achievement unlocking logic
- Streak maintenance

### Spaced Repetition
`DataManager.swift` implements:
- Review scheduling based on mastery
- Smart word selection for study
- Daily limit enforcement (free/premium)

### Statistics & Charts
`StatisticsView.swift` displays:
- Words learned over time (Bar chart)
- Study time trends (Line/Area chart)
- Accuracy visualization (Circular progress)
- Category breakdown

## Customization

### Adding New Achievements
Edit `Core/Models/Achievement.swift`:
```swift
static let predefinedAchievements: [...] = [
    ("Title", "Description", "icon.name", xp, requirement, .category),
    // Add more...
]
```

### Changing XP Values
Edit `Utilities/Constants/AppConstants.swift`:
```swift
static let xpPerWord = 10
static let xpPerQuizCorrect = 20
```

### Custom Word Lists
Use `DataManager.loadSampleWords()` or import JSON:
```swift
let word = Word(
    english: "Journey",
    transcription: "/ˈdʒɜːrni/",
    translation: "Путешествие",
    difficulty: .beginner
)
dataManager.addWord(word)
```

## Design System

### Colors
- Brand Primary: `#6C5CE7`
- Brand Secondary: `#A29BFE`
- Accent: `#FD79A8`
- XP Gold: `#F39C12`
- Streak Fire: `#E74C3C`

### Typography
- System Rounded font family
- Dynamic type support
- Sizes: 12pt (caption) → 48pt (word cards)

### Animations
- Spring animations (response: 0.5, damping: 0.7)
- Hero transitions for level-up
- Pulse effects for achievements
- Card flip with 3D rotation

## Notifications

The app supports:
- Daily study reminders (customizable time)
- Streak at-risk warnings
- Achievement unlocked notifications
- Level-up celebrations

## Premium Subscription

StoreKit 2 implementation with:
- Monthly subscription
- Yearly subscription (50% savings)
- Automatic renewal
- Restore purchases
- Transaction verification

Product IDs:
- `wordflow.premium.monthly`
- `wordflow.premium.yearly`

## Data Privacy

- All data stored locally with SwiftData
- No user data sent to servers (except OpenAI API for explanations)
- Export functionality for user data portability

## Performance

- Lazy loading for word lists
- Efficient SwiftData queries with predicates
- Image caching (when images are added)
- Background task handling for AI requests

## Future Enhancements

- [ ] Image generation for words (Unsplash/DALL-E)
- [ ] Audio lessons with native speakers
- [ ] Social features (leaderboards, friends)
- [ ] Custom word collections
- [ ] Offline mode improvements
- [ ] Widget support
- [ ] Apple Watch companion app

## License

MIT License - feel free to use for learning or commercial projects

## Credits

Created by WordFlow Team
Powered by OpenAI GPT-4

---

**Note**: This is a production-ready app template. Replace API keys and configure StoreKit products in App Store Connect before release.

For questions or support: support@wordflow.app
