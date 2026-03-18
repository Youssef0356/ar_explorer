# AR Explorer 🚀

**AR Explorer** is a high-tech, interactive mobile learning platform designed to teach Augmented Reality (AR) concepts through gamification, interactive modules, and professional tools. Built with Flutter, it offers a premium experience with dynamic animations and deep technical content.

---

## 🌟 Key Features

### 📖 Interactive Learning
*   **Concept Modules**: In-depth lessons on AR, VR, MR, XR, and their real-world applications.
*   **Rich Content Rendering**: Support for complex layouts, code snippets, and visual aids.
*   **Daily Keywords**: Stay updated with essential AR terminology every day.

### 🎮 Gamification & Challenges
*   **Interactive Quizzes**: Test your knowledge with module-specific quizzes and track your performance with detailed analytics.
*   **Coding Challenges**: Solve "Fill-in-the-gap" coding exercises focused on AR development (Unity, C#, ARCore, ARKit).
*   **AR Systems Engineer Path**: A specialized game-like experience with zones and progression steps.
*   **Achievments & Badges**: Earn shareable badges as you progress through the roadmap.

### 🛠 Professional Tools
*   **Roadmap**: A visual guide to mastering AR development.
*   **Interview Prep**: Specialized section for AR job interview questions and tips.
*   **PDF Certificates**: Generate and export professional certificates upon course completion.
*   **Bookmarks**: Save important notes and topics for quick reference.

### 💎 Premium Experience
*   **Enhanced Visuals**: Dynamic background effects and premium micro-animations.
*   **Ad-Free Experience**: Continuous learning without interruptions.
*   **Advanced Notes**: Exclusive deep-dive content for premium users.

---

## 🏗 Architectural Overview

The project follows a modular structure for scalability and maintainability:

*   `lib/core/`: Contains the global theme (`app_theme.dart`) and core constants.
*   `lib/data/`: Centralized data store for modules, quizzes, flashcards, and coding challenges.
*   `lib/models/`: Strongly-typed data models for all system components.
*   `lib/screens/`: UI layer containing all feature-specific screens (Home, Quiz, Game, etc.).
*   `lib/services/`: Business logic and external integrations (Ads, Progress, Subscriptions, Sounds).
*   `lib/widgets/`: Reusable UI components like the `AnimatedGoogleBackground` and `ContentRenderer`.

---

## 🚀 Tech Stack

*   **Framework**: [Flutter](https://flutter.dev/) (3.11.0+)
*   **State Management**: [Provider](https://pub.dev/packages/provider)
*   **Animations**: [flutter_animate](https://pub.dev/packages/flutter_animate)
*   **Local Storage**: [shared_preferences](https://pub.dev/packages/shared_preferences)
*   **Monetization**: Google Mobile Ads & In-App Purchases
*   **Exports**: PDF generation and Printing services

---

## 🛠 Setup & Development

### Prerequisites
*   Flutter SDK installed.
*   Android Studio / Xcode for mobile emulation.

### Getting Started
1.  Clone the repository.
2.  Run `flutter pub get` to install dependencies.
3.  Configure your environment for AdMob and In-App Purchases if needed.
4.  Run `flutter run` to start the application.

---

---

## 📝 License

Part of the Mobile Development collection. (c) 2026 AR Explorer Team.
