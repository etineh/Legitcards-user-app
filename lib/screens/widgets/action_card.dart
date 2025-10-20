import 'package:flutter/material.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';

class ActionCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.text,
    this.icon = Icons.arrow_forward_ios,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: context.purpleText.withOpacity(0.2), // Custom splash
        highlightColor: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.purpleText.withOpacity(0.3)),
          ),
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: icon == Icons.delete
                      ? Colors.redAccent
                      : context.blackWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
              Icon(
                icon,
                color: icon == Icons.delete
                    ? Colors.redAccent
                    : context.purpleText,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
