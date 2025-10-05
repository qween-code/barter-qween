const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin
const serviceAccount = require('../serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Delete all old items from database
async function cleanOldItems() {
  console.log('🗑️  Starting to clean old items from database...\n');
  
  try {
    // Get all items
    const itemsSnapshot = await db.collection('items').get();
    const totalItems = itemsSnapshot.size;
    
    console.log(`📊 Found ${totalItems} items in database`);
    
    if (totalItems === 0) {
      console.log('✅ No items to delete. Database is already clean.\n');
      return;
    }
    
    // Confirm deletion
    console.log(`⚠️  About to delete ${totalItems} items...`);
    
    // Delete in batches (Firestore batch limit is 500)
    const batchSize = 500;
    let deletedCount = 0;
    
    const deleteInBatch = async (snapshot) => {
      const batch = db.batch();
      snapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });
      await batch.commit();
      deletedCount += snapshot.size;
      console.log(`✅ Deleted batch: ${deletedCount}/${totalItems} items`);
    };
    
    // Delete all items
    let query = db.collection('items').limit(batchSize);
    
    while (deletedCount < totalItems) {
      const snapshot = await query.get();
      
      if (snapshot.size === 0) break;
      
      await deleteInBatch(snapshot);
      
      // Get next batch
      const lastDoc = snapshot.docs[snapshot.docs.length - 1];
      query = db.collection('items').startAfter(lastDoc).limit(batchSize);
    }
    
    console.log('\n' + '='.repeat(60));
    console.log('✨ CLEANUP COMPLETE!');
    console.log('='.repeat(60));
    console.log(`🗑️  Total items deleted: ${deletedCount}`);
    console.log(`📊 Items remaining: 0`);
    console.log('='.repeat(60) + '\n');
    
  } catch (error) {
    console.error('❌ Error cleaning database:', error);
    throw error;
  }
}

// Run cleanup
cleanOldItems()
  .then(() => {
    console.log('✅ Cleanup script completed successfully!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Cleanup script failed:', error);
    process.exit(1);
  });
