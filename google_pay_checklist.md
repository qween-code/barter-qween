# ✅ Google Pay Kurulum Kontrol Listesi

Bu kontrol listesi ile Google Pay entegrasyonunuzun eksiksiz olduğunu doğrulayın.

## 📋 Ön Kontrol

- [ ] Google Pay Business Console hesabı oluşturuldu
- [ ] Google Cloud Console projesi hazır
- [ ] Google Pay API etkinleştirildi
- [ ] Service Account oluşturuldu
- [ ] Google Merchant ID alındı

## 🔧 Teknik Kontrol

### 1. Service Account Key
- [ ] `serviceAccountKey.json` dosyası proje kök dizininde
- [ ] `.gitignore` dosyasında `serviceAccountKey.json` var
- [ ] Dosya okuma izinleri doğru ayarlanmış

### 2. Google Pay Konfigürasyonu
- [ ] `assets/payments/google_pay.json` dosyası mevcut
- [ ] `environment` değeri `PRODUCTION` olarak ayarlı
- [ ] `merchantId` gerçek değerle güncellendi
- [ ] `gateway` ve `gatewayMerchantId` doğru

### 3. Dependencies
- [ ] Flutter `pay` paketi yüklü
- [ ] Firebase paketleri güncel
- [ ] `crypto` paketi mevcut

### 4. Firebase Functions
- [ ] `functions/src/payment/` klasörü mevcut
- [ ] `paymentTriggers.ts` ve `paymentVerification.ts` dosyaları var
- [ ] Functions deploy edildi

## 🚀 Test Adımları

### 1. Google Pay Butonu Testi
```dart
// Ödeme sayfasında Google Pay butonu görünür olmalı
PaymentSelectionPage(
  amount: 100.0,
  paymentType: PaymentType.cashDifferential,
)
```

### 2. Ödeme İşleme Testi
```dart
// Ödeme servisi çağrısı
final result = await paymentService.processBarterPayment(
  amount: 50.0,
  recipientId: 'user123',
  tradeId: 'trade456',
);
```

### 3. Webhook Testi
```javascript
// Firebase Functions loglarında görülecek
onPaymentStatusUpdated({
  paymentId: 'payment123',
  status: 'completed'
})
```

## 🔍 Sorun Giderme

### Yaygın Hatalar

**Hata: "Google Pay bu cihazda desteklenmiyor"**
- [ ] Cihazda Google Play Services yüklü mü?
- [ ] Google Pay uygulaması yüklü mü?
- [ ] Test ortamında mısın?

**Hata: "Merchant ID bulunamadı"**
- [ ] Merchant ID doğru formatta mı?
- [ ] Google Pay Business Console'da aktif mi?
- [ ] Web sitesi doğrulaması tamamlandı mı?

**Hata: "Ödeme doğrulanamadı"**
- [ ] Service Account Key doğru yerde mi?
- [ ] Firebase Functions deploy edildi mi?
- [ ] Token validation çalışıyor mu?

## 📞 Destek Bilgileri

**Google Pay Business Console:**
- Hesap: [pay.google.com/business/console](https://pay.google.com/business/console)
- Destek: Google Pay Business Support

**Google Cloud Console:**
- Proje: [console.cloud.google.com](https://console.cloud.google.com)
- API'ler: Google Pay API etkin mi?

**Firebase Console:**
- Functions: [console.firebase.google.com](https://console.firebase.google.com)
- Authentication: Email verification etkin mi?

## 🎯 Son Kontrol

- [ ] Tüm testler geçiyor
- [ ] Production ortamında çalışıyor
- [ ] Güvenlik kontrolleri aktif
- [ ] Webhook'lar çalışıyor
- [ ] Bildirimler gönderiliyor
- [ ] Ödeme geçmişi kaydediliyor

## 🚨 Acil Durum Prosedürü

Eğer sorun yaşarsanız:

1. **Log'ları kontrol edin:**
   ```bash
   firebase functions:log
   flutter logs
   ```

2. **Test ortamında deneyin:**
   ```json
   "environment": "TEST"
   ```

3. **Destek ekibiyle iletişime geçin:**
   - Teknik destek: dev@barterqween.com
   - Acil durum: +90XXXXXXXXXX

## 📅 Zaman Çizelgesi

- **Kurulum:** 2-3 saat
- **Test:** 1-2 saat
- **Production Deploy:** 30 dakika
- **İlk Ödeme Testi:** 15 dakika

Başarılar! 🚀