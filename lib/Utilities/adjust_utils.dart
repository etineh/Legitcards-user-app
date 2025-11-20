import 'dart:math';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:legit_cards/constants/app_colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../data/models/history_model.dart';

class AdjustUtils {
  static String normalizePhone(String phone) {
    phone = phone.trim();

    // If it already starts with +, return as is
    if (phone.startsWith('+')) return phone;

    // Example: Nigeria default (+234)
    if (phone.startsWith('0')) {
      return '+234${phone.substring(1)}';
    }

    // Otherwise, just return with +
    return '+$phone';
  }

  static String generateUsername(String fullName) {
    // take first name or full name if no space
    String base = fullName.trim().contains(" ")
        ? fullName.trim().split(" ").first
        : fullName.trim();

    // add 4 random digits
    final random = Random();
    String randomDigits =
        (1000 + random.nextInt(900000)).toString(); // ensures 6 digits

    return "$base$randomDigits";
  }

  static String getFirstName(String fullName) {
    final parts = fullName.trim().split(" ");
    return parts.isNotEmpty ? parts.first : "";
  }

  static String getLastName(String fullName) {
    final parts = fullName.trim().split(" ");
    return parts.length > 1 ? parts.sublist(1).join(" ") : parts.first;
  }

  static String formatWithComma(num number) {
    final str = number.toStringAsFixed(2); // keep 2 decimals
    final parts = str.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    final buffer = StringBuffer();
    int count = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      buffer.write(integerPart[i]);
      count++;
      if (count % 3 == 0 && i != 0) buffer.write(',');
    }
    return buffer.toString().split('').reversed.join('') + decimalPart;
  }

  /// Compresses an image if it's larger than 1MB and returns the optimized File.
  /// If compression isn't needed or fails, it returns the original file.
  static Future<File> optimizeImage(File file,
      {int maxSizeInBytes = 1024 * 1024}) async {
    final bytes = await file.length();
    if (kDebugMode) {
      print("General log: the image size is ${bytes / (1024 * 1024)} MB");
    }

    // if file is already small enough
    if (bytes <= maxSizeInBytes) return file;

    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.path,
        "${DateTime.now().millisecondsSinceEpoch}.jpg",
      );

      final XFile? compressedFile =
          await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 70,
      );

      if (compressedFile != null) {
        // ✅ convert XFile → File before returning
        return File(compressedFile.path);
      }
    } catch (e) {
      if (kDebugMode) {
        print("General log: ⚠️ Image compression failed: $e");
      }
    }

    // fallback (if compression fails)
    return file;
  }

  static String shortName(String? name) {
    if (name == null || name.isEmpty) return "";
    return name.length > 15 ? name.substring(0, 15) : name;
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'selling':
      case 'exchanging':
        return AppColors.primaryPurple;
      case 'completed':
      case 'success':
        return Colors.green;
      case 'failed':
      case 'declined':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static IconData getIconForTitle(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('withdrawal')) return Icons.account_balance_wallet;
    if (lowerTitle.contains('trade') && lowerTitle.contains('completed')) {
      return Icons.check_circle;
    }
    if (lowerTitle.contains('trade') && lowerTitle.contains('declined')) {
      return Icons.cancel;
    }
    if (lowerTitle.contains('reward') || lowerTitle.contains('bonus')) {
      return Icons.card_giftcard;
    }
    if (lowerTitle.contains('weekend') || lowerTitle.contains('vibes')) {
      return Icons.celebration;
    }
    return Icons.notifications;
  }

  static Color getColorForTitle(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('withdrawal')) return Colors.blue;
    if (lowerTitle.contains('completed')) return Colors.green;
    if (lowerTitle.contains('declined')) return Colors.red;
    if (lowerTitle.contains('reward') || lowerTitle.contains('bonus')) {
      return Colors.orange;
    }
    if (lowerTitle.contains('weekend')) return Colors.purple;
    return AppColors.lightPurple;
  }

  // Extract MongoDB ObjectId (24 character hex string) from userid
  static String extractObjectId(String userid) {
    // MongoDB ObjectId is always 24 hex characters
    final regex = RegExp(r'^[a-f0-9]{24}');
    final match = regex.firstMatch(userid.toLowerCase());

    if (match != null) {
      return match.group(0)!;
    }

    // Fallback: take first 24 characters if it looks like an ObjectId
    if (userid.length >= 24) {
      return userid.substring(0, 24);
    }

    return userid; // Return as-is if can't extract
  }

  static bool statusWithCancelOption(GiftCardTradeM transaction) {
    return (transaction.status.toLowerCase() == 'pending' ||
        transaction.status.toLowerCase() == 'selling' ||
        transaction.status.toLowerCase() == 'exchanging');
  }

  // Get card abbreviation (2 letters for multi-word, 1 for single word)
  static String getCardAbbreviation(String cardName) {
    final words = cardName.trim().split(' ');
    if (words.length >= 2) {
      // Take first letter of first two words
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else {
      // Take first letter for single word
      return words[0][0].toUpperCase();
    }
  }
}
