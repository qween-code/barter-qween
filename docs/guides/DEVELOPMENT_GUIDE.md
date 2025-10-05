# 🛠️ Barter Qween - Development Guide

**Son Güncelleme:** 5 Ocak 2025  
**Hedef Kitle:** Developers, DevOps, QA

---

## 📋 İçindekiler
1. [Setup & Installation](#setup--installation)
2. [Project Architecture](#project-architecture)
3. [Development Workflow](#development-workflow)
4. [Testing Guide](#testing-guide)
5. [Firebase Configuration](#firebase-configuration)
6. [Deployment](#deployment)
7. [Troubleshooting](#troubleshooting)

---

## 🚀 Setup & Installation

### Prerequisites
```bash
# Required
- Flutter SDK 3.24.3 or higher
- Dart SDK 3.5.3 or higher
- Android Studio / VS Code
- Git

# Optional
- Firebase CLI
- Node.js 20+ (for Firebase Functions)
- Android SDK (for Android builds)
- Xcode (for iOS builds - macOS only)
```

### Installation Steps

#### 1. Clone Repository
```bash
git clone https://github.com/qween-code/barter-qween.git
cd barter-qween
```

#### 2. Install Dependencies
```bash
# Flutter dependencies
flutter pub get

# Firebase Functions dependencies (optional)
cd functions
npm install
cd ..
```

#### 3. Firebase Setup
```bash
# Install Firebase CLI (if not installed)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Select project
firebase use bogazici-barter
```

#### 4. Configure Firebase Files

**Android (`android/app/google-services.json`):**
- Download from Firebase Console → Project Settings → Your apps → Android
- Place in `android/app/`

**iOS (`ios/Runner/GoogleService-Info.plist`):**
- Download from Firebase Console → Project Settings → Your apps → iOS  
- Place in `ios/Runner/`

#### 5. Run the App
```bash
# Check connected devices
flutter devices

# Run on Android emulator
flutter run -d emulator-5554

# Run on connected Android device
flutter run

# Run with specific flavor (if configured)
flutter run --flavor dev
```

---

## 🏗️ Project Architecture

### Clean Architecture Layers

```
lib/
├── core/                       # Core functionality
│   ├── di/                     # Dependency Injection
│   │   └── injection.dart      # GetIt configuration
│   ├── error/                  # Error handling
│   │   ├── exceptions.dart     # Custom exceptions
│   │   └── failures.dart       # Failure classes
│   ├── routes/                 # Navigation
│   │   ├── app_routes.dart     # Route definitions
│   │   └── route_generator.dart
│   ├── services/               # App-wide services
│   │   ├── analytics_service.dart
│   │   ├── fcm_service.dart
│   │   ├── admob_service.dart
│   │   ├── iap_service.dart
│   │   └── payment_service.dart
│   ├── theme/                  # UI Theme
│   │   ├── app_colors.dart
│   │   ├── app_dimensions.dart
│   │   ├── app_text_styles.dart
│   │   ├── neumorphism_standards.dart
│   │   └── neuromorphic_effects.dart
│   └── utils/                  # Utilities
│       ├── constants.dart
│       └── validators.dart
├── data/                       # Data Layer
│   ├── datasources/            # Data sources
│   │   ├── remote/             # Firebase datasources
│   │   └── local/              # Local storage
│   ├── models/                 # Data models (JSON)
│   │   ├── user_model.dart
│   │   ├── item_model.dart
│   │   ├── trade_offer_model.dart
│   │   └── ...
│   └── repositories/           # Repository implementations
│       ├── user_repository_impl.dart
│       ├── item_repository_impl.dart
│       └── ...
├── domain/                     # Business Logic Layer
│   ├── entities/               # Business entities
│   │   ├── user_entity.dart
│   │   ├── item_entity.dart
│   │   └── ...
│   ├── repositories/           # Repository interfaces
│   │   ├── user_repository.dart
│   │   ├── item_repository.dart
│   │   └── ...
│   └── usecases/               # Use cases
│       ├── get_user_profile.dart
│       ├── create_item.dart
│       └── ...
└── presentation/               # UI Layer
    ├── blocs/                  # State management
    │   ├── auth/               # Auth BLoC
    │   ├── item/               # Item BLoC
    │   ├── trade/              # Trade BLoC
    │   └── ...
    ├── pages/                  # Screens
    │   ├── auth/
    │   ├── home/
    │   ├── item/
    │   ├── trade/
    │   ├── chat/
    │   └── ...
    └── widgets/                # Reusable widgets
        ├── common/
        ├── neumorphism/
        └── ...
```

### State Management (BLoC Pattern)

#### BLoC Structure
```dart
// Event
abstract class ItemEvent {}
class LoadItems extends ItemEvent {}
class CreateItem extends ItemEvent {
  final ItemEntity item;
  CreateItem(this.item);
}

// State
abstract class ItemState {}
class ItemInitial extends ItemState {}
class ItemLoading extends ItemState {}
class ItemLoaded extends ItemState {
  final List<ItemEntity> items;
  ItemLoaded(this.items);
}
class ItemError extends ItemState {
  final String message;
  ItemError(this.message);
}

// BLoC
class ItemBloc extends Bloc<ItemEvent, ItemState> {
  final GetItemsUseCase getItems;
  final CreateItemUseCase createItem;
  
  ItemBloc({
    required this.getItems,
    required this.createItem,
  }) : super(ItemInitial()) {
    on<LoadItems>(_onLoadItems);
    on<CreateItem>(_onCreateItem);
  }
  
  Future<void> _onLoadItems(LoadItems event, Emitter<ItemState> emit) async {
    emit(ItemLoading());
    final result = await getItems();
    result.fold(
      (failure) => emit(ItemError(failure.message)),
      (items) => emit(ItemLoaded(items)),
    );
  }
}
```

#### Usage in Widget
```dart
class ItemListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ItemBloc>()..add(LoadItems()),
      child: BlocBuilder<ItemBloc, ItemState>(
        builder: (context, state) {
          if (state is ItemLoading) {
            return CircularProgressIndicator();
          } else if (state is ItemLoaded) {
            return ListView.builder(
              itemCount: state.items.length,
              itemBuilder: (context, index) => ItemCard(state.items[index]),
            );
          } else if (state is ItemError) {
            return Text(state.message);
          }
          return SizedBox();
        },
      ),
    );
  }
}
```

### Dependency Injection (GetIt)

```dart
// core/di/injection.dart
final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() {
  getIt.init();
}

// Annotations
@injectable  // Standard singleton
@lazySingleton  // Lazy loaded singleton
@singleton  // Eager singleton

// Usage
@injectable
class ItemRepository implements ItemRepositoryInterface {
  final ItemRemoteDataSource remoteDataSource;
  
  ItemRepository(this.remoteDataSource);
}

// In main.dart
void main() {
  configureDependencies();
  runApp(MyApp());
}
```

---

## 💻 Development Workflow

### Branch Strategy
```
master              # Production-ready code
  └── develop       # Development branch
      ├── feature/* # New features
      ├── fix/*     # Bug fixes
      └── chore/*   # Maintenance tasks
```

### Commit Convention
```bash
feat: Add new feature
fix: Bug fix
docs: Documentation changes
style: Code style changes (formatting)
refactor: Code refactoring
test: Test additions/changes
chore: Build process or auxiliary tool changes

# Examples
feat: Add chat notification system
fix: Resolve profile page crash
docs: Update setup instructions
chore: Update dependencies
```

### Pull Request Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Widget tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
```

---

## 🧪 Testing Guide

### Unit Tests

#### Running Tests
```bash
# All tests
flutter test

# Specific test file
flutter test test/domain/usecases/get_items_test.dart

# With coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

#### Test Structure
```dart
// test/domain/usecases/get_items_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([ItemRepository])
void main() {
  late GetItemsUseCase usecase;
  late MockItemRepository mockRepository;

  setUp(() {
    mockRepository = MockItemRepository();
    usecase = GetItemsUseCase(mockRepository);
  });

  test('should return list of items from repository', () async {
    // Arrange
    final tItems = [ItemEntity(id: '1', title: 'Test')];
    when(mockRepository.getItems()).thenAnswer((_) async => Right(tItems));

    // Act
    final result = await usecase();

    // Assert
    expect(result, Right(tItems));
    verify(mockRepository.getItems());
    verifyNoMoreInteractions(mockRepository);
  });
}
```

### Widget Tests
```dart
// test/presentation/widgets/item_card_test.dart
void main() {
  testWidgets('ItemCard displays item information', (tester) async {
    final item = ItemEntity(
      id: '1',
      title: 'Test Item',
      description: 'Description',
    );

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: ItemCard(item))),
    );

    expect(find.text('Test Item'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
  });
}
```

### Integration Tests
```dart
// integration_test/app_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete user flow test', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Login
    await tester.enterText(find.byKey(Key('email_field')), 'test@test.com');
    await tester.enterText(find.byKey(Key('password_field')), 'password');
    await tester.tap(find.byKey(Key('login_button')));
    await tester.pumpAndSettle();

    // Navigate to create item
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Fill item form
    await tester.enterText(find.byKey(Key('title_field')), 'New Item');
    await tester.tap(find.byKey(Key('submit_button')));
    await tester.pumpAndSettle();

    // Verify item created
    expect(find.text('New Item'), findsWidgets);
  });
}
```

### Device Testing Guide

#### Android Physical Device
```bash
# Enable USB debugging on device
# Settings → About Phone → Tap Build Number 7 times
# Settings → Developer Options → Enable USB Debugging

# Check connected devices
adb devices

# Install debug APK
flutter build apk --debug
adb install build/app/outputs/flutter-apk/app-debug.apk

# View logs
adb logcat | grep flutter
```

#### iOS Physical Device (macOS only)
```bash
# Open Xcode
open ios/Runner.xcworkspace

# Select your device
# Product → Destination → Your Device

# Run
flutter run -d <device-id>
```

#### Testing Scenarios

**Critical Flows:**
1. **Authentication Flow**
   - Register new user
   - Login with email/password
   - Login with Google
   - Logout

2. **Item Management**
   - Create new item (with photos)
   - Edit item
   - Delete item
   - View item details

3. **Trade Flow**
   - Send trade offer
   - Receive trade offer
   - Accept trade
   - Reject trade
   - Complete trade

4. **Chat Flow**
   - Start new conversation
   - Send message
   - Receive message
   - View conversation history

5. **Notification Flow**
   - Receive push notification
   - Tap notification
   - Navigate to correct screen
   - Mark as read

---

## 🔥 Firebase Configuration

### Firestore Security Rules

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && isOwner(userId);
      allow update: if isAuthenticated() && isOwner(userId);
      allow delete: if false;
      
      // Subcollections
      match /notifications/{notifId} {
        allow read: if isOwner(userId);
        allow write: if isOwner(userId);
      }
      
      match /fcmTokens/{tokenId} {
        allow read: if isOwner(userId);
        allow write: if isOwner(userId);
      }
    }
    
    // Items collection
    match /items/{itemId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && 
                      request.resource.data.ownerId == request.auth.uid;
      allow update: if isAuthenticated() && 
                      resource.data.ownerId == request.auth.uid;
      allow delete: if isAuthenticated() && 
                      resource.data.ownerId == request.auth.uid;
    }
    
    // Trade offers
    match /tradeOffers/{offerId} {
      allow read: if isAuthenticated() && 
                    (resource.data.senderId == request.auth.uid || 
                     resource.data.receiverId == request.auth.uid);
      allow create: if isAuthenticated() && 
                      request.resource.data.senderId == request.auth.uid;
      allow update: if isAuthenticated() && 
                      (resource.data.senderId == request.auth.uid || 
                       resource.data.receiverId == request.auth.uid);
      allow delete: if false;
    }
    
    // Conversations
    match /conversations/{conversationId} {
      allow read: if isAuthenticated() && 
                    request.auth.uid in resource.data.participantIds;
      allow create: if isAuthenticated() && 
                      request.auth.uid in request.resource.data.participantIds;
      allow update: if isAuthenticated() && 
                      request.auth.uid in resource.data.participantIds;
      allow delete: if false;
    }
    
    // Messages
    match /messages/{messageId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && 
                      request.resource.data.senderId == request.auth.uid;
      allow update: if false;
      allow delete: if false;
    }
    
    // Ratings
    match /ratings/{ratingId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && 
                      request.resource.data.raterId == request.auth.uid;
      allow update: if isAuthenticated() && 
                      resource.data.raterId == request.auth.uid;
      allow delete: if false;
    }
  }
}
```

### Deploy Security Rules
```bash
firebase deploy --only firestore:rules
```

### Cloud Functions

#### Setup
```bash
cd functions
npm install
```

#### Local Testing
```bash
# Start emulator
firebase emulators:start

# Test specific function
firebase functions:shell
```

#### Deploy Functions
```bash
# Deploy all functions
firebase deploy --only functions

# Deploy specific function
firebase deploy --only functions:onMessageCreated
```

#### Function Structure
```typescript
// functions/src/index.ts
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

export const onMessageCreated = functions.firestore
  .document("messages/{messageId}")
  .onCreate(async (snapshot, context) => {
    const message = snapshot.data();
    const conversationId = message.conversationId;
    
    // Get conversation
    const conversationDoc = await admin.firestore()
      .collection("conversations")
      .doc(conversationId)
      .get();
    
    const conversation = conversationDoc.data();
    if (!conversation) return;
    
    // Get recipient
    const recipientId = conversation.participantIds.find(
      (id: string) => id !== message.senderId
    );
    
    // Send notification
    await sendPushNotification(recipientId, {
      title: "New Message",
      body: message.text,
      data: {
        type: "chat",
        conversationId: conversationId,
      },
    });
  });
```

---

## 📦 Deployment

### Build Configuration

#### Android Release Build
```bash
# Generate keystore (first time only)
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# Update android/key.properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-upload-keystore.jks>

# Build release APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

#### iOS Release Build (macOS only)
```bash
# Update version in pubspec.yaml
version: 1.0.0+1

# Clean build
flutter clean
flutter pub get

# Build iOS
flutter build ios --release

# Open Xcode for signing
open ios/Runner.xcworkspace
```

### Play Store Deployment

1. **Create Developer Account**
   - https://play.google.com/console
   - Pay $25 one-time fee

2. **Create App**
   - App name: "Barter Qween"
   - Default language: Turkish
   - Category: Social / Shopping

3. **Upload APK/Bundle**
   - Internal testing → Create release
   - Upload `app-release.aab`
   - Add release notes

4. **Store Listing**
   - Short description (80 chars)
   - Full description (4000 chars)
   - Screenshots (min 2, max 8)
   - Feature graphic (1024x500)
   - App icon (512x512)

5. **Content Rating**
   - Complete questionnaire
   - Get rating

6. **Pricing & Distribution**
   - Free/Paid
   - Countries
   - Age restrictions

---

## 🔧 Troubleshooting

### Common Issues

#### 1. Flutter Doctor Issues
```bash
flutter doctor -v
flutter doctor --android-licenses
```

#### 2. Build Errors
```bash
# Clean build
flutter clean
flutter pub get
flutter pub upgrade

# Clear cache
rm -rf build/
rm -rf ios/Pods ios/Podfile.lock
cd ios && pod install && cd ..
```

#### 3. Firebase Connection Issues
```bash
# Verify google-services.json exists
ls android/app/google-services.json

# Check Firebase project
firebase projects:list

# Re-initialize if needed
firebase use bogazici-barter
```

#### 4. Hot Reload Not Working
```bash
# Restart with hot reload
r

# Restart with full rebuild
R

# Or restart Flutter
flutter run
```

#### 5. Gradle Build Errors
```bash
# Update Gradle wrapper
cd android
./gradlew wrapper --gradle-version 8.0
cd ..

# Clear Gradle cache
cd android && ./gradlew clean && cd ..
```

---

## 📚 Additional Resources

- **Flutter Documentation:** https://docs.flutter.dev/
- **Firebase Documentation:** https://firebase.google.com/docs
- **BLoC Pattern:** https://bloclibrary.dev/
- **GetIt DI:** https://pub.dev/packages/get_it
- **Clean Architecture:** https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html

---

**Son Güncelleme:** 5 Ocak 2025  
**Dokümantasyon Versiyonu:** 2.0
