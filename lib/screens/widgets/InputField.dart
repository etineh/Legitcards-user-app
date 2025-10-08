import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:legit_cards/constants/app_colors.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';

class InputField extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final String? hintText;
  final String? initialValue;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Function(String)? onFieldSubmitted;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final VoidCallback? onSuffixTap;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final bool autofocus;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final Color? enabledBorderColor;
  final Color? textColor;
  final Color? hintTextColor;

  const InputField({
    super.key,
    this.controller,
    required this.labelText,
    this.hintText,
    this.initialValue,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onFieldSubmitted,
    this.inputFormatters,
    this.validator,
    this.onSuffixTap,
    this.maxLines,
    this.minLines,
    this.enabled = true,
    this.autofocus = false,
    this.fillColor,
    this.contentPadding,
    this.margin,
    this.borderRadius = 16.0,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.enabledBorderColor,
    this.textColor,
    this.hintTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMaxLines = obscureText ? null : maxLines;
    final effectiveMinLines = obscureText ? null : minLines;
    final effectiveKeyboardType =
        obscureText ? TextInputType.text : keyboardType;

    return Container(
      margin: margin,
      child: TextFormField(
        controller: controller,
        initialValue: initialValue,
        obscureText: obscureText,
        keyboardType: effectiveKeyboardType,
        onChanged: onChanged,
        textInputAction: textInputAction,
        onFieldSubmitted: onFieldSubmitted,
        inputFormatters: inputFormatters,
        validator: validator,
        maxLines: effectiveMaxLines,
        minLines: effectiveMinLines,
        enabled: enabled,
        autofocus: autofocus,
        style: TextStyle(
          color: textColor ?? context.blackWhite, // customizable text color
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: hintTextColor ?? Colors.grey[400], // customizable hint color
          ),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: Colors.grey[600])
              : null,
          suffixIcon: suffixIcon ??
              (obscureText
                  ? IconButton(
                      icon: Icon(
                        obscureText
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.grey[600],
                      ),
                      onPressed: onSuffixTap,
                    )
                  : null),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: enabledBorderColor ?? AppColors.lighterPurple,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: focusedBorderColor ?? AppColors.lightPurple,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: errorBorderColor ?? Colors.red,
              width: 2,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: enabledBorderColor ?? context.backgroundGray,
            ),
          ),
          filled: true,
          fillColor: fillColor ?? Colors.grey[50],
          contentPadding: contentPadding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          errorStyle: TextStyle(
            color: errorBorderColor ?? Colors.red,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
