import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob Service - Reklam yönetimi
class AdMobService {
  static AdMobService? _instance;
  static AdMobService get instance => _instance ??= AdMobService._();

  AdMobService._();

  bool _isInitialized = false;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  /// Ad Unit IDs
  // TODO: Production için gerçek ad unit ID'leri ekleyin
  static String get _bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ID
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get _interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // Test ID
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get _rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // Test ID
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Initialize AdMob
  Future<void> initialize() async {
    if (_isInitialized) return;

    await MobileAds.instance.initialize();
    _isInitialized = true;
  }

  /// Create banner ad widget
  BannerAd createBannerAd({
    AdSize size = AdSize.banner,
    BannerAdListener? listener,
  }) {
    return BannerAd(
      adUnitId: _bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: listener ??
          BannerAdListener(
            onAdLoaded: (ad) {
              // Debug: Banner ad loaded
            },
            onAdFailedToLoad: (ad, error) {
              // Debug: Banner ad failed to load: $error
              ad.dispose();
            },
          ),
    );
  }

  /// Load interstitial ad
  Future<void> loadInterstitialAd({
    required VoidCallback onAdLoaded,
    VoidCallback? onAdFailedToLoad,
  }) async {
    if (!_isInitialized) await initialize();

    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              // Debug: Interstitial ad failed to show: $error
              ad.dispose();
              _interstitialAd = null;
            },
          );
          onAdLoaded();
        },
        onAdFailedToLoad: (error) {
          // Debug: Interstitial ad failed to load: $error
          if (onAdFailedToLoad != null) {
            onAdFailedToLoad();
          }
        },
      ),
    );
  }

  /// Show interstitial ad
  Future<void> showInterstitialAd() async {
    if (_interstitialAd != null) {
      await _interstitialAd!.show();
      _interstitialAd = null;
    }
    // Debug: Interstitial ad not loaded yet
  }

  /// Load rewarded ad
  Future<void> loadRewardedAd({
    required VoidCallback onAdLoaded,
    VoidCallback? onAdFailedToLoad,
  }) async {
    if (!_isInitialized) await initialize();

    await RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              // Debug: Rewarded ad failed to show: $error
              ad.dispose();
              _rewardedAd = null;
            },
          );
          onAdLoaded();
        },
        onAdFailedToLoad: (error) {
          // Debug: Rewarded ad failed to load: $error
          if (onAdFailedToLoad != null) {
            onAdFailedToLoad();
          }
        },
      ),
    );
  }

  /// Show rewarded ad
  Future<bool> showRewardedAd({
    required Function(RewardItem reward) onUserEarnedReward,
  }) async {
    if (_rewardedAd != null) {
      bool rewardEarned = false;
      
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          rewardEarned = true;
          onUserEarnedReward(reward);
        },
      );
      
      _rewardedAd = null;
      return rewardEarned;
    }
    // Debug: Rewarded ad not loaded yet
    return false;
  }

  /// Dispose ads
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}

/// Ad Manager Widget için helper
class AdHelper {
  /// Interstitial ad gösterim sıklığı kontrolü
  static int _interstitialAdCounter = 0;
  static const int _interstitialAdFrequency = 3; // Her 3 aksiyon için bir reklam

  /// Check if should show interstitial ad
  static bool shouldShowInterstitialAd() {
    _interstitialAdCounter++;
    if (_interstitialAdCounter >= _interstitialAdFrequency) {
      _interstitialAdCounter = 0;
      return true;
    }
    return false;
  }

  /// Show interstitial ad if needed
  static Future<void> showInterstitialIfNeeded({
    VoidCallback? onComplete,
  }) async {
    if (shouldShowInterstitialAd()) {
      await AdMobService.instance.loadInterstitialAd(
        onAdLoaded: () async {
          await AdMobService.instance.showInterstitialAd();
          if (onComplete != null) onComplete();
        },
        onAdFailedToLoad: () {
          if (onComplete != null) onComplete();
        },
      );
    } else {
      if (onComplete != null) onComplete();
    }
  }

  /// Get adaptive banner size
  /// For simple implementation, returns standard banner size
  /// For adaptive sizing, pass BuildContext to calculate screen width
  static Future<AdSize> getAdaptiveBannerSize([BuildContext? context]) async {
    if (context != null) {
      final screenWidth = MediaQuery.of(context).size.width.toInt();
      return AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(screenWidth)
          ?? AdSize.banner;
    }
    // Fallback to standard banner when no context provided
    return AdSize.banner;
  }
}

/// Banner ad widget helper
class BannerAdWidget {
  final BannerAd ad;
  bool isLoaded = false;

  BannerAdWidget({required this.ad}) {
    ad.load();
  }

  void dispose() {
    ad.dispose();
  }
}
