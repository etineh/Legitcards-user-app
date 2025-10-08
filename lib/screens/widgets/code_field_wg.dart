import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../constants/app_colors.dart';

class CodeField extends StatelessWidget {
  final Function(String)? onCompleted;
  final Function(String)? onChanged;
  final int length;
  final TextInputType keyboardType;

  const CodeField({
    super.key,
    this.onCompleted,
    this.onChanged,
    this.length = 6,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      length: length,
      keyboardType: keyboardType, // can be number
      animationType: AnimationType.fade,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(8),
        fieldHeight: 50,
        fieldWidth: 45,
        // background
        activeFillColor: AppColors.lighterPurple,
        inactiveFillColor: Colors.white70,
        selectedFillColor: Colors.white,
        // border
        activeColor: AppColors.primaryPurple,
        selectedColor: AppColors.primaryPurple,
        inactiveColor: AppColors.lighterPurple,
      ),
      animationDuration: const Duration(milliseconds: 300),
      enableActiveFill: true,
      textStyle: const TextStyle(color: Colors.black),
      onCompleted: onCompleted,
      onChanged: onChanged,
    );
  }
}
