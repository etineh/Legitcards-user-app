import 'package:flutter/material.dart';
import 'package:legit_cards/constants/app_colors.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? imagePath;
  final EdgeInsetsGeometry? margin;

  const LogoWidget({
    super.key,
    this.size = 80.0,
    this.backgroundColor,
    this.iconColor,
    this.imagePath = 'assets/images/trans_logo2.png',
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      margin: margin,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor != null
            ? (backgroundColor ?? AppColors.primaryPurple)
            : null, // Only use color if gradient is not provided
        gradient: const LinearGradient(
          colors: [
            Color(0xFFBF2882), // light purple
            Color(0xFF5B2C98), // deep indigo
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: imagePath != null
            ? Image.asset(
                imagePath!,
                width: size * 0.75,
                height: size * 0.75,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.card_giftcard,
                      size: size * 0.4,
                      color: iconColor ?? const Color(0xFF8B5CF6),
                    ),
                  );
                },
              )
            : Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.card_giftcard,
                  size: size * 0.4,
                  color: iconColor ?? const Color(0xFF8B5CF6),
                ),
              ),
      ),
    );
  }
}
