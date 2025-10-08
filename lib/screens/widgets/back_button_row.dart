import 'package:flutter/material.dart';

class BackButtonRow extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final Color? iconColor;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? buttonSize;
  final bool showSpaceAfter; // For consistent spacing
  final Widget? customIcon;

  const BackButtonRow({
    super.key,
    this.onPressed,
    this.icon = Icons.arrow_back,
    this.iconColor,
    this.iconSize,
    this.padding,
    this.margin,
    this.buttonSize,
    this.showSpaceAfter = true,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Row(
        children: [
          // Back Button
          IconButton(
            onPressed: onPressed ?? () => Navigator.pop(context),
            icon: customIcon ??
                Icon(
                  icon,
                  color: iconColor ?? Colors.black,
                  size: iconSize,
                ),
            padding: padding ?? EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: buttonSize ?? 40,
              minHeight: buttonSize ?? 40,
            ),
            splashRadius: buttonSize ?? 24,
            visualDensity: VisualDensity.compact,
          ),
          // Optional space after
          if (showSpaceAfter) const SizedBox(width: 16),
        ],
      ),
    );
  }
}
