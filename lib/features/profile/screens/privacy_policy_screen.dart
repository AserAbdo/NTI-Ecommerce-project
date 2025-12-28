import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentYear = DateTime.now().year;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0E21)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.privacy_tip_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Last updated: December $currentYear',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Introduction
            _buildSection(
              'Introduction',
              Icons.article_rounded,
              'Welcome to Vendora. We respect your privacy and are committed to protecting your personal data. This privacy policy will inform you about how we look after your personal data when you visit our app and tell you about your privacy rights.',
              isDark,
            ),

            _buildSection(
              'Information We Collect',
              Icons.data_usage_rounded,
              '''We may collect and process the following data about you:

• Personal identification information (name, email address, phone number)
• Billing and shipping addresses
• Payment information (processed securely through our payment providers)
• Order history and preferences
• Device information and app usage data
• Location data (with your permission)''',
              isDark,
            ),

            _buildSection(
              'How We Use Your Information',
              Icons.settings_rounded,
              '''Your information is used to:

• Process and fulfill your orders
• Provide customer support
• Send order updates and notifications
• Personalize your shopping experience
• Improve our app and services
• Prevent fraud and ensure security
• Comply with legal obligations''',
              isDark,
            ),

            _buildSection(
              'Data Security',
              Icons.security_rounded,
              'We implement appropriate technical and organizational security measures to protect your personal data against accidental or unlawful destruction, loss, alteration, unauthorized disclosure, or access. All payment transactions are encrypted using SSL technology.',
              isDark,
            ),

            _buildSection(
              'Data Sharing',
              Icons.share_rounded,
              '''We may share your data with:

• Payment processors for transaction processing
• Shipping partners for order delivery
• Analytics providers to improve our services
• Legal authorities when required by law

We never sell your personal data to third parties.''',
              isDark,
            ),

            _buildSection(
              'Your Rights',
              Icons.gavel_rounded,
              '''You have the right to:

• Access your personal data
• Correct inaccurate data
• Request deletion of your data
• Object to processing of your data
• Request data portability
• Withdraw consent at any time''',
              isDark,
            ),

            _buildSection(
              'Cookies and Tracking',
              Icons.cookie_rounded,
              'We use cookies and similar tracking technologies to enhance your experience, analyze app usage, and deliver personalized content. You can control cookie preferences through your device settings.',
              isDark,
            ),

            _buildSection(
              'Children\'s Privacy',
              Icons.child_care_rounded,
              'Our services are not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13. If you believe we have collected data from a child, please contact us immediately.',
              isDark,
            ),

            _buildSection(
              'Changes to This Policy',
              Icons.update_rounded,
              'We may update this privacy policy from time to time. We will notify you of any significant changes by posting the new policy on this page and updating the "Last updated" date.',
              isDark,
            ),

            _buildSection(
              'Contact Us',
              Icons.contact_mail_rounded,
              '''If you have any questions about this privacy policy or our data practices, please contact us:

📧 Email: privacy@vendora.com
📞 Phone: +20 123 456 7890
📍 Address: Cairo, Egypt''',
              isDark,
            ),

            const SizedBox(height: 30),

            // Accept Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.success,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'By using our app, you agree to this privacy policy.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'I Understand',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    IconData icon,
    String content,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
