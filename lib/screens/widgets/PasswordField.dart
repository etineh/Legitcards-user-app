import 'package:flutter/material.dart';
import 'package:legit_cards/constants/app_colors.dart';
import 'package:legit_cards/data/repository/app_repository.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String labelText;
  final String? hintText;
  final bool initialObscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputAction textInputAction;
  final Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool autofocus;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final Color? enabledBorderColor;

  const PasswordField({
    super.key,
    this.controller,
    required this.labelText,
    this.hintText,
    this.initialObscureText = true,
    this.prefixIcon = Icons.lock_outlined,
    this.suffixIcon,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.validator,
    this.enabled = true,
    this.autofocus = false,
    this.fillColor,
    this.contentPadding,
    this.margin,
    this.borderRadius = 16.0,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.enabledBorderColor,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.initialObscureText;
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscureText,
        // NO maxLines or minLines - let Flutter handle it automatically
        keyboardType: TextInputType.text, // Always text for passwords
        textInputAction: widget.textInputAction,
        onFieldSubmitted: widget.onFieldSubmitted,
        validator: widget.validator,
        enabled: widget.enabled,
        autofocus: widget.autofocus,
        style: TextStyle(
          color: context.blackWhite,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          labelStyle: TextStyle(
            color: context.defaultColor.withOpacity(0.3),
          ),
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: widget.prefixIcon != null
              ? Icon(
                  widget.prefixIcon,
                  color: Colors.grey[600],
                )
              : null,
          suffixIcon: widget.suffixIcon ??
              IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey[600],
                ),
                onPressed: _toggleObscureText,
              ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(
              color: widget.enabledBorderColor ?? Colors.grey[300]!,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(
              color: widget.focusedBorderColor ?? AppColors.lightPurple,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(
              color: widget.errorBorderColor ?? Colors.red,
              width: 2,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(
              color: widget.enabledBorderColor ?? context.backgroundGray,
            ),
          ),
          filled: true,
          fillColor: widget.fillColor ?? Colors.grey[50],
          contentPadding: widget.contentPadding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          errorStyle: TextStyle(
            color: widget.errorBorderColor ?? Colors.red,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
