import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:io';

import 'package:flutter/foundation.dart';

class CloudinaryUtils {
  static final _cloudinary = CloudinaryPublic(
    'dhvucxi2s',
    'legitcards',
    cache: false,
  );

  static Future<String?> uploadImage(File imageFile) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl; // ✅ Cloud image URL
    } catch (e) {
      if (kDebugMode) {
        print("General log: Cloudinary upload failed: $e");
      }
      return null;
    }
  }
}
