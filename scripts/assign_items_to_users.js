const admin = require('firebase-admin');

// Initialize Firebase Admin
const serviceAccount = require('../serviceAccountKey.json');

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();

// User IDs from seed_world_class_users.js
const USER_IDS = [
  'user_ayse_yilmaz',
  'user_mehmet_demir',
  'user_zeynep_kaya',
  'user_can_ozdemir',
  'user_elif_sahin',
  'user_burak_yildiz',
  'user_merve_aydin',
  'user_ahmet_kilic',
  'user_gizem_ozkan',
  'user_cem_gunes',
  'user_kerem_ozturk',
];

// Category to user mapping (realistic assignments)
const CATEGORY_USER_MAP = {
  'Shoes': ['user_ayse_yilmaz', 'user_can_ozdemir', 'user_merve_aydin'],
  "Women's Fashion": ['user_ayse_yilmaz', 'user_zeynep_kaya', 'user_merve_aydin', 'user_gizem_ozkan'],
  'Electronics': ['user_mehmet_demir', 'user_kerem_ozturk', 'user_ahmet_kilic'],
  'Home & Living': ['user_zeynep_kaya', 'user_ahmet_kilic'],
  'Kids & Baby': ['user_elif_sahin'],
  'Sports & Outdoors': ['user_burak_yildiz'],
  'Books, Movies & Music': ['user_cem_gunes', 'user_elif_sahin'],
};

async function assignItemsToUsers() {
  console.log('🔄 Starting to assign items to different users...\n');

  try {
    // Get all items
    const itemsSnapshot = await db.collection('items').get();
    console.log(`📊 Found ${itemsSnapshot.size} items to reassign\n`);

    let updatedCount = 0;
    const batch = db.batch();

    for (const itemDoc of itemsSnapshot.docs) {
      const item = itemDoc.data();
      const category = item.category || 'Other';
      
      // Find suitable users for this category
      let possibleUsers = CATEGORY_USER_MAP[category] || USER_IDS;
      
      // Randomly select a user from possible users
      const selectedUserId = possibleUsers[Math.floor(Math.random() * possibleUsers.length)];
      
      // Get user data
      const userDoc = await db.collection('users').doc(selectedUserId).get();
      const userData = userDoc.data();
      
      if (!userData) {
        console.log(`⚠️  User ${selectedUserId} not found, skipping item ${item.title}`);
        continue;
      }

      // Update item with new owner
      batch.update(itemDoc.ref, {
        ownerId: selectedUserId,
        ownerName: userData.displayName,
        ownerPhotoUrl: userData.photoUrl,
        sellerId: selectedUserId,
        sellerName: userData.displayName,
        sellerAvatar: userData.photoUrl,
        
        // Update seller stats from user
        sellerResponseTime: userData.averageResponseTime || 'Within 1 day',
        sellerRating: userData.averageRating || 0,
        sellerTotalSales: userData.totalSales || 0,
        
        // Update seller badges
        fastShipping: userData.fastShipper || false,
        topRatedSeller: userData.isTopSeller || false,
        
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      updatedCount++;
      console.log(`✅ [${updatedCount}/${itemsSnapshot.size}] ${item.title} → ${userData.displayName}`);
    }

    // Commit batch
    console.log('\n📤 Committing changes to Firestore...');
    await batch.commit();

    console.log('\n' + '='.repeat(60));
    console.log('✨ ASSIGNMENT COMPLETE!');
    console.log('='.repeat(60));
    console.log(`✅ Updated ${updatedCount} items`);
    console.log('='.repeat(60));

    // Show distribution
    console.log('\n📊 DISTRIBUTION BY USER:');
    const userCounts = {};
    
    for (const itemDoc of itemsSnapshot.docs) {
      const item = itemDoc.data();
      const category = item.category || 'Other';
      const possibleUsers = CATEGORY_USER_MAP[category] || USER_IDS;
      const selectedUserId = possibleUsers[Math.floor(Math.random() * possibleUsers.length)];
      userCounts[selectedUserId] = (userCounts[selectedUserId] || 0) + 1;
    }

    // Get actual distribution
    const finalSnapshot = await db.collection('items').get();
    const finalDistribution = {};
    
    for (const doc of finalSnapshot.docs) {
      const ownerId = doc.data().ownerId;
      finalDistribution[ownerId] = (finalDistribution[ownerId] || 0) + 1;
    }

    for (const [userId, count] of Object.entries(finalDistribution)) {
      const userDoc = await db.collection('users').doc(userId).get();
      const userName = userDoc.exists ? userDoc.data().displayName : userId;
      console.log(`  ${userName}: ${count} items`);
    }

    console.log('='.repeat(60) + '\n');

  } catch (error) {
    console.error('❌ Error assigning items:', error);
    throw error;
  }
}

// Run assignment
assignItemsToUsers()
  .then(() => {
    console.log('✅ Assignment script completed successfully!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Assignment script failed:', error);
    process.exit(1);
  });
