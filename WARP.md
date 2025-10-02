# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

**Barter Qween** is a modern Flutter trading/bartering app with Firebase backend, built using Clean Architecture principles and BLoC state management. Users can create, browse, and trade items with each other through a comprehensive trade offer system.

**Tech Stack:**
- Flutter 3.27.1+ with Dart 3.8.1+
- Firebase (Auth, Firestore, Storage, Messaging)
- BLoC state management with flutter_bloc
- Dependency injection with get_it/injectable
- Clean Architecture (Domain/Data/Presentation layers)

## Essential Commands

### Development Setup
```bash
# Install dependencies
flutter pub get

# Generate dependency injection code (REQUIRED after adding new services)
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Code Quality & Analysis
```bash
# Analyze code for issues
flutter analyze

# Format code
dart format .

# Check code formatting
dart format --set-exit-if-changed .
```

### Build Commands
```bash
# Debug build
flutter build apk --debug

# Release build (production)
flutter build apk --release

# App bundle for Play Store
flutter build appbundle --release
```

### Firebase Deployment
```bash
# Deploy Firestore rules and indexes (REQUIRED after schema changes)
firebase deploy --only firestore:rules,firestore:indexes,storage

# Seed database with test data
npm run seed
```

### Testing
```bash
# Run tests (when available)
flutter test

# Run tests with coverage
flutter test --coverage
```

## Architecture Overview

This project follows **Clean Architecture** with strict layer separation:

### Core Structure
```
lib/
├── core/                     # Shared functionality
│   ├── di/                  # Dependency injection (get_it/injectable)
│   ├── error/               # Exception & failure handling
│   ├── routes/              # Navigation routes
│   ├── theme/               # App theming (Material Design 3)
│   └── utils/               # Utilities & constants
│
├── domain/                   # Business logic (pure Dart)
│   ├── entities/            # Domain models
│   ├── repositories/        # Repository interfaces
│   └── usecases/            # Business use cases
│
├── data/                     # External data (Firebase)
│   ├── models/              # Data models with Firebase serialization
│   ├── datasources/remote/  # Firebase data sources
│   └── repositories/        # Repository implementations
│
└── presentation/             # UI layer
    ├── blocs/               # BLoC state management
    ├── pages/               # Screen widgets
    └── widgets/             # Reusable UI components
```

### State Management Pattern
- **BLoC (Business Logic Component)** pattern throughout
- Events trigger business logic
- States drive UI updates
- Clear separation of concerns

### Key Design Patterns
1. **Repository Pattern** - Abstracts data sources
2. **Dependency Injection** - Injectable services with get_it
3. **Either Pattern** - Functional error handling with dartz
4. **Event-Driven Architecture** - BLoC events and states

## Firebase Integration

### Collections Schema
```javascript
// Core collections
users/               # User profiles
items/               # Tradeable items
tradeOffers/         # Trade negotiations
favorites/           # User favorites (future)
```

### Security Rules
- **Storage:** User-scoped paths (`items/{userId}/`)
- **Firestore:** Role-based access with authentication checks
- **Indexes:** Composite indexes for complex queries

### Required Firebase Setup
1. Authentication (Email/Password + Google Sign-In)
2. Cloud Firestore with security rules
3. Firebase Storage for images
4. Firebase Messaging for notifications

## Common Development Tasks

### Adding New Features
1. **Domain Layer First:** Create entities, use cases, repository interfaces
2. **Data Layer:** Implement Firebase data sources and repository
3. **Presentation Layer:** Create BLoC (events/states) and UI
4. **Dependency Injection:** Update `injection.dart` and run build_runner

### BLoC Implementation Pattern
```dart
// Event
sealed class FeatureEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// State
sealed class FeatureState extends Equatable {
  @override
  List<Object> get props => [];
}

// BLoC
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  // Constructor with dependency injection
  // Event handlers using on<Event>()
}
```

### Firebase Operations
- Always use repository pattern, never direct Firebase calls in UI
- Handle offline scenarios and network errors
- Use proper error handling with Either<Failure, Success> pattern
- Images: Upload to Storage with user-scoped paths

### Error Handling
- Domain exceptions mapped to failures
- UI displays user-friendly error messages
- Offline capability considerations

## Code Quality Guidelines

### File Naming & Structure
- Snake_case for file names
- Follow Clean Architecture folder structure
- Consistent import organization (external → internal → relative)

### BLoC Guidelines
- One BLoC per feature/screen
- Events are user actions or system events
- States represent UI states (loading, loaded, error)
- Use Equatable for events and states
- Provide BLoCs via MultiBlocProvider when needed

### Firebase Best Practices
- Use composite indexes for complex queries
- Implement proper security rules
- Cache frequently accessed data
- Optimize image sizes and use cached_network_image

## Current Development Status

**Completed Phases:**
- ✅ Phase 0: Authentication (Email/Password, Google Sign-In)
- ✅ Phase 1: Profile Management (view, edit, avatar upload)
- ✅ Phase 2: Item Management (CRUD, search, categories, sharing)
- ✅ Phase 3: Trade System (send, accept, reject, cancel offers)

**Active Development:**
- Phase 4: Chat System (real-time messaging)
- Phase 5: Advanced Search & Filters
- Phase 6: Push Notifications
- Phase 7: UI/UX Polish

**Known Issues:**
- Search functionality needs backend optimization (current: client-side only)
- Testing coverage is minimal (~2%)
- Some performance optimizations needed for large datasets

## Key Dependencies

### Core Flutter
```yaml
flutter_bloc: ^8.1.3          # State management
equatable: ^2.0.5             # Value equality
get_it: ^7.6.4               # Service locator
injectable: ^2.3.2            # DI code generation
dartz: ^0.10.1               # Functional programming
```

### Firebase
```yaml
firebase_core: ^2.24.0        # Firebase SDK
firebase_auth: ^4.17.0        # Authentication
cloud_firestore: ^4.15.0     # Database
firebase_storage: ^11.5.0    # File storage
firebase_messaging: ^14.7.10  # Push notifications
google_sign_in: ^6.2.1       # Google Auth
```

### Development Tools
```yaml
build_runner: ^2.4.6         # Code generation
injectable_generator: ^2.4.1  # DI generation
flutter_lints: ^5.0.0        # Code analysis
```

## Environment Setup Requirements

- Flutter 3.27.1 or higher
- Dart 3.8.1 or higher
- Firebase CLI (for deploying rules)
- Node.js (for seeding scripts)
- Valid Firebase project with all services enabled

## Testing Strategy

While current test coverage is minimal, the architecture supports:
- **Unit Tests:** Use cases, repositories, BLoCs
- **Widget Tests:** UI components
- **Integration Tests:** Full user flows
- **Firebase Integration:** Use Firebase emulator suite

## Deployment Notes

- **Debug APK:** ~43 MB
- **Release APK:** ~26 MB estimated
- Requires Firebase configuration files:
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`
- Firebase rules and indexes must be deployed before production

## Important Notes

- Always run `build_runner` after modifying dependency injection
- Firebase indexes take 5-10 minutes to build after deployment
- Use BlocProvider.value() when navigating to preserve parent BLoCs
- Images are stored with user-scoped paths for security
- The app uses Material Design 3 with custom theming

---

This codebase demonstrates production-ready Flutter development with enterprise-level architecture patterns and comprehensive Firebase integration.