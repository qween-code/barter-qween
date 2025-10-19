import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * NOTIFICATION PREFERENCES HELPER
 * Manages user notification settings and preferences
 * Allows granular control over which notifications to receive
 */
export interface NotificationPreferences {
  // Global setting
  globalNotificationsEnabled: boolean;

  // Category-specific settings
  messages: {
    enabled: boolean;
    batchNotifications: boolean;
  };

  tradeOffers: {
    enabled: boolean;
    batchNotifications: boolean;
  };

  tradeUpdates: {
    enabled: boolean;
    batchNotifications: boolean;
  };

  items: {
    enabled: boolean; // New items from followed sellers
    batchNotifications: boolean;
  };

  social: {
    enabled: boolean; // Follows, ratings, etc
    batchNotifications: boolean;
  };

  campaigns: {
    enabled: boolean; // Campaigns and promotions
    batchNotifications: boolean;
  };

  warnings: {
    enabled: boolean; // Account warnings
    batchNotifications: boolean;
  };

  system: {
    enabled: boolean; // System notifications
    batchNotifications: boolean;
  };

  // Quiet hours
  quietHours: {
    enabled: boolean;
    startHour: number; // 0-23
    endHour: number; // 0-23
  };

  // Frequency
  maxNotificationsPerHour: number; // 0 = unlimited
  dontDisturbMode: boolean;
}

export class PreferencesHelper {
  /**
   * Default notification preferences
   */
  static getDefaultPreferences(): NotificationPreferences {
    return {
      globalNotificationsEnabled: true,
      messages: { enabled: true, batchNotifications: false },
      tradeOffers: { enabled: true, batchNotifications: true },
      tradeUpdates: { enabled: true, batchNotifications: true },
      items: { enabled: true, batchNotifications: true },
      social: { enabled: true, batchNotifications: true },
      campaigns: { enabled: true, batchNotifications: true },
      warnings: { enabled: true, batchNotifications: false },
      system: { enabled: true, batchNotifications: false },
      quietHours: { enabled: false, startHour: 22, endHour: 8 },
      maxNotificationsPerHour: 0,
      dontDisturbMode: false,
    };
  }

  /**
   * Get user preferences with defaults for missing fields
   */
  static async getUserPreferences(userId: string): Promise<NotificationPreferences> {
    try {
      const userDoc = await db.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        functions.logger.warn(`User not found: ${userId}`);
        return this.getDefaultPreferences();
      }

      const userData = userDoc.data();
      const preferences = userData?.notificationPreferences || {};

      // Merge with defaults
      return {
        ...this.getDefaultPreferences(),
        ...preferences,
      };
    } catch (error) {
      functions.logger.error(`Error getting preferences for user ${userId}:`, error);
      return this.getDefaultPreferences();
    }
  }

  /**
   * Set user preferences
   */
  static async setUserPreferences(
    userId: string,
    preferences: Partial<NotificationPreferences>
  ): Promise<void> {
    try {
      await db
        .collection('users')
        .doc(userId)
        .update({
          notificationPreferences: admin.firestore.FieldValue.arrayUnion([
            preferences,
          ]),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

      functions.logger.info(`Updated preferences for user ${userId}`);
    } catch (error) {
      functions.logger.error(
        `Error setting preferences for user ${userId}:`,
        error
      );
      throw error;
    }
  }

  /**
   * Check if notification category is enabled for user
   */
  static async isCategoryEnabled(
    userId: string,
    category: keyof Omit<NotificationPreferences, 'globalNotificationsEnabled' | 'quietHours' | 'maxNotificationsPerHour' | 'dontDisturbMode'>
  ): Promise<boolean> {
    try {
      const preferences = await this.getUserPreferences(userId);

      // Check global setting
      if (!preferences.globalNotificationsEnabled) {
        return false;
      }

      // Check Do Not Disturb
      if (preferences.dontDisturbMode) {
        return false;
      }

      // Check quiet hours
      if (preferences.quietHours.enabled) {
        const now = new Date();
        const currentHour = now.getHours();
        const startHour = preferences.quietHours.startHour;
        const endHour = preferences.quietHours.endHour;

        // Handle overnight quiet hours (e.g., 22:00 to 08:00)
        if (startHour > endHour) {
          if (currentHour >= startHour || currentHour < endHour) {
            return false;
          }
        } else {
          if (currentHour >= startHour && currentHour < endHour) {
            return false;
          }
        }
      }

      // Check rate limiting
      if (preferences.maxNotificationsPerHour > 0) {
        const sent = await this.getNotificationCountThisHour(userId);
        if (sent >= preferences.maxNotificationsPerHour) {
          functions.logger.info(
            `Rate limit reached for user ${userId}: ${sent}/${preferences.maxNotificationsPerHour}`
          );
          return false;
        }
      }

      // Check category setting
      const categorySettings = preferences[category] as { enabled: boolean };
      return categorySettings?.enabled ?? true;
    } catch (error) {
      functions.logger.error(
        `Error checking category ${category} for user ${userId}:`,
        error
      );
      return true; // Default to enabled on error
    }
  }

  /**
   * Check if user wants batched notifications for a category
   */
  static async shouldBatchNotifications(
    userId: string,
    category: keyof Omit<NotificationPreferences, 'globalNotificationsEnabled' | 'quietHours' | 'maxNotificationsPerHour' | 'dontDisturbMode'>
  ): Promise<boolean> {
    try {
      const preferences = await this.getUserPreferences(userId);
      const categorySettings = preferences[category] as { batchNotifications?: boolean };
      return categorySettings?.batchNotifications ?? false;
    } catch (error) {
      functions.logger.error(
        `Error checking batch setting for user ${userId}, category ${category}:`,
        error
      );
      return false;
    }
  }

  /**
   * Get number of notifications sent this hour
   */
  static async getNotificationCountThisHour(userId: string): Promise<number> {
    try {
      const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000);

      const snapshot = await db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('createdAt', '>=', oneHourAgo)
        .count()
        .get();

      return snapshot.data().count;
    } catch (error) {
      functions.logger.error(
        `Error getting notification count for user ${userId}:`,
        error
      );
      return 0;
    }
  }

  /**
   * Validate preference object
   */
  static validatePreferences(preferences: any): boolean {
    if (!preferences) return false;

    // Check required fields
    const requiredFields = [
      'globalNotificationsEnabled',
      'messages',
      'tradeOffers',
      'quietHours',
    ];

    for (const field of requiredFields) {
      if (!(field in preferences)) {
        return false;
      }
    }

    return true;
  }

  /**
   * Create preference document for new user
   */
  static async initializeUserPreferences(userId: string): Promise<void> {
    try {
      const userRef = db.collection('users').doc(userId);
      const userData = await userRef.get();

      if (userData.exists && userData.get('notificationPreferences')) {
        return; // Already initialized
      }

      await userRef.update({
        notificationPreferences: this.getDefaultPreferences(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      functions.logger.info(`Initialized preferences for new user ${userId}`);
    } catch (error) {
      functions.logger.error(
        `Error initializing preferences for user ${userId}:`,
        error
      );
    }
  }
}
