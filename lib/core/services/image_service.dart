import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:injectable/injectable.dart';

/// Kaliteli görsel yükleme servisi
@injectable
class ImageService {
  static const String placeholderPath = 'assets/images/placeholder/';
  
  /// Kullanıcı avatarı için kaliteli görsel widget
  static Widget userAvatar({
    String? imageUrl,
    double size = 40.0,
    String? placeholder,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildPlaceholder(size),
                errorWidget: (context, url, error) => _buildPlaceholder(size),
                memCacheWidth: (size * 2).toInt(),
                memCacheHeight: (size * 2).toInt(),
              )
            : _buildPlaceholder(size),
      ),
    );
  }
  
  /// Ürün görseli için kaliteli widget
  static Widget itemImage({
    String? imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: fit,
                placeholder: (context, url) => _buildItemPlaceholder(width, height),
                errorWidget: (context, url, error) => _buildItemPlaceholder(width, height),
                memCacheWidth: width != null ? (width * 2).toInt() : null,
                memCacheHeight: height != null ? (height * 2).toInt() : null,
              )
            : _buildItemPlaceholder(width, height),
      ),
    );
  }
  
  /// Placeholder widget
  static Widget _buildPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Colors.grey[300]!,
            Colors.grey[400]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: Colors.grey[600],
      ),
    );
  }
  
  /// Ürün placeholder widget
  static Widget _buildItemPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[300]!,
            Colors.grey[400]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.image,
        size: (width != null && height != null) 
            ? (width < height ? width * 0.3 : height * 0.3)
            : 40,
        color: Colors.grey[600],
      ),
    );
  }
}
