import 'package:flutter/material.dart';
import 'package:legit_cards/screens/widgets/app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class DirectSupportScreen extends StatelessWidget {
  const DirectSupportScreen({super.key});

  // Contact details
  static const String phoneNumber = '+234 (0) 806-051-7997';
  static const String email = 'support@legitcards.com.ng';
  static const String whatsappUrl = 'https://wa.me/2348060517997';
  static const String instagramUrl = 'https://instagram.com/legitcards_ng';
  static const String facebookUrl = 'https://facebook.com/legitcardsng';
  static const String privacyPolicyUrl =
      'https://legitcards.com.ng/privacy-policy.php';
  static const String termsUrl = 'https://legitcards.com.ng/terms.php';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomAppBar(title: "Direct Support"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Main Contact Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Phone Call Section
                    _buildContactSection(
                      context,
                      icon: Icons.phone,
                      iconColor: Colors.green,
                      title: 'Phone Call',
                      subtitle: phoneNumber,
                      hint: 'Tap number to call',
                      onTap: () => _makePhoneCall(context),
                    ),
                    const SizedBox(height: 24),

                    // WhatsApp Section
                    _buildContactSection(
                      context,
                      icon: Icons.chat,
                      iconColor: Colors.green,
                      title: 'WhatsApp',
                      subtitle: phoneNumber,
                      hint: null,
                      onTap: () => _openWhatsApp(context),
                    ),
                    const SizedBox(height: 24),

                    // Email Section
                    _buildContactSection(
                      context,
                      icon: Icons.email,
                      iconColor: Colors.blue,
                      title: 'Email',
                      subtitle: email,
                      hint: 'Tap email to open mail app',
                      onTap: () => _sendEmail(context),
                    ),
                    const SizedBox(height: 32),

                    // Socials Section
                    const Text(
                      'Socials',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // _buildSocialButton(
                        //   context,
                        //   icon: 'assets/whatsapp.png', // Or use Icons.chat
                        //   color: Colors.green,
                        //   onTap: () => _openWhatsApp(context),
                        // ),
                        // const SizedBox(width: 16),
                        // _buildSocialButton(
                        //   context,
                        //   icon: 'assets/instagram.png', // Or use custom icon
                        //   color: Colors.pink,
                        //   onTap: () => _openInstagram(context),
                        // ),
                        // const SizedBox(width: 16),
                        _buildSocialButton(
                          context,
                          icon: 'assets/facebook.png', // Or use Icons.facebook
                          color: Colors.blue.shade800,
                          onTap: () => _openFacebook(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Privacy Policy Link
              TextButton(
                onPressed: () => _launchUrl(context, privacyPolicyUrl),
                child: const Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),

              // Terms and Conditions Link
              TextButton(
                onPressed: () => _launchUrl(context, termsUrl),
                child: const Text(
                  'Terms and Conditions',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Copyright
              Text(
                '© 2021 - ${DateTime.now().year} Legit cards. All Right Reserved.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? hint,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 4),
            Text(
              hint,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required String icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            _getSocialIcon(icon),
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }

  IconData _getSocialIcon(String icon) {
    if (icon.contains('whatsapp')) return Icons.chat;
    if (icon.contains('instagram')) return Icons.camera_alt;
    if (icon.contains('facebook')) return Icons.facebook;
    return Icons.public;
  }

  // Action Methods
  Future<void> _makePhoneCall(BuildContext context) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '2348060517997');
    if (!await launchUrl(phoneUri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not make phone call')),
        );
      }
    }
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final Uri whatsappUri = Uri.parse(whatsappUrl);
    if (!await launchUrl(whatsappUri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }

  Future<void> _sendEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Support Request',
    );
    if (!await launchUrl(emailUri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email app')),
        );
      }
    }
  }

  Future<void> _openInstagram(BuildContext context) async {
    final Uri instagramUri = Uri.parse(instagramUrl);
    if (!await launchUrl(instagramUri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Instagram')),
        );
      }
    }
  }

  Future<void> _openFacebook(BuildContext context) async {
    final Uri facebookUri = Uri.parse(facebookUrl);
    if (!await launchUrl(facebookUri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Facebook')),
        );
      }
    }
  }

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }
}
