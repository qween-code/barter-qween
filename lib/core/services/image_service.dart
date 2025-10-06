import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:injectable/injectable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

/// Kaliteli görsel yükleme servisi
@injectable
class ImageService {
  final FirebaseStorage _storage;
  
  ImageService(this._storage);
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
  
  /// Compress image before upload
  Future<File?> compressImage(File file) async {
    try {
      final filePath = file.absolute.path;
      final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
      final splitted = filePath.substring(0, lastIndex);
      final outPath = "${splitted}_compressed.jpg";

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        outPath,
        quality: 85,
        minWidth: 1024,
        minHeight: 1024,
      );

      return result != null ? File(result.path) : null;
    } catch (e) {
      print('Error compressing image: $e');
      return file; // Return original if compression fails
    }
  }

  /// Upload item image to Firebase Storage
  Future<String?> uploadItemImage(File imageFile, String itemId) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final ref = _storage.ref().child('items/$itemId/$fileName');
      
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Upload user avatar
  Future<String?> uploadUserAvatar(File imageFile, String userId) async {
    try {
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('users/$userId/$fileName');
      
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }

  /// Delete image from Firebase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
    }
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
