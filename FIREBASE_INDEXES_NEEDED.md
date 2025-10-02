# Firebase Index Oluşturma Gereksinimi

## Gerekli Index'ler

Uygulamanız aşağıdaki Firebase Firestore indexlerine ihtiyaç duyuyor:

### 1. Favorites Index (Favoriler için)
**Sorgu:** `favorites where userId==XXX order by -createdAt, -__name__`

**Index URL:**
```
https://console.firebase.google.com/v1/r/project/bogazici-barter/firestore/indexes?create_composite=ClFwcm9qZWN0cy9ib2dhemljaS1iYXJ0ZXIvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2Zhdm9yaXRlcy9pbmRleGVzL18QARoKCgZ1c2VySWQQARoNCgljcmVhdGVkQXQQAhoMCghfX25hbWVfXxAC
```

**Manuel Oluşturma:**
- Collection: `favorites`
- Fields:
  - `userId` (Ascending)
  - `createdAt` (Descending)
  - `__name__` (Descending)

---

### 2. Messages Index (Mesajlar için - Mark as Read)
**Sorgu:** `messages where conversationId==XXX and senderId!=YYY and isRead==false order by senderId, __name__`

**Index URL:**
```
https://console.firebase.google.com/v1/r/project/bogazici-barter/firestore/indexes?create_composite=ClBwcm9qZWN0cy9ib2dhemljaS1iYXJ0ZXIvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL21lc3NhZ2VzL2luZGV4ZXMvXxABGhIKDmNvbnZlcnNhdGlvbklkEAEaDAoIaXNSZWFkEAEaDAoIc2VuZGVySWQQARoMCghfX25hbWVfXxAB
```

**Manuel Oluşturma:**
- Collection: `messages`
- Fields:
  - `conversationId` (Ascending)
  - `isRead` (Ascending)
  - `senderId` (Ascending)
  - `__name__` (Ascending)

---

## Oluşturma Talimatları

### Otomatik Yöntem (Önerilen):
1. Yukarıdaki Index URL'lerini tarayıcınıza kopyalayın
2. Firebase Console'da otomatik olarak index oluşturma sayfası açılacak
3. "Create Index" butonuna tıklayın
4. Index oluşturulması 5-15 dakika sürebilir

### Manuel Yöntem:
1. Firebase Console'a gidin: https://console.firebase.google.com/
2. Projenizi seçin: `bogazici-barter`
3. Sol menüden "Firestore Database" seçin
4. "Indexes" sekmesine tıklayın
5. "Create Index" butonuna tıklayın
6. Yukarıdaki alanları doldurun

---

## Index Durumu Kontrolü

Index'lerin oluşturulup oluşturulmadığını kontrol etmek için:

1. Firebase Console > Firestore Database > Indexes
2. "Building" (Oluşturuluyor) durumunda olanlar yeşile dönene kadar bekleyin
3. Tüm indexler "Enabled" (Etkin) durumuna geldiğinde uygulamayı tekrar test edin

---

## Otomatik Index Dağıtımı (Gelecek için)

Mevcut `firestore.indexes.json` dosyanıza bu indexleri ekleyin ve şu komutla dağıtın:

```bash
firebase deploy --only firestore:indexes
```

**Not:** Bu işlem için Firebase CLI kurulu ve yapılandırılmış olmalı.

---

**Status:** ⚠️ Index'ler oluşturulması gerekiyor  
**Priority:** 🔴 Yüksek - Favorites ve Chat özelliklerinin çalışması için gerekli  
**Created:** 2025-10-02
