import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { paymentVerificationService } from './paymentVerification';

admin.initializeApp();
const db = admin.firestore();

// Payment status update trigger
export const onPaymentStatusUpdated = functions.firestore
  .document('payments/{paymentId}')
  .onUpdate(async (change, context) => {
    try {
      const before = change.before.data();
      const after = change.after.data();

      if (!before || !after) return null;

      const beforeStatus = before.status as string | undefined;
      const afterStatus = after.status as string | undefined;

      // Only trigger when status changes
      if (beforeStatus === afterStatus) return null;

      const paymentId = context.params.paymentId;
      const userId = after.userId as string | undefined;
      const paymentType = after.paymentType as string | undefined;
      const amount = after.amount as number | undefined;

      functions.logger.info(`Payment status changed: ${beforeStatus} -> ${afterStatus}`, {
        paymentId,
        userId,
        paymentType,
        amount,
      });

      // Handle different payment statuses
      if (afterStatus === 'completed') {
        await handlePaymentCompleted(after, paymentId);
      } else if (afterStatus === 'failed') {
        await handlePaymentFailed(after, paymentId);
      } else if (afterStatus === 'refunded') {
        await handlePaymentRefunded(after, paymentId);
      }

      return null;
    } catch (error) {
      functions.logger.error('Error in onPaymentStatusUpdated trigger:', error);
      return null;
    }
  });

// Handle successful payment completion
async function handlePaymentCompleted(paymentData: any, paymentId: string) {
  try {
    const userId = paymentData.userId;
    const paymentType = paymentData.paymentType;
    const amount = paymentData.amount;
    const barterData = paymentData.barterData || {};

    // Update user payment statistics
    await updateUserPaymentStats(userId, amount, 'completed');

    // Handle barter-specific payment completion
    if (barterData.isBarterPayment && barterData.tradeId) {
      await handleBarterPaymentCompleted(paymentData, paymentId);
    }

    // Handle subscription payment
    if (paymentType === 'subscription' && paymentData.subscriptionId) {
      await handleSubscriptionPaymentCompleted(paymentData, paymentId);
    }

    functions.logger.info(`Payment completed successfully: ${paymentId}`);
  } catch (error) {
    functions.logger.error('Error handling payment completion:', error);
  }
}

// Handle failed payments
async function handlePaymentFailed(paymentData: any, paymentId: string) {
  try {
    const userId = paymentData.userId;

    // Update user payment statistics
    await updateUserPaymentStats(userId, paymentData.amount || 0, 'failed');

    // Send failure notification to user
    await sendPaymentNotification(
      userId,
      'Ödeme Başarısız',
      'Ödeme işleminiz tamamlanamadı. Lütfen tekrar deneyin.',
      'payment_failed',
      paymentId
    );

    functions.logger.info(`Payment failed: ${paymentId}`);
  } catch (error) {
    functions.logger.error('Error handling payment failure:', error);
  }
}

// Handle refunded payments
async function handlePaymentRefunded(paymentData: any, paymentId: string) {
  try {
    const userId = paymentData.userId;
    const amount = paymentData.amount;

    // Update user payment statistics
    await updateUserPaymentStats(userId, amount, 'refunded');

    // Send refund notification to user
    await sendPaymentNotification(
      userId,
      'Ödeme İade Edildi',
      `₺${amount} tutarındaki ödemeniz iade edildi.`,
      'payment_refunded',
      paymentId
    );

    functions.logger.info(`Payment refunded: ${paymentId}`);
  } catch (error) {
    functions.logger.error('Error handling payment refund:', error);
  }
}

// Handle barter-specific payment completion
async function handleBarterPaymentCompleted(paymentData: any, paymentId: string) {
  try {
    const barterData = paymentData.barterData || {};
    const tradeId = barterData.tradeId;
    const recipientId = barterData.recipientId;

    if (!tradeId || !recipientId) return;

    // Update trade status to indicate payment completed
    await db.collection('tradeOffers').doc(tradeId).update({
      paymentStatus: 'completed',
      paymentId: paymentId,
      paymentCompletedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Send notification to recipient
    await sendPaymentNotification(
      recipientId,
      'Ödeme Alındı',
      'Takas işlemi için para farkı ödemesi alındı.',
      'barter_payment_received',
      tradeId,
      { paymentId, amount: paymentData.amount }
    );

    // Send confirmation to payer
    await sendPaymentNotification(
      paymentData.userId,
      'Ödeme Gönderildi',
      'Para farkı ödemeniz başarıyla gönderildi.',
      'barter_payment_sent',
      tradeId,
      { paymentId, amount: paymentData.amount }
    );

    functions.logger.info(`Barter payment completed: ${paymentId} for trade ${tradeId}`);
  } catch (error) {
    functions.logger.error('Error handling barter payment completion:', error);
  }
}

// Handle subscription payment completion
async function handleSubscriptionPaymentCompleted(paymentData: any, paymentId: string) {
  try {
    const subscriptionId = paymentData.subscriptionId;
    const userId = paymentData.userId;

    // Update subscription status
    await db.collection('subscriptions').doc(subscriptionId).update({
      status: 'active',
      paymentId: paymentId,
      activatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Update user premium status
    await db.collection('users').doc(userId).update({
      isPremium: true,
      premiumSince: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Send confirmation notification
    await sendPaymentNotification(
      userId,
      'Premium Üyelik Aktif',
      'Premium üyeliğiniz başarıyla aktifleştirildi.',
      'subscription_activated',
      subscriptionId,
      { paymentId }
    );

    functions.logger.info(`Subscription activated: ${subscriptionId} via payment ${paymentId}`);
  } catch (error) {
    functions.logger.error('Error handling subscription payment completion:', error);
  }
}

// Update user payment statistics
async function updateUserPaymentStats(userId: string, amount: number, status: string) {
  try {
    const increment = status === 'completed' ? 1 : 0;
    const totalAmount = status === 'completed' ? amount : 0;

    await db.collection('users').doc(userId).update({
      totalPayments: admin.firestore.FieldValue.increment(increment),
      totalPaymentAmount: admin.firestore.FieldValue.increment(totalAmount),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  } catch (error) {
    functions.logger.error('Error updating user payment stats:', error);
  }
}

// Send payment notification
async function sendPaymentNotification(
  userId: string,
  title: string,
  body: string,
  type: string,
  entityId: string,
  additionalData?: any
) {
  try {
    // Check for duplicate notifications
    const isDuplicate = await isDuplicateNotification(userId, type, entityId, 5);
    if (isDuplicate) {
      functions.logger.info(`Duplicate payment notification for user ${userId}`);
      return;
    }

    const payload = {
      title,
      body,
      type,
      entityId,
      data: {
        entityId,
        type,
        ...additionalData,
      },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await db.collection('users').doc(userId).collection('notifications').add(payload);

    functions.logger.info(`Payment notification sent to user ${userId}`);
  } catch (error) {
    functions.logger.error('Error sending payment notification:', error);
  }
}

// Check for duplicate notifications
async function isDuplicateNotification(
  userId: string,
  type: string,
  entityId: string,
  timeWindowMinutes: number
): Promise<boolean> {
  try {
    const cutoff = new Date(Date.now() - timeWindowMinutes * 60 * 1000);

    const snapshot = await db
      .collection('users')
      .doc(userId)
      .collection('notifications')
      .where('type', '==', type)
      .where('entityId', '==', entityId)
      .where('createdAt', '>', cutoff)
      .limit(1)
      .get();

    return !snapshot.empty;
  } catch (error) {
    functions.logger.error('Error checking duplicate notification:', error);
    return false;
  }
}

// HTTP endpoint for manual payment verification
export const verifyPayment = functions.https.onCall(async (data, context) => {
  try {
    // Check if user is authenticated
    if (!context.auth?.uid) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated to verify payments'
      );
    }

    const { paymentId, verificationData } = data;

    if (!paymentId) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Payment ID is required'
      );
    }

    functions.logger.info('Manual payment verification requested', {
      paymentId,
      verifiedBy: context.auth.uid,
    });

    // Verify payment using service account
    const isVerified = await paymentVerificationService.processPaymentVerification(
      paymentId,
      verificationData
    );

    if (!isVerified) {
      throw new functions.https.HttpsError(
        'internal',
        'Payment verification failed'
      );
    }

    return {
      success: true,
      message: 'Payment verified successfully',
      paymentId,
    };
  } catch (error) {
    functions.logger.error('Error in verifyPayment function:', error);

    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    throw new functions.https.HttpsError(
      'internal',
      'Payment verification failed'
    );
  }
});

// HTTP endpoint for payment validation
export const validatePayment = functions.https.onCall(async (data, context) => {
  try {
    const paymentData = data.paymentData;

    if (!paymentData) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Payment data is required'
      );
    }

    const validation = await paymentVerificationService.validatePaymentData(paymentData);

    return {
      isValid: validation.isValid,
      errors: validation.errors,
    };
  } catch (error) {
    functions.logger.error('Error in validatePayment function:', error);

    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    throw new functions.https.HttpsError(
      'internal',
      'Payment validation failed'
    );
  }
});