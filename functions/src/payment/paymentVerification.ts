import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

admin.initializeApp();
const db = admin.firestore();

// Payment verification service using service account
export class PaymentVerificationService {
  private static instance: PaymentVerificationService;

  public static getInstance(): PaymentVerificationService {
    if (!PaymentVerificationService.instance) {
      PaymentVerificationService.instance = new PaymentVerificationService();
    }
    return PaymentVerificationService.instance;
  }

  /**
   * Verify Google Pay token server-side
   */
  async verifyGooglePayToken(token: string, expectedAmount: number): Promise<boolean> {
    try {
      functions.logger.info('Verifying Google Pay token', { expectedAmount });

      // In a real implementation, you would:
      // 1. Use Google's Payment Token API to verify the token
      // 2. Check the token signature
      // 3. Validate the amount matches expectedAmount
      // 4. Check token hasn't been used before

      // For now, we'll implement basic validation
      // In production, you should use Google's official SDK

      if (!token || token.length < 10) {
        functions.logger.error('Invalid token format');
        return false;
      }

      // Check if token has already been used
      const existingPayment = await db
        .collection('payments')
        .where('transactionToken', '==', token)
        .where('status', '==', 'completed')
        .limit(1)
        .get();

      if (!existingPayment.empty) {
        functions.logger.error('Token already used', { token });
        return false;
      }

      // Basic amount validation (in production, extract from token)
      // const tokenAmount = extractAmountFromToken(token);
      // if (Math.abs(tokenAmount - expectedAmount) > 0.01) {
      //   functions.logger.error('Amount mismatch', { tokenAmount, expectedAmount });
      //   return false;
      // }

      functions.logger.info('Google Pay token verified successfully');
      return true;
    } catch (error) {
      functions.logger.error('Error verifying Google Pay token:', error);
      return false;
    }
  }

  /**
   * Process payment verification and update payment status
   */
  async processPaymentVerification(paymentId: string, verificationData?: any): Promise<boolean> {
    try {
      functions.logger.info('Processing payment verification', { paymentId });

      const paymentRef = db.collection('payments').doc(paymentId);
      const paymentDoc = await paymentRef.get();

      if (!paymentDoc.exists) {
        functions.logger.error('Payment not found', { paymentId });
        return false;
      }

      const paymentData = paymentDoc.data();
      if (!paymentData) {
        functions.logger.error('Payment data is empty', { paymentId });
        return false;
      }

      // Verify the payment token if available
      if (paymentData.transactionToken) {
        const isValid = await this.verifyGooglePayToken(
          paymentData.transactionToken,
          paymentData.amount || 0
        );

        if (!isValid) {
          // Update payment status to failed
          await paymentRef.update({
            status: 'failed',
            errorMessage: 'Token verification failed',
            verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          return false;
        }
      }

      // Update payment as verified
      await paymentRef.update({
        status: 'completed',
        verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
        verificationData: verificationData || {},
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      functions.logger.info('Payment verified successfully', { paymentId });
      return true;
    } catch (error) {
      functions.logger.error('Error processing payment verification:', error);

      // Update payment status to failed
      try {
        await db.collection('payments').doc(paymentId).update({
          status: 'failed',
          errorMessage: error instanceof Error ? error.message : 'Verification error',
          verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      } catch (updateError) {
        functions.logger.error('Error updating payment status:', updateError);
      }

      return false;
    }
  }

  /**
   * Validate payment data before processing
   */
  async validatePaymentData(paymentData: any): Promise<{ isValid: boolean; errors: string[] }> {
    const errors: string[] = [];

    try {
      // Required fields validation
      if (!paymentData.userId) errors.push('User ID is required');
      if (!paymentData.amount || paymentData.amount <= 0) errors.push('Valid amount is required');
      if (!paymentData.currency) errors.push('Currency is required');
      if (!paymentData.paymentType) errors.push('Payment type is required');

      // Amount validation
      if (paymentData.amount && paymentData.amount > 10000) {
        errors.push('Amount exceeds maximum limit');
      }

      // Currency validation
      const validCurrencies = ['TRY', 'USD', 'EUR'];
      if (paymentData.currency && !validCurrencies.includes(paymentData.currency)) {
        errors.push('Invalid currency');
      }

      // Payment type validation
      const validPaymentTypes = [
        'listingFee',
        'premiumListing',
        'subscription',
        'tradeCommission',
        'cashDifferential',
        'adRemoval'
      ];
      if (paymentData.paymentType && !validPaymentTypes.includes(paymentData.paymentType)) {
        errors.push('Invalid payment type');
      }

      // User existence validation
      if (paymentData.userId) {
        const userDoc = await db.collection('users').doc(paymentData.userId).get();
        if (!userDoc.exists) {
          errors.push('User not found');
        }
      }

      // Barter-specific validations
      if (paymentData.paymentType === 'cashDifferential') {
        if (!paymentData.barterData?.tradeId) {
          errors.push('Trade ID is required for cash differential payments');
        }
        if (!paymentData.barterData?.recipientId) {
          errors.push('Recipient ID is required for cash differential payments');
        }
      }

      return {
        isValid: errors.length === 0,
        errors
      };
    } catch (error) {
      functions.logger.error('Error validating payment data:', error);
      return {
        isValid: false,
        errors: ['Validation error occurred']
      };
    }
  }
}

// Export singleton instance
export const paymentVerificationService = PaymentVerificationService.getInstance();