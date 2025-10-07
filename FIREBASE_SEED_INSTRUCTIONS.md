# 🔥 Firebase Seed İşlemi Talimatları

## 1️⃣ ServiceAccountKey.json İndirme

1. Firebase Console'a git: https://console.firebase.google.com
2. `bogazici-barter` projesini aç
3. **Project Settings** (⚙️ ikonu) → **Service accounts** sekmesi
4. **Generate new private key** butonuna tıkla
5. İndirilen JSON dosyasını `serviceAccountKey.json` olarak proje kök dizinine kaydet

## 2️⃣ Firebase Seed Script'ini Çalıştır

```bash
cd C:\Users\qw\Desktop\barter_qween
node seed_firebase.js
```

## 3️⃣ Seed Edilen Veriler

Script şunları oluşturacak:
- **10 Test Kullanıcısı** (Alice, Bob, Carol, David, vb.)
- **15 Ürün** (iPhone, MacBook, Kitaplar, vb.)
- **5 Trade Offer** (Pending, Accepted, Rejected durumlarında)
- **6 Rating** (Kullanıcı değerlendirmeleri)
- **Favoriler** (Kullanıcıların favori ürünleri)

## 4️⃣ Test Kullanıcısı ile Giriş

Email: **alice.johnson@example.com**  
Password: **Test123!**

veya diğer test kullanıcıları:
- bob.smith@example.com
- carol.white@example.com
- david.brown@example.com

## 5️⃣ Firebase Indexes

Seed işleminden sonra, aşağıdaki hatayı alırsan index oluşturman gerekir:

```
https://console.firebase.google.com/v1/r/project/bogazici-barter/firestore/indexes
```

Linklere tıklayarak Firebase Console'dan otomatik index oluştur.

## 6️⃣ Doğrulama

Firestore'da şunları kontrol et:
- `users` collection'ında 10 kullanıcı olmalı
- `items` collection'ında 15 ürün olmalı
- `tradeOffers` collection'ında 5 trade olmalı
- `ratings` collection'ında 6 rating olmalı
- `favorites` collection'ında favoriler olmalı

---

## ✅ Tamamlanınca

Uygulamayı yeniden başlat ve ana sayfada ürünlerin göründüğünü doğrula!

```bash
flutter run -d emulator-5554
```
