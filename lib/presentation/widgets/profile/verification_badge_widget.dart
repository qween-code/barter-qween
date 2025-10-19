import 'package:flutter/material.dart';

/// Verification Badge Widget
/// Shows TruYou verification status (OfferUp style)
class VerificationBadgeWidget extends StatelessWidget {
  final bool isPhoneVerified;
  final bool isEmailVerified;
  final bool isIdVerified;
  final bool isSelfieVerified;
  final bool showDetails;
  final VoidCallback? onTap;

  const VerificationBadgeWidget({
    Key? key,
    this.isPhoneVerified = false,
    this.isEmailVerified = false,
    this.isIdVerified = false,
    this.isSelfieVerified = false,
    this.showDetails = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final verificationLevel = _getVerificationLevel();

    if (verificationLevel == 'None') {
      return const SizedBox.shrink();
    }

    if (showDetails) {
      return _buildDetailedView();
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _getColor().withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getIcon(), size: 16, color: _getColor()),
            const SizedBox(width: 6),
            Text(
              verificationLevel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getColor(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedView() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            children: [
              Icon(Icons.verified_user, color: _getColor()),
              const SizedBox(width: 12),
              const Text(
                'Verification Status',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildVerificationItem(
            'Phone Number',
            isPhoneVerified,
            'Verified phone number',
          ),
          _buildVerificationItem(
            'Email Address',
            isEmailVerified,
            'Verified email address',
          ),
          _buildVerificationItem(
            'Government ID',
            isIdVerified,
            'TruYou ID verification',
          ),
          _buildVerificationItem(
            'Selfie Photo',
            isSelfieVerified,
            'TruYou selfie verification',
          ),

          if (!isIdVerified || !isSelfieVerified) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Complete Verification'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVerificationItem(
    String label,
    bool isVerified,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            isVerified ? Icons.check_circle : Icons.circle_outlined,
            size: 20,
            color: isVerified ? Colors.green : Colors.grey.shade400,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getVerificationLevel() {
    if (isIdVerified && isSelfieVerified) {
      return 'TruYou Verified';
    } else if (isIdVerified) {
      return 'ID Verified';
    } else if (isEmailVerified && isPhoneVerified) {
      return 'Basic Verified';
    } else if (isEmailVerified || isPhoneVerified) {
      return 'Partially Verified';
    }
    return 'None';
  }

  IconData _getIcon() {
    if (isIdVerified && isSelfieVerified) {
      return Icons.verified_user;
    } else if (isIdVerified) {
      return Icons.badge;
    }
    return Icons.verified;
  }

  Color _getColor() {
    if (isIdVerified && isSelfieVerified) {
      return Colors.green;
    } else if (isIdVerified) {
      return Colors.blue;
    } else if (isEmailVerified && isPhoneVerified) {
      return Colors.orange;
    }
    return Colors.grey;
  }
}
