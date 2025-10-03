#!/usr/bin/env node

/**
 * Add location coordinates to existing test items
 * Uses approximate coordinates for Turkish cities
 */

const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Turkish city coordinates (approximate center)
const CITY_COORDINATES = {
  'İstanbul': { latitude: 41.0082, longitude: 28.9784 },
  'Ankara': { latitude: 39.9334, longitude: 32.8597 },
  'İzmir': { latitude: 38.4237, longitude: 27.1428 },
  'Bursa': { latitude: 40.1826, longitude: 29.0665 },
  'Antalya': { latitude: 36.8969, longitude: 30.7133 },
  'Adana': { latitude: 37.0000, longitude: 35.3213 },
  'Konya': { latitude: 37.8746, longitude: 32.4932 },
  'Gaziantep': { latitude: 37.0662, longitude: 37.3833 },
  'Mersin': { latitude: 36.8121, longitude: 34.6415 },
  'Diyarbakır': { latitude: 37.9144, longitude: 40.2306 },
};

async function addLocationsToItems() {
  console.log('🗺️  Adding location coordinates to test items...\n');

  try {
    // Get all test items
    const snapshot = await db.collection('items')
      .where('isTestData', '==', true)
      .get();

    if (snapshot.empty) {
      console.log('❌ No test items found!');
      return;
    }

    console.log(`📦 Found ${snapshot.size} test items\n`);

    const batch = db.batch();
    let updateCount = 0;

    snapshot.docs.forEach(doc => {
      const item = doc.data();
      const city = item.city;

      if (city && CITY_COORDINATES[city]) {
        const coords = CITY_COORDINATES[city];
        
        // Add small random offset (±0.1 degree ~ 10km)
        const latitude = coords.latitude + (Math.random() - 0.5) * 0.2;
        const longitude = coords.longitude + (Math.random() - 0.5) * 0.2;

        batch.update(doc.ref, {
          latitude,
          longitude,
          fullAddress: `${city}, Türkiye`
        });

        console.log(`✅ ${item.title.substring(0, 40)}... → ${city} (${latitude.toFixed(4)}, ${longitude.toFixed(4)})`);
        updateCount++;
      } else {
        console.log(`⚠️  ${item.title.substring(0, 40)}... → No coordinates for "${city}"`);
      }
    });

    if (updateCount > 0) {
      await batch.commit();
      console.log(`\n✅ Updated ${updateCount} items with location coordinates!`);
    } else {
      console.log('\n❌ No items were updated');
    }

  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    process.exit(0);
  }
}

addLocationsToItems();
