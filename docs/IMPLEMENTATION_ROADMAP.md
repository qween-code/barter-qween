# 📋 DETAYLI UYGULAMA YOL HARİTASI
## Barter Qween - Eksik Özellikler İmplementasyon Planı

> **Proje Yapısı:** Clean Architecture + BLoC Pattern + Repository Pattern  
> **Backend:** Firebase (Firestore + Cloud Functions + Storage + Auth)  
> **Tahmini Süre:** 18-26 hafta (4.5-6.5 ay)

---

## 🎯 FAZ 1: KRİTİK ÖZELLİKLER (7-11 HAFTA)

### ✅ SPRINT 1: BARTER HAVUZU ŞARTLARI SİSTEMİ (2-3 HAFTA) - ✅ TAMAMLANDI

> **Öncelik:** 🔥 Kritik - Brief'in ana diferansiyatörü  
> **Karmaşıklık:** Yüksek  
> **Bağımlılıklar:** Mevcut item ve trade sistemleri  
> **Tamamlanma Tarihi:** 1 Haziran 2025  
> **Dokümantasyon:** SPRINT1_COMPLETED.md

#### 1.1. Domain Layer - Entity Genişletmeleri

**Dosya: `lib/domain/entities/barter_condition_entity.dart` (YENİ)**
```dart
// Barter şartlarını tanımlayan yeni entity
class BarterConditionEntity extends Equatable {
  final String id;
  final BarterConditionType type;
  final double? cashDifferential;     // "Ürün + X TL"
  final List<String>? acceptedCategories; // Kabul edilen kategoriler
  final String? specificItemRequest;  // Belirli ürün talebi
  final double? minValue;             // Minimum değer
  final double? maxValue;             // Maximum değer
  final String? description;          // Özel şartlar açıklaması
}

enum BarterConditionType {
  directSwap,          // Direkt takas
  cashPlus,            // Ürün + para
  cashMinus,           // Ürün - para (alıcı ekstra ödeme yapacak)
  categorySpecific,    // Belirli kategorilerle takas
  specificItem,        // Belirli ürün talebi
  valueRange,          // Değer aralığı
}
```

**Dosya: `lib/domain/entities/item_entity.dart` (GÜNCELLEME)**
```dart
// Mevcut ItemEntity'ye eklenecekler:
class ItemEntity extends Equatable {
  // ... Mevcut fieldlar ...
  
  // YENİ FIELDLAR:
  final ItemTier? tier;                      // Küçük/Orta/Büyük
  final double? monetaryValue;               // TL cinsinden değer
  final BarterConditionEntity? barterCondition; // Barter şartları
  final List<String>? videoUrls;             // Video desteği
  final bool? requiresDelivery;              // Teslimat gereksinimi
  final String? deliveryInfo;                // Teslimat bilgisi
  final ModerationStatus moderationStatus;   // Onay durumu
  final String? adminNotes;                  // Admin notları
  final DateTime? approvedAt;                // Onay tarihi
  final String? approvedBy;                  // Onaylayan admin
}

enum ItemTier {
  small,   // Küçük değer (0-500 TL)
  medium,  // Orta değer (500-2000 TL)
  large,   // Büyük değer (2000+ TL)
}

enum ModerationStatus {
  pending,      // Onay bekliyor
  approved,     // Onaylandı
  rejected,     // Reddedildi
  flagged,      // İşaretlendi (inceleme gerekiyor)
  autoApproved, // Otomatik onaylandı
}
```

**Dosya: `lib/domain/entities/trade_offer_entity.dart` (GÜNCELLEME)**
```dart
// Mevcut TradeOfferEntity'ye eklenecekler:
class TradeOfferEntity extends Equatable {
  // ... Mevcut fieldlar ...
  
  // YENİ FIELDLAR:
  final double? cashDifferential;      // Para farkı (+/-)
  final CashPaymentDirection? paymentDirection; // Kim ödeyecek
  final String? conditionNotes;        // Şart notları
  final bool meetsBarterCondition;     // Şartlara uyuyor mu?
}

enum CashPaymentDirection {
  fromOfferer,  // Teklif veren ödeyecek
  toOfferer,    // Teklif veren alacak
}
```

#### 1.2. Data Layer - Model ve Repository

**Dosya: `lib/data/models/barter_condition_model.dart` (YENİ)**
```dart
class BarterConditionModel extends BarterConditionEntity {
  // Entity'den Model'e dönüşüm
  // Firestore'dan JSON mapping
  factory BarterConditionModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

**Dosya: `lib/data/models/item_model.dart` (GÜNCELLEME)**
```dart
// ItemModel'e yeni fieldların JSON mapping'i ekle
class ItemModel extends ItemEntity {
  // ... Mevcut kod ...
  
  // YENİ FIELDLAR İÇİN JSON MAPPING:
  factory ItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ItemModel(
      // ... Mevcut mapping ...
      tier: _parseTier(data['tier']),
      monetaryValue: data['monetaryValue']?.toDouble(),
      barterCondition: data['barterCondition'] != null 
          ? BarterConditionModel.fromJson(data['barterCondition'])
          : null,
      videoUrls: List<String>.from(data['videoUrls'] ?? []),
      moderationStatus: _parseModerationStatus(data['moderationStatus']),
      // ...
    );
  }
}
```

**Dosya: `lib/domain/repositories/barter_repository.dart` (YENİ)**
```dart
abstract class BarterRepository {
  Future<Either<Failure, List<ItemEntity>>> getItemsByBarterCondition(
    BarterConditionEntity condition,
  );
  
  Future<Either<Failure, bool>> validateBarterMatch(
    String offeredItemId,
    String requestedItemId,
  );
  
  Future<Either<Failure, double>> calculateCashDifferential(
    String item1Id,
    String item2Id,
  );
}
```

**Dosya: `lib/data/repositories/barter_repository_impl.dart` (YENİ)**
```dart
class BarterRepositoryImpl implements BarterRepository {
  final FirebaseFirestore _firestore;
  
  @override
  Future<Either<Failure, bool>> validateBarterMatch(...) async {
    // Barter şartlarını kontrol et
    // Değer uyumunu hesapla
    // Kategori uygunluğunu kontrol et
  }
}
```

#### 1.3. Presentation Layer - BLoC ve UI

**Dosya: `lib/presentation/blocs/barter/barter_bloc.dart` (YENİ)**
```dart
// Barter şartlarını yöneten BLoC
class BarterBloc extends Bloc<BarterEvent, BarterState> {
  final ValidateBarterMatchUseCase validateBarterMatch;
  final CalculateCashDifferentialUseCase calculateCashDifferential;
  
  BarterBloc({
    required this.validateBarterMatch,
    required this.calculateCashDifferential,
  }) : super(BarterInitial()) {
    on<ValidateBarterCondition>(_onValidateCondition);
    on<CalculateCashDifference>(_onCalculateDifference);
  }
}
```

**Dosya: `lib/presentation/pages/items/create_item_wizard_page.dart` (YENİ - WIZARD)**
```dart
// Adım adım ilan oluşturma wizard'ı
class CreateItemWizardPage extends StatefulWidget {
  // Step 1: Kategori seçimi
  // Step 2: Foto/Video yükleme
  // Step 3: Açıklama ve detaylar
  // Step 4: Değerleme (TL fiyat)
  // Step 5: Barter şartları belirleme
  // Step 6: İnceleme ve gönderim
}
```

**Dosya: `lib/presentation/widgets/barter/barter_condition_selector.dart` (YENİ)**
```dart
// Barter şartlarını seçmek için widget
class BarterConditionSelector extends StatefulWidget {
  // "Direkt takas" seçeneği
  // "Ürünüm + X TL" seçeneği
  // "Belirli kategorilerle takas" seçeneği
  // "Belirli ürün talebi" seçeneği
}
```

**Dosya: `lib/presentation/widgets/items/monetary_value_input.dart` (YENİ)**
```dart
// TL cinsinden fiyat girişi widget'ı
class MonetaryValueInput extends StatelessWidget {
  final double? initialValue;
  final Function(double) onChanged;
  // Para birimi formatı (₺)
  // Değer aralığı önerileri
}
```

#### 1.4. Firebase Backend - Cloud Functions

**Dosya: `functions/src/barter/matchingAlgorithm.ts` (YENİ)**
```typescript
// Barter eşleştirme algoritması
export const calculateBarterMatch = functions.https.onCall(async (data, context) => {
  const { offeredItemId, requestedItemId } = data;
  
  // 1. İki ürünün değerlerini al
  // 2. Kategori uyumunu kontrol et
  // 3. Barter şartlarını karşılaştır
  // 4. Uygunluk skoru hesapla
  // 5. Para farkı önerisi hesapla (gerekirse)
  
  return {
    isMatch: boolean,
    compatibilityScore: number,
    suggestedCashDifferential: number,
    reason: string,
  };
});
```

**Firestore Collections (YENİ/GÜNCELLEME):**
```
items/
  {itemId}/
    barterCondition:
      type: "cashPlus"
      cashDifferential: 500
      acceptedCategories: ["Electronics", "Fashion"]
    monetaryValue: 2500
    tier: "medium"
    moderationStatus: "pending"
    videoUrls: []
```

#### 1.5. UseCase Implementasyonu

**Dosya: `lib/domain/usecases/barter/validate_barter_match_usecase.dart` (YENİ)**
**Dosya: `lib/domain/usecases/barter/calculate_cash_differential_usecase.dart` (YENİ)**
**Dosya: `lib/domain/usecases/barter/get_matching_items_usecase.dart` (YENİ)**

#### 1.6. Dependency Injection

**Dosya: `lib/core/di/injection.dart` (GÜNCELLEME)**
```dart
// Yeni barter servisleri DI'a ekle
@module
abstract class AppModule {
  // ... Mevcut dependencies ...
  
  // YENİ DEPENDENCIES:
  @lazySingleton
  BarterRepository get barterRepository => BarterRepositoryImpl(
    firestore: get<FirebaseFirestore>(),
  );
  
  @lazySingleton
  ValidateBarterMatchUseCase get validateBarterMatch => ValidateBarterMatchUseCase(
    repository: get<BarterRepository>(),
  );
}
```

---

### ✅ SPRINT 2: BARTER GÖRSEL SİSTEMİ (1 HAFTA) - ✅ TAMAMLANDI

> **Öncelik:** 🔥 Kritik - UI/UX gereksinimi  
> **Karmaşıklık:** Orta  
> **Tamamlanma Tarihi:** 1 Haziran 2025  
> **Dokümantasyon:** SPRINT2_COMPLETED.md  
> **Özellikler:** Tüm barter display widget'ları, tier badges, match results page

### ✅ SPRINT 3: MATCH BİLDİRİMLERİ & UYUMLULUK ALGORİTMASI (1 HAFTA) - ✅ TAMAMLANDI

> **Öncelik:** 🔥 Kritik - Kullanıcı engagement  
> **Karmaşıklık:** Yüksek  
> **Tamamlanma Tarihi:** 1 Haziran 2025  
> **Dokümantasyon:** SPRINT3_COMPLETED.md  
> **Özellikler:** Gerçek zamanlı uyumluluk skoru, FCM match notifications, badge system

### ✅ SPRINT 4: ÇOKLU DİL DESTEĞİ (1-2 HAFTA) - ✅ TAMAMLANDI

> **Öncelik:** 🔥 Kritik - Global platform hedefi
> **Karmaşıklık:** Orta
> **Tamamlanma Tarihi:** 3 Ekim 2025
> **Dokümantasyon:** SPRINT4_COMPLETED.md
> **Framework:** Flutter Intl (l10n)

#### 2.1. L10n Kurulumu

**Dosya: `pubspec.yaml` (GÜNCELLEME)**
```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.0

flutter:
  generate: true
  
flutter_intl:
  enabled: true
```

**Dosya: `l10n.yaml` (YENİ)**
```yaml
arb-dir: lib/l10n
template-arb-file: app_tr.arb
output-localization-file: app_localizations.dart
```

#### 2.2. ARB Translation Files

**Dosya: `lib/l10n/app_tr.arb` (YENİ - Türkçe)**
```json
{
  "@@locale": "tr",
  "appTitle": "Barter Qween",
  "home": "Ana Sayfa",
  "explore": "Keşfet",
  "trades": "Takaslar",
  "profile": "Profil",
  "createItem": "İlan Oluştur",
  "itemTitle": "İlan Başlığı",
  "description": "Açıklama",
  "category": "Kategori",
  "barterConditions": "Takas Şartları",
  "monetaryValue": "Tahmini Değer (TL)",
  "directSwap": "Direkt Takas",
  "cashPlus": "Ürünüm + Para",
  "cashMinus": "Ürünüm - Para",
  // ... 200+ string
}
```

**Dosya: `lib/l10n/app_en.arb` (YENİ - İngilizce)**
```json
{
  "@@locale": "en",
  "appTitle": "Barter Qween",
  "home": "Home",
  "explore": "Explore",
  "trades": "Trades",
  "profile": "Profile",
  // ... İngilizce çeviriler
}
```

**Dosya: `lib/l10n/app_ar.arb` (YENİ - Arapça - RTL)**
```json
{
  "@@locale": "ar",
  "appTitle": "بارتر كوين",
  "home": "الرئيسية",
  // ... Arapça çeviriler (RTL desteği ile)
}
```

#### 2.3. Locale Management BLoC

**Dosya: `lib/presentation/blocs/locale/locale_bloc.dart` (YENİ)**
```dart
class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  final SharedPreferences prefs;
  
  LocaleBloc({required this.prefs}) : super(LocaleInitial()) {
    on<ChangeLocale>(_onChangeLocale);
    on<LoadSavedLocale>(_onLoadSavedLocale);
  }
  
  Future<void> _onChangeLocale(ChangeLocale event, Emitter<LocaleState> emit) async {
    await prefs.setString('locale', event.locale.languageCode);
    emit(LocaleChanged(locale: event.locale));
  }
}
```

#### 2.4. UI Updates

**Dosya: `lib/main.dart` (GÜNCELLEME)**
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocaleBloc(prefs: getIt())..add(LoadSavedLocale()),
      child: BlocBuilder<LocaleBloc, LocaleState>(
        builder: (context, localeState) {
          return MaterialApp(
            // YENİ:
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('tr'), // Türkçe
              Locale('en'), // İngilizce
              Locale('ar'), // Arapça
            ],
            locale: localeState is LocaleChanged 
                ? localeState.locale 
                : const Locale('tr'),
            // ...
          );
        },
      ),
    );
  }
}
```

**Dosya: `lib/presentation/pages/settings/language_settings_page.dart` (YENİ)**
```dart
// Dil seçimi ekranı
class LanguageSettingsPage extends StatelessWidget {
  // Türkçe seçeneği (bayrak + isim)
  // İngilizce seçeneği
  // Arapça seçeneği
  // RTL layout toggle
}
```

#### 2.5. String Migration Script

**Dosya: `scripts/migrate_strings.dart` (YENİ - Yardımcı Script)**
```dart
// Tüm hardcoded Türkçe stringleri bul ve ARB'ye taşı
// Otomatik replacement yap
void main() {
  // 1. Tüm .dart dosyalarını tara
  // 2. Hardcoded stringleri tespit et
  // 3. ARB dosyasına ekle
  // 4. AppLocalizations çağrısıyla değiştir
}
```

---

### 🔄 SPRINT 5: YÖNETİCİ PANELİ & İLAN ONAY SİSTEMİ (3-4 HAFTA)

> **Öncelik:** 🔥 Kritik - Brief'in temel gereksinimi  
> **Karmaşıklık:** Çok Yüksek  
> **Platform:** Flutter Web (Admin Panel)

#### 3.1. Domain Layer - Admin Entities

**Dosya: `lib/domain/entities/admin_user_entity.dart` (YENİ)**
```dart
class AdminUserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final AdminRole role;
  final List<AdminPermission> permissions;
  final DateTime createdAt;
  final bool isActive;
}

enum AdminRole {
  superAdmin,    // Tüm yetkiler
  moderator,     // İlan onaylama
  support,       // Kullanıcı desteği
  analyst,       // Raporlama
}

enum AdminPermission {
  approveItems,
  rejectItems,
  banUsers,
  viewAnalytics,
  manageUsers,
  editItemTiers,
  viewReports,
}
```

**Dosya: `lib/domain/entities/moderation_request_entity.dart` (YENİ)**
```dart
class ModerationRequestEntity extends Equatable {
  final String id;
  final String itemId;
  final ItemEntity item;
  final String userId;
  final ModerationStatus status;
  final ModerationPriority priority;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? reviewNotes;
  final ItemTier? suggestedTier;
  final List<String>? flagReasons;
}

enum ModerationPriority {
  low,
  medium,
  high,
  urgent,
}
```

#### 3.2. Admin Repository

**Dosya: `lib/domain/repositories/admin_repository.dart` (YENİ)**
```dart
abstract class AdminRepository {
  Future<Either<Failure, List<ModerationRequestEntity>>> getPendingItems({
    int page,
    int limit,
    ModerationPriority? priority,
  });
  
  Future<Either<Failure, void>> approveItem({
    required String itemId,
    required ItemTier tier,
    String? notes,
  });
  
  Future<Either<Failure, void>> rejectItem({
    required String itemId,
    required String reason,
  });
  
  Future<Either<Failure, AdminDashboardStats>> getDashboardStats();
  
  Future<Either<Failure, List<UserReportEntity>>> getUserReports();
}
```

#### 3.3. Firebase - Admin Claims & Rules

**Firebase Authentication Custom Claims:**
```typescript
// functions/src/admin/setAdminClaims.ts
export const setAdminRole = functions.https.onCall(async (data, context) => {
  // Sadece superAdmin çağırabilir
  if (context.auth?.token.role !== 'superAdmin') {
    throw new functions.https.HttpsError('permission-denied', 'Unauthorized');
  }
  
  const { userId, role, permissions } = data;
  
  await admin.auth().setCustomUserClaims(userId, {
    role: role,
    permissions: permissions,
    isAdmin: true,
  });
});
```

**Firestore Security Rules (GÜNCELLEME):**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Admin collection - sadece adminler erişebilir
    match /admins/{adminId} {
      allow read: if request.auth.token.isAdmin == true;
      allow write: if request.auth.token.role == 'superAdmin';
    }
    
    // Items - moderasyon durumuna göre görünürlük
    match /items/{itemId} {
      allow read: if resource.data.moderationStatus == 'approved' 
                  || request.auth.uid == resource.data.ownerId
                  || request.auth.token.isAdmin == true;
      
      allow create: if request.auth != null;
      
      allow update: if request.auth.uid == resource.data.ownerId
                    || request.auth.token.isAdmin == true;
      
      // Admin onay/red işlemleri
      allow update: if request.auth.token.permissions.hasAny(['approveItems'])
                    && request.resource.data.diff(resource.data).affectedKeys()
                       .hasOnly(['moderationStatus', 'tier', 'adminNotes', 'approvedAt', 'approvedBy']);
    }
    
    // Moderation requests
    match /moderationRequests/{requestId} {
      allow read, write: if request.auth.token.isAdmin == true;
    }
  }
}
```

#### 3.4. Cloud Functions - Auto-Moderation & Tier Assignment

**Dosya: `functions/src/moderation/autoTierAssignment.ts` (YENİ)**
```typescript
// Yeni ilan oluşturulduğunda otomatik tier belirleme
export const assignItemTier = functions.firestore
  .document('items/{itemId}')
  .onCreate(async (snap, context) => {
    const item = snap.data();
    
    // Tier hesaplama algoritması
    const tier = calculateTier({
      monetaryValue: item.monetaryValue,
      category: item.category,
      condition: item.condition,
      images: item.images.length,
      description: item.description.length,
    });
    
    // Moderation request oluştur
    await admin.firestore().collection('moderationRequests').add({
      itemId: context.params.itemId,
      userId: item.ownerId,
      status: 'pending',
      priority: determinePriority(tier),
      suggestedTier: tier,
      submittedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    
    // Item'ı pending durumuna al
    await snap.ref.update({
      moderationStatus: 'pending',
      tier: tier, // Önerilen tier
    });
  });

function calculateTier(item: any): string {
  const { monetaryValue, category, condition } = item;
  
  // Değer bazlı hesaplama
  if (monetaryValue < 500) return 'small';
  if (monetaryValue < 2000) return 'medium';
  return 'large';
}

function determinePriority(tier: string): string {
  // Büyük ilanlar yüksek öncelik
  if (tier === 'large') return 'high';
  if (tier === 'medium') return 'medium';
  return 'low';
}
```

**Dosya: `functions/src/moderation/contentModeration.ts` (YENİ)**
```typescript
// Google Cloud Vision API ile içerik moderasyonu
export const moderateItemImages = functions.firestore
  .document('items/{itemId}')
  .onCreate(async (snap, context) => {
    const item = snap.data();
    const vision = require('@google-cloud/vision');
    const client = new vision.ImageAnnotatorClient();
    
    // Her görseli kontrol et
    for (const imageUrl of item.images) {
      const [result] = await client.safeSearchDetection(imageUrl);
      const detections = result.safeSearchAnnotation;
      
      // Uygunsuz içerik tespit edilirse
      if (detections.adult === 'VERY_LIKELY' || 
          detections.violence === 'VERY_LIKELY') {
        await snap.ref.update({
          moderationStatus: 'rejected',
          rejectionReason: 'Inappropriate content detected',
        });
        
        // Admin bildirim gönder
        await sendAdminNotification({
          type: 'inappropriateContent',
          itemId: context.params.itemId,
        });
        
        return;
      }
    }
  });
```

#### 3.5. Admin Web Panel - Flutter Web

**Dosya: `lib/presentation/pages/admin/admin_dashboard_page.dart` (YENİ)**
```dart
class AdminDashboardPage extends StatelessWidget {
  // DASHBOARD WIDGETS:
  // - Pending items count
  // - Approved/rejected today
  // - Average review time
  // - User reports count
  // - Analytics charts
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sol sidebar - navigasyon
          AdminSidebar(),
          
          // Ana içerik
          Expanded(
            child: Column(
              children: [
                // Üst bar - kullanıcı, bildirimler
                AdminAppBar(),
                
                // İçerik alanı
                Expanded(child: _buildDashboardContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

**Dosya: `lib/presentation/pages/admin/item_moderation_page.dart` (YENİ)**
```dart
class ItemModerationPage extends StatefulWidget {
  // MODERATION WORKFLOW:
  // 1. Pending items listesi (filtreleme, sıralama)
  // 2. Item preview (büyük görseller, tüm detaylar)
  // 3. Tier assignment dropdown
  // 4. Approve/Reject buttons
  // 5. Notes/reason text field
  // 6. Quick actions (flag, priority change)
}
```

**Dosya: `lib/presentation/widgets/admin/item_review_card.dart` (YENİ)**
```dart
class ItemReviewCard extends StatelessWidget {
  final ModerationRequestEntity request;
  
  // CARD COMPONENTS:
  // - Item images carousel
  // - Item details (title, description, category)
  // - User info & history (previous items, ratings)
  // - Suggested tier (from algorithm)
  // - Quick approve/reject actions
  // - Detailed review modal
}
```

**Dosya: `lib/presentation/pages/admin/user_management_page.dart` (YENİ)**
```dart
class UserManagementPage extends StatelessWidget {
  // USER MANAGEMENT:
  // - User list with search/filters
  // - User details modal
  // - Ban/unban user
  // - View user activity
  // - User reports
}
```

#### 3.6. Admin BLoC

**Dosya: `lib/presentation/blocs/admin/admin_bloc.dart` (YENİ)**
```dart
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final GetPendingItemsUseCase getPendingItems;
  final ApproveItemUseCase approveItem;
  final RejectItemUseCase rejectItem;
  final GetDashboardStatsUseCase getDashboardStats;
  
  AdminBloc({
    required this.getPendingItems,
    required this.approveItem,
    required this.rejectItem,
    required this.getDashboardStats,
  }) : super(AdminInitial()) {
    on<LoadPendingItems>(_onLoadPendingItems);
    on<ApproveItemRequested>(_onApproveItem);
    on<RejectItemRequested>(_onRejectItem);
    on<LoadDashboardStats>(_onLoadDashboardStats);
  }
}
```

#### 3.7. Admin Route Guard

**Dosya: `lib/core/routes/admin_route_guard.dart` (YENİ)**
```dart
class AdminRouteGuard {
  static Future<bool> checkAdminAccess(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    
    final idTokenResult = await user.getIdTokenResult();
    final isAdmin = idTokenResult.claims?['isAdmin'] == true;
    
    if (!isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yetkisiz erişim')),
      );
    }
    
    return isAdmin;
  }
}
```

---

### 🔄 SPRINT 6: İLAN BÜYÜKLÜK/DEĞER SİSTEMİ (1-2 HAFTA)

> **Öncelik:** 🔥 Kritik  
> **Karmaşıklık:** Orta  
> **Bağımlılık:** Sprint 1 (monetaryValue field)

#### 4.1. Value Estimation Algorithm

**Dosya: `lib/core/utils/value_estimation.dart` (YENİ)**
```dart
class ValueEstimationHelper {
  static double estimateValue({
    required String category,
    required String condition,
    required int imageCount,
    required int descriptionLength,
    String? brand,
  }) {
    double baseValue = _getCategoryBaseValue(category);
    
    // Durum çarpanı
    double conditionMultiplier = _getConditionMultiplier(condition);
    
    // Görsel kalitesi bonusu
    double imageBonus = imageCount >= 3 ? 1.1 : 1.0;
    
    // Açıklama detay bonusu
    double descriptionBonus = descriptionLength > 200 ? 1.05 : 1.0;
    
    return baseValue * conditionMultiplier * imageBonus * descriptionBonus;
  }
  
  static double _getCategoryBaseValue(String category) {
    // Kategori bazlı ortalama değerler
    const categoryValues = {
      'Electronics': 1500.0,
      'Fashion': 500.0,
      'Furniture': 2000.0,
      'Books': 100.0,
      // ...
    };
    return categoryValues[category] ?? 500.0;
  }
  
  static ItemTier getTierFromValue(double value) {
    if (value < 500) return ItemTier.small;
    if (value < 2000) return ItemTier.medium;
    return ItemTier.large;
  }
}
```

**Dosya: `functions/src/ml/valueEstimation.ts` (YENİ - ML Model)**
```typescript
// Machine Learning tabanlı değer tahmini (opsiyonel, gelişmiş)
import * as tf from '@tensorflow/tfjs-node';

export const estimateItemValue = functions.https.onCall(async (data, context) => {
  const { category, condition, description, imageUrls } = data;
  
  // 1. Benzer ilanları bul (Firestore query)
  const similarItems = await findSimilarItems(category, condition);
  
  // 2. Ortalama değeri hesapla
  const avgValue = calculateAverageValue(similarItems);
  
  // 3. ML model ile tahmin (opsiyonel)
  // const prediction = await mlModel.predict(features);
  
  return {
    estimatedValue: avgValue,
    confidence: 0.75,
    tier: determineTier(avgValue),
  };
});
```

#### 4.2. UI - Value Input Widget

**Dosya: `lib/presentation/widgets/items/value_estimation_widget.dart` (YENİ)**
```dart
class ValueEstimationWidget extends StatefulWidget {
  // VALUE INPUT MODES:
  // 1. Manuel giriş (kullanıcı TL girer)
  // 2. Otomatik tahmin (algoritma önerir)
  // 3. Aralık seçimi (min-max)
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Otomatik tahmin butonu
        ElevatedButton(
          onPressed: _estimateValue,
          child: Text('Değeri Otomatik Tahmin Et'),
        ),
        
        // Tahmin sonucu gösterimi
        if (_estimatedValue != null)
          Card(
            child: Column(
              children: [
                Text('Tahmini Değer: ${_estimatedValue} ₺'),
                Text('Seviye: ${_tier.displayName}'),
                Text('Güven: ${_confidence}%'),
              ],
            ),
          ),
        
        // Manuel değer girişi
        CustomTextField(
          label: 'Veya manuel değer girin',
          keyboardType: TextInputType.number,
          suffixText: '₺',
        ),
        
        // Tier gösterimi (small/medium/large badge)
        TierBadge(tier: _currentTier),
      ],
    );
  }
}
```

**Dosya: `lib/presentation/widgets/items/tier_badge.dart` (YENİ)**
```dart
class TierBadge extends StatelessWidget {
  final ItemTier tier;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getTierColor(tier),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getTierIcon(tier), size: 16),
          SizedBox(width: 4),
          Text(_getTierLabel(tier)),
        ],
      ),
    );
  }
  
  Color _getTierColor(ItemTier tier) {
    switch (tier) {
      case ItemTier.small:
        return Colors.green;
      case ItemTier.medium:
        return Colors.orange;
      case ItemTier.large:
        return Colors.red;
    }
  }
}
```

---

## 🎯 FAZ 2: KULLANICI DENEYİMİ İYİLEŞTİRMELERİ (5-7 HAFTA)

### ✅ SPRINT 5: VİDEO YÜKLEME SİSTEMİ (1 HAFTA)

> **Öncelik:** 🟡 Orta  
> **Karmaşıklık:** Orta

#### 5.1. Dependencies

**Dosya: `pubspec.yaml` (GÜNCELLEME)**
```yaml
dependencies:
  image_picker: ^1.0.0      # Mevcut
  video_player: ^2.8.0      # YENİ
  video_compress: ^3.1.2    # YENİ - Video compression
  chewie: ^1.7.0            # YENİ - Video player UI
```

#### 5.2. Video Upload Widget

**Dosya: `lib/presentation/widgets/items/video_upload_widget.dart` (YENİ)**
```dart
class VideoUploadWidget extends StatefulWidget {
  final Function(List<String>) onVideosSelected;
  final int maxVideos;
  final int maxDurationSeconds;
  
  // VIDEO UPLOAD FLOW:
  // 1. Gallery'den video seç veya kamera ile çek
  // 2. Video preview (thumbnail + duration)
  // 3. Video compression (Firebase Storage limitleri için)
  // 4. Firebase Storage'a yükle
  // 5. Download URL'i al ve Firestore'a kaydet
}
```

**Dosya: `lib/core/services/video_service.dart` (YENİ)**
```dart
class VideoService {
  final FirebaseStorage _storage;
  
  Future<String> uploadVideo(File videoFile, String itemId) async {
    // 1. Video compress (max 50MB)
    final compressedVideo = await VideoCompress.compressVideo(
      videoFile.path,
      quality: VideoQuality.MediumQuality,
    );
    
    // 2. Firebase Storage'a yükle
    final ref = _storage.ref().child('items/$itemId/videos/${DateTime.now().millisecondsSinceEpoch}.mp4');
    await ref.putFile(File(compressedVideo!.path));
    
    // 3. Download URL al
    return await ref.getDownloadURL();
  }
  
  Future<Uint8List> generateThumbnail(File videoFile) async {
    // Video'dan thumbnail oluştur
    final thumbnail = await VideoCompress.getByteThumbnail(
      videoFile.path,
      quality: 50,
    );
    return thumbnail!;
  }
}
```

#### 5.3. Video Player Widget

**Dosya: `lib/presentation/widgets/items/video_player_widget.dart` (YENİ)**
```dart
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  
  @override
  Widget build(BuildContext context) {
    return Chewie(
      controller: ChewieController(
        videoPlayerController: VideoPlayerController.network(videoUrl),
        autoPlay: false,
        looping: false,
        aspectRatio: 16 / 9,
      ),
    );
  }
}
```

#### 5.4. Item Detail Page Update

**Dosya: `lib/presentation/pages/items/item_detail_page.dart` (GÜNCELLEME)**
```dart
class ItemDetailPage extends StatelessWidget {
  // GÜNCELLEME:
  // - Images carousel'e video desteği ekle
  // - Video thumbnail'lerde play icon göster
  // - Video'ya tıklanınca fullscreen player aç
  
  Widget _buildMediaCarousel() {
    return PageView.builder(
      itemCount: item.images.length + item.videoUrls.length,
      itemBuilder: (context, index) {
        if (index < item.images.length) {
          return Image.network(item.images[index]);
        } else {
          final videoIndex = index - item.images.length;
          return VideoThumbnailWidget(
            videoUrl: item.videoUrls[videoIndex],
            onTap: () => _openVideoPlayer(item.videoUrls[videoIndex]),
          );
        }
      },
    );
  }
}
```

---

### ✅ SPRINT 6: HARİTA ENTEGRASYONU (1 HAFTA)

> **Öncelik:** 🟡 Orta  
> **Karmaşıklık:** Orta

#### 6.1. Dependencies

**Dosya: `pubspec.yaml` (GÜNCELLEME)**
```yaml
dependencies:
  google_maps_flutter: ^2.5.0
  geolocator: ^10.0.0
  geocoding: ^2.1.0
```

#### 6.2. Location Service

**Dosya: `lib/core/services/location_service.dart` (YENİ)**
```dart
class LocationService {
  Future<Position?> getCurrentLocation() async {
    // Konum izni kontrolü
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return null;
    
    // Mevcut konumu al
    return await Geolocator.getCurrentPosition();
  }
  
  Future<String> getAddressFromCoordinates(double lat, double lon) async {
    final placemarks = await placemarkFromCoordinates(lat, lon);
    final place = placemarks.first;
    return '${place.locality}, ${place.country}';
  }
  
  double calculateDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // km
  }
}
```

#### 6.3. Map Widget

**Dosya: `lib/presentation/widgets/map/items_map_view.dart` (YENİ)**
```dart
class ItemsMapView extends StatefulWidget {
  final List<ItemEntity> items;
  
  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _userLocation,
        zoom: 12,
      ),
      markers: _buildMarkers(),
      onTap: _onMapTapped,
    );
  }
  
  Set<Marker> _buildMarkers() {
    return items.where((item) => item.latitude != null).map((item) {
      return Marker(
        markerId: MarkerId(item.id),
        position: LatLng(item.latitude!, item.longitude!),
        icon: _getMarkerIcon(item.tier),
        infoWindow: InfoWindow(
          title: item.title,
          snippet: '${item.monetaryValue} ₺',
          onTap: () => _openItemDetail(item),
        ),
      );
    }).toSet();
  }
}
```

#### 6.4. Location Filter

**Dosya: `lib/presentation/widgets/search/location_filter_widget.dart` (YENİ)**
```dart
class LocationFilterWidget extends StatefulWidget {
  // LOCATION FILTERS:
  // - "Yakınımdakiler" (radius slider: 5-50km)
  // - Şehir seçimi dropdown
  // - Haritada göster toggle
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: Text('Konuma göre filtrele'),
          value: _useLocation,
          onChanged: (value) => setState(() => _useLocation = value),
        ),
        
        if (_useLocation) ...[
          // Radius slider
          Text('Mesafe: $_radius km'),
          Slider(
            value: _radius,
            min: 5,
            max: 50,
            divisions: 9,
            onChanged: (value) => setState(() => _radius = value),
          ),
          
          // Haritada göster
          ElevatedButton(
            onPressed: _showMapView,
            child: Text('Haritada Göster'),
          ),
        ],
      ],
    );
  }
}
```

#### 6.5. Item Entity Update

**Dosya: `lib/domain/entities/item_entity.dart` (GÜNCELLEME)**
```dart
class ItemEntity extends Equatable {
  // ... Mevcut fieldlar ...
  
  // YENİ LOCATION FIELDLAR:
  final double? latitude;
  final double? longitude;
  final String? fullAddress;
}
```

---

### ✅ SPRINT 7: SSS & YARDIM SİSTEMİ (3-5 GÜN)

> **Öncelik:** 🟡 Orta  
> **Karmaşıklık:** Düşük

#### 7.1. Help Content Structure

**Dosya: `lib/core/constants/help_content.dart` (YENİ)**
```dart
class HelpContent {
  static const List<HelpCategory> categories = [
    HelpCategory(
      id: 'getting-started',
      title: 'Başlangıç',
      icon: Icons.rocket_launch,
      articles: [
        HelpArticle(
          id: 'how-barter-works',
          title: 'Barter Nasıl Çalışır?',
          content: '''
            # Barter Nedir?
            Barter, ürünlerinizi para kullanmadan değiş tokuş...
          ''',
        ),
        // ...
      ],
    ),
    HelpCategory(
      id: 'creating-listings',
      title: 'İlan Oluşturma',
      articles: [
        HelpArticle(
          id: 'value-estimation',
          title: 'Ürün Değeri Nasıl Belirlenir?',
          content: '''...''',
        ),
        HelpArticle(
          id: 'barter-conditions',
          title: 'Takas Şartları Nedir?',
          content: '''...''',
        ),
      ],
    ),
    HelpCategory(
      id: 'safety',
      title: 'Güvenlik İpuçları',
      articles: [
        HelpArticle(
          id: 'safe-trading',
          title: 'Güvenli Takas İçin İpuçları',
          content: '''...''',
        ),
      ],
    ),
    HelpCategory(
      id: 'faq',
      title: 'Sık Sorulan Sorular',
      articles: [...],
    ),
  ];
}
```

#### 7.2. Help Pages

**Dosya: `lib/presentation/pages/help/help_center_page.dart` (YENİ)**
```dart
class HelpCenterPage extends StatelessWidget {
  // HELP CENTER LAYOUT:
  // - Arama çubuğu (help articles içinde)
  // - Kategoriler grid
  // - Popüler makaleler
  // - İletişim/destek butonu
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Yardım Merkezi')),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(),
          
          // Categories
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
              ),
              itemCount: HelpContent.categories.length,
              itemBuilder: (context, index) {
                final category = HelpContent.categories[index];
                return HelpCategoryCard(category: category);
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

**Dosya: `lib/presentation/pages/help/help_article_page.dart` (YENİ)**
```dart
class HelpArticlePage extends StatelessWidget {
  final HelpArticle article;
  
  // ARTICLE DISPLAY:
  // - Markdown rendering
  // - İmage/video embedding
  // - "Bu yardımcı oldu mu?" feedback
  // - İlgili makaleler
}
```

#### 7.3. In-App Help Tooltips

**Dosya: `lib/presentation/widgets/help/help_tooltip.dart` (YENİ)**
```dart
class HelpTooltip extends StatelessWidget {
  final String message;
  final String? articleId; // İlgili help article'a link
  
  // TOOLTIP:
  // - "?" icon butonu
  // - Tooltip popup
  // - "Daha fazla bilgi" linki
}
```

---

### ✅ SPRINT 8: KULLANICI TEKLİFLERİ EKRANI (3-5 GÜN)

> **Öncelik:** 🟡 Orta  
> **Karmaşıklık:** Düşük

#### 8.1. Enhanced Trade Offers Page

**Dosya: `lib/presentation/pages/trades/trades_page.dart` (GÜNCELLEME)**
```dart
class TradesPage extends StatefulWidget {
  // MEVCUT SAYFA İYİLEŞTİRMELERİ:
  // - Tab bar: Gelen Teklifler / Giden Teklifler / Geçmiş
  // - Durum filtreleri (pending, accepted, rejected, completed)
  // - Sıralama (tarih, değer, durum)
  // - Teklif karşılaştırma özelliği
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Takaslarım'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Gelen (${_incomingCount})'),
              Tab(text: 'Giden (${_outgoingCount})'),
              Tab(text: 'Geçmiş'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildIncomingOffers(),
            _buildOutgoingOffers(),
            _buildTradeHistory(),
          ],
        ),
      ),
    );
  }
}
```

**Dosya: `lib/presentation/widgets/trades/trade_comparison_widget.dart` (YENİ)**
```dart
class TradeComparisonWidget extends StatelessWidget {
  final List<TradeOfferEntity> offers;
  
  // COMPARISON VIEW:
  // - Side-by-side ürün karşılaştırması
  // - Değer farkı hesaplaması
  // - Para farkı gösterimi
  // - Kullanıcı derecelendirmesi karşılaştırması
  // - En iyi teklifi öner (algoritma)
}
```

---

### ✅ SPRINT 9: KİMLİK DOĞRULAMA (1 HAFTA)

> **Öncelik:** 🟡 Orta  
> **Karmaşıklık:** Orta

#### 9.1. Phone Verification

**Dosya: `lib/presentation/pages/auth/phone_verification_page.dart` (YENİ)**
```dart
class PhoneVerificationPage extends StatefulWidget {
  // PHONE VERIFICATION FLOW:
  // 1. Telefon numarası girişi (+90 Türkiye default)
  // 2. SMS kodu gönderme
  // 3. OTP kodu doğrulama
  // 4. Profil güncelleme
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stepper(
        currentStep: _currentStep,
        steps: [
          Step(
            title: Text('Telefon Numarası'),
            content: PhoneNumberInput(),
          ),
          Step(
            title: Text('Doğrulama Kodu'),
            content: OTPInput(),
          ),
        ],
      ),
    );
  }
}
```

#### 9.2. ID Verification (Opsiyonel)

**Dosya: `lib/presentation/pages/profile/id_verification_page.dart` (YENİ)**
```dart
class IDVerificationPage extends StatelessWidget {
  // ID VERIFICATION FLOW (opsiyonel, büyük işlemler için):
  // 1. ID fotoğrafı yükleme (ön/arka)
  // 2. Selfie çekme
  // 3. Admin onayına gönderme
  // 4. Verified badge kazanma
}
```

#### 9.3. Verified Badge

**Dosya: `lib/domain/entities/user_entity.dart` (GÜNCELLEME)**
```dart
class UserEntity extends Equatable {
  // ... Mevcut fieldlar ...
  
  // YENİ VERIFICATION FIELDLAR:
  final bool isPhoneVerified;
  final bool isIdVerified;
  final DateTime? verifiedAt;
  final VerificationTier? verificationTier;
}

enum VerificationTier {
  none,         // Doğrulama yok
  phone,        // Telefon doğrulaması
  id,           // Kimlik doğrulaması
  trusted,      // Güvenilir kullanıcı (çok başarılı takas)
}
```

---

## 🎯 FAZ 3: MONETİZASYON & İYİLEŞTİRMELER (3-4 HAFTA)

### ✅ SPRINT 10: MONETİZASYON SİSTEMLERİ (2 HAFTA)

> **Öncelik:** 🟢 Düşük (MVP sonrası)  
> **Karmaşıklık:** Orta-Yüksek

#### 10.1. In-App Purchase Integration

**Dosya: `pubspec.yaml` (GÜNCELLEME)**
```yaml
dependencies:
  in_app_purchase: ^3.1.0
```

**Dosya: `lib/core/services/iap_service.dart` (YENİ)**
```dart
class IAPService {
  static const String productPremiumListing = 'premium_listing';
  static const String productFeaturedListing = 'featured_listing_7days';
  static const String productSubscriptionMonthly = 'subscription_monthly';
  
  Future<bool> purchasePremiumListing(String itemId) async {
    // 1. IAP satın alma flow
    // 2. Backend'e verify et
    // 3. Item'ı premium yap
  }
}
```

#### 10.2. Subscription Model

**Dosya: `lib/domain/entities/subscription_entity.dart` (YENİ)**
```dart
class SubscriptionEntity extends Equatable {
  final String id;
  final String userId;
  final SubscriptionPlan plan;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final SubscriptionFeatures features;
}

enum SubscriptionPlan {
  free,       // Ücretsiz: 5 aktif ilan
  basic,      // Basic: 15 aktif ilan + öncelikli destek
  premium,    // Premium: Sınırsız ilan + öne çıkarma + reklaamsız
}

class SubscriptionFeatures {
  final int maxActiveItems;
  final bool prioritySupport;
  final bool adFree;
  final int featuredListingsPerMonth;
  final bool advancedAnalytics;
}
```

#### 10.3. Monetization Pages

**Dosya: `lib/presentation/pages/monetization/premium_page.dart` (YENİ)**
```dart
class PremiumPage extends StatelessWidget {
  // PREMIUM PLANS DISPLAY:
  // - Plan karşılaştırması tablosu
  // - Özellik listesi
  // - Fiyatlandırma (₺ ve $)
  // - Satın alma butonları
  // - "7 gün ücretsiz dene" banner
}
```

---

### ✅ SPRINT 11: GELİŞMİŞ ARAMA & FİLTRELER (3-5 GÜN)

**Dosya: `lib/presentation/pages/search/advanced_search_page.dart` (YENİ)**
```dart
class AdvancedSearchPage extends StatelessWidget {
  // ADVANCED FILTERS:
  // - Fiyat aralığı slider (monetaryValue)
  // - Tier filter (small/medium/large)
  // - Barter condition filter
  // - Mesafe filtresi (location-based)
  // - Verified users only toggle
  // - Durum filtresi (new, like new, ...)
  // - Sıralama: Yeni, Popüler, Değer (yüksek/düşük), Mesafe
}
```

---

### ✅ SPRINT 12: BİLDİRİM TERCİHLERİ (2-3 GÜN)

**Dosya: `lib/presentation/pages/settings/notification_settings_page.dart` (YENİ)**
```dart
class NotificationSettingsPage extends StatelessWidget {
  // NOTIFICATION PREFERENCES:
  // - Push notifications toggle
  // - Email notifications toggle
  // - Kategori bazlı tercihler:
  //   • Yeni teklif aldığımda
  //   • Teklifim kabul/red edildiğinde
  //   • Mesaj aldığımda
  //   • İlanım onaylandığında
  //   • Favorilediğim ilan güncellendiğinde
  //   • Yakınımda yeni ilan eklendiğinde
  // - Sessiz saatler (do not disturb)
}
```

---

### ✅ SPRINT 13: PERFORMANS İYİLEŞTİRMELERİ (3-5 GÜN)

#### 13.1. Image Optimization

**Dosya: `lib/core/services/image_optimization_service.dart` (YENİ)**
```dart
class ImageOptimizationService {
  Future<File> compressImage(File image) async {
    // 1. Resim boyutunu küçült (max 1920x1080)
    // 2. JPEG compression (quality: 85%)
    // 3. WebP formatına çevir (daha küçük boyut)
    final img = decodeImage(image.readAsBytesSync())!;
    final resized = copyResize(img, width: 1920);
    return File('path')..writeAsBytesSync(encodeJpg(resized, quality: 85));
  }
}
```

#### 13.2. Caching Strategy

**Dosya: `lib/core/services/cache_service.dart` (YENİ)**
```dart
class CacheService {
  final SharedPreferences prefs;
  final Hive hive;
  
  // CACHE LAYERS:
  // 1. Memory cache (GetIt singleton için)
  // 2. Disk cache (Hive - user profile, categories, ...)
  // 3. Image cache (CachedNetworkImage mevcut)
  
  Future<void> cacheUserProfile(UserEntity user) async {
    await hive.box('users').put(user.id, user.toJson());
  }
  
  Future<UserEntity?> getCachedUserProfile(String userId) async {
    final json = hive.box('users').get(userId);
    return json != null ? UserEntity.fromJson(json) : null;
  }
}
```

#### 13.3. Pagination Improvements

**Dosya: `lib/presentation/widgets/pagination/paginated_list_view.dart` (GÜNCELLEME)**
```dart
// Tüm list view'lerde kullanılacak generic paginated widget
class PaginatedListView<T> extends StatefulWidget {
  final Future<List<T>> Function(int page, int limit) fetchData;
  final Widget Function(BuildContext, T) itemBuilder;
  final int pageSize;
  
  // FEATURES:
  // - Infinite scroll
  // - Pull to refresh
  // - Loading shimmer
  // - Empty state
  // - Error retry
}
```

---

## 📂 YENİ OLUŞTURULACAK DOSYA YAPISI

```
lib/
├── domain/
│   ├── entities/
│   │   ├── barter_condition_entity.dart       [YENİ]
│   │   ├── admin_user_entity.dart             [YENİ]
│   │   ├── moderation_request_entity.dart     [YENİ]
│   │   ├── subscription_entity.dart           [YENİ]
│   │   ├── item_entity.dart                   [GÜNCELLEME]
│   │   ├── trade_offer_entity.dart            [GÜNCELLEME]
│   │   └── user_entity.dart                   [GÜNCELLEME]
│   ├── repositories/
│   │   ├── barter_repository.dart             [YENİ]
│   │   ├── admin_repository.dart              [YENİ]
│   │   └── monetization_repository.dart       [YENİ]
│   └── usecases/
│       ├── barter/
│       │   ├── validate_barter_match_usecase.dart
│       │   ├── calculate_cash_differential_usecase.dart
│       │   └── get_matching_items_usecase.dart
│       ├── admin/
│       │   ├── approve_item_usecase.dart
│       │   ├── reject_item_usecase.dart
│       │   └── get_pending_items_usecase.dart
│       └── monetization/
│           └── purchase_premium_usecase.dart
│
├── data/
│   ├── models/
│   │   ├── barter_condition_model.dart        [YENİ]
│   │   ├── admin_user_model.dart              [YENİ]
│   │   ├── item_model.dart                    [GÜNCELLEME]
│   │   └── trade_offer_model.dart             [GÜNCELLEME]
│   └── repositories/
│       ├── barter_repository_impl.dart        [YENİ]
│       ├── admin_repository_impl.dart         [YENİ]
│       └── monetization_repository_impl.dart  [YENİ]
│
├── presentation/
│   ├── blocs/
│   │   ├── barter/
│   │   │   ├── barter_bloc.dart               [YENİ]
│   │   │   ├── barter_event.dart              [YENİ]
│   │   │   └── barter_state.dart              [YENİ]
│   │   ├── admin/
│   │   │   ├── admin_bloc.dart                [YENİ]
│   │   │   ├── admin_event.dart               [YENİ]
│   │   │   └── admin_state.dart               [YENİ]
│   │   └── locale/
│   │       ├── locale_bloc.dart               [YENİ]
│   │       ├── locale_event.dart              [YENİ]
│   │       └── locale_state.dart              [YENİ]
│   │
│   ├── pages/
│   │   ├── items/
│   │   │   ├── create_item_wizard_page.dart   [YENİ - Wizard]
│   │   │   └── create_item_page.dart          [MEVCUT]
│   │   ├── admin/
│   │   │   ├── admin_dashboard_page.dart      [YENİ]
│   │   │   ├── item_moderation_page.dart      [YENİ]
│   │   │   └── user_management_page.dart      [YENİ]
│   │   ├── help/
│   │   │   ├── help_center_page.dart          [YENİ]
│   │   │   └── help_article_page.dart         [YENİ]
│   │   ├── monetization/
│   │   │   └── premium_page.dart              [YENİ]
│   │   ├── settings/
│   │   │   ├── language_settings_page.dart    [YENİ]
│   │   │   └── notification_settings_page.dart [YENİ]
│   │   └── auth/
│   │       └── phone_verification_page.dart   [YENİ]
│   │
│   └── widgets/
│       ├── barter/
│       │   ├── barter_condition_selector.dart  [YENİ]
│       │   └── cash_differential_widget.dart   [YENİ]
│       ├── items/
│       │   ├── video_upload_widget.dart        [YENİ]
│       │   ├── video_player_widget.dart        [YENİ]
│       │   ├── monetary_value_input.dart       [YENİ]
│       │   ├── tier_badge.dart                 [YENİ]
│       │   └── value_estimation_widget.dart    [YENİ]
│       ├── map/
│       │   └── items_map_view.dart             [YENİ]
│       ├── admin/
│       │   ├── item_review_card.dart           [YENİ]
│       │   ├── admin_sidebar.dart              [YENİ]
│       │   └── admin_app_bar.dart              [YENİ]
│       └── help/
│           └── help_tooltip.dart               [YENİ]
│
├── core/
│   ├── l10n/                                   [YENİ KLASÖR]
│   │   ├── app_tr.arb                         [YENİ - Türkçe]
│   │   ├── app_en.arb                         [YENİ - İngilizce]
│   │   └── app_ar.arb                         [YENİ - Arapça]
│   ├── services/
│   │   ├── video_service.dart                 [YENİ]
│   │   ├── location_service.dart              [YENİ]
│   │   ├── iap_service.dart                   [YENİ]
│   │   ├── cache_service.dart                 [YENİ]
│   │   └── image_optimization_service.dart    [YENİ]
│   ├── utils/
│   │   └── value_estimation.dart              [YENİ]
│   ├── constants/
│   │   └── help_content.dart                  [YENİ]
│   └── routes/
│       └── admin_route_guard.dart             [YENİ]
│
functions/                                      [Firebase Cloud Functions]
├── src/
│   ├── barter/
│   │   └── matchingAlgorithm.ts              [YENİ]
│   ├── moderation/
│   │   ├── autoTierAssignment.ts             [YENİ]
│   │   └── contentModeration.ts              [YENİ]
│   ├── admin/
│   │   └── setAdminClaims.ts                 [YENİ]
│   └── ml/
│       └── valueEstimation.ts                [YENİ - Opsiyonel]
└── index.ts                                   [GÜNCELLEME]
```

---

## 📊 SPRINT TAKİP TABLOSU

| Sprint | Özellik | Tahmini Süre | Bağımlılıklar | Kritiklik |
|--------|---------|--------------|---------------|-----------|
| **1** | Barter Havuzu Şartları | 2-3 hafta | - | 🔥 Yüksek |
| **2** | Çoklu Dil Desteği | 1-2 hafta | - | 🔥 Yüksek | ✅ |
| **3** | Admin Panel & Onay | 4-5 hafta | Sprint 1 | 🔥 Yüksek |
| **4** | İlan Değer Sistemi | 2-3 hafta | Sprint 1 | 🔥 Yüksek |
| **5** | Video Yükleme | 1.5-2 hafta | - | 🟡 Orta |
| **6** | Harita Entegrasyonu | 1.5-2 hafta | - | 🟡 Orta |
| **7** | SSS & Yardım | 3-5 gün | - | 🟡 Orta |
| **8** | Gelişmiş Teklif Ekranı | 3-5 gün | - | 🟡 Orta |
| **9** | Kimlik Doğrulama | 1 hafta | - | 🟡 Orta |
| **10** | Monetizasyon | 2 hafta | - | 🟢 Düşük |
| **11** | Gelişmiş Filtreler | 3-5 gün | Sprint 4, 6 | 🟢 Düşük |
| **12** | Bildirim Tercihleri | 2-3 gün | - | 🟢 Düşük |
| **13** | Performans İyileştirme | 3-5 gün | - | 🟢 Düşük |

---

## ✅ HER SPRINT İÇİN CHECKLIST

### Sprint Başlangıç Checklist:
- [ ] Sprint hedeflerini netleştir
- [ ] Gerekli dependencies'leri yükle
- [ ] Firebase konfigürasyonunu kontrol et
- [ ] Branch oluştur (`feature/sprint-X-feature-name`)
- [ ] Design mockup'larını hazırla (Figma)

### Geliştirme Checklist:
- [ ] Domain entities oluştur/güncelle
- [ ] Repository interface tanımla
- [ ] Data models ve repository impl
- [ ] Use cases yaz
- [ ] BLoC implement et (event, state, bloc)
- [ ] UI sayfaları ve widget'ları yaz
- [ ] DI container'a ekle
- [ ] Firebase backend (Cloud Functions, Firestore rules)
- [ ] Unit testler yaz
- [ ] Widget testler yaz

### Sprint Bitiş Checklist:
- [ ] Code review yap
- [ ] Linting errors düzelt
- [ ] Test coverage kontrol et (min %70)
- [ ] README güncelle
- [ ] CHANGELOG.md güncelle
- [ ] Pull request oluştur
- [ ] QA testi yap
- [ ] Main branch'e merge et
- [ ] Sprint retrospektif toplantısı

---

## 🚀 DEPLOYMENT PIPELINE

### 1. Development
```bash
# Feature branch'te geliştirme
git checkout -b feature/sprint-1-barter-conditions
# ... development ...
git push origin feature/sprint-1-barter-conditions
```

### 2. Testing
```bash
# Test coverage
flutter test --coverage
# Analyze
flutter analyze
```

### 3. Staging
```bash
# Firebase staging environment
firebase use staging
flutter build apk --flavor staging
firebase deploy --only functions:staging
```

### 4. Production
```bash
# Production deployment
firebase use production
flutter build apk --release
flutter build ios --release
firebase deploy --only functions
```

---

## 📈 PROJE TAKİP METRİKLERİ

### Her Sprint Sonunda Ölçülecekler:
1. **Kod Kalitesi**
   - Test coverage (hedef: %80+)
   - Code smells (SonarQube)
   - Technical debt ratio

2. **Performans**
   - App startup time
   - Screen load time
   - Firebase query response time
   - Image/video load time

3. **Kullanıcı Metrikleri (Production'da)**
   - DAU/MAU
   - Session duration
   - Feature adoption rate
   - Crash-free rate (hedef: 99%+)

---

## 💡 ÖNEMLİ NOTLAR

### 1. Clean Architecture Consistency
Her yeni özellik eklerken **mutlaka** Clean Architecture katmanlarına uy:
- Domain layer: Entities, Repositories (interface), Use Cases
- Data layer: Models, Repositories (implementation), Data Sources
- Presentation layer: BLoC, Pages, Widgets

### 2. BLoC Pattern
Tüm state management BLoC ile yapılmalı. Direct widget state kullanma.

### 3. Firebase Best Practices
- Firestore queries: Compound index'leri unutma
- Cloud Functions: Timeout ve memory limitlerine dikkat
- Storage: Image compression her zaman yap

### 4. Testing Priority
En kritik özellikler için önce test yaz:
1. Barter matching algorithm
2. Value estimation
3. Admin moderation workflow
4. Payment/IAP flow
### 5. Localization
Her yeni string eklediğinde ARB dosyalarına ekle. Hardcoded string kullanma!

### 6. PDF Referansı
Orijinal proje brief'i barter_qween/docs/BRIEF.pdf dosyasında korunmaktadır. Bu roadmap'de yapılan güncellemeler 03 Ekim 2025 tarihi itibarıyla geçerlidir.

---

## 🎯 SONUÇ

Bu roadmap, projeyi **18-26 hafta** içinde tamamlamak için detaylı bir plandır. Her sprint bağımsız olarak geliştirilebilir ve test edilebilir.

**Öncelik sırası:**
1. **FAZ 1** (8-13 hafta) - Kritik özellikler, brief gereksinimleri
2. **FAZ 2** (6-8 hafta) - UX iyileştirmeleri
3. **FAZ 3** (4-5 hafta) - Monetizasyon ve polish

Her sprint sonunda **demo** ve **retrospektif** yapılmalı. İlerleme düzenli olarak `PROJECT_STATUS.md` dosyasında güncellenmelidir.

---

**SON GÜNCELLEme:** {{current_date}}  
**HAZIRLLAYAN:** AI Assistant  
**DURUM:** 📝 Planlama Tamamlandı - Uygulama Bekliyor
