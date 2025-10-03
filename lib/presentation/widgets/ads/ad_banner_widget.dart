import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/services/admob_service.dart';

/// Reusable Ad Banner Widget
/// 
/// Features:
/// - Automatic loading and disposal
/// - Error handling with placeholder
/// - Loading state
/// - Adaptive sizing
/// 
/// Usage:
/// ```dart
/// AdBannerWidget(
///   placement: AdPlacement.bottom,
/// )
/// ```
class AdBannerWidget extends StatefulWidget {
  final AdPlacement placement;
  final bool showPlaceholder;
  
  const AdBannerWidget({
    Key? key,
    this.placement = AdPlacement.bottom,
    this.showPlaceholder = true,
  }) : super(key: key);

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadAd() {
    _bannerAd = AdMobService.instance.createBannerAd(
      size: _getAdSize(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isLoaded = true;
              _isError = false;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner ad failed to load: $error');
          if (mounted) {
            setState(() {
              _isError = true;
              _isLoaded = false;
            });
          }
          ad.dispose();
        },
      ),
    );
    _bannerAd!.load();
  }

  AdSize _getAdSize() {
    switch (widget.placement) {
      case AdPlacement.top:
      case AdPlacement.bottom:
        return AdSize.banner; // 320x50
      case AdPlacement.inline:
        return AdSize.mediumRectangle; // 300x250
      case AdPlacement.large:
        return AdSize.largeBanner; // 320x100
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything if ad is not loaded and placeholder is disabled
    if (!_isLoaded && !widget.showPlaceholder) {
      return const SizedBox.shrink();
    }

    // Show error placeholder
    if (_isError) {
      return _buildErrorPlaceholder();
    }

    // Show loading placeholder
    if (!_isLoaded) {
      return _buildLoadingPlaceholder();
    }

    // Show actual ad
    return _buildAd();
  }

  Widget _buildAd() {
    if (_bannerAd == null) return const SizedBox.shrink();

    final adSize = _getAdSize();
    
    return Container(
      width: adSize.width.toDouble(),
      height: adSize.height.toDouble(),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  Widget _buildLoadingPlaceholder() {
    final adSize = _getAdSize();
    
    return Container(
      width: adSize.width.toDouble(),
      height: adSize.height.toDouble(),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Reklam yükleniyor...',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    if (!widget.showPlaceholder) {
      return const SizedBox.shrink();
    }

    final adSize = _getAdSize();
    
    return Container(
      width: adSize.width.toDouble(),
      height: adSize.height.toDouble(),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Icon(
        Icons.info_outline,
        color: Colors.grey[400],
        size: 24,
      ),
    );
  }
}

/// Ad Placement Types
enum AdPlacement {
  top,
  bottom,
  inline,
  large,
}

/// Smart Ad Banner - Shows ad only for free users
class SmartAdBanner extends StatelessWidget {
  final AdPlacement placement;
  final bool isFreePlan;
  
  const SmartAdBanner({
    Key? key,
    this.placement = AdPlacement.bottom,
    required this.isFreePlan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isFreePlan) {
      return const SizedBox.shrink();
    }

    return AdBannerWidget(placement: placement);
  }
}

/// List Ad Banner - Appears between list items
class ListAdBanner extends StatelessWidget {
  final bool isFreePlan;
  
  const ListAdBanner({
    Key? key,
    required this.isFreePlan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isFreePlan) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: const AdBannerWidget(
        placement: AdPlacement.inline,
      ),
    );
  }
}

/// Bottom Sheet Ad Banner - For bottom sheets
class BottomSheetAdBanner extends StatelessWidget {
  final bool isFreePlan;
  
  const BottomSheetAdBanner({
    Key? key,
    required this.isFreePlan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isFreePlan) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: const AdBannerWidget(
        placement: AdPlacement.large,
      ),
    );
  }
}

/// Ad Free Badge Widget - Shows for premium users
class AdFreeBadge extends StatelessWidget {
  const AdFreeBadge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.block,
            color: Colors.white,
            size: 16,
          ),
          SizedBox(width: 6),
          Text(
            'Reklamsız',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
