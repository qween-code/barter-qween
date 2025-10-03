import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import '../../domain/entities/subscription_entity.dart';

/// IAP (In-App Purchase) Service
/// 
/// Bu servis uygulama içi satın almaları yönetir:
/// - Subscription (Abonelik) satın alma
/// - Purchase restore (Satın almaları geri yükleme)
/// - Receipt verification (Makbuz doğrulama)
/// - Auto-renewal handling (Otomatik yenileme)
class IAPService {
  static IAPService? _instance;
  static IAPService get instance => _instance ??= IAPService._();

  IAPService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  
  // Satın alma callback'leri
  Function(PurchaseDetails)? onPurchaseSuccess;
  Function(PurchaseDetails, dynamic error)? onPurchaseError;
  Function(PurchaseDetails)? onPurchaseRestored;

  /// Store'da tanımlı ürün ID'leri
  /// NOT: Bu ID'ler App Store Connect ve Google Play Console'da tanımlanmalı
  static const List<String> _productIds = [
    'barter_qween_basic_monthly',
    'barter_qween_basic_yearly',
    'barter_qween_premium_monthly',
    'barter_qween_premium_yearly',
  ];

  /// IAP servisini başlat
  Future<bool> initialize() async {
    try {
      // Platform-specific initialization
      if (Platform.isAndroid) {
        final androidDetails = InAppPurchaseAndroidPlatformAddition.instance;
        // Android billing client hazır olana kadar bekle
        await androidDetails.isFeatureSupported(BillingClientFeature.subscriptions);
      }

      // IAP servisi kullanılabilir mi kontrol et
      _isAvailable = await _iap.isAvailable();
      
      if (!_isAvailable) {
        print('⚠️ In-App Purchase servisi kullanılamıyor');
        return false;
      }

      // Satın alma stream'ini dinle
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () => _subscription?.cancel(),
        onError: (error) {
          print('❌ Purchase stream error: $error');
        },
      );

      // Ürünleri yükle
      await loadProducts();

      print('✅ IAP Service başlatıldı');
      return true;
    } catch (e) {
      print('❌ IAP initialization error: $e');
      return false;
    }
  }

  /// Store'dan ürünleri yükle
  Future<void> loadProducts() async {
    if (!_isAvailable) return;

    try {
      final ProductDetailsResponse response = await _iap.queryProductDetails(_productIds.toSet());

      if (response.error != null) {
        print('❌ Product query error: ${response.error}');
        return;
      }

      if (response.notFoundIDs.isNotEmpty) {
        print('⚠️ Bulunamayan ürünler: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
      print('✅ ${_products.length} ürün yüklendi');

      // Debug: Ürünleri listele
      for (var product in _products) {
        print('  📦 ${product.id}: ${product.title} - ${product.price}');
      }
    } catch (e) {
      print('❌ Load products error: $e');
    }
  }

  /// Ürün detayını ID ile getir
  ProductDetails? getProduct(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Plan için ürünleri getir
  List<ProductDetails> getProductsForPlan(SubscriptionPlan plan) {
    final planPrefix = plan == SubscriptionPlan.basic ? 'basic' : 'premium';
    return _products.where((p) => p.id.contains(planPrefix)).toList();
  }

  /// Abonelik satın al
  Future<bool> purchaseSubscription({
    required String productId,
    String? oldSubscriptionId, // Android upgrade/downgrade için
  }) async {
    if (!_isAvailable) {
      print('❌ IAP servisi kullanılamıyor');
      return false;
    }

    final product = getProduct(productId);
    if (product == null) {
      print('❌ Ürün bulunamadı: $productId');
      return false;
    }

    try {
      print('🛒 Satın alma başlatılıyor: ${product.title}');

      late PurchaseParam purchaseParam;

      if (Platform.isAndroid) {
        // Android subscription change/upgrade
        final oldPurchaseDetails = oldSubscriptionId != null
            ? await _getOldSubscriptionToken(oldSubscriptionId)
            : null;

        purchaseParam = GooglePlayPurchaseParam(
          productDetails: product,
          changeSubscriptionParam: oldPurchaseDetails != null
              ? ChangeSubscriptionParam(
                  oldPurchaseDetails: oldPurchaseDetails,
                  prorationMode: ProrationMode.immediateWithTimeProration,
                )
              : null,
        );
      } else if (Platform.isIOS) {
        purchaseParam = PurchaseParam(productDetails: product);
      } else {
        purchaseParam = PurchaseParam(productDetails: product);
      }

      // Satın almayı başlat
      final success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      print(success ? '✅ Satın alma başlatıldı' : '❌ Satın alma başlatılamadı');
      return success;
    } catch (e) {
      print('❌ Purchase error: $e');
      return false;
    }
  }

  /// Satın almaları geri yükle (restore)
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;

    try {
      print('🔄 Satın almalar geri yükleniyor...');
      await _iap.restorePurchases();
      print('✅ Restore tamamlandı');
    } catch (e) {
      print('❌ Restore error: $e');
    }
  }

  /// Satın alma güncellemelerini işle
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      print('📦 Purchase update: ${purchaseDetails.productID} - ${purchaseDetails.status}');

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          _handlePendingPurchase(purchaseDetails);
          break;
        case PurchaseStatus.purchased:
          _handleSuccessfulPurchase(purchaseDetails);
          break;
        case PurchaseStatus.restored:
          _handleRestoredPurchase(purchaseDetails);
          break;
        case PurchaseStatus.error:
          _handleFailedPurchase(purchaseDetails);
          break;
        case PurchaseStatus.canceled:
          _handleCanceledPurchase(purchaseDetails);
          break;
      }

      // Satın alma tamamlandı - pending olmayacak şekilde işaretle
      if (purchaseDetails.pendingCompletePurchase) {
        _iap.completePurchase(purchaseDetails);
      }
    }
  }

  /// Pending purchase işleme
  void _handlePendingPurchase(PurchaseDetails purchaseDetails) {
    print('⏳ Satın alma beklemede: ${purchaseDetails.productID}');
    // Kullanıcıya loading göster
  }

  /// Başarılı satın alma işleme
  void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) {
    print('✅ Satın alma başarılı: ${purchaseDetails.productID}');
    
    // Server-side verification yapılmalı (Production'da zorunlu)
    _verifyPurchase(purchaseDetails).then((isValid) {
      if (isValid) {
        // Callback'i çağır
        if (onPurchaseSuccess != null) {
          onPurchaseSuccess!(purchaseDetails);
        }
        
        // Firestore'a subscription ekle
        _saveSubscriptionToFirestore(purchaseDetails);
      } else {
        print('❌ Purchase verification failed');
        if (onPurchaseError != null) {
          onPurchaseError!(purchaseDetails, 'Verification failed');
        }
      }
    });
  }

  /// Geri yüklenen satın alma işleme
  void _handleRestoredPurchase(PurchaseDetails purchaseDetails) {
    print('🔄 Satın alma geri yüklendi: ${purchaseDetails.productID}');
    
    if (onPurchaseRestored != null) {
      onPurchaseRestored!(purchaseDetails);
    }
    
    // Firestore'da subscription güncelle
    _saveSubscriptionToFirestore(purchaseDetails);
  }

  /// Başarısız satın alma işleme
  void _handleFailedPurchase(PurchaseDetails purchaseDetails) {
    print('❌ Satın alma başarısız: ${purchaseDetails.error}');
    
    if (onPurchaseError != null) {
      onPurchaseError!(purchaseDetails, purchaseDetails.error);
    }
  }

  /// İptal edilen satın alma işleme
  void _handleCanceledPurchase(PurchaseDetails purchaseDetails) {
    print('🚫 Satın alma iptal edildi: ${purchaseDetails.productID}');
  }

  /// Purchase verification (Server-side yapılmalı)
  /// Bu sadece temel bir kontrol, production'da Firebase Functions kullanılmalı
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // TODO: Server-side verification implement et
    // Firebase Functions ile App Store/Play Store API'lerini çağırarak doğrula
    
    // Şimdilik basit kontrol
    return purchaseDetails.verificationData.serverVerificationData.isNotEmpty;
  }

  /// Subscription'ı Firestore'a kaydet
  Future<void> _saveSubscriptionToFirestore(PurchaseDetails purchaseDetails) async {
    // TODO: Firestore'a subscription kaydetme implementasyonu
    print('📝 Subscription Firestore\'a kaydedilecek: ${purchaseDetails.productID}');
    
    // Bu method Repository pattern ile implement edilmeli
    // SubscriptionRepository.saveSubscription() çağrılmalı
  }

  /// Eski subscription token'ını getir (Android upgrade için)
  Future<PurchaseDetails?> _getOldSubscriptionToken(String oldSubscriptionId) async {
    // TODO: Eski purchase details'ı Firestore'dan veya cache'den getir
    return null;
  }

  /// Aktif subscription'ı kontrol et
  Future<bool> hasActiveSubscription() async {
    if (!_isAvailable) return false;

    try {
      // Platform-specific query
      if (Platform.isAndroid) {
        final androidAddition = InAppPurchaseAndroidPlatformAddition.instance;
        final response = await androidAddition.queryPastPurchases();
        
        if (response.error != null) {
          print('❌ Query error: ${response.error}');
          return false;
        }

        // Aktif subscription var mı kontrol et
        return response.pastPurchases.any((purchase) =>
            _productIds.contains(purchase.productID) &&
            purchase.status == PurchaseStatus.purchased);
      } else if (Platform.isIOS) {
        final iosAddition = InAppPurchaseStoreKitPlatformAddition.instance;
        // iOS için past purchases query
        // Not: iOS'ta otomatik restore yapılır
        return false; // Implement edilmeli
      }
      
      return false;
    } catch (e) {
      print('❌ Check subscription error: $e');
      return false;
    }
  }

  /// Subscription plan'ı product ID'den çıkar
  SubscriptionPlan? getPlanFromProductId(String productId) {
    if (productId.contains('basic')) {
      return SubscriptionPlan.basic;
    } else if (productId.contains('premium')) {
      return SubscriptionPlan.premium;
    }
    return null;
  }

  /// Billing period'u product ID'den çıkar
  String getBillingPeriod(String productId) {
    if (productId.contains('monthly')) {
      return 'monthly';
    } else if (productId.contains('yearly')) {
      return 'yearly';
    }
    return 'unknown';
  }

  /// Dispose
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}

/// IAP Exception
class IAPException implements Exception {
  final String message;
  final dynamic error;

  IAPException(this.message, [this.error]);

  @override
  String toString() => 'IAPException: $message${error != null ? ' - $error' : ''}';
}

/// Purchase status helper
extension PurchaseDetailsExtension on PurchaseDetails {
  bool get isPurchased => status == PurchaseStatus.purchased;
  bool get isPending => status == PurchaseStatus.pending;
  bool get isRestored => status == PurchaseStatus.restored;
  bool get isFailed => status == PurchaseStatus.error;
  bool get isCanceled => status == PurchaseStatus.canceled;
}
