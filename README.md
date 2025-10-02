# 🌟 Barter Qween

**A Modern Flutter Barter/Trading App with Firebase Backend**

Trade items you don't need for things you want! Barter Qween is a feature-rich mobile application built with Flutter and Firebase, following Clean Architecture principles and BLoC state management.

[![Flutter](https://img.shields.io/badge/Flutter-3.27.1-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 📱 Features

### ✅ **Authentication**
- 📧 Email/Password registration and login
- 🔑 Google Sign-In integration  
- 🔐 Password reset via email
- 👤 Persistent authentication state

### ✅ **Profile Management**
- 👤 View and edit user profile
- 📸 Avatar upload with Firebase Storage
- 📊 User statistics display
- ✏️ Update personal information

### ✅ **Item Management**
- ➕ Create items with multiple images (up to 5)
- 📝 Full CRUD operations
- 🔍 Real-time search (title, description, category)
- 🏷️ Category filtering (7 categories)
- 📱 Grid and list view toggle
- 📤 Share items via social media
- 🎨 Beautiful image carousel
- 🖼️ Cached images for performance
- ✏️ Edit and delete your items

### ✅ **Trade System**
- 📬 Send trade offers with messages
- 📨 Received and sent trade tabs
- ✅ Accept trade offers
- ❌ Reject trade offers  
- 🚫 Cancel sent offers
- 🔔 **Pending trade count badge**
- 📄 Detailed trade view with timeline
- 🎨 Status badges (6 states)

### ✅ **UI/UX**
- 🏠 5-tab dashboard
- 🎨 Material Design 3
- 🌈 Custom color scheme
- 📱 Responsive layouts
- ✨ Smooth animations
- 🔄 Pull-to-refresh

---

## 🏗️ Architecture

```
lib/
├── core/                      # Core functionality
│   ├── di/                    # Dependency Injection
│   ├── error/                 # Error handling
│   ├── routes/                # Navigation
│   └── theme/                 # App theme
│
├── domain/                    # Business Logic
│   ├── entities/              # Domain models
│   ├── repositories/          # Repository interfaces
│   └── usecases/              # Use cases
│
├── data/                      # Data Layer
│   ├── models/                # Data models
│   ├── datasources/           # Remote data sources
│   └── repositories/          # Repository implementations
│
└── presentation/              # UI Layer
    ├── blocs/                 # BLoC state management
    ├── pages/                 # UI pages (14 pages)
    └── widgets/               # Reusable widgets
```

**Design Patterns:** BLoC, Repository, Dependency Injection, Clean Architecture

---

## 🚀 Quick Start

### Prerequisites
- Flutter 3.27.1+
- Dart 3.x+
- Firebase account

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/barter-qween.git
cd barter-qween/barter_qween

# Install dependencies
flutter pub get

# Generate DI code
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Firebase Setup

1. Create Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add Android/iOS apps
3. Download config files:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`
4. Enable services:
   - Authentication (Email, Google)
   - Cloud Firestore
   - Firebase Storage
   - Firebase Messaging
5. Deploy rules & indexes:
   ```bash
   firebase deploy --only firestore:rules,firestore:indexes,storage
   ```

---

## 📦 Tech Stack

| Category | Technologies |
|----------|-------------|
| **Framework** | Flutter 3.27.1, Dart 3.x |
| **State Management** | flutter_bloc, equatable |
| **DI** | get_it, injectable |
| **Backend** | Firebase (Auth, Firestore, Storage, Messaging) |
| **Images** | cached_network_image, image_picker |
| **Utilities** | dartz, intl, share_plus |

---

## 📊 Statistics

| Metric | Value |
|--------|-------|
| Total Pages | 14 |
| Lines of Code | ~10,000+ |
| Compilation Errors | 0 |
| Debug APK | 43 MB |
| Release APK | 26 MB |
| Build Time | ~45s |

---

## 📸 App Structure

### Pages Overview

```
📱 App Pages (14 total)
├── Auth (4)
│   ├── Login
│   ├── Register  
│   ├── Forgot Password
│   └── Onboarding
├── Profile (2)
│   ├── View Profile
│   └── Edit Profile
├── Items (4)
│   ├── Item List (with search)
│   ├── Item Detail
│   ├── Create Item
│   └── Edit Item
├── Trades (3)
│   ├── Trades List (Received/Sent)
│   ├── Send Trade Offer
│   └── Trade Detail
└── Dashboard (1)
    └── Main Dashboard (5 tabs)
```

---

## 🔥 Firebase Collections

### **users**
```js
{
  uid, email, displayName, photoUrl,
  phoneNumber, bio, location,
  createdAt, updatedAt
}
```

### **items**
```js
{
  id, title, description, category,
  images[], condition, ownerId, ownerName,
  city, status, createdAt, updatedAt,
  viewCount, favoriteCount
}
```

### **tradeOffers**
```js
{
  id, fromUserId, toUserId,
  fromUserName, toUserName,
  offeredItemId, offeredItemTitle, offeredItemImages[],
  requestedItemId, requestedItemTitle, requestedItemImages[],
  message, status,
  createdAt, updatedAt
}
```

---

## ✨ Recent Updates

### v1.0.0 (October 2025)
- ✅ Added real-time search functionality
- ✅ Added pending trade count badge
- ✅ Improved empty states
- ✅ Fixed all compilation errors
- ✅ Added Trade Detail Page
- ✅ Complete trade flow implementation
- ✅ Comprehensive error handling

---

## 🎯 Development Phases

| Phase | Feature | Status |
|-------|---------|--------|
| 0 | Authentication | ✅ 100% |
| 1 | Profile Management | ✅ 100% |
| 2 | Item Management | ✅ 100% |
| 3 | Trade System | ✅ 100% |
| 4 | Chat System | ⏳ Planned |
| 5 | Favorites | ⏳ Planned |
| 6 | Notifications | ⏳ Planned |
| 7 | Advanced Features | ⏳ Planned |

---

## 🧪 Testing

```bash
# Analyze code
flutter analyze

# Build debug
flutter build apk --debug

# Build release
flutter build apk --release

# Run tests (when added)
flutter test
```

**Current Status:** 0 errors, 78 info warnings (style suggestions)

---

## 🤝 Contributing

1. Fork the project
2. Create feature branch (`git checkout -b feature/Amazing`)
3. Commit changes (`git commit -m 'Add Amazing'`)
4. Push branch (`git push origin feature/Amazing`)
5. Open Pull Request

---

## 📄 License

MIT License - see [LICENSE](LICENSE) file

---

## 👨‍💻 Credits

Built with ❤️ using:
- Flutter & Dart
- Firebase
- BLoC Pattern
- Clean Architecture
- Material Design 3

---

## 📞 Support

- 📧 Email: support@barterqween.com
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/barter-qween/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/yourusername/barter-qween/discussions)

---

**🌟 Star this repo if you find it useful!**

*Version 1.0.0 - October 2025*
