import 'package:flutter/material.dart';
import 'package:legit_cards/Utilities/adjust_utils.dart';
import 'package:legit_cards/Utilities/adjust_utils.dart';
import 'package:legit_cards/Utilities/date_utils.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import 'package:legit_cards/screens/widgets/app_bar.dart';

import '../../constants/app_colors.dart';
import '../../data/models/notification_model.dart';

class NotificationDetailScreen extends StatelessWidget {
  final NotificationM notification;

  const NotificationDetailScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    // final color = AdjustUtils.getColorForTitle(notification.notification.title);
    final icon = AdjustUtils.getIconForTitle(notification.notification.title);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: const CustomAppBar(title: "Notification"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFBF2882), // light purple
                    Color(0xFF5B2C98),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    notification.notification.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Time
                  Text(
                    DateAndTimeUtils.formatToDateAndTime(
                        notification.createdAt),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            // Body content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Message',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: context.blackWhite.withOpacity(0.7),
                      ),
                    ),
                    const Divider(height: 24),
                    Text(
                      notification.notification.body,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: context.blackWhite,
                      ),
                    ),
                    if (notification.reference.isNotEmpty) ...[
                      const Divider(height: 32),
                      Row(
                        children: [
                          Icon(
                            Icons.tag,
                            size: 16,
                            color: context.blackWhite.withOpacity(0.5),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Reference: ${notification.reference}',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.blackWhite.withOpacity(0.5),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
