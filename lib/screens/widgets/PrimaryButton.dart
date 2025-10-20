import 'package:flutter/material.dart';
import 'package:legit_cards/constants/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? disabledBackgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final TextStyle? textStyle;
  final Widget? loadingWidget;
  final String? loadingText;
  final double? loadingSize;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.height = 50.0,
    this.width,
    this.borderRadius = 28.0,
    this.backgroundColor = AppColors.lightPurple,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.padding,
    this.margin,
    this.textStyle,
    this.loadingWidget,
    this.loadingText,
    this.loadingSize,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? AppColors.primaryPurple;
    final effectiveForegroundColor = foregroundColor ?? Colors.white;
    final effectiveDisabledColor = disabledBackgroundColor ?? Colors.grey[300]!;

    return Container(
      margin: margin,
      height: height,
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isLoading || !isEnabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled && !isLoading
              ? effectiveBackgroundColor
              : effectiveDisabledColor,
          foregroundColor:
              isEnabled ? effectiveForegroundColor : Colors.grey[500],
          disabledBackgroundColor: effectiveDisabledColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: isLoading
            ? (loadingWidget ??
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: loadingSize ?? 20,
                      width: loadingSize ?? 20,
                      child: CircularProgressIndicator(
                        color: effectiveForegroundColor,
                        strokeWidth: 2,
                      ),
                    ),
                    if (loadingText != null) ...[
                      const SizedBox(width: 12),
                      Text(
                        loadingText!,
                        style: textStyle?.copyWith(
                            color: effectiveForegroundColor),
                      ),
                    ],
                  ],
                ))
            : Text(
                text,
                style: textStyle ??
                    TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: effectiveForegroundColor,
                    ),
              ),
      ),
    );
  }
}
