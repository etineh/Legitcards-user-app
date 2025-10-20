import 'package:flutter/material.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';

import '../../constants/app_colors.dart';
import '../../constants/k.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent, // Make background transparent
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFBF2882), // light purple
              Color(0xFF5B2C98), // deep indigo
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(K.isAndroid() ? Icons.arrow_back : Icons.arrow_back_ios,
            color: Colors.white),
        onPressed: onBack ?? () => context.goBack(),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
