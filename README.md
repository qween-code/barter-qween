# 🎯 Barter Qween - Modern Takas Platformu

**Versiyon:** v1.2.0-beta  
**Platform:** Flutter (iOS & Android)  
**Firebase Project:** bogazici-barter

[![Flutter](https://img.shields.io/badge/Flutter-3.24.3-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)

Barter Qween, Boğaziçi Üniversitesi öğrencileri için geliştirilmiş modern bir takas/değiş tokuş platformudur. Gerçek zamanlı mesajlaşma, akıllı bildirimler ve Pinterest-seviyesi neuromorphic tasarım ile kullanıcı deneyimini üst seviyeye taşır.

---

## ✨ Öne Çıkan Özellikler

### Core Features
- 🔐 **Güvenli Kimlik Doğrulama** - Email/Password + Google Sign-in
- 📦 **Ürün Yönetimi** - Çoklu fotoğraf desteği ile ürün ekleme/düzenleme
- 🤝 **Akıllı Takas Sistemi** - Teklif gönderme, kabul/red, durum takibi
- 💬 **Gerçek Zamanlı Chat** - Anlık mesajlaşma ve bildirimler
- ⭐ **Rating Sistemi** - 5 yıldız + yorum ile güvenilirlik
- 🔔 **Push Notifications** - Cloud Functions ile otomatik bildirimler
- 🎨 **Ultra-Deep Neuromorphic UI** - Pinterest-level design system (16-24 layers)
- 📊 **Analytics Tracking** - Firebase Analytics entegrasyonu

### Technical Excellence
- 🏗️ **Clean Architecture** - Domain, Data, Presentation layers
- 🔄 **BLoC Pattern** - Advanced state management
- 💉 **Dependency Injection** - GetIt + Injectable
- 🔥 **Firebase Backend** - Firestore, Functions, FCM, Storage
- 🚀 **Performance Optimized** - 60 FPS animations, efficient rendering

---

## 📚 Dokümantasyon

### 📖 Ana Dökümanlar
1. **[PROJECT_MASTER.md](PROJECT_MASTER.md)** - Proje durumu, müşteri gereksinimleri, kritik sorunlar
2. **[DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)** - Setup, architecture, testing, deployment
3. **[FEATURE_ROADMAP.md](FEATURE_ROADMAP.md)** - Sprint plan, upcoming features, timeline
4. **[DESIGN_SYSTEM.md](DESIGN_SYSTEM.md)** - Neuromorphic design system, UI components
5. **[docs/Bogaziçi Barter Mobil Uygulama Brief Dosyası.pdf](docs/)** - Müşteri brief (referans)

### 🔗 Hızlı Linkler
- **Firebase Console:** https://console.firebase.google.com/project/bogazici-barter
- **GitHub Repo:** https://github.com/qween-code/barter-qween
- **Analytics:** https://console.firebase.google.com/project/bogazici-barter/analytics

---

## 🚀 Hızlı Başlangıç

### Gereksinimler

```bash
Flutter SDK 3.24.3+
Dart SDK 3.5.3+
Firebase CLI
Android Studio / VS Code
Git
```

### Kurulum

#### 1. Projeyi Klonla
```bash
git clone https://github.com/qween-code/barter-qween.git
cd barter_qween
```

#### 2. Dependencies Yükle
```bash
flutter pub get
```

#### 3. Firebase Yapılandır
```bash
# Firebase CLI kurulu değilse
npm install -g firebase-tools

# Firebase'e giriş yap
firebase login

# Projeyi seç
firebase use bogazici-barter
```

#### 4. Uygulamayı Çalıştır
```bash
# Android emulator'da çalıştır
flutter run

# Belirli cihazda çalıştır
flutter run -d <device-id>
```

> **Detaylı setup için:** [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)

---

## 📊 Proje Durumu

### Geliştirme İstatistikleri
| Metrik | Değer |
|--------|-------|
| **Kod Satırı** | ~45,000 lines |
| **Sayfalar** | 35+ screens |
| **Widget'lar** | 24+ custom widgets |
| **Firebase Functions** | 4 deployed |
| **Analytics Events** | 12+ tracked |
| **Test Coverage** | Expanding (target: 60%+) |

### Son Commit
```
388edf7 - fix: Resolve 943 compilation errors in neuromorphic design system
         (1,158 → 215 errors, %81.4 azalma)
```

### 🔴 Kritik Sorunlar (Çözülüyor)
- Profile page crash
- Favorites not working
- Search functionality broken
- Firestore permission issues
- 215 compilation warnings (deprecated APIs)

**Production Readiness:** 65% → Kritik bug'lar aktif olarak çözülüyor

> **Detaylı durum için:** [PROJECT_MASTER.md](PROJECT_MASTER.md)

---

## 🏗️ Architecture

```
lib/
├── core/              # Framework & utilities
│   ├── di/            # Dependency Injection (GetIt)
│   ├── error/         # Error handling
│   ├── routes/        # Navigation
│   ├── services/      # App services (Analytics, FCM, AdMob)
│   └── theme/         # Neuromorphic design system
│
├── domain/            # Business Logic
│   ├── entities/      # Domain models
│   ├── repositories/  # Repository interfaces
│   └── usecases/      # Use cases
│
├── data/              # Data Layer
│   ├── models/        # Data models
│   ├── datasources/   # Remote data sources (Firebase)
│   └── repositories/  # Repository implementations
│
└── presentation/      # UI Layer
    ├── blocs/         # BLoC state management
    ├── pages/         # UI screens (35+)
    └── widgets/       # Reusable widgets (24+)
```

**Pattern:** Clean Architecture + BLoC  
**DI:** GetIt + Injectable  
**Backend:** Firebase (Firestore, Functions, Auth, Storage, FCM)

> **Architecture detayları:** [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)

---

## 🎨 Design System

### Neuromorphic UI Highlights
- ✨ **16-24 layer shadows** - Ultra-deep 3D perception
- 🎯 **40+ shadow presets** - Ready-to-use combinations
- 💡 **Dynamic lighting** - Real-time light calculations
- 🎬 **Smooth animations** - 60 FPS interactions
- 📊 **Performance profiler** - Built-in monitoring tools

### Key Components
```dart
// Primary Button (12-layer shadows)
PrimaryButton(
  text: 'Takas Teklifi Gönder',
  onPressed: () {},
  enableUltraEffects: true,
)

// Neuromorphic Container
NeumorphismContainer(
  type: NeumorphismType.ultraOutset,
  depth: CardDepth.deep,
  enableParallax: true,
  child: YourWidget(),
)

// Neuromorphic Icon (4-layer with glow)
NeuromorphicIcon(
  icon: Icons.favorite,
  enableGlow: true,
  glowColor: AppColors.primary,
)
```

> **Complete design system:** [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md)

---

## 📅 Roadmap

### Current Sprint (Ocak 2025)
**Sprint 11: Bug Fixes & Stabilization**
- [x] Neuromorphic design errors (%81.4 fix)
- [ ] Profile page crash fix
- [ ] Favorites functionality fix
- [ ] Search functionality fix
- [ ] Unit test coverage (60%+)

### Upcoming Features
- **Sprint 12:** Production preparation (release build, store listing)
- **Sprint 13:** Advanced search (Algolia integration)
- **Sprint 14:** Social features (follow system, comments)
- **Sprint 15:** Premium features V2
- **Sprint 16:** AI integration (recommendations, image recognition)

### Production Timeline
- **Şubat 2025:** Soft launch (beta testers)
- **Şubat 2025:** Beta launch (500-1000 users)
- **Mart 2025:** Public launch (Play Store)
- **Nisan 2025+:** Growth & scaling

> **Complete roadmap:** [FEATURE_ROADMAP.md](FEATURE_ROADMAP.md)

---

## 🧪 Testing & Build

### Analysis
```bash
# Code analysis
flutter analyze

# Current status: 215 warnings (mostly deprecated APIs)
```

### Build
```bash
# Debug build
flutter build apk --debug

# Release build  
flutter build apk --release

# Install to device
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Testing
```bash
# Run tests
flutter test

# With coverage
flutter test --coverage
```

> **Testing guide:** [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#testing-guide)

---

## 🔥 Firebase Services

### Active Services
- ✅ **Authentication** - Email/Password, Google Sign-in
- ✅ **Firestore** - Real-time database
- ✅ **Storage** - Image uploads
- ✅ **Cloud Functions** - 4 deployed functions
  - `onMessageCreated` - New message notifications
  - `onTradeOfferCreated` - Trade offer notifications
  - `onTradeOfferUpdated` - Trade status updates
  - `onNotificationCreated` - General notifications
- ✅ **Analytics** - 12+ custom events
- ✅ **Cloud Messaging (FCM)** - Push notifications

### Firestore Collections
```
users/                    # User profiles
  └── {uid}/
      ├── notifications/  # User notifications
      └── fcmTokens/      # Push tokens
items/                    # Trading items
tradeOffers/              # Trade proposals
conversations/            # Chat conversations
messages/                 # Chat messages
ratings/                  # User ratings
```

---

## 🤝 Contributing

### Development Workflow
1. Branch oluştur: `feature/your-feature` veya `fix/bug-description`
2. Commit yap: Conventional commits kullan
3. Push yap: `git push origin feature/your-feature`
4. Pull request aç

### Commit Convention
```bash
feat:     # Yeni özellik
fix:      # Bug fix
docs:     # Dokümantasyon
style:    # Code style (formatting)
refactor: # Code refactoring
test:     # Test ekleme/güncelleme
chore:    # Build/tool changes

# Örnekler
feat: Add chat notification system
fix: Resolve profile page crash
docs: Update setup instructions
```

---

## 📄 License

This project is proprietary software developed for Boğaziçi University.

**© 2025 Barter Qween. All rights reserved.**

---

## 📞 İletişim

- **GitHub:** https://github.com/qween-code/barter-qween
- **Firebase:** https://console.firebase.google.com/project/bogazici-barter
- **Issues:** https://github.com/qween-code/barter-qween/issues

---

## 🌟 Credits

Built with ❤️ using:
- **Flutter & Dart** - Cross-platform framework
- **Firebase** - Backend infrastructure
- **BLoC Pattern** - State management
- **Clean Architecture** - Code organization
- **Neuromorphic Design** - Pinterest-level UI/UX

---

**Son Güncelleme:** 5 Ocak 2025  
**Status:** 🟡 **Development In Progress** - Production hazırlık aşamasında

🌟 **Star this repo if you find it useful!**
