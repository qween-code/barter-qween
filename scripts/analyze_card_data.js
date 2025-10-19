const admin = require('firebase-admin');
const path = require('path');

const serviceAccountPath = path.join(__dirname, '..', 'serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(require(serviceAccountPath)),
});

const db = admin.firestore();

async function analyze() {
  const snapshot = await db.collection('items').get();
  const stats = {
    total: snapshot.size,
    maxTitleLength: 0,
    maxTitleItem: null,
    maxBrandLength: 0,
    missingCity: [],
    missingOwner: [],
    conditions: new Map(),
    badgesUsage: new Map(),
    ownerIds: new Set(),
  };

  snapshot.forEach((doc) => {
    const data = doc.data();

    if (data.title && data.title.length > stats.maxTitleLength) {
      stats.maxTitleLength = data.title.length;
      stats.maxTitleItem = { id: doc.id, title: data.title };
    }

    if (data.brand && data.brand.length > stats.maxBrandLength) {
      stats.maxBrandLength = data.brand.length;
    }

    if (!data.city) {
      stats.missingCity.push({ id: doc.id, title: data.title, ownerId: data.ownerId });
    }

    if (!data.ownerId) {
      stats.missingOwner.push({ id: doc.id, title: data.title });
    }

    if (data.ownerId) {
      stats.ownerIds.add(data.ownerId);
    }

    if (data.condition) {
      stats.conditions.set(
        data.condition,
        (stats.conditions.get(data.condition) || 0) + 1,
      );
    }

    if (Array.isArray(data.badges)) {
      data.badges.forEach((badge) => {
        stats.badgesUsage.set(badge, (stats.badgesUsage.get(badge) || 0) + 1);
      });
    }
  });

  console.log('Total items:', stats.total);
  console.log('Longest title length:', stats.maxTitleLength, stats.maxTitleItem);
  console.log('Longest brand length:', stats.maxBrandLength);
  console.log('Items missing city:', stats.missingCity.length);
  if (stats.missingCity.length) {
    console.log(stats.missingCity.slice(0, 10));
  }
  console.log('Items missing owner:', stats.missingOwner.length);
  console.log('Unique ownerIds on items:', stats.ownerIds.size);

  const usersSnap = await db.collection('users').get();
  const userIds = new Set();
  usersSnap.forEach((doc) => userIds.add(doc.id));
  const orphanOwners = [...stats.ownerIds].filter((id) => !userIds.has(id));
  console.log('User documents:', userIds.size);
  console.log('OwnerIds without user doc:', orphanOwners.length);
  if (orphanOwners.length) {
    console.log('Sample missing ownerIds:', orphanOwners.slice(0, 10));
  }
  console.log('Condition distribution:', Object.fromEntries(stats.conditions));
  console.log('Badges distribution:', Object.fromEntries(stats.badgesUsage));
}

analyze()
  .catch((err) => {
    console.error('Error analyzing items', err);
  })
  .finally(() => admin.app().delete());
