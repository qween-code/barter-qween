# 🔧 DEVELOPMENT WORKFLOW

## Git Branch Strategy

### Ana Dallar
```
main (production)
  └── develop (integration)
       └── feature/* (sprint özellikleri)
       └── bugfix/* (hata düzeltmeleri)
       └── hotfix/* (acil düzeltmeler)
```

### Branch Naming Convention
```
feature/sprint-1-barter-conditions
feature/sprint-2-i18n
bugfix/fix-image-upload
hotfix/critical-auth-issue
```

## Sprint Workflow

### Sprint Başlangıcı
```bash
# 1. Develop'tan yeni feature branch oluştur
git checkout develop
git pull origin develop
git checkout -b feature/sprint-1-barter-conditions

# 2. İlk commit (boş commit ile başla)
git commit --allow-empty -m "chore: start sprint 1 - barter conditions"
git push -u origin feature/sprint-1-barter-conditions
```

### Geliştirme Sırasında
```bash
# Sık sık commit yap (atomic commits)
git add .
git commit -m "feat(domain): add barter condition entity"
git push

# Her gün develop'tan değişiklikleri çek
git checkout develop
git pull origin develop
git checkout feature/sprint-1-barter-conditions
git merge develop
```

### Sprint Bitişi
```bash
# 1. Test et
flutter test --coverage
flutter analyze

# 2. Pull request oluştur
# GitHub/GitLab üzerinden PR aç

# 3. Code review sonrası merge
# develop <- feature branch

# 4. Branch'i temizle
git branch -d feature/sprint-1-barter-conditions
git push origin --delete feature/sprint-1-barter-conditions
```

## Commit Message Convention

### Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- **feat**: Yeni özellik
- **fix**: Bug fix
- **docs**: Dokümantasyon
- **style**: Code formatting
- **refactor**: Code refactoring
- **test**: Test ekleme/güncelleme
- **chore**: Build/config değişiklikleri

### Örnekler
```bash
feat(domain): add barter condition entity
fix(ui): resolve image carousel crash
docs(readme): update installation steps
refactor(bloc): simplify trade bloc logic
test(usecase): add unit tests for barter matching
chore(deps): update firebase dependencies
```

## Development Environment Setup

### 1. Flutter Environment
```bash
# Flutter version kontrol
flutter --version  # Should be 3.19.0+

# Dependencies yükle
flutter pub get

# Code generation
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Firebase Setup
```bash
# Firebase CLI yükle (eğer yoksa)
npm install -g firebase-tools

# Login
firebase login

# Proje seç
firebase use default

# Functions bağımlılıkları
cd functions
npm install
cd ..
```

### 3. IDE Setup

**VS Code Extensions:**
- Dart
- Flutter
- Bloc
- GitLens
- Error Lens

**Recommended settings.json:**
```json
{
  "dart.lineLength": 100,
  "editor.formatOnSave": true,
  "dart.flutterSdkPath": "path/to/flutter",
  "[dart]": {
    "editor.rulers": [100],
    "editor.tabSize": 2
  }
}
```

## Code Quality Checks

### Pre-commit Checklist
```bash
# 1. Format code
dart format .

# 2. Analyze
flutter analyze

# 3. Run tests
flutter test

# 4. Check coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### CI/CD Pipeline (GitHub Actions örnek)
```yaml
# .github/workflows/flutter.yml
name: Flutter CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
```

## Daily Development Routine

### Her Gün
1. **Morning sync**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout feature/your-branch
   git merge develop
   ```

2. **Küçük commitler yap** (her mantıksal değişiklik için)

3. **Testlerini yaz** (TDD tercih ediliyor)

4. **End of day push**
   ```bash
   git push origin feature/your-branch
   ```

## Sprint Review Checklist

### Sprint bitince kontrol et:
- [ ] Tüm testler geçiyor mu? (`flutter test`)
- [ ] Analyze temiz mi? (`flutter analyze`)
- [ ] Coverage %70+ mı?
- [ ] README güncel mi?
- [ ] CHANGELOG.md güncellenmiş mi?
- [ ] Yeni dependencies dokümante edilmiş mi?
- [ ] Breaking changes var mı? (varsa not al)
- [ ] Firebase'de gerekli index'ler oluşturuldu mu?
- [ ] Security rules güncellenmiş mi?

## Debugging Tips

### Flutter DevTools
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### Firebase Emulator
```bash
# Local test için emulator kullan
firebase emulators:start
```

### Logging Best Practices
```dart
// Debug log
debugPrint('User ID: $userId');

// Production log (Firebase Analytics)
analyticsService.logEvent(
  name: 'barter_condition_created',
  parameters: {'condition_type': 'cashPlus'},
);
```

## Troubleshooting

### Common Issues

**1. Build errors after dependency update**
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

**2. Firebase connection issues**
```bash
# FlutterFire CLI ile yeniden yapılandır
flutterfire configure
```

**3. iOS build issues**
```bash
cd ios
pod deintegrate
pod install
cd ..
```

## Performance Monitoring

### Metrics to Track
- App startup time: < 3 seconds
- Screen transition: < 300ms
- API response time: < 1 second
- Memory usage: < 200MB
- Crash-free rate: > 99%

### Tools
- Firebase Performance Monitoring
- Firebase Crashlytics
- Flutter DevTools

---

**Hazırlayan:** AI Assistant  
**Versiyon:** 1.0  
**Son Güncelleme:** 2025-01-03
