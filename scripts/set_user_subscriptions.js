/**
 * Set User Subscriptions - Firebase Admin Script
 * 
 * Bu script test kullanıcılarına abonelik planları atar:
 * - turhanhamza -> Premium plan
 * - weemustang -> Basic plan
 * 
 * Kullanım:
 * node scripts/set_user_subscriptions.js
 */

const admin = require('firebase-admin');

// Firebase Admin başlat (Application Default Credentials kullanarak)
try {
  admin.initializeApp({
    projectId: 'barter-qween' // Firebase project ID'nizi buraya yazın
  });
  console.log('✅ Firebase Admin başlatıldı');
} catch (error) {
  // Zaten başlatılmışsa hata verme
  if (error.code !== 'app/duplicate-app') {
    throw error;
  }
}

const db = admin.firestore();

// Kullanıcı email'leri
const TEST_USERS = {
  PREMIUM: 'turhanhamza',  // Premium user
  BASIC: 'weemustang'       // Basic user
};

// Abonelik planları
const SUBSCRIPTION_PLANS = {
  PREMIUM: {
    plan: 'premium',
    status: 'active',
    displayName: '💎 Premium',
    monthlyPrice: 99.99,
    yearlyPrice: 999.99,
    features: {
      maxActiveListings: 50,
      freeListingsPerMonth: 999,
      premiumListingAvailable: true,
      premiumListingsPerMonth: 10,
      adFree: true,
      tradeCommissionRate: 0.0,
      prioritySupport: true,
      advancedSearch: true,
      analyticsAccess: true
    }
  },
  BASIC: {
    plan: 'basic',
    status: 'active',
    displayName: '⭐ Temel',
    monthlyPrice: 49.99,
    yearlyPrice: 499.99,
    features: {
      maxActiveListings: 10,
      freeListingsPerMonth: 5,
      premiumListingAvailable: true,
      premiumListingsPerMonth: 2,
      adFree: true,
      tradeCommissionRate: 3.0,
      prioritySupport: false,
      advancedSearch: true,
      analyticsAccess: true
    }
  }
};

/**
 * Kullanıcıyı email ile bul
 */
async function findUserByEmail(email) {
  try {
    console.log(`🔍 Kullanıcı aranıyor: ${email}`);
    
    const usersSnapshot = await db.collection('users')
      .where('email', '==', email)
      .limit(1)
      .get();

    if (usersSnapshot.empty) {
      console.log(`❌ Kullanıcı bulunamadı: ${email}`);
      return null;
    }

    const userDoc = usersSnapshot.docs[0];
    return {
      id: userDoc.id,
      data: userDoc.data()
    };
  } catch (error) {
    console.error(`❌ Kullanıcı arama hatası (${email}):`, error.message);
    return null;
  }
}

/**
 * Kullanıcıya abonelik ata
 */
async function setUserSubscription(userId, subscriptionPlan, email) {
  try {
    console.log(`\n📝 Abonelik oluşturuluyor...`);
    console.log(`   Kullanıcı: ${email}`);
    console.log(`   Plan: ${subscriptionPlan.displayName}`);

    const now = new Date();
    const startDate = now;
    const expiryDate = new Date(now);
    expiryDate.setFullYear(expiryDate.getFullYear() + 1); // 1 yıl geçerli

    const subscriptionData = {
      userId: userId,
      plan: subscriptionPlan.plan,
      status: subscriptionPlan.status,
      startDate: admin.firestore.Timestamp.fromDate(startDate),
      expiryDate: admin.firestore.Timestamp.fromDate(expiryDate),
      autoRenew: true,
      storeProductId: `barter_qween_${subscriptionPlan.plan}_yearly`,
      storeTransactionId: `TEST_TXN_${Date.now()}_${userId.substring(0, 8)}`,
      paymentId: `TEST_PAYMENT_${Date.now()}`,
      createdAt: admin.firestore.Timestamp.fromDate(now),
      lastRenewedAt: admin.firestore.Timestamp.fromDate(now),
      cancelledAt: null
    };

    // Subscriptions koleksiyonuna ekle
    const subscriptionRef = await db.collection('subscriptions').add(subscriptionData);
    console.log(`✅ Subscription oluşturuldu: ${subscriptionRef.id}`);

    // User dokümanını güncelle
    await db.collection('users').doc(userId).update({
      subscriptionPlan: subscriptionPlan.plan,
      subscriptionStatus: 'active',
      subscriptionId: subscriptionRef.id,
      updatedAt: admin.firestore.Timestamp.fromDate(now)
    });
    console.log(`✅ User dokümanı güncellendi`);

    // User stats güncelle (varsa)
    const statsRef = db.collection('user_stats').doc(userId);
    const statsDoc = await statsRef.get();
    
    if (statsDoc.exists) {
      await statsRef.update({
        subscriptionPlan: subscriptionPlan.plan,
        maxActiveListings: subscriptionPlan.features.maxActiveListings,
        freeListingsThisMonth: subscriptionPlan.features.freeListingsPerMonth,
        updatedAt: admin.firestore.Timestamp.fromDate(now)
      });
      console.log(`✅ User stats güncellendi`);
    }

    console.log(`\n🎉 ${email} için ${subscriptionPlan.displayName} plan başarıyla atandı!`);
    console.log(`   📅 Başlangıç: ${startDate.toLocaleDateString('tr-TR')}`);
    console.log(`   📅 Bitiş: ${expiryDate.toLocaleDateString('tr-TR')}`);
    console.log(`   🎁 Özellikler:`);
    console.log(`      - Max İlan: ${subscriptionPlan.features.maxActiveListings}`);
    console.log(`      - Ücretsiz İlan/Ay: ${subscriptionPlan.features.freeListingsPerMonth}`);
    console.log(`      - Premium İlan/Ay: ${subscriptionPlan.features.premiumListingsPerMonth}`);
    console.log(`      - Reklamsız: ${subscriptionPlan.features.adFree ? 'Evet' : 'Hayır'}`);
    console.log(`      - Komisyon: %${subscriptionPlan.features.tradeCommissionRate}`);

    return subscriptionRef.id;
  } catch (error) {
    console.error(`❌ Abonelik oluşturma hatası:`, error.message);
    throw error;
  }
}

/**
 * Ana fonksiyon
 */
async function main() {
  console.log('🚀 Kullanıcı Abonelik Ayarlama Başlatıldı\n');
  console.log('=' .repeat(60));

  try {
    // 1. Premium kullanıcı (turhanhamza)
    console.log('\n1️⃣  PREMIUM KULLANICI');
    console.log('-'.repeat(60));
    
    const premiumUser = await findUserByEmail(TEST_USERS.PREMIUM);
    if (premiumUser) {
      await setUserSubscription(
        premiumUser.id,
        SUBSCRIPTION_PLANS.PREMIUM,
        TEST_USERS.PREMIUM
      );
    }

    // 2. Basic kullanıcı (weemustang)
    console.log('\n2️⃣  BASIC KULLANICI');
    console.log('-'.repeat(60));
    
    const basicUser = await findUserByEmail(TEST_USERS.BASIC);
    if (basicUser) {
      await setUserSubscription(
        basicUser.id,
        SUBSCRIPTION_PLANS.BASIC,
        TEST_USERS.BASIC
      );
    }

    console.log('\n' + '='.repeat(60));
    console.log('✅ TÜM ABONELIKLER BAŞARIYLA AYARLANDI!');
    console.log('='.repeat(60));

    console.log('\n📊 ÖZET:');
    console.log(`   💎 Premium: ${TEST_USERS.PREMIUM}`);
    console.log(`   ⭐ Basic: ${TEST_USERS.BASIC}`);

    console.log('\n📝 NOT:');
    console.log('   - Test abonelikleri 1 yıl geçerli');
    console.log('   - Store product ID\'leri test değerleri ile atandı');
    console.log('   - Gerçek production\'da store purchase gerekli');

  } catch (error) {
    console.error('\n❌ HATA:', error.message);
    process.exit(1);
  }

  process.exit(0);
}

// Script'i çalıştır
main();
