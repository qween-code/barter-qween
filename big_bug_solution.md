# BIG BUG SOLUTION PLAN

Bu doküman, Barter Qween projesinde yanlış çalışan veya eksik kalan kritik alanları düzeltmek için izlenecek yol haritasını içerir. Başlıklar altında ilgili semptomlar, olası kök nedenler, çözüm adımları ve doğrulama kontrolleri yer alır. Tüm adımlar tamamlandıkça durum notları güncellenmelidir.

---

## 1. Takip Sistemi Çalışmıyor
**Durum:** [ ] Devam ediyor
- Firestore kurallarıyla uyumlu olacak şekilde `followUser` / `unfollowUser` transaction'ları güncellendi; gerçek cihaz testi bekleniyor.
- Permission hatası devam ederse kurallarda `followers` sekmesinin eşleşmesi tekrar gözden geçirilecek.
- Sosyal listeler normalize edilerek sıralı/benzersiz hale getirildi; Firestore kurallarındaki liste eşitliği kontrolleriyle uyumlu veri gönderiliyor.
- **Semptom:** Kullanıcılar birbirini takip edemiyor, sayılar güncellenmiyor.
- **Olası Nedenler:**
  - `profile_remote_datasource` içindeki Firestore transaction akışında hata.
  - Firestore kuralları +/−1 sınırını uygun şekilde doğrulamıyor.
  - UI tarafında state güncellemeleri eksik.
- **Çözüm Adımları:**
  1. `followUser` ve `unfollowUser` transaction loglarına debug çıktısı ekle.
  2. `social.followers` / `social.following` listelerini transaction içinden güncelle ve duplication kontrolü yap.
  3. Firestore kurallarında takipçi/following sayaçlarının +/−1 değiştiğini doğrula.
  4. Bloc katmanında başarılı işlem sonrası local state’i güncelle.
- **Doğrulama:**
  - İki ayrı kullanıcı hesabıyla takip/geri takip senaryosunu çalıştır.
  - Sayaçların eşzamanlı işlemlerde de doğru arttığını/azaldığını gör.

## 2. Medya Yükleme (Galeri & Kamera) Çalışmıyor
**Durum:** [ ] Devam ediyor
- **Semptom:** Yeni ilan fotoğrafları yüklenmiyor, varsayılan saat görseli kalıyor.
- **Olası Nedenler:**
  - `create_item_page` içinde dosya seçim ve upload akışı bozuk.
  - Kamera izni veya image picker konfigürasyonu eksik.
  - Upload sonrası Firestore item kaydına URL yazılmıyor.
- **Çözüm Adımları:**
  1. `ImageService` ve `create_item_page`’deki seç/kamera fonksiyonlarını gözden geçir.
  2. `image_picker` kullanımında izin kontrolleri ve hata yakalamaları ekle.
  3. Upload servisinin döndürdüğü URL’nin item modeline yazıldığından emin ol.
  4. Camera seçeneği için `pickImage(source: ImageSource.camera)` entegrasyonunu tamamla.
- **Doğrulama:**
  - Galeri ve kamera ile ayrı ayrı deneme yap, önizleme ve Firestore kaydını kontrol et.

## 3. Kullanıcıya Kendi Ürünleri Gösterilmiyor
**Durum:** [ ] Devam ediyor
- **Semptom:** Feed’de kullanıcı kendi ilanını görüyor.
- **Çözüm Adımları:**
  1. `world_class_explore_page` ve `item_repository` sorgularında current user filtresi ekle.
  2. Firestore sorgusunda `ownerId != currentUserId` koşulu olmadığı için client-side filtre uygula.
- **Doğrulama:** Aynı kullanıcıyla giriş yapıldığında feed’de kendi ilanları görünmemeli.

## 4. Kategori Bölümü Tasarımı
**Durum:** [ ] Devam ediyor
- **Semptom:** Kategoriler iki satırlı grid, köşeleri keskin.
- **Çözüm Adımları:**
  1. `world_class_category_grid`’i tek satır scrollable pill tasarıma dönüştür.
  2. Türkçe kategori adlarını düzenle (Elektronik, Moda vb.).
  3. UI testlerinde mobil/tablet kırılımlarını kontrol et.
- **Doğrulama:** Kullanıcı yan kaydırma ile kategorileri dolaşabilmeli, kartlar yuvarlak köşeli olmalı.

## 5. Sayaçlar (Görüntülenme, Favori, Takip) Gerçek Değer Göstersin
**Durum:** [ ] Devam ediyor
- **Semptom:** Sayaçlar gerçek veriyi yansıtmıyor.
- **Çözüm Adımları:**
  1. Favori ve view sayacı için `runTransaction` bloklarında +/− güncellemesini kontrol et.
  2. Firestore kurallarıyla sayaç değişimlerinin tutarlılığını doğrula.
  3. Her sayaç güncellemesinde server timestamp kullan.
- **Doğrulama:** Aynı anda iki cihazdan işlem yapıldığında sayaç değerleri doğru kalmalı.

## 6. Ana Sayfa Selamlama Mesajı
**Durum:** [ ] Devam ediyor
- **Semptom:** “Hey Trader” sabit metni gösteriliyor.
- **Çözüm Adımları:**
  1. Home Bloc’ta kullanıcı adı çekilip UI’a iletilmeli.
  2. İsim yoksa “Misafir” gibi güvenli fallback kullan.
- **Doğrulama:** Farklı kullanıcı adlarıyla girişte mesaj değişmeli.

## 7. Bildirim Sekmeleri ve Provider Sorunu
**Durum:** [ ] Devam ediyor
- **Semptom:** Bildirimler Trendyol benzeri sekmelere ayrıldı ancak dialog açılırken provider hatası geliyor.
- **Çözüm Adımları:**
  1. `NotificationsPage`’de `showDialog` çağrıları için doğru context kullan.
  2. NotificationBloc provider’ının scope’unu genişlet.
  3. Silme/okundu yapma aksiyonlarının state güncellemesini test et.
- **Doğrulama:** Tüm sekmelerde (Takas & Teklif, Mesajlar, Diğer) navigation ve dialog işlemleri sorunsuz çalışmalı.

## 8. Profil Düzenleme Çalışmıyor
**Durum:** [ ] Devam ediyor
- **Semptom:** Profilde yapılan değişiklik kaydedilmiyor.
- **Çözüm Adımları:**
  1. `edit_profile_page` submit handler’ı ve servis çağrısını incele.
  2. Zorunlu alan validasyonlarını doğrula.
  3. Başarılı güncellemede kullanıcı state’ini yenile.
- **Doğrulama:** Profilde isim/bio/şehir değişikliği sonrası veri yenilenmeli.

## 9. Çıkış Yap Butonu Konumu
**Durum:** [ ] Devam ediyor
- **Semptom:** Logout butonu erişmesi zor bir yerde.
- **Çözüm Adımları:**
  1. Profil sayfasında daha görünür bir CTA konumuna taşı.
  2. Çıkış işleminden sonra kullanıcı login ekranına yönlendirilmeli.
- **Doğrulama:** Farklı kullanıcı rolleriyle logout denemesi.

## 10. Paylaş Butonları
**Durum:** [ ] Devam ediyor
- **Semptom:** İlan ve profil paylaş butonları çalışmıyor.
- **Çözüm Adımları:**
  1. `share_plus` çağrılarını gerçek URL veya uygulama içi deeplink ile güncelle.
  2. Share sheet açılışını cihazlarda test et.
- **Doğrulama:** Android/iOS paylaşımları, kopyalanan linkin doğru olması.

## 11. Değerlendirme Kullanıcı İsimleri
**Durum:** [ ] Devam ediyor
- **Semptom:** Review’larda kullanıcı adı gözükmüyor.
- **Çözüm Adımları:**
  1. Review listesini çekerken `userId` üzerinden `users` koleksiyonundan displayName alın.
  2. Performans için caching/Map kullanımını değerlendir.
- **Doğrulama:** Tüm değerlendirmelerde isimlerin görünmesi.
- Trade teklifleri oluşturulurken `fromUserName` / `toUserName` alanları gerçek kullanıcı bilgileriyle doldurulacak şekilde güncellendi.
- Mevcut trade kayıtları okunurken eksik isimler Firestore'dan çekilerek UI'da gerçek kullanıcı adlarıyla gösterilecek.

## 12. Google Pay Entegrasyonu
**Durum:** [ ] Devam ediyor
- **Semptom:** Stripe kodu kaldırıldı ama Google Pay henüz gateway bağlantısına sahip değil.
- **Çözüm Adımları:**
  1. `assets/payments/google_pay.json` dosyasını gerçek gateway bilgileriyle güncelle.
  2. Sunucu tarafında token doğrulayıp ödeme kaydı oluşturacak endpoint ekle.
  3. Flutter tarafında `processGooglePay` yanıtını kullanıcıya göster.
- **Doğrulama:** Test modunda Google Pay ile deneme işlemi.

## 13. Google Maps API Anahtarı
**Durum:** [ ] Devam ediyor
- **Semptom:** Android/iOS manifestlerinde placeholder anahtar var.
- **Çözüm Adımları:**
  1. `serviceAccountKey.json` içindeki `maps_api_key` değerini CI/CD veya build aşamasında manifest’e yerleştir.
  2. Anahtarın gizli kalması için environment değişkenleri kullan.
- **Doğrulama:** Harita ekranında yetkilendirme hatasının kaybolması.

## 14. Firestore Transaction “Future already completed” Hatası
**Durum:** [ ] Devam ediyor
- **Semptom:** Transaction sonuçları çakışıyor, loglarda uyarı çıkıyor.
- **Çözüm Adımları:**
  1. Hata görülen transaction (favori, view veya takip) loglarını incele.
  2. Transaction içinde `return` ve async çağrıları doğru sırada mı kontrol et.
  3. Gerekirse `FieldValue.increment` kullanıp transaction’dan çıkar.
- **Doğrulama:** Hata loglarının temizlenmesi.

## 15. Görsel Hata Dayanıklılığı
**Durum:** [ ] Devam ediyor
- **Semptom:** Bazı Image.network çağrıları 404 atıyor.
- **Çözüm Adımları:**
  1. `FallbackNetworkImage` tüm kritik kartlarda kullanıldı mı kontrol et.
  2. Eksik ekranlara widget’i ekle.
- **Doğrulama:** Bozuk URL’lerde bile placeholder simgesi görünmeli.

## 16. Genel Kod Kalitesi
**Durum:** [ ] Devam ediyor
- **Semptom:** `flutter analyze` yüzlerce uyarı veriyor.
- **Çözüm Adımları:**
  1. Öncelikli hataları (derleme engelleyen) düzelt.
  2. Kullanılmayan dosya ve kod bloklarını temizle.
- **Doğrulama:** Analyzer uyarılarının kademeli olarak azalması.

---

## Test & Yayın Kontrolleri
1. `flutter analyze` → Hatalar çözülene kadar tekrar et.
2. `flutter test` → En kritik testlerin geçtiğini doğrula.
3. Manuel Senaryolar:
   - Takip/çıkar, favori ekle/çıkar, görüntüleme artırma.
   - Yeni ilan oluşturma (galeri + kamera), paylaşım akışları.
   - Bildirim sekmeleri ve dialogları, profil düzenleme, logout.
4. Google Pay test ödemesi.
5. Google Maps ekranı yetkilendirme kontrolü.
6. Firestore Rules ve Index deploy (`firebase deploy --only firestore:rules,indexes`).

---

## Durum Takibi
- Her konu çözüldüğünde bu dosyada “Tamamlandı” notu eklenmeli.
- Yeni sorunlar ortaya çıkarsa ilgili başlığa ek açıklama yazılmalı.
