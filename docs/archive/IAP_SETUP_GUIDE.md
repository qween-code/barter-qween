# IAP (In-App Purchase) Setup Guide

## 📚 IAP Nedir?

**IAP (In-App Purchase)** = **Uygulama İçi Satın Alma**

Kullanıcıların uygulama içinden App Store (iOS) veya Google Play Store (Android) üzerinden satın alma yapmasını sağlar.

### IAP Çeşitleri:
1. **Consumable** - Tek kullanımlık (örn: oyun parası, coins)
2. **Non-Consumable** - Kalıcı (örn: reklam kaldırma, premium features)
3. **Subscription** - Abonelik (bizim kullandığımız) ✅

---

## 🎯 BarterQween'de IAP

### Subscription Products (Abonelikler):
```
1. barter_qween_basic_monthly   → Basic Monthly (₺49.99/ay)
2. barter_qween_basic_yearly    → Basic Yearly (₺499.99/yıl)
3. barter_qween_premium_monthly → Premium Monthly (₺99.99/ay)
4. barter_qween_premium_yearly  → Premium Yearly (₺999.99/yıl)
```

### Özellikler:
- ✅ Otomatik yenileme (auto-renewal)
- ✅ Subscription upgrade/downgrade
- ✅ Purchase restore
- ✅ Receipt verification
- ✅ Cross-platform sync (iOS ↔ Android)

---

## 🔧 Teknik Implementasyon

### IAPService Kullanımı

```dart
import 'package:barter_qween/core/services/iap_service.dart';

// 1. Servisi başlat
await IAPService.instance.initialize();

// 2. Ürünleri yükle (otomatik yüklenir)
// IAPService.instance.loadProducts() // Zaten initialize'da çağrılır

// 3. Ürünleri listele
final products = IAPService.instance.getProductsForPlan(SubscriptionPlan.basic);
for (var product in products) {
  print('${product.title}: ${product.price}');
}

// 4. Satın alma yap
final success = await IAPService.instance.purchaseSubscription(
  productId: 'barter_qween_basic_monthly',
);

// 5. Satın almaları geri yükle
await IAPService.instance.restorePurchases();

// 6. Aktif subscription kontrol
final hasActive = await IAPService.instance.hasActiveSubscription();
```

### Callbacks

```dart
// Purchase success callback
IAPService.instance.onPurchaseSuccess = (purchaseDetails) {
  print('✅ Satın alma başarılı: ${purchaseDetails.productID}');
  // Firestore'a kaydet, UI güncelle
};

// Purchase error callback
IAPService.instance.onPurchaseError = (purchaseDetails, error) {
  print('❌ Hata: $error');
  // Kullanıcıya hata mesajı göster
};

// Restore callback
IAPService.instance.onPurchaseRestored = (purchaseDetails) {
  print('🔄 Geri yüklendi: ${purchaseDetails.productID}');
  // Firestore güncelle
};
```

---

## 🍎 iOS Setup (App Store Connect)

### 1. App Store Connect'te Ürün Oluştur

1. **App Store Connect** → Your App → **Subscriptions**
2. **Create Subscription Group**: "BarterQween Subscriptions"
3. **Add Subscription** için her product:

#### Basic Monthly
- **Product ID**: `barter_qween_basic_monthly`
- **Reference Name**: Basic Monthly Subscription
- **Subscription Duration**: 1 month
- **Price**: ₺49.99
- **Localizations**: Turkish

#### Basic Yearly
- **Product ID**: `barter_qween_basic_yearly`
- **Reference Name**: Basic Yearly Subscription
- **Subscription Duration**: 1 year
- **Price**: ₺499.99
- **Localizations**: Turkish

#### Premium Monthly
- **Product ID**: `barter_qween_premium_monthly`
- **Reference Name**: Premium Monthly Subscription
- **Subscription Duration**: 1 month
- **Price**: ₺99.99
- **Localizations**: Turkish

#### Premium Yearly
- **Product ID**: `barter_qween_premium_yearly`
- **Reference Name**: Premium Yearly Subscription
- **Subscription Duration**: 1 year
- **Price**: ₺999.99
- **Localizations**: Turkish

### 2. iOS Info.plist

```xml
<!-- ios/Runner/Info.plist -->
<key>SKAdNetworkItems</key>
<array>
    <!-- Add your SKAdNetwork IDs here -->
</array>
```

### 3. iOS Capabilities

Xcode'da:
- **Signing & Capabilities** → **+ Capability** → **In-App Purchase**

### 4. Sandbox Testing

1. **App Store Connect** → **Users and Access** → **Sandbox Testers**
2. Test kullanıcısı ekle (gerçek email kullanmayın)
3. iOS Settings → App Store → Sandbox Account → Login

---

## 🤖 Android Setup (Google Play Console)

### 1. Google Play Console'da Ürün Oluştur

1. **Play Console** → Your App → **Subscriptions**
2. **Create subscription** için her product:

#### Basic Monthly
- **Product ID**: `barter_qween_basic_monthly`
- **Name**: Basic Monthly
- **Description**: ⭐ Temel plan - Aylık abonelik
- **Billing period**: Monthly
- **Price**: ₺49.99
- **Free trial**: Opsiyonel (7 gün)

#### Basic Yearly
- **Product ID**: `barter_qween_basic_yearly`
- **Name**: Basic Yearly
- **Description**: ⭐ Temel plan - Yıllık abonelik (~%17 indirim)
- **Billing period**: Yearly
- **Price**: ₺499.99

#### Premium Monthly
- **Product ID**: `barter_qween_premium_monthly`
- **Name**: Premium Monthly
- **Description**: 💎 Premium plan - Aylık abonelik
- **Billing period**: Monthly
- **Price**: ₺99.99

#### Premium Yearly
- **Product ID**: `barter_qween_premium_yearly`
- **Name**: Premium Yearly
- **Description**: 💎 Premium plan - Yıllık abonelik (~%17 indirim)
- **Billing period**: Yearly
- **Price**: ₺999.99

### 2. Android Manifest

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="com.android.vending.BILLING" />
```

### 3. build.gradle

```gradle
// android/app/build.gradle
dependencies {
    implementation 'com.android.billingclient:billing:6.1.0'
}
```

### 4. License Testing

1. **Play Console** → **Setup** → **License Testing**
2. Test hesabı ekle (Google account)
3. Test cihazında bu hesapla giriş yap
4. Testing modda satın almalar gerçek para ödemez

---

## 🔐 Server-Side Receipt Verification

### Firebase Functions ile Verification

```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');

// iOS Receipt Verification
exports.verifyAppleReceipt = functions.https.onCall(async (data, context) => {
  const { receiptData, userId } = data;
  
  // Apple Server'a gönder
  const response = await fetch('https://buy.itunes.apple.com/verifyReceipt', {
    method: 'POST',
    body: JSON.stringify({
      'receipt-data': receiptData,
      'password': 'YOUR_SHARED_SECRET'
    })
  });
  
  const result = await response.json();
  
  if (result.status === 0) {
    // Valid receipt
    await admin.firestore().collection('subscriptions').add({
      userId,
      platform: 'ios',
      productId: result.latest_receipt_info[0].product_id,
      expiresDate: new Date(parseInt(result.latest_receipt_info[0].expires_date_ms)),
      verifiedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    return { success: true };
  }
  
  return { success: false, error: 'Invalid receipt' };
});

// Android Receipt Verification
exports.verifyGoogleReceipt = functions.https.onCall(async (data, context) => {
  const { purchaseToken, productId, userId } = data;
  
  // Google Play Developer API ile doğrula
  // https://developers.google.com/android-publisher/api-ref/rest/v3/purchases.subscriptions/get
  
  // Örnek implementation
  const { google } = require('googleapis');
  const androidpublisher = google.androidpublisher('v3');
  
  const result = await androidpublisher.purchases.subscriptions.get({
    packageName: 'com.barterqween.app',
    subscriptionId: productId,
    token: purchaseToken
  });
  
  if (result.data.purchaseState === 0) {
    // Valid purchase
    await admin.firestore().collection('subscriptions').add({
      userId,
      platform: 'android',
      productId,
      expiresDate: new Date(parseInt(result.data.expiryTimeMillis)),
      verifiedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    return { success: true };
  }
  
  return { success: false, error: 'Invalid purchase' };
});
```

---

## 🔄 Purchase Flow

### Satın Alma Akışı:

```
1. Kullanıcı plan seçer (Basic/Premium, Monthly/Yearly)
   ↓
2. IAPService.purchaseSubscription() çağrılır
   ↓
3. Store (App Store/Play Store) ödeme ekranı açılır
   ↓
4. Kullanıcı ödeme yapar (veya iptal eder)
   ↓
5. Purchase stream güncelleme alır
   ↓
6. Receipt server-side verification (Firebase Functions)
   ↓
7. Firestore'a subscription kaydedilir
   ↓
8. User document güncellenir (subscriptionPlan, subscriptionStatus)
   ↓
9. UI güncellenir (premium features aktif olur)
```

### Restore Flow:

```
1. Kullanıcı "Satın Almaları Geri Yükle" butonuna basar
   ↓
2. IAPService.restorePurchases() çağrılır
   ↓
3. Store'dan önceki satın almalar getir ilir
   ↓
4. Her purchase için verification yapılır
   ↓
5. Firestore güncellenir
   ↓
6. UI güncellenir
```

---

## 🧪 Test Senaryoları

### Test Edilmesi Gerekenler:

- [ ] ✅ Subscription satın alma (monthly)
- [ ] ✅ Subscription satın alma (yearly)
- [ ] ✅ Purchase restore
- [ ] ✅ Subscription upgrade (Basic → Premium)
- [ ] ✅ Subscription downgrade (Premium → Basic)
- [ ] ✅ Subscription cancel
- [ ] ✅ Subscription renewal
- [ ] ✅ Subscription expiry
- [ ] ✅ Failed purchase
- [ ] ✅ Cancelled purchase
- [ ] ✅ Cross-device sync

### Sandbox Test:

**iOS**:
```
Settings → App Store → Sandbox Account
Test kullanıcısı ile giriş yap
```

**Android**:
```
Play Console → License Testing
Test hesabı ekle
```

---

## 📊 Firestore Data Model

### Subscriptions Collection:

```javascript
subscriptions/{subscriptionId}
{
  userId: string,
  plan: 'free' | 'basic' | 'premium',
  status: 'active' | 'expired' | 'cancelled' | 'paused',
  startDate: Timestamp,
  expiryDate: Timestamp,
  autoRenew: boolean,
  storeProductId: string,
  storeTransactionId: string,
  platform: 'ios' | 'android',
  paymentId: string?,
  createdAt: Timestamp,
  lastRenewedAt: Timestamp?,
  cancelledAt: Timestamp?
}
```

### Users Update:

```javascript
users/{userId}
{
  ...existing fields,
  subscriptionPlan: 'free' | 'basic' | 'premium',
  subscriptionStatus: 'active' | 'expired' | 'cancelled',
  subscriptionId: string?,
  updatedAt: Timestamp
}
```

---

## ⚠️ Önemli Notlar

### Production Checklist:

- [ ] **Store product ID'leri oluşturuldu** (App Store Connect + Play Console)
- [ ] **Pricing ayarlandı** (₺49.99, ₺499.99, ₺99.99, ₺999.99)
- [ ] **Server-side verification** implement edildi (Firebase Functions)
- [ ] **Firestore security rules** güncellendi
- [ ] **Subscription webhook'ları** ayarlandı (renewal, cancellation)
- [ ] **Test edildi** (sandbox ortamda)
- [ ] **Production'da test edildi** (gerçek satın alma)
- [ ] **Refund policy** eklendi (uygulama içinde ve store'da)
- [ ] **Privacy Policy** güncellendi (subscription bilgileri için)

### Güvenlik:

🚨 **ASLA client-side verification'a güvenme!**
- Receipt verification mutlaka server-side yapılmalı
- Firebase Functions kullan
- Subscription durumunu Firestore'da server tarafında sakla

### Auto-Renewal:

- iOS ve Android otomatik yenilemeyi handle eder
- Webhook'lar ile yenileme bildirimlerini al
- Firestore'u güncel tut

---

## 🎁 Bonus: Free Trial

### 7 Günlük Ücretsiz Deneme:

```dart
// Play Console / App Store Connect'te free trial aktif et
// Kod tarafında özel bir şey yapmaya gerek yok
// Store otomatik handle eder
```

**Kullanıcı deneyimi**:
1. İlk abonelik → 7 gün ücretsiz
2. 7. günden sonra → Otomatik ücretlendir
3. İptal ederse → Süre sonunda biter

---

## 📞 Destek & Troubleshooting

### Sık Karşılaşılan Sorunlar:

**"Product not found"**:
- Store'da product ID'lerin doğru olduğundan emin ol
- iOS: Agreements aktif mi kontrol et
- Android: App published mi kontrol et (en azından internal testing)

**"Purchase failed"**:
- Sandbox hesabı kullanıyor musun?
- Billing eklentisi yüklü mü? (`flutter pub get`)
- Platform manifest/plist ayarları doğru mu?

**"Receipt verification failed"**:
- Shared secret doğru mu? (iOS)
- Service account key doğru mu? (Android)
- Firebase Functions deploy edilmiş mi?

---

**IAP Implementation Complete! 🎉**

Test kullanıcıları için abonelikler Firebase Console'dan manuel eklenebilir.
