const admin = require('firebase-admin');
const serviceAccount = require('../barter_qween/google-services.json');

// Firebase Admin SDK'yı başlat
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: serviceAccount.project_id
});

const db = admin.firestore();
const auth = admin.auth();

async function setupAdminUser() {
  try {
    const email = 'turhanhamza@gmail.com';

    console.log(`🔧 Admin kullanıcısı ayarlanıyor: ${email}`);

    // Önce kullanıcıyı bul veya oluştur
    let user;
    try {
      user = await auth.getUserByEmail(email);
      console.log(`✅ Kullanıcı bulundu: ${user.uid}`);
    } catch (error) {
      if (error.code === 'auth/user-not-found') {
        console.log(`👤 Kullanıcı bulunamadı, yeni kullanıcı oluşturuluyor...`);
        user = await auth.createUser({
          email: email,
          displayName: 'Super Admin',
          emailVerified: true,
        });
        console.log(`✅ Yeni kullanıcı oluşturuldu: ${user.uid}`);
      } else {
        throw error;
      }
    }

    // Super admin custom claims'leri ayarla
    const customClaims = {
      role: 'superAdmin',
      permissions: [
        'approveItems',
        'rejectItems',
        'banUsers',
        'viewAnalytics',
        'manageUsers',
        'editItemTiers',
        'viewReports',
        'manageAdmins',
        'accessAllData'
      ],
      isAdmin: true,
      isSuperAdmin: true,
      createdAt: new Date().toISOString(),
    };

    // Custom claims'leri kullanıcıya ata
    await auth.setCustomUserClaims(user.uid, customClaims);
    console.log(`✅ Custom claims başarıyla ayarlandı`);

    // Admin kullanıcısını Firestore'da kaydet
    await db.collection('admins').doc(user.uid).set({
      email: email,
      name: 'Super Admin',
      role: 'superAdmin',
      permissions: customClaims.permissions,
      isActive: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      lastLogin: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`✅ Admin kullanıcısı Firestore'a kaydedildi`);

    // Admin istatistiklerini başlat
    await db.collection('adminStats').doc('global').set({
      totalApprovedItems: 0,
      totalRejectedItems: 0,
      totalActiveUsers: 0,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    console.log(`✅ Admin istatistikleri başlatıldı`);

    console.log(`🎉 Admin kullanıcısı başarıyla kuruldu!`);
    console.log(`📧 Email: ${email}`);
    console.log(`🔑 Tüm admin yetkileri aktif`);

    process.exit(0);
  } catch (error) {
    console.error(`❌ Hata oluştu:`, error);
    process.exit(1);
  }
}

// Script'i çalıştır
setupAdminUser();