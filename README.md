# LinguaFlow - Modern Language Learning App

A beautiful, modern language learning application built with Flutter. LinguaFlow features a creative UI with glassmorphism effects, smooth animations, and an engaging learning experience.

## ✨ Features

### 🎨 Modern UI Design
- **Glassmorphism Cards**: Beautiful frosted glass effect cards throughout the app
- **Gradient Backgrounds**: Stunning gradient color schemes
- **Smooth Animations**: Fluid transitions and animations using flutter_animate
- **Custom Typography**: Google Fonts integration for beautiful text

### 📚 Learning Features
- **Word of the Day**: Discover new words daily with definitions and examples
- **Interactive Flashcards**: Flip cards to learn word definitions, pronunciations, and examples
- **Vocabulary Tracking**: Save and review all learned words
- **Progress Tracking**: Visual progress indicators and statistics
- **Streak System**: Maintain your learning streak with daily practice

### 🎯 Gamification
- **Achievement System**: Unlock achievements as you progress
- **Streak Counter**: Track consecutive days of learning
- **Progress Visualization**: Beautiful circular progress indicators
- **Word Counter**: See how many words you've learned

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd testapplication
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## 📦 Dependencies

- `http`: For API calls to Free Dictionary API
- `shared_preferences`: For local data storage
- `flutter_animate`: For smooth animations
- `google_fonts`: For beautiful typography
- `flutter_svg`: For SVG support
- `shimmer`: For loading animations
- `confetti`: For celebration effects
- `flutter_staggered_animations`: For staggered animations

## 🌐 APIs Used

- **Free Dictionary API**: Provides word definitions, pronunciations, examples, and more
  - Base URL: `https://api.dictionaryapi.dev/api/v2/entries/en`
- **Random Word API**: Generates random words for learning
  - Base URL: `https://random-word-api.herokuapp.com/word`

## 📱 Screens

### Home Screen
- Word of the Day display
- Quick stats (streak, words learned)
- Language selection
- Navigation to learning features

### Flashcard Screen
- Interactive flip cards
- Word pronunciation
- Definitions and examples
- Progress tracking
- Mark words as learned

### Vocabulary Screen
- List of all learned words
- Word details modal
- Search and filter capabilities

### Progress Screen
- Streak visualization
- Learning statistics
- Achievement system
- Progress charts

## 🎨 Design Philosophy

LinguaFlow is designed to be:
- **Modern**: Uses latest UI trends like glassmorphism and gradients
- **Engaging**: Gamification elements keep users motivated
- **Beautiful**: Every screen is carefully crafted for visual appeal
- **Functional**: Clean, intuitive navigation and interactions

## 🔮 Future Enhancements

- Multiple language support (currently focused on English)
- Spaced repetition algorithm
- Pronunciation practice with speech recognition
- Social features and leaderboards
- Offline mode with cached content
- Custom word lists and categories

## 📄 License

This project is open source and available for personal and commercial use.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

---

Built with ❤️ using Flutter
