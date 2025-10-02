import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: AppTextStyles.displaySmall,
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              'Last Updated: ${DateTime.now().year}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing24),
            _buildSection(
              title: '1. Information We Collect',
              content:
                  'We collect information you provide directly to us, including your name, email address, profile information, and items you list for trade. We also collect information about your use of the service, including your trades and communications with other users.',
            ),
            _buildSection(
              title: '2. How We Use Your Information',
              content:
                  'We use the information we collect to provide, maintain, and improve our services, to communicate with you, to monitor and analyze trends, and to personalize your experience.',
            ),
            _buildSection(
              title: '3. Information Sharing',
              content:
                  'We do not sell your personal information. We may share your information with other users as necessary to facilitate trades, with service providers who assist us in operating the platform, and when required by law.',
            ),
            _buildSection(
              title: '4. Data Storage and Security',
              content:
                  'We use Firebase services to store and process your data. While we implement security measures to protect your information, no method of transmission over the internet is 100% secure.',
            ),
            _buildSection(
              title: '5. Photos and Images',
              content:
                  'Photos you upload are stored securely and are only visible to other users of the platform. You retain all rights to your photos but grant us a license to display them on the platform.',
            ),
            _buildSection(
              title: '6. Location Data',
              content:
                  'If you choose to share your location, we use it to help you find nearby trades. You can disable location sharing at any time in your device settings.',
            ),
            _buildSection(
              title: '7. Communications',
              content:
                  'We may send you service-related emails and notifications. You can opt out of promotional communications but will still receive important service updates.',
            ),
            _buildSection(
              title: '8. Your Rights',
              content:
                  'You have the right to access, correct, or delete your personal information. You can exercise these rights through your account settings or by contacting us.',
            ),
            _buildSection(
              title: '9. Children\'s Privacy',
              content:
                  'Our service is not intended for users under 13 years of age. We do not knowingly collect personal information from children under 13.',
            ),
            _buildSection(
              title: '10. Changes to Privacy Policy',
              content:
                  'We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page.',
            ),
            _buildSection(
              title: '11. Contact Us',
              content:
                  'If you have questions about this privacy policy, please contact us at privacy@barterqween.com',
            ),
            const SizedBox(height: AppDimensions.spacing32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing8),
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
