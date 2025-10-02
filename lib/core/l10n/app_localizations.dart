import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Auth
      'sign_in': 'Sign In',
      'sign_up': 'Sign Up',
      'email': 'Email',
      'password': 'Password',
      'full_name': 'Full Name',
      'forgot_password': 'Forgot Password?',
      'create_account': 'Create Account',
      'already_have_account': 'Already have an account?',
      'dont_have_account': "Don't have an account?",
      'continue_with_google': 'Continue with Google',
      'continue_with_phone': 'Continue with Phone',
      
      // Navigation
      'home': 'Home',
      'explore': 'Explore',
      'trades': 'Trades',
      'favorites': 'Favorites',
      'profile': 'Profile',
      
      // Items
      'discover_items': 'Discover Items',
      'my_listings': 'My Listings',
      'create_item': 'Create Item',
      'edit_item': 'Edit Item',
      'item_title': 'Item Title',
      'item_description': 'Description',
      'category': 'Category',
      'condition': 'Condition',
      'location': 'Location',
      'add_photos': 'Add Photos',
      'save': 'Save',
      'delete': 'Delete',
      'share': 'Share',
      
      // Categories
      'all': 'All',
      'electronics': 'Electronics',
      'fashion': 'Fashion',
      'home': 'Home',
      'books': 'Books',
      'sports': 'Sports',
      'toys': 'Toys',
      
      // Conditions
      'new': 'New',
      'like_new': 'Like New',
      'good': 'Good',
      'fair': 'Fair',
      'poor': 'Poor',
      
      // Trades
      'send_trade_offer': 'Send Trade Offer',
      'accept_trade': 'Accept Trade',
      'reject_trade': 'Reject',
      'trade_history': 'Trade History',
      'pending': 'Pending',
      'accepted': 'Accepted',
      'rejected': 'Rejected',
      'completed': 'Completed',
      
      // Profile
      'edit_profile': 'Edit Profile',
      'settings': 'Settings',
      'logout': 'Logout',
      'total_items': 'Total Items',
      'completed_trades': 'Completed Trades',
      'member_since': 'Member Since',
      
      // Search & Filter
      'search': 'Search',
      'search_items': 'Search items...',
      'filter': 'Filter',
      'filter_options': 'Filter Options',
      'apply_filters': 'Apply Filters',
      'reset': 'Reset',
      'price_range': 'Price Range',
      'max_distance': 'Maximum Distance',
      'show_only_active': 'Show only active items',
      
      // Messages
      'no_items': 'No items yet',
      'no_trades': 'No trades yet',
      'no_favorites': 'No favorites yet',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'item_created': 'Item created successfully',
      'item_updated': 'Item updated successfully',
      'item_deleted': 'Item deleted successfully',
      'trade_sent': 'Trade offer sent',
      'trade_accepted': 'Trade accepted',
      'trade_rejected': 'Trade rejected',
      
      // Common
      'yes': 'Yes',
      'no': 'No',
      'cancel': 'Cancel',
      'ok': 'OK',
      'confirm': 'Confirm',
      'back': 'Back',
      'next': 'Next',
      'done': 'Done',
      'view_details': 'View Details',
      'coming_soon': 'Coming Soon!',
    },
    'tr': {
      // Auth
      'sign_in': 'Giriş Yap',
      'sign_up': 'Kayıt Ol',
      'email': 'E-posta',
      'password': 'Şifre',
      'full_name': 'Ad Soyad',
      'forgot_password': 'Şifremi Unuttum?',
      'create_account': 'Hesap Oluştur',
      'already_have_account': 'Zaten hesabınız var mı?',
      'dont_have_account': 'Hesabınız yok mu?',
      'continue_with_google': 'Google ile Devam Et',
      'continue_with_phone': 'Telefon ile Devam Et',
      
      // Navigation
      'home': 'Ana Sayfa',
      'explore': 'Keşfet',
      'trades': 'Takaslar',
      'favorites': 'Favoriler',
      'profile': 'Profil',
      
      // Items
      'discover_items': 'Ürünleri Keşfet',
      'my_listings': 'İlanlarım',
      'create_item': 'İlan Oluştur',
      'edit_item': 'İlanı Düzenle',
      'item_title': 'Ürün Başlığı',
      'item_description': 'Açıklama',
      'category': 'Kategori',
      'condition': 'Durum',
      'location': 'Konum',
      'add_photos': 'Fotoğraf Ekle',
      'save': 'Kaydet',
      'delete': 'Sil',
      'share': 'Paylaş',
      
      // Categories
      'all': 'Tümü',
      'electronics': 'Elektronik',
      'fashion': 'Moda',
      'home': 'Ev',
      'books': 'Kitap',
      'sports': 'Spor',
      'toys': 'Oyuncak',
      
      // Conditions
      'new': 'Sıfır',
      'like_new': 'Sıfır Gibi',
      'good': 'İyi',
      'fair': 'Orta',
      'poor': 'Kötü',
      
      // Trades
      'send_trade_offer': 'Takas Teklifi Gönder',
      'accept_trade': 'Takası Kabul Et',
      'reject_trade': 'Reddet',
      'trade_history': 'Takas Geçmişi',
      'pending': 'Beklemede',
      'accepted': 'Kabul Edildi',
      'rejected': 'Reddedildi',
      'completed': 'Tamamlandı',
      
      // Profile
      'edit_profile': 'Profili Düzenle',
      'settings': 'Ayarlar',
      'logout': 'Çıkış Yap',
      'total_items': 'Toplam Ürün',
      'completed_trades': 'Tamamlanan Takaslar',
      'member_since': 'Üyelik Tarihi',
      
      // Search & Filter
      'search': 'Ara',
      'search_items': 'Ürün ara...',
      'filter': 'Filtrele',
      'filter_options': 'Filtre Seçenekleri',
      'apply_filters': 'Filtreleri Uygula',
      'reset': 'Sıfırla',
      'price_range': 'Fiyat Aralığı',
      'max_distance': 'Maksimum Mesafe',
      'show_only_active': 'Sadece aktif ürünleri göster',
      
      // Messages
      'no_items': 'Henüz ürün yok',
      'no_trades': 'Henüz takas yok',
      'no_favorites': 'Henüz favori yok',
      'loading': 'Yükleniyor...',
      'error': 'Hata',
      'success': 'Başarılı',
      'item_created': 'Ürün başarıyla oluşturuldu',
      'item_updated': 'Ürün başarıyla güncellendi',
      'item_deleted': 'Ürün başarıyla silindi',
      'trade_sent': 'Takas teklifi gönderildi',
      'trade_accepted': 'Takas kabul edildi',
      'trade_rejected': 'Takas reddedildi',
      
      // Common
      'yes': 'Evet',
      'no': 'Hayır',
      'cancel': 'İptal',
      'ok': 'Tamam',
      'confirm': 'Onayla',
      'back': 'Geri',
      'next': 'İleri',
      'done': 'Bitti',
      'view_details': 'Detayları Gör',
      'coming_soon': 'Yakında!',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
  
  // Convenience getters
  String get signIn => translate('sign_in');
  String get signUp => translate('sign_up');
  String get email => translate('email');
  String get password => translate('password');
  String get fullName => translate('full_name');
  String get forgotPassword => translate('forgot_password');
  String get createAccount => translate('create_account');
  String get alreadyHaveAccount => translate('already_have_account');
  String get dontHaveAccount => translate('dont_have_account');
  String get continueWithGoogle => translate('continue_with_google');
  String get continueWithPhone => translate('continue_with_phone');
  
  String get home => translate('home');
  String get explore => translate('explore');
  String get trades => translate('trades');
  String get favorites => translate('favorites');
  String get profile => translate('profile');
  
  String get discoverItems => translate('discover_items');
  String get myListings => translate('my_listings');
  String get createItem => translate('create_item');
  String get editItem => translate('edit_item');
  String get itemTitle => translate('item_title');
  String get itemDescription => translate('item_description');
  String get category => translate('category');
  String get condition => translate('condition');
  String get location => translate('location');
  String get addPhotos => translate('add_photos');
  String get save => translate('save');
  String get delete => translate('delete');
  String get share => translate('share');
  
  String get search => translate('search');
  String get searchItems => translate('search_items');
  String get filter => translate('filter');
  String get filterOptions => translate('filter_options');
  String get applyFilters => translate('apply_filters');
  String get reset => translate('reset');
  
  String get yes => translate('yes');
  String get no => translate('no');
  String get cancel => translate('cancel');
  String get ok => translate('ok');
  String get confirm => translate('confirm');
  String get back => translate('back');
  String get next => translate('next');
  String get done => translate('done');
  String get viewDetails => translate('view_details');
  String get comingSoon => translate('coming_soon');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'tr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
