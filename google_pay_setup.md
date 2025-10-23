# 🚀 Google Pay Merchant ID Kurulum Rehberi

Bu rehber, BarterQween uygulaması için Google Pay entegrasyonunu tamamlamak için gerekli adımları içerir.

## 📋 Ön Koşullar

1. **Google Developer Account** - Google Play Console hesabınız olmalı
2. **Google Pay Business Console** - Business profile oluşturmanız gerekiyor
3. **Web Site Doğrulama** - Domain doğrulaması yapmanız gerekebilir

## 🏪 Adım 1: Google Pay Business Console'a Kayıt

### 1.1 Business Profile Oluşturun

1. [Google Pay Business Console](https://pay.google.com/business/console) adresine gidin
2. **"Başla"** butonuna tıklayın
3. **"İşletme profili oluştur"** seçeneğini seçin

### 1.2 İşletme Bilgilerini Girin

```
İşletme Adı: BarterQween
İşletme Kategorisi: Online Marketplace / E-ticaret
Web Sitesi: https://bogazici-barter.web.app
İşletme Adresi: Türkiye (gerçek adres bilgilerinizi girin)
Vergi Numarası: (Türk vergi numaranız varsa)
```

### 1.3 Doğrulama Sürecini Tamamlayın

Google size bir doğrulama süreci başlatacak:

**Seçenek 1: Web Sitesi Doğrulama (Önerilen)**
1. Google size bir HTML dosyası verecek
2. Bu dosyayı web sitenizin root dizinine yükleyin
3. Google Search Console'dan doğrulayın

**Seçenek 2: Google Analytics Doğrulama**
1. Google Analytics hesabınızı bağlayın
2. Analytics'te doğrulama yapın

## 🔧 Adım 2: Merchant ID ve API Anahtarları Alın

### 2.1 Google Pay API'yi Etkinleştirin

1. [Google Cloud Console](https://console.cloud.google.com/) adresine gidin
2. Yeni bir proje oluşturun veya mevcut projeyi seçin
3. **API ve Servisler** → **Kütüphane** bölümüne gidin
4. **"Google Pay API"** araması yapın ve etkinleştirin

### 2.2 Service Account Oluşturun

1. **API ve Servisler** → **Kimlik Bilgileri** → **Service Account Oluştur**
2. Service Account adı: `barterqween-payment-processor`
3. **"Oluştur ve Devam Et"** butonuna tıklayın
4. Role olarak **"Editor"** seçin

### 2.3 API Anahtarını İndirin

1. Oluşturduğunuz Service Account'ı seçin
2. **"Anahtarlar"** sekmesine gidin
3. **"Anahtar Ekle"** → **"Yeni Anahtar Oluştur"**
4. **JSON** formatını seçin ve **"Oluştur"** butonuna tıklayın
5. İndirilen JSON dosyasını güvenli bir yerde saklayın

## 💳 Adım 3: Google Pay Merchant ID'yi Yapılandırın

### 3.1 Google Pay Business Console'a Dönün

1. Business Console'a geri gidin
2. **"Entegrasyon"** sekmesine tıklayın
3. **"Google Pay API"** sekmesini seçin

### 3.2 Web Sitesi Entegrasyonunu Yapılandırın

```
Uygulama Adı: BarterQween
Paket Adı: com.barterqween.app (Android için)
App Store ID: (iOS için)
Desteklenen Kart Ağları:
  ✓ Visa
  ✓ Mastercard
  ✓ American Express
Para Birimi: TRY (Türk Lirası)
```

## 📁 Adım 4: Konfigürasyon Dosyalarını Güncelleyin

### 4.1 Service Account Key'i Projeye Ekleyin

1. İndirdiğiniz JSON dosyasının adını `serviceAccountKey.json` olarak değiştirin
2. Bu dosyayı projenizin root dizinine koyun:
   ```
   barter_qween/
   ├── serviceAccountKey.json  ← Bu dosyayı buraya koyun
   ├── functions/
   ├── lib/
   └── ...
   ```

### 4.2 Google Pay Konfigürasyonunu Güncelleyin

`assets/payments/google_pay.json` dosyasını düzenleyin:

```json
{
  "provider": "google_pay",
  "data": {
    "environment": "PRODUCTION",
    "merchantInfo": {
      "merchantId": "ALINAN_MERCHANT_ID",
      "merchantName": "BarterQween - Güvenli Takas Platformu"
    }
  }
}
```

## 🔐 Adım 5: Güvenlik Yapılandırması

### 5.1 API Anahtarlarını Güvenli Hale Getirin

1. `serviceAccountKey.json` dosyasını `.gitignore`'a ekleyin:
   ```
   # Ödeme sistemi
   serviceAccountKey.json
   *.key
   ```

2. Environment variable olarak da kullanabilirsiniz:
   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="serviceAccountKey.json"
   ```

## ✅ Adım 6: Test ve Doğrulama

### 6.1 Google Pay Test Ortamı

1. Google Pay Business Console'da test ortamını etkinleştirin
2. Test kartları ile deneme yapın:
   - 4111 1111 1111 1111 (Visa)
   - 5555 5555 5555 4444 (Mastercard)

### 6.2 Production'a Geçiş

Test başarılı olduktan sonra:

1. `google_pay.json` dosyasında `"environment": "TEST"` → `"environment": "PRODUCTION"`
2. Firebase Functions'ı deploy edin:
   ```bash
   firebase deploy --only functions
   ```

## 🚨 Önemli Notlar

### Güvenlik Uyarıları

⚠️ **Service Account Key'i kimseyle paylaşmayın**
⚠️ **Production API anahtarlarını log'lamayın**
⚠️ **Environment variable'ları source control'dan uzak tutun**

### Sorun Giderme

**Yaygın Hatalar:**
- `MERCHANT_ID_NOT_FOUND` → Merchant ID'yi kontrol edin
- `PAYMENT_FAILED` → Google Pay API'yi tekrar kontrol edin
- `INVALID_COUNTRY` → Desteklenen ülkeleri kontrol edin

**Destek:**
- Google Pay Business Console destek ekibi
- Google Cloud Console destek
- Firebase destek forumları

## 📞 İletişim Bilgileri

Bu kurulum tamamlandıktan sonra şu bilgileri bize sağlayın:

1. **Google Merchant ID**
2. **Service Account Email**
3. **Web Site Doğrulama Durumu**

Bu bilgilerle Google Pay entegrasyonunu tamamen aktif hale getirebiliriz!