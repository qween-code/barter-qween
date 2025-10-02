import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
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
              title: '1. Acceptance of Terms',
              content:
                  'By accessing and using Barter Qween, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.',
            ),
            _buildSection(
              title: '2. Description of Service',
              content:
                  'Barter Qween is a platform that facilitates the exchange of goods between users. We provide the technology and infrastructure to enable users to list items, browse listings, and arrange trades.',
            ),
            _buildSection(
              title: '3. User Responsibilities',
              content:
                  'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account. You must notify us immediately of any unauthorized use of your account.',
            ),
            _buildSection(
              title: '4. Trading Rules',
              content:
                  'All trades must be conducted in good faith. Users must accurately describe items, provide honest photos, and follow through on accepted trades. Fraudulent behavior or misrepresentation will result in account suspension.',
            ),
            _buildSection(
              title: '5. Prohibited Items',
              content:
                  'Users may not list illegal items, stolen goods, weapons, drugs, or any items that violate local, state, or federal laws. Violation of this policy will result in immediate account termination.',
            ),
            _buildSection(
              title: '6. Liability',
              content:
                  'Barter Qween acts as a facilitator only. We are not responsible for the quality, safety, or legality of items listed. Users trade at their own risk. We recommend meeting in public places and taking appropriate safety precautions.',
            ),
            _buildSection(
              title: '7. Privacy',
              content:
                  'Your use of Barter Qween is also governed by our Privacy Policy. Please review our Privacy Policy to understand our practices.',
            ),
            _buildSection(
              title: '8. Modifications to Service',
              content:
                  'We reserve the right to modify or discontinue the service at any time without notice. We shall not be liable to you or any third party for any modification or discontinuance of the service.',
            ),
            _buildSection(
              title: '9. Termination',
              content:
                  'We may terminate or suspend your account immediately, without prior notice or liability, for any reason, including breach of these Terms.',
            ),
            _buildSection(
              title: '10. Contact Information',
              content:
                  'If you have any questions about these Terms, please contact us at support@barterqween.com',
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
