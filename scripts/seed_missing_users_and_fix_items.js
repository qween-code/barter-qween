const admin = require('firebase-admin');
const path = require('path');

const serviceAccount = require(path.join(__dirname, '..', 'serviceAccountKey.json'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const { FieldValue } = admin.firestore;

const userSeeds = [
  {
    id: 'gyS6J2CgkIV9kHOi2sK969EFsug1',
    data: {
      displayName: 'Elif Yılmaz',
      email: 'elif.yilmaz@bartermail.com',
      photoUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=256&q=80',
      isEmailVerified: true,
      phoneNumber: null,
      address: null,
      bio: 'Vintage parçalar ve koleksiyon ürünleri takası yapıyorum.',
      city: 'Kayseri',
      location: 'Melikgazi, Kayseri, Turkey',
      latitude: 38.7312,
      longitude: 35.4787,
      trustScore: 88,
      social: {
        followersCount: 940,
        followingCount: 154,
      },
      stats: {
        completedTrades: 5,
        pendingTrades: 1,
        listingCount: 24,
        positiveReviews: 29,
      },
      totalFavorites: 11,
    },
  },
  {
    id: '6MuworQd1aOWLkET3sAExWJFh2u2',
    data: {
      displayName: 'Mert Demir',
      email: 'mert.demir@bartermail.com',
      photoUrl: 'https://images.unsplash.com/photo-1544723795-3fb6469f5b39?w=256&q=80',
      isEmailVerified: true,
      phoneNumber: null,
      address: null,
      bio: 'Teknoloji ürünleri ve premium aksesuarlar arıyorum.',
      city: 'Izmir',
      location: 'Karşıyaka, Izmir, Turkey',
      latitude: 38.4555,
      longitude: 27.1090,
      trustScore: 86,
      social: {
        followersCount: 720,
        followingCount: 203,
      },
      stats: {
        completedTrades: 7,
        pendingTrades: 2,
        listingCount: 31,
        positiveReviews: 41,
      },
      totalFavorites: 9,
    },
  },
  {
    id: 'bLDKImtWRrPuplQThrzT4IVUuW52',
    data: {
      displayName: 'Zeynep Arslan',
      email: 'zeynep.arslan@bartermail.com',
      photoUrl: 'https://images.unsplash.com/photo-1531891437562-4301cf35b7e4?w=256&q=80',
      isEmailVerified: true,
      phoneNumber: null,
      address: null,
      bio: 'Sürdürülebilir moda tutkunuyum, sneaker koleksiyonum var.',
      city: 'Bursa',
      location: 'Nilüfer, Bursa, Turkey',
      latitude: 40.2230,
      longitude: 28.9036,
      trustScore: 83,
      social: {
        followersCount: 580,
        followingCount: 167,
      },
      stats: {
        completedTrades: 4,
        pendingTrades: 1,
        listingCount: 19,
        positiveReviews: 24,
      },
      totalFavorites: 7,
    },
  },
  {
    id: 'oGOgYIq0sKeJfSdrpUlC09WUxm93',
    data: {
      displayName: 'Kerem Aydın',
      email: 'kerem.aydin@bartermail.com',
      photoUrl: 'https://images.unsplash.com/photo-1542596768-5d1d21f1cf98?w=256&q=80',
      isEmailVerified: true,
      phoneNumber: null,
      address: null,
      bio: 'Akıllı ev cihazları ve premium kulaklık koleksiyoneri.',
      city: 'Adana',
      location: 'Çukurova, Adana, Turkey',
      latitude: 37.0632,
      longitude: 35.3213,
      trustScore: 85,
      social: {
        followersCount: 610,
        followingCount: 142,
      },
      stats: {
        completedTrades: 6,
        pendingTrades: 1,
        listingCount: 27,
        positiveReviews: 33,
      },
      totalFavorites: 10,
    },
  },
  {
    id: 'XBc2ja5OwQPewX6snFT4abJKC7i1',
    data: {
      displayName: 'Selin Kılıç',
      email: 'selin.kilic@bartermail.com',
      photoUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=256&q=80',
      isEmailVerified: true,
      phoneNumber: null,
      address: null,
      bio: 'Bisiklet ve outdoor ekipmanları için takas arıyorum.',
      city: 'Konya',
      location: 'Selçuklu, Konya, Turkey',
      latitude: 37.8746,
      longitude: 32.4932,
      trustScore: 82,
      social: {
        followersCount: 460,
        followingCount: 118,
      },
      stats: {
        completedTrades: 3,
        pendingTrades: 1,
        listingCount: 16,
        positiveReviews: 18,
      },
      totalFavorites: 6,
    },
  },
  {
    id: 'gj5ptYNj6OSZ7efdIJteDTpy0h03',
    data: {
      displayName: 'Hamza Trhn',
      email: 'hamza.trhn@bartermail.com',
      photoUrl: 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=256&q=80',
      isEmailVerified: true,
      phoneNumber: null,
      address: null,
      bio: 'Gourmet ürünler ve koleksiyon parçaları ekliyorum.',
      city: 'Istanbul',
      location: 'Kadıköy, Istanbul, Turkey',
      latitude: 40.9900,
      longitude: 29.0250,
      trustScore: 79,
      social: {
        followersCount: 390,
        followingCount: 132,
      },
      stats: {
        completedTrades: 2,
        pendingTrades: 1,
        listingCount: 9,
        positiveReviews: 12,
      },
      totalFavorites: 5,
    },
  },
];

const itemFixes = [
  {
    id: 'ToiKDJ4iFw4n40Axdvgb',
    data: {
      city: 'Istanbul',
      fullAddress: 'Kadıköy, Istanbul, Turkey',
      meetupLocation: 'Kadıköy, Istanbul, Turkey',
      latitude: 40.9900,
      longitude: 29.0250,
    },
  },
  {
    id: 'U9RJrO7tEHTyFQsxjQtw',
    data: {
      city: 'Istanbul',
      fullAddress: 'Kadıköy, Istanbul, Turkey',
      meetupLocation: 'Kadıköy, Istanbul, Turkey',
      latitude: 40.9900,
      longitude: 29.0250,
    },
  },
  {
    id: 'ZCTmId9bIQ4LET86SXEf',
    data: {
      city: 'Istanbul',
      fullAddress: 'Kadıköy, Istanbul, Turkey',
      meetupLocation: 'Kadıköy, Istanbul, Turkey',
      latitude: 40.9900,
      longitude: 29.0250,
    },
  },
];

async function upsertUsers() {
  for (const user of userSeeds) {
    const docRef = db.collection('users').doc(user.id);
    const existing = await docRef.get();
    const payload = {
      uid: user.id,
      updatedAt: FieldValue.serverTimestamp(),
      ...user.data,
    };

    if (!existing.exists) {
      payload.createdAt = FieldValue.serverTimestamp();
    }

    await docRef.set(payload, { merge: true });
    console.log(`Upserted user ${user.id}`);
  }
}

async function fixItems() {
  for (const item of itemFixes) {
    await db
      .collection('items')
      .doc(item.id)
      .set(
        {
          ...item.data,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    console.log(`Updated item ${item.id}`);
  }
}

async function run() {
  try {
    await upsertUsers();
    await fixItems();
  } finally {
    await admin.app().delete();
  }
}

run().catch((err) => {
  console.error('Seeding failed', err);
  process.exitCode = 1;
});
