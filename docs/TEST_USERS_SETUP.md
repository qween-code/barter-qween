# Test Users Setup Guide

## 🧪 Test Kullanıcıları

BarterQween monetization sistemini test etmek için 3 farklı plan seviyesinde test kullanıcıları:

### 1. 💎 Premium User
**Email:** turhanhamza@gmail.com  
**Plan:** Premium (₺99.99/ay)  
**Özellikler:**
- ✅ 50 aktif ilan limiti
- ✅ Sınırsız ücretsiz ilan/ay
- ✅ 10 premium ilan/ay
- ✅ Reklamsız deneyim
- ✅ %0 trade komisyonu
- ✅ Öncelikli destek
- ✅ Gelişmiş arama
- ✅ İstatistik erişimi

### 2. ⭐ Basic User
**Email:** weemustang@gmail.com  
**Plan:** Basic (₺49.99/ay)  
**Özellikler:**
- ✅ 10 aktif ilan limiti
- ✅ 5 ücretsiz ilan/ay
- ✅ 2 premium ilan/ay
- ✅ Reklamsız deneyim
- ✅ %3 trade komisyonu
- ❌ Öncelikli destek yok
- ✅ Gelişmiş arama
- ✅ İstatistik erişimi

### 3. 🆓 Free User
**Email:** wee6134@gmail.com  
**Plan:** Free (₺0)  
**Özellikler:**
- ✅ 3 aktif ilan limiti
- ✅ 1 ücretsiz ilan/ay
- ❌ Premium ilan yok
- ❌ Reklamlar gösterilir
- ✅ %5 trade komisyonu
- ❌ Öncelikli destek yok
- ❌ Gelişmiş arama yok
- ❌ İstatistik erişimi yok

---

## 🔧 Firebase Setup

### Manuel Olarak Firebase Console'dan

1. **Firebase Console** → **Firestore Database**
2. **subscriptions** koleksiyonuna git
3. Her kullanıcı için document ekle:

#### Premium User (turhanhamza@gmail.com)
```javascript
{
  userId: "USER_ID_FROM_USERS_COLLECTION", // turhanhamza'nın user ID'si
  plan: "premium",
  status: "active",
  startDate: Timestamp.now(),
  expiryDate: Timestamp.fromDate(new Date(Date.now() + 365 * 24 * 60 * 60 * 1000)), // 1 yıl
  autoRenew: true,
  storeProductId: "barter_qween_premium_yearly",
  storeTransactionId: "TEST_TXN_PREMIUM_001",
  paymentId: "TEST_PAYMENT_PREMIUM_001",
  createdAt: Timestamp.now(),
  lastRenewedAt: Timestamp.now(),
  cancelledAt: null
}
```

#### Basic User (weemustang@gmail.com)
```javascript
{
  userId: "USER_ID_FROM_USERS_COLLECTION", // weemustang'in user ID'si
  plan: "basic",
  status: "active",
  startDate: Timestamp.now(),
  expiryDate: Timestamp.fromDate(new Date(Date.now() + 365 * 24 * 60 * 60 * 1000)), // 1 yıl
  autoRenew: true,
  storeProductId: "barter_qween_basic_yearly",
  storeTransactionId: "TEST_TXN_BASIC_001",
  paymentId: "TEST_PAYMENT_BASIC_001",
  createdAt: Timestamp.now(),
  lastRenewedAt: Timestamp.now(),
  cancelledAt: null
}
```

#### Free User (wee6134@gmail.com)
```javascript
// Free kullanıcılar için subscription dokümanı OLUŞTURMA!
// Sadece users koleksiyonunda:
{
  subscriptionPlan: "free",
  subscriptionStatus: "free",
  subscriptionId: null
}
```

4. **users** koleksiyonunda her kullanıcı için güncelle:

```javascript
// turhanhamza@gmail.com
{
  ...mevcut_fields,
  subscriptionPlan: "premium",
  subscriptionStatus: "active",
  subscriptionId: "SUBSCRIPTION_DOC_ID",
  updatedAt: Timestamp.now()
}

// weemustang@gmail.com
{
  ...mevcut_fields,
  subscriptionPlan: "basic",
  subscriptionStatus: "active",
  subscriptionId: "SUBSCRIPTION_DOC_ID",
  updatedAt: Timestamp.now()
}

// wee6134@gmail.com
{
  ...mevcut_fields,
  subscriptionPlan: "free",
  subscriptionStatus: "free",
  subscriptionId: null,
  updatedAt: Timestamp.now()
}
```

---

## 🧪 Test Senaryoları

### Scenario 1: İlan Oluşturma Limitleri

**Free User (wee6134@gmail.com):**
1. Giriş yap
2. 3 aktif ilan oluştur ✅
3. 4. ilanı oluşturmaya çalış ❌
4. Mesaj: "Maximum active listing limit reached. Upgrade to Basic plan for 10 listings or Premium for 50 listings"

**Basic User (weemustang@gmail.com):**
1. Giriş yap
2. 10 aktif ilan oluştur ✅
3. 11. ilanı oluşturmaya çalış ❌
4. Mesaj: "Upgrade to Premium for 50 listings"

**Premium User (turhanhamza@gmail.com):**
1. Giriş yap
2. 50 aktif ilan oluştur ✅
3. Limit kontrolü çalışıyor ✅

### Scenario 2: Aylık İlan Kotası

**Free User (wee6134@gmail.com):**
1. Ay içinde 1 ilan ücretsiz ✅
2. 2. ilan → Ödeme ekranı ₺9.99 ⚠️

**Basic User (weemustang@gmail.com):**
1. Ay içinde 5 ilan ücretsiz ✅
2. 6. ilan → Ödeme ekranı ₺9.99 ⚠️

**Premium User (turhanhamza@gmail.com):**
1. Sınırsız ücretsiz ilan ✅

### Scenario 3: Premium İlan

**Free User:**
- Premium ilan butonu disabled ❌

**Basic User:**
- Ayda 2 premium ilan ücretsiz ✅
- 3. premium ilan → ₺29.99 ödeme ⚠️

**Premium User:**
- Ayda 10 premium ilan ücretsiz ✅
- 11. premium ilan → ₺29.99 ödeme ⚠️

### Scenario 4: Reklam Gösterimi

**Free User:**
- Banner reklamlar gösterilir ✅
- Interstitial reklamlar (her 3 aksiyon) ✅

**Basic & Premium Users:**
- Hiç reklam gösterilmez ❌

### Scenario 5: Trade Komisyonu

**Trade Tamamlandığında:**
- Free User: %5 komisyon kesintisi
- Basic User: %3 komisyon kesintisi
- Premium User: %0 komisyon (ücretsiz)

**Örnek:**
- Trade değeri: ₺1000
- Free: ₺50 komisyon ödemesi
- Basic: ₺30 komisyon ödemesi
- Premium: ₺0 komisyon

### Scenario 6: Abonelik Upgrade

**Free → Basic:**
1. Free user settings'e gir
2. "Upgrade to Basic" buton
3. IAP flow başlat
4. ₺49.99 ödeme yap
5. Plan upgrade olur ✅

**Basic → Premium:**
1. Basic user settings'e gir
2. "Upgrade to Premium" buton
3. Kalan günler kredilenir
4. ₺99.99 ödeme yap
5. Plan upgrade olur ✅

### Scenario 7: Premium Features Visibility

**Features UI:**
```
Free User sees:
- 🔒 Premium features locked
- "Upgrade to unlock" badges
- Limited features available

Basic User sees:
- ⭐ Basic badge
- Blue color scheme
- Some features unlocked
- "Upgrade to Premium for more" prompt

Premium User sees:
- 💎 Premium badge
- Premium orange color scheme
- All features unlocked
- Priority support access
```

---

## 📊 Test Checklist

### İlan Yönetimi
- [ ] Free: 3 ilan limiti çalışıyor
- [ ] Basic: 10 ilan limiti çalışıyor
- [ ] Premium: 50 ilan limiti çalışıyor
- [ ] Aylık kota tracking doğru
- [ ] Ay başında kota sıfırlanıyor

### Ücretler
- [ ] İlan ücreti ₺9.99 doğru hesaplanıyor
- [ ] Premium ilan ücreti ₺29.99 doğru
- [ ] Komisyon oranları doğru (%0, %3, %5)

### Reklam
- [ ] Free users reklamları görüyor
- [ ] Basic/Premium users reklam görmüyor
- [ ] Interstitial frekans kontrolü çalışıyor

### Premium Features
- [ ] Premium listing boost çalışıyor (3x-5x visibility)
- [ ] Premium badge doğru gösteriliyor
- [ ] Color scheme plan'a göre değişiyor

### Abonelik
- [ ] Active subscription kontrolü çalışıyor
- [ ] Expiry date tracking doğru
- [ ] Auto-renewal çalışıyor
- [ ] Cancel işlemi çalışıyor
- [ ] Upgrade remaining days credit veriyor

### Security
- [ ] Firestore rules premium feature'ları koruyor
- [ ] Server-side validation çalışıyor
- [ ] Subscription status sync doğru

---

## 🎯 Success Criteria

Tüm test senaryoları başarılı olmalı:

✅ **Free User:**
- 3 ilan limiti
- 1 ücretsiz ilan/ay
- Reklamlar gösteriliyor
- %5 komisyon

✅ **Basic User:**
- 10 ilan limiti
- 5 ücretsiz ilan/ay
- Reklamsız
- %3 komisyon
- 2 premium ilan/ay

✅ **Premium User:**
- 50 ilan limiti
- Sınırsız ücretsiz ilan
- Reklamsız
- %0 komisyon
- 10 premium ilan/ay
- Tüm premium features

---

## 🚀 Next Steps

1. Firebase Console'dan test kullanıcılarını setup et
2. Her 3 kullanıcı ile giriş yap
3. Test senaryolarını çalıştır
4. Sonuçları dokümante et
5. Bug varsa düzelt
6. Production'a deploy

**Test Kullanıcıları Hazır! 🎉**
