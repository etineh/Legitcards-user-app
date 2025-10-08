import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:legit_cards/constants/app_colors.dart';

class TermsCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? checkColor;
  final Color? textColor;
  final double textSize;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onPrivacyPolicyTap;
  final VoidCallback? onTermsTap;
  final String? privacyPolicyText;
  final String? termsText;
  final String? prefixText;
  final String? suffixText;

  const TermsCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.checkColor,
    this.textColor,
    this.textSize = 14.0,
    this.margin,
    this.onPrivacyPolicyTap,
    this.onTermsTap,
    this.privacyPolicyText = 'privacy policy',
    this.termsText = 'terms and conditions',
    this.prefixText = 'By clicking Sign Up, you have read and agreed to our ',
    this.suffixText = '.',
  });

  @override
  State<TermsCheckbox> createState() => _TermsCheckboxState();
}

class _TermsCheckboxState extends State<TermsCheckbox> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  void _handleCheckboxChanged(bool? newValue) {
    if (newValue != null) {
      setState(() {
        _value = newValue;
      });
      widget.onChanged?.call(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: Row(
        children: [
          Checkbox(
            value: _value,
            onChanged: widget.onChanged != null ? _handleCheckboxChanged : null,
            activeColor: widget.activeColor ?? AppColors.lightPurple,
            checkColor: widget.checkColor ?? Colors.white,
            side: const BorderSide(
              color: Colors.grey,
              width: 1.5,
            ),
            // side: const BorderSide(color: Colors.transparent),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: widget.textColor ?? Colors.grey[600],
                  fontSize: widget.textSize,
                ),
                children: [
                  if (widget.prefixText != null) ...[
                    TextSpan(text: widget.prefixText!),
                  ],
                  if (widget.onPrivacyPolicyTap != null) ...[
                    TextSpan(
                      text: widget.privacyPolicyText,
                      style: TextStyle(
                        color: widget.activeColor ?? AppColors.lightPurple,
                        decoration: TextDecoration.underline,
                        decorationColor:
                            widget.activeColor ?? AppColors.lightPurple,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = widget.onPrivacyPolicyTap,
                    ),
                  ] else ...[
                    TextSpan(text: widget.privacyPolicyText),
                  ],
                  if (widget.privacyPolicyText != null &&
                      widget.termsText != null)
                    const TextSpan(text: ' and '),
                  if (widget.onTermsTap != null) ...[
                    TextSpan(
                      text: widget.termsText,
                      style: TextStyle(
                        color: widget.activeColor ?? AppColors.lightPurple,
                        decoration: TextDecoration.underline,
                        decorationColor:
                            widget.activeColor ?? AppColors.lightPurple,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = widget.onTermsTap,
                    ),
                  ] else ...[
                    TextSpan(text: widget.termsText),
                  ],
                  if (widget.suffixText != null) ...[
                    TextSpan(text: widget.suffixText!),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
