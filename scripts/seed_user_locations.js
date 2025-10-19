const admin = require('firebase-admin');

const serviceAccount = require('../serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

const cityCatalog = {
  Istanbul: { lat: 41.0082, lng: 28.9784, districts: ['Kadıköy', 'Beşiktaş', 'Şişli', 'Üsküdar'] },
  Ankara: { lat: 39.9334, lng: 32.8597, districts: ['Çankaya', 'Keçiören', 'Mamak', 'Yenimahalle'] },
  Izmir: { lat: 38.4237, lng: 27.1428, districts: ['Konak', 'Bornova', 'Karşıyaka', 'Buca'] },
  Bursa: { lat: 40.1826, lng: 29.0665, districts: ['Osmangazi', 'Yıldırım', 'Nilüfer', 'Gemlik'] },
  Antalya: { lat: 36.8969, lng: 30.7133, districts: ['Muratpaşa', 'Kepez', 'Konyaaltı', 'Alanya'] },
  Adana: { lat: 37.0, lng: 35.3213, districts: ['Seyhan', 'Yüreğir', 'Çukurova', 'Sarıçam'] },
  Konya: { lat: 37.8746, lng: 32.4932, districts: ['Meram', 'Selçuklu', 'Karatay', 'Ereğli'] },
  Gaziantep: { lat: 37.0662, lng: 37.3833, districts: ['Şahinbey', 'Şehitkamil', 'Oğuzeli', 'Nizip'] },
  Mersin: { lat: 36.8121, lng: 34.6415, districts: ['Akdeniz', 'Toroslar', 'Mezitli', 'Yenişehir'] },
  Kayseri: { lat: 38.7312, lng: 35.4787, districts: ['Kocasinan', 'Melikgazi', 'Talas', 'Develi'] },
};

function pickRandomDistrict(cityMeta) {
  const districts = cityMeta.districts;
  return districts[Math.floor(Math.random() * districts.length)];
}

function jitterCoordinate(value) {
  return value + (Math.random() * 0.02 - 0.01);
}

async function ensureLocations() {
  const snapshot = await db.collection('users').get();
  if (snapshot.empty) {
    console.log('⚠️  No user documents found.');
    return;
  }

  let updatedCount = 0;

  for (const doc of snapshot.docs) {
    const data = doc.data();
    const hasCompleteLocation =
      data.city &&
      data.location &&
      typeof data.latitude === 'number' &&
      typeof data.longitude === 'number';

    if (hasCompleteLocation) {
      continue;
    }

    const preferredCity = data.city && cityCatalog[data.city]
      ? data.city
      : Object.keys(cityCatalog)[Math.floor(Math.random() * Object.keys(cityCatalog).length)];

    const cityMeta = cityCatalog[preferredCity];
    const district = pickRandomDistrict(cityMeta);

    const payload = {
      city: preferredCity,
      district,
      location: `${district}, ${preferredCity}`,
      latitude: Number(jitterCoordinate(cityMeta.lat).toFixed(6)),
      longitude: Number(jitterCoordinate(cityMeta.lng).toFixed(6)),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await doc.ref.set(payload, { merge: true });
    updatedCount += 1;
    console.log(`📍 Updated location for user ${doc.id} → ${payload.location}`);
  }

  if (updatedCount === 0) {
    console.log('✅ All user documents already contain location data.');
  } else {
    console.log(`✅ Completed: ${updatedCount} user documents updated with location info.`);
  }
}

ensureLocations()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error('❌ Failed to seed user locations:', error);
    process.exit(1);
  });
