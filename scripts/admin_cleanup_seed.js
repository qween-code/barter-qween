const admin = require('firebase-admin');
const path = require('path');

const serviceAccountPath = path.join(__dirname, '..', 'serviceAccountKey.json');
let serviceAccount;

try {
  serviceAccount = require(serviceAccountPath);
} catch (error) {
  console.error('❌ serviceAccountKey.json bulunamadı. Firebase Admin başlatılamıyor.');
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: 'bogazici-barter.appspot.com',
});

const auth = admin.auth();
const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

async function listUsers() {
  const googleUsers = [];
  const nonGoogleUsers = [];
  let nextPageToken;

  do {
    const result = await auth.listUsers(1000, nextPageToken);
    result.users.forEach((userRecord) => {
      const providers = userRecord.providerData.map((p) => p.providerId);
      const hasGoogle = providers.includes('google.com');
      if (hasGoogle) {
        googleUsers.push(userRecord);
      } else {
        nonGoogleUsers.push(userRecord);
      }
    });
    nextPageToken = result.pageToken;
  } while (nextPageToken);

  return { googleUsers, nonGoogleUsers };
}

async function batchDeleteDocs(docs) {
  const chunks = [];
  for (let i = 0; i < docs.length; i += 400) {
    chunks.push(docs.slice(i, i + 400));
  }

  for (const chunk of chunks) {
    const batch = db.batch();
    chunk.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
  }
}

async function deleteCollectionByQuery(query) {
  const snapshot = await query.get();
  if (snapshot.empty) return;
  await batchDeleteDocs(snapshot.docs);
}

async function deleteCollections(collectionNames) {
  for (const name of collectionNames) {
    const snapshot = await db.collection(name).get();
    if (!snapshot.empty) {
      console.log(`🧹 ${name} koleksiyonu temizleniyor (${snapshot.size} doküman)...`);
      await batchDeleteDocs(snapshot.docs);
    }
  }
}

async function deleteUserRelatedData(uid) {
  await db.collection('users').doc(uid).delete().catch(() => {});
  await db.collection('admins').doc(uid).delete().catch(() => {});

  await deleteCollectionByQuery(
    db.collection('items').where('ownerId', '==', uid)
  );

  await deleteCollectionByQuery(
    db.collection('tradeOffers').where('fromUserId', '==', uid)
  );
  await deleteCollectionByQuery(
    db.collection('tradeOffers').where('toUserId', '==', uid)
  );

  const conversationsSnapshot = await db
    .collection('conversations')
    .where('participants', 'array-contains', uid)
    .get();

  if (!conversationsSnapshot.empty) {
    for (const convoDoc of conversationsSnapshot.docs) {
      await deleteCollectionByQuery(
        db.collection('messages').where('conversationId', '==', convoDoc.id)
      );
    }
    await batchDeleteDocs(conversationsSnapshot.docs);
  }
}

async function deleteNonGoogleUsers(nonGoogleUsers) {
  if (!nonGoogleUsers.length) {
    console.log('✅ Google dışı kullanıcı bulunamadı.');
    return [];
  }

  console.log(`👤 Google dışı ${nonGoogleUsers.length} kullanıcı siliniyor...`);
  const deleted = [];

  for (const user of nonGoogleUsers) {
    try {
      await deleteUserRelatedData(user.uid);
      await auth.deleteUser(user.uid);
      deleted.push(user.uid);
      console.log(`   • Silindi: ${user.email || user.uid}`);
    } catch (error) {
      console.error(`   • Kullanıcı silinemedi (${user.email || user.uid}):`, error.message);
    }
  }

  return deleted;
}

function buildLocationPresets(activeUsers) {
  const presets = [
    {
      city: 'Istanbul',
      fullAddress: 'Beşiktaş, Istanbul, Turkey',
      latitude: 41.0430,
      longitude: 29.0023,
    },
    {
      city: 'Istanbul',
      fullAddress: 'Kadıköy, Istanbul, Turkey',
      latitude: 40.9915,
      longitude: 29.0270,
    },
    {
      city: 'Ankara',
      fullAddress: 'Çankaya, Ankara, Turkey',
      latitude: 39.9097,
      longitude: 32.8530,
    },
  ];

  return activeUsers.map(({ user }, index) => ({ user, location: presets[index] }));
}

async function ensureUserProfile(userRecord, location) {
  const userRef = db.collection('users').doc(userRecord.uid);
  const doc = await userRef.get();

  const baseData = {
    uid: userRecord.uid,
    email: userRecord.email,
    displayName: userRecord.displayName || userRecord.email?.split('@')[0] || 'Trader',
    photoUrl: userRecord.photoURL || null,
    phoneNumber: userRecord.phoneNumber || null,
    city: location.city,
    location: location.fullAddress,
    latitude: location.latitude,
    longitude: location.longitude,
    createdAt: doc.exists ? doc.data().createdAt || FieldValue.serverTimestamp() : FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
    stats: {
      completedTrades: 0,
      positiveReviews: 0,
      listingCount: 0,
    },
  };

  await userRef.set(baseData, { merge: true });
}

async function purgeInactiveUserDocs(activeUserIds) {
  const snapshot = await db.collection('users').get();
  const deletions = snapshot.docs.filter((doc) => !activeUserIds.includes(doc.id));
  if (!deletions.length) return;

  console.log(`🗑️  Kullanıcı koleksiyonunda ${deletions.length} ekstra kayıt siliniyor...`);
  await batchDeleteDocs(deletions);
}

async function promoteToAdmin(userRecord) {
  const adminRef = db.collection('admins').doc(userRecord.uid);
  await adminRef.set(
    {
      email: userRecord.email,
      name: userRecord.displayName || userRecord.email || 'Admin User',
      role: 'superAdmin',
      permissions: [
        'approveItems',
        'rejectItems',
        'banUsers',
        'viewAnalytics',
        'manageUsers',
        'editItemTiers',
        'viewReports',
      ],
      isActive: true,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true }
  );
}

function buildItemPayloads(ownerConfigs) {
  const items = [
    {
      title: 'Apple Vision Pro Developer Kit',
      description:
        'Apple Vision Pro (256GB) geliştirici kiti. Demo amaçlı 1 hafta kullanıldı, tüm aksesuarları mevcut.',
      category: 'Electronics',
      condition: 'Like New',
      price: 145000,
      images: [
        'https://images.unsplash.com/photo-1707343843437-caacff5cfa74?w=1600&q=80',
        'https://images.unsplash.com/photo-1704300291304-dad685c57c16?w=1600&q=80',
      ],
      features: ['Spatial Computing', '256GB Storage', 'Developer Kit'],
    },
    {
      title: 'Custom Gaming PC (RTX 4090)',
      description:
        'Intel i9-14900K, RTX 4090, 64GB DDR5 RAM ve sıvı soğutma ile üst seviye oyun istasyonu.',
      category: 'Electronics',
      condition: 'Like New',
      price: 185000,
      images: [
        'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=1600&q=80',
        'https://images.unsplash.com/photo-1587202372775-98927b5f261c?w=1600&q=80',
      ],
      features: ['RTX 4090', 'Intel i9-14900K', 'Custom Water Cooling'],
    },
    {
      title: 'Rolex Submariner 124060 (2023)',
      description:
        'Rolex Submariner 41mm, 2023 üretim, kutulu ve sertifikalı. Servis garantisi devam ediyor.',
      category: 'Luxury',
      condition: 'Like New',
      price: 475000,
      images: [
        'https://images.unsplash.com/photo-1524593947800-3160b66cfd3f?w=1600&q=80',
        'https://images.unsplash.com/photo-1518544801976-3e159e64ab3f?w=1600&q=80',
      ],
      features: ['41mm', 'Automatic', 'Ceramic Bezel'],
    },
    {
      title: 'Leica Q3 Full-Frame Kamera',
      description:
        'Leica Q3, Summilux 28mm f/1.7 lens ile. 500 shutter altında, faturalı ve kutulu.',
      category: 'Electronics',
      condition: 'Like New',
      price: 210000,
      images: [
        'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=1600&q=80',
        'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=1500&q=80',
      ],
      features: ['Full-Frame', 'Summilux 28mm', '8K Video'],
    },
    {
      title: 'Tesla Model Y Wall Connector (Gen 3)',
      description:
        'Tesla Model Y için 7,4kW duvar şarj ünitesi. Kutusunda, hiç kullanılmadı.',
      category: 'Automotive',
      condition: 'Brand New',
      price: 18500,
      images: [
        'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=1600&q=80',
        'https://images.unsplash.com/photo-1563720223185-11003d516935?w=1600&q=80',
      ],
      features: ['7.4kW', 'Wi-Fi Control', 'Official Accessory'],
    },
    {
      title: 'Hermès Birkin 30 Togo Leather',
      description:
        'Hermès Birkin 30, Togo deri, Gold hardware. 2022 üretim, tam set ve kusursuz durumda.',
      category: 'Luxury',
      condition: 'Like New',
      price: 880000,
      images: [
        'https://images.unsplash.com/photo-1612810806695-30ba32e7f3c1?w=1600&q=80',
        'https://images.unsplash.com/photo-1600181954050-41c0f9c85ba6?w=1600&q=80',
      ],
      features: ['Gold Hardware', 'Togo Leather', '30cm Size'],
    },
    {
      title: 'Sony A95L 65" QD-OLED TV',
      description:
        'Sony Bravia XR A95L, 65 inç QD-OLED TV. 4 ay kullanıldı, garantisi 2026’ya kadar devam ediyor.',
      category: 'Electronics',
      condition: 'Like New',
      price: 120000,
      images: [
        'https://images.unsplash.com/photo-1587825140608-75b9c83f8151?w=1600&q=80',
        'https://images.unsplash.com/photo-1580894908361-967195033215?w=1600&q=80',
      ],
      features: ['QD-OLED', 'Dolby Vision', 'Google TV'],
    },
    {
      title: 'Specialized Turbo Vado 5.0 E-Bike',
      description:
        'Specialized Turbo Vado 5.0 e-bike, 2023 modeli. Batarya sağlığı %98, 900 km kullanıldı.',
      category: 'Sports',
      condition: 'Excellent',
      price: 135000,
      images: [
        'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=1600&q=80',
        'https://images.unsplash.com/photo-1541621132827-487011dfba07?w=1600&q=80',
      ],
      features: ['90Nm Torque', 'Removable Battery', 'Integrated Lights'],
    },
    {
      title: 'DJI Inspire 3 Fly More Combo',
      description:
        'DJI Inspire 3, X9-8K kamera, 3 batarya ve ProSSD dahil. Profesyonel sinema çekimleri için ideal.',
      category: 'Electronics',
      condition: 'Like New',
      price: 730000,
      images: [
        'https://images.unsplash.com/photo-1484704849700-f032a568e944?w=1600&q=80',
        'https://images.unsplash.com/photo-1486848538113-ce1a4923fbc5?w=1600&q=80',
      ],
      features: ['8K RAW', 'Cinema-Grade', 'ProSSD'],
    },
    {
      title: 'Brompton Electric C Line Explore',
      description:
        'Brompton Electric C Line, 6 vitesli. Şehir içi kullanım için mükemmel, pil sağlığı %95.',
      category: 'Sports',
      condition: 'Like New',
      price: 165000,
      images: [
        'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=1600&q=80',
        'https://images.unsplash.com/photo-1456990493443-0d0ee76c54fb?w=1600&q=80',
      ],
      features: ['Electric Assist', 'Folding Bike', 'UK Made'],
    },
    {
      title: 'Bang & Olufsen Beolab 28 Hoparlör Seti',
      description:
        'Bang & Olufsen Beolab 28 kablosuz hoparlör çifti. Adaptif odaklama ve ultra ince tasarım.',
      category: 'Electronics',
      condition: 'Like New',
      price: 460000,
      images: [
        'https://images.unsplash.com/photo-1585386959984-a4155224a1ad?w=1600&q=80',
        'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=1600&q=80',
      ],
      features: ['Adaptive Sound', 'Wireless', 'AirPlay 2'],
    },
    {
      title: 'Louis Vuitton Horizon 70 Valiz',
      description:
        'Louis Vuitton Horizon 70 kabin boy valiz. Monogram Canvas, 2023 koleksiyonu.',
      category: 'Luxury',
      condition: 'Brand New',
      price: 195000,
      images: [
        'https://images.unsplash.com/photo-1518640467707-6811f4a6ab73?w=1600&q=80',
        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=1600&q=80',
      ],
      features: ['Monogram Canvas', '4 Wheels', 'TSA Lock'],
    },
    {
      title: 'Porsche Design Chronograph 1 All-Black',
      description:
        'Porsche Design Chronograph 1, titanyum kasa ve otomatik mekanizma. Limitli üretim.',
      category: 'Luxury',
      condition: 'Like New',
      price: 285000,
      images: [
        'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=1600&q=80',
        'https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=1600&q=80',
      ],
      features: ['Titanium Case', 'Automatic', 'Limited Edition'],
    },
    {
      title: 'Fender Custom Shop Stratocaster',
      description:
        'Fender Custom Shop 1963 Stratocaster. Nitro lake, el yapımı, Collector’s Choice.',
      category: 'Music',
      condition: 'Excellent',
      price: 175000,
      images: [
        'https://images.unsplash.com/photo-1504274066651-8d31a536b11a?w=1600&q=80',
        'https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=1600&q=80',
      ],
      features: ['Nitro Finish', 'Hand-Wound Pickups', 'Relic Level'],
    },
    {
      title: 'Moog One 16-Voice Synthesizer',
      description:
        'Moog One 16-voice analog synthesizer. Stüdyo ortamında sadece birkaç kayıt için kullanıldı.',
      category: 'Music',
      condition: 'Like New',
      price: 320000,
      images: [
        'https://images.unsplash.com/photo-1516280030429-27679b3dc9cf?w=1600&q=80',
        'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=1600&q=80',
      ],
      features: ['16-Voice Poly', 'Triplet LFO', 'Analog'],
    },
    {
      title: 'Leica Noctilux-M 50mm f/0.95 ASPH',
      description:
        'Leica Noctilux-M 50mm f/0.95 lens. Sıfıra yakın kondisyon, lens hood ve kutu dahil.',
      category: 'Electronics',
      condition: 'Like New',
      price: 310000,
      images: [
        'https://images.unsplash.com/photo-1519181245277-cffeb31da2fb?w=1600&q=80',
        'https://images.unsplash.com/photo-1461958505230-b706e8f41ef1?w=1600&q=80',
      ],
      features: ['f/0.95', 'ASPH', 'M Mount'],
    },
    {
      title: 'Moncler Grenoble Glacier Ceket',
      description:
        'Moncler Grenoble Glacier teknik kayak ceketi. 2024 koleksiyonu, sadece iki kez giyildi.',
      category: 'Fashion',
      condition: 'Like New',
      price: 52000,
      images: [
        'https://images.unsplash.com/photo-1521579971123-1192931a1452?w=1600&q=80',
        'https://images.unsplash.com/photo-1489515217757-5fd1be406fef?w=1600&q=80',
      ],
      features: ['Waterproof', 'Breathable', 'Primaloft'],
    },
    {
      title: 'Supreme Skate Deck Koleksiyonu (Set of 5)',
      description:
        'Supreme işbirliği serisinden 5 parçalık kaset koleksiyonu. Hiç kullanılmadı, duvar montajlı.',
      category: 'Collectibles',
      condition: 'New',
      price: 68000,
      images: [
        'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=1600&q=80',
        'https://images.unsplash.com/photo-1552345382-91befe8b0f37?w=1600&q=80',
      ],
      features: ['Limited Edition', 'Set of 5', 'Wall Mount'],
    },
    {
      title: 'Gucci Jackie 1961 Hobo Çanta',
      description:
        'Gucci Jackie 1961 mini hobo çanta. Smaragd yeşili deri, 2023 sezonu.',
      category: 'Luxury',
      condition: 'Like New',
      price: 62000,
      images: [
        'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=1600&q=80',
        'https://images.unsplash.com/photo-1621609776216-2d7b75ec79a0?w=1600&q=80',
      ],
      features: ['Italian Leather', 'Mini Size', 'Gold Hardware'],
    },
    {
      title: 'Omega Speedmaster Moonwatch Sapphire',
      description:
        'Omega Speedmaster Professional Moonwatch, safir cam ve siyah bezel ile. Tam set.',
      category: 'Luxury',
      condition: 'Like New',
      price: 195000,
      images: [
        'https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=1600&q=80',
        'https://images.unsplash.com/photo-1556228578-0e0b0a5a8e2f?w=1600&q=80',
      ],
      features: ['Manual Winding', 'Sapphire Crystal', 'Moonwatch'],
    },
    {
      title: 'Samsung 110" MicroLED TV',
      description:
        'Samsung 110 inç MicroLED TV. Profesyonel kurulumu yapıldı, showroom’da sergilendi.',
      category: 'Electronics',
      condition: 'Like New',
      price: 1250000,
      images: [
        'https://images.unsplash.com/photo-1600573472550-8090b5e0743c?w=1600&q=80',
        'https://images.unsplash.com/photo-1593642632559-0c3ba1b59ad1?w=1600&q=80',
      ],
      features: ['MicroLED', '110 inch', 'HDR10+'],
    },
    {
      title: 'Eames Lounge Chair & Ottoman (Walnut)',
      description:
        'Herman Miller Eames Lounge Chair & Ottoman, American Walnut kaplama ve siyah deri.',
      category: 'Home',
      condition: 'Excellent',
      price: 185000,
      images: [
        'https://images.unsplash.com/photo-1470309864661-68328b2cd0a5?w=1600&q=80',
        'https://images.unsplash.com/photo-1578898886271-9c6b0e46decb?w=1600&q=80',
      ],
      features: ['Walnut Shell', 'Leather Cushion', 'Iconic Design'],
    },
    {
      title: 'Miele Dialog Fırın (DX 7000)',
      description:
        'Miele Dialog fırın. Tam akıllı sensörlü pişirme, 2024 ithal ürün, 3 ay kullanıldı.',
      category: 'Home Appliances',
      condition: 'Like New',
      price: 89000,
      images: [
        'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=1600&q=80',
        'https://images.unsplash.com/photo-1503387762-592deb58ef4e?w=1600&q=80',
      ],
      features: ['Gourmet Assistant', 'M Touch', 'Wireless Roast Probe'],
    },
    {
      title: 'Canyon Ultimate CFR Aero Road Bike',
      description:
        'Canyon Ultimate CFR, Di2 elektronik vites, karbon tekerlek seti. Yarış seviyesinde.',
      category: 'Sports',
      condition: 'Excellent',
      price: 145000,
      images: [
        'https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=1600&q=80',
        'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=1600&q=80',
      ],
      features: ['Di2 Ultegra', 'Carbon Wheels', 'Aerodynamic Frame'],
    },
    {
      title: 'Apple Mac Pro (M2 Ultra, 192GB)',
      description:
        'Apple Mac Pro M2 Ultra, 24-Core CPU, 76-Core GPU, 192GB unified memory. Sinema projeleri için kullanıldı.',
      category: 'Electronics',
      condition: 'Like New',
      price: 540000,
      images: [
        'https://images.unsplash.com/photo-1527443224154-dc2d0fc59401?w=1600&q=80',
        'https://images.unsplash.com/photo-1593642702909-dec73df255d7?w=1600&q=80',
      ],
      features: ['M2 Ultra', 'Afterburner-class', '192GB Unified Memory'],
    },
    {
      title: 'Blackmagic URSA Mini Pro 12K',
      description:
        'Blackmagic URSA Mini Pro 12K, PL mount, 12K Super 35 sensör. Netflix onaylı set.',
      category: 'Electronics',
      condition: 'Like New',
      price: 365000,
      images: [
        'https://images.unsplash.com/photo-1489515217757-5fd1be406fef?w=1600&q=80',
        'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=1600&q=80',
      ],
      features: ['12K RAW', 'PL Mount', 'Netflix Approved'],
    },
    {
      title: 'Hasselblad X2D 100C Orta Format',
      description:
        'Hasselblad X2D 100C orta format kamera. 100MP sensör, CFexpress kart ile birlikte.',
      category: 'Electronics',
      condition: 'Like New',
      price: 420000,
      images: [
        'https://images.unsplash.com/photo-1519183071298-a2962eadcdb2?w=1600&q=80',
        'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=1600&q=80',
      ],
      features: ['100MP', 'IBIS', 'Phase Detect AF'],
    },
    {
      title: 'Sony FX6 Full-Frame Sinema Kamera',
      description:
        'Sony FX6, full-frame sinema kamera, 4K 120fps, XLR girişleriyle profesyonel set.',
      category: 'Electronics',
      condition: 'Excellent',
      price: 245000,
      images: [
        'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=1600&q=80',
        'https://images.unsplash.com/photo-1484704849700-f032a568e944?w=1600&q=80',
      ],
      features: ['4K 120fps', 'Full-Frame', 'S-Cinetone'],
    },
    {
      title: 'Audeze LCD-5 Referans Kulaklık',
      description:
        'Audeze LCD-5 planar manyetik referans kulaklık. Orijinal kablo ve kutu ile.',
      category: 'Electronics',
      condition: 'Like New',
      price: 92000,
      images: [
        'https://images.unsplash.com/photo-1580894906472-6b81f3d3a2d7?w=1600&q=80',
        'https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=1600&q=80',
      ],
      features: ['Planar Magnetic', 'Ultra-Low Distortion', 'Reference Tuning'],
    },
    {
      title: 'Prada Linea Rossa Snowboard Seti',
      description:
        'Prada Linea Rossa snowboard seti; board, bağlama ve taşıma çantası dahil.',
      category: 'Sports',
      condition: 'Like New',
      price: 68000,
      images: [
        'https://images.unsplash.com/photo-1526666923127-b2970f64b422?w=1600&q=80',
        'https://images.unsplash.com/photo-1489515217757-5fd1be406fef?w=1600&q=80',
      ],
      features: ['Carbon Core', 'All-Mountain', 'Limited Edition'],
    },
    {
      title: 'Leica D-Lux 7 Street Kit',
      description:
        'Leica D-Lux 7 Street Kit özel sürüm. El askısı ve çanta dahil, 4K video.',
      category: 'Electronics',
      condition: 'Like New',
      price: 42000,
      images: [
        'https://images.unsplash.com/photo-1519181245277-cffeb31da2fb?w=1600&q=80',
        'https://images.unsplash.com/photo-1470309864661-68328b2cd0a5?w=1600&q=80',
      ],
      features: ['4K Video', 'Street Kit', 'Fast Lens'],
    },
    {
      title: 'Herman Miller Embody Gaming Edition',
      description:
        'Herman Miller Embody Gaming Edition ergonomik sandalye. Stokta zor bulunan siyah/yeşil model.',
      category: 'Home',
      condition: 'Like New',
      price: 54000,
      images: [
        'https://images.unsplash.com/photo-1520880867055-1e30d1cb001c?w=1600&q=80',
        'https://images.unsplash.com/photo-1545239351-1141bd82e8a6?w=1600&q=80',
      ],
      features: ['Pixelated Support', 'Cooling Foam', 'Ergonomic'],
    },
    {
      title: 'DJI Mavic 3 Pro Cine Premium Combo',
      description:
        'DJI Mavic 3 Pro Cine, Apple ProRes destekli. 3 kamera sistemi ve ND filtre seti dahil.',
      category: 'Electronics',
      condition: 'Like New',
      price: 152000,
      images: [
        'https://images.unsplash.com/photo-1508612761958-e931b49cecdc?w=1600&q=80',
        'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?w=1600&q=80',
      ],
      features: ['ProRes', 'Triple Camera', '46min Flight'],
    },
    {
      title: 'Peloton Bike+ Akıllı Fitness Bisikleti',
      description:
        'Peloton Bike+ 3. kuşak, otomatik direnç ayarı, dönebilen ekran, premium seviye set.',
      category: 'Sports',
      condition: 'Excellent',
      price: 64000,
      images: [
        'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=1600&q=80',
        'https://images.unsplash.com/photo-1586122896534-77967d69d817?w=1600&q=80',
      ],
      features: ['Auto Follow', 'Rotating Screen', 'HD Camera'],
    },
    {
      title: 'Tiffany & Co. Soleste Yüzük (1.5 ct)',
      description:
        'Tiffany Soleste platinyum yüzük, 1.5ct G renk pırlanta, sertifikalı ve temizleme setiyle.',
      category: 'Luxury',
      condition: 'Like New',
      price: 390000,
      images: [
        'https://images.unsplash.com/photo-1522312346375-d1a52e2b99b3?w=1600&q=80',
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=1600&q=80',
      ],
      features: ['1.5ct Diamond', 'Platinum', 'GIA Certified'],
    },
    {
      title: 'TAG Heuer Carrera Glassbox 39mm',
      description:
        'TAG Heuer Carrera Glassbox kronograf. 39mm, kalibre TH20-00, 2023 koleksiyonu.',
      category: 'Luxury',
      condition: 'Brand New',
      price: 165000,
      images: [
        'https://images.unsplash.com/photo-1475180098004-ca77a66827be?w=1600&q=80',
        'https://images.unsplash.com/photo-1489515217757-5fd1be406fef?w=1600&q=80',
      ],
      features: ['Automatic Chronograph', 'Glassbox', '39mm'],
    },
    {
      title: 'RIMOWA Classic Aluminium Check-In L',
      description:
        'RIMOWA Classic aluminium Check-In L. Az kullanıldı, ufak çizikler mevcut.',
      category: 'Luxury',
      condition: 'Good',
      price: 42000,
      images: [
        'https://images.unsplash.com/photo-1556740749-887f6717d7e4?w=1600&q=80',
        'https://images.unsplash.com/photo-1518544801976-3e159e64ab3f?w=1600&q=80',
      ],
      features: ['Aluminium Body', 'TSA Locks', 'Ball-Bearing Wheels'],
    },
    {
      title: 'Apple Studio Display Pro 32"',
      description:
        'Apple Studio Display Pro, 32" Retina 6K, nano-texture cam ve yükseklik ayarlı stand.',
      category: 'Electronics',
      condition: 'Like New',
      price: 195000,
      images: [
        'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=1600&q=80',
        'https://images.unsplash.com/photo-1558888400-16d918014c6d?w=1600&q=80',
      ],
      features: ['6K Retina', 'Nano-Texture', 'Height Adjustable'],
    },
    {
      title: 'ASUS ROG Flow X16 (RTX 4080)',
      description:
        'ASUS ROG Flow X16, RTX 4080, Ryzen 9 7945HX, miniLED ekran. Hibrit oyuncu/dizüstü.',
      category: 'Electronics',
      condition: 'Like New',
      price: 135000,
      images: [
        'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=1600&q=80',
        'https://images.unsplash.com/photo-1587202372775-98927b5f261c?w=1600&q=80',
      ],
      features: ['RTX 4080', 'MiniLED', 'Convertible'],
    },
    {
      title: 'Yamaha U1 Profesyonel Kuyruklu Piyano',
      description:
        'Yamaha U1 upright piyano, parlak siyah. Yeni akortlandı, stüdyo ortamında kullanıldı.',
      category: 'Music',
      condition: 'Excellent',
      price: 285000,
      images: [
        'https://images.unsplash.com/photo-1513883049090-d0b7439799bf?w=1600&q=80',
        'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=1600&q=80',
      ],
      features: ['Professional Upright', 'Black Polish', 'Recent Tuning'],
    },
  ];

  return items.map((item, index) => {
    const ownerConfig = ownerConfigs[index % ownerConfigs.length];
    const jitterLat = ownerConfig.location.latitude + (Math.random() - 0.5) * 0.01;
    const jitterLng = ownerConfig.location.longitude + (Math.random() - 0.5) * 0.01;

    return {
      ...item,
      ownerId: ownerConfig.user.uid,
      ownerName: ownerConfig.user.displayName || ownerConfig.user.email || 'Trader',
      city: ownerConfig.location.city,
      fullAddress: ownerConfig.location.fullAddress,
      latitude: Number(jitterLat.toFixed(6)),
      longitude: Number(jitterLng.toFixed(6)),
      meetupLocation: ownerConfig.location.fullAddress,
      barterCondition: {
        enabled: true,
        lookingFor: ['Premium Electronics', 'Luxury Goods', 'E-Mobility'],
        categories: ['Electronics', 'Luxury', 'Sports'],
        condition: 'Like New',
        maxCashDifferential: 75000,
        notes: 'Yalnızca premium ürünlerle takas düşünülür.',
      },
      shippingAvailable: true,
      localPickupOnly: false,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
      status: 'active',
      viewCount: Math.floor(Math.random() * 140) + 60,
      favoriteCount: Math.floor(Math.random() * 60) + 15,
    };
  });
}


async function seedItems(items) {
  console.log(`📦 ${items.length} ürün ekleniyor...`);
  const createdItems = [];

  for (const item of items) {
    const itemRef = db.collection('items').doc();
    await itemRef.set({ id: itemRef.id, ...item });
    createdItems.push({ id: itemRef.id, ...item });
    console.log(`   • ${item.title} (${item.ownerName})`);
  }

  return createdItems;
}

function buildTrades(users, items) {
  // Kullanıcı sırası: [admin, ikinci, üçüncü]
  const [u0, u1, u2] = users;
  const userItems = {
    [u0.user.uid]: items.filter((item) => item.ownerId === u0.user.uid),
    [u1.user.uid]: items.filter((item) => item.ownerId === u1.user.uid),
    [u2.user.uid]: items.filter((item) => item.ownerId === u2.user.uid),
  };

  return [
    {
      from: u0,
      to: u1,
      offered: userItems[u0.user.uid][0],
      requested: userItems[u1.user.uid][2],
      message: 'Vision Pro yerine Gucci Jackie almak isterim, üstüne nakit de ekleyebilirim.',
      status: 'pending',
    },
    {
      from: u2,
      to: u0,
      offered: userItems[u2.user.uid][1],
      requested: userItems[u0.user.uid][3],
      message: 'Porsche Design saat için Leica Noctilux + 20K teklifim var.',
      status: 'negotiating',
    },
    {
      from: u1,
      to: u2,
      offered: userItems[u1.user.uid][4],
      requested: userItems[u2.user.uid][2],
      message: 'TAG Heuer Glassbox ile Hasselblad X2D takası nasıl olur?',
      status: 'accepted',
    },
    {
      from: u0,
      to: u2,
      offered: userItems[u0.user.uid][5],
      requested: userItems[u2.user.uid][3],
      message: 'Mac Pro seti ile Peloton Bike+’ı takaslayalım, fiyatlar denk.',
      status: 'completed',
      responseMessage: 'Anlaştık, teslimatı cuma günü yapıyoruz.',
    },
    {
      from: u2,
      to: u1,
      offered: userItems[u2.user.uid][4],
      requested: userItems[u1.user.uid][6],
      message: 'DJI Mavic 3 Pro Cine için Peloton + 15K TL teklifim var.',
      status: 'pending',
    },
    {
      from: u1,
      to: u0,
      offered: userItems[u1.user.uid][7],
      requested: userItems[u0.user.uid][2],
      message: 'Beolab 28 çiftini Canyon Ultimate ile değiştirmek istersen haber ver.',
      status: 'cancelled',
      responseMessage: 'Teklifim geçerliliğini yitirdi, başka biri ile anlaşacağım.',
    },
  ];
}

async function seedTrades(trades) {
  console.log('🤝 Trade teklifleri oluşturuluyor...');
  for (const trade of trades) {
    const tradeRef = db.collection('tradeOffers').doc();
    await tradeRef.set({
      id: tradeRef.id,
      fromUserId: trade.from.user.uid,
      toUserId: trade.to.user.uid,
      fromUserName: trade.from.user.displayName || trade.from.user.email,
      toUserName: trade.to.user.displayName || trade.to.user.email,
      offeredItemId: trade.offered.id,
      offeredItemTitle: trade.offered.title,
      offeredItemImages: trade.offered.images,
      requestedItemId: trade.requested.id,
      requestedItemTitle: trade.requested.title,
      requestedItemImages: trade.requested.images,
      message: trade.message,
      status: trade.status,
      responseMessage: trade.responseMessage || null,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    console.log(`   • ${trade.from.user.email} → ${trade.to.user.email} (${trade.status})`);
  }
}

function buildConversationSeeds(users, items) {
  const [u0, u1, u2] = users;
  const userItems = {
    [u0.user.uid]: items.filter((item) => item.ownerId === u0.user.uid),
    [u1.user.uid]: items.filter((item) => item.ownerId === u1.user.uid),
    [u2.user.uid]: items.filter((item) => item.ownerId === u2.user.uid),
  };

  return [
    {
      pair: [u0, u1],
      listingId: userItems[u0.user.uid][0].id,
      messages: [
        {
          sender: u0,
          text: 'Selam! Vision Pro ile ilgili merak ettiğin noktalar varsa anlatayım.',
        },
        {
          sender: u1,
          text: 'Ekran parlaklığı ve kullanım süresi nasıl? RTX makineyle değiştirmeyi düşünüyorum.',
        },
        {
          sender: u0,
          text: 'Batarya 2 saate kadar dayanıyor, cihaz neredeyse sıfır. Cumartesi demo yapabiliriz.',
        },
      ],
    },
    {
      pair: [u0, u2],
      listingId: userItems[u2.user.uid][1].id,
      messages: [
        {
          sender: u2,
          text: 'Rolex Submariner için Leica Noctilux + 30K teklifim var, uygun mu?',
        },
        {
          sender: u0,
          text: 'Saat çok temiz, face-to-face teslim ederim. Nakit farkı biraz artırabilir miyiz?',
        },
        {
          sender: u2,
          text: '35K yapalım, Beşiktaş’ta perşembe buluşalım mı?',
        },
      ],
    },
    {
      pair: [u1, u2],
      listingId: userItems[u1.user.uid][4].id,
      messages: [
        {
          sender: u1,
          text: 'TAG Heuer Glassbox yerine Hasselblad X2D almak istiyorum, üstüne cash ekleyebilirim.',
        },
        {
          sender: u2,
          text: 'X2D için biraz daha yüksek teklif gerekir, aksesuar dahil mi?',
        },
        {
          sender: u1,
          text: 'Evet, ekstra batarya ve CFexpress kart da vereceğim. 45K fark yeter mi?',
        },
      ],
    },
    {
      pair: [u1, u0],
      listingId: userItems[u1.user.uid][6].id,
      messages: [
        {
          sender: u1,
          text: 'Beolab 28 hoparlörleri için salonundaki akustik uygun mu, test etmek isterim.',
        },
        {
          sender: u0,
          text: 'Şu an Sonos Arc kullanıyorum, cumartesi getirip birlikte deneyebiliriz.',
        },
        {
          sender: u1,
          text: 'Süper, 14:00 gibi uğrarım. Canyon bisikleti de getiriyorum.',
        },
      ],
    },
    {
      pair: [u2, u0],
      listingId: userItems[u0.user.uid][5].id,
      messages: [
        {
          sender: u2,
          text: 'Mac Pro setini kısa dönem kiralama seçeneğiyle alabilir miyim?',
        },
        {
          sender: u0,
          text: 'Satış önceliğim ama 2 hafta test için bırakabilirim, depozit talep ederim.',
        },
        {
          sender: u2,
          text: 'Tamamdır, depozit detaylarını DM’den paylaşır mısın?',
        },
      ],
    },
  ];
}

async function seedConversations(conversationSeeds) {
  console.log('💬 Konuşmalar ve mesajlar oluşturuluyor...');

  for (const seed of conversationSeeds) {
    const [userA, userB] = seed.pair;
    const convoRef = db.collection('conversations').doc();

    const lastMessage = seed.messages[seed.messages.length - 1];

    await convoRef.set({
      participants: [userA.user.uid, userB.user.uid],
      listingId: seed.listingId || null,
      lastMessage: lastMessage.text,
      lastMessageSenderId: lastMessage.sender.user.uid,
      lastMessageTime: FieldValue.serverTimestamp(),
      unreadCount: {
        [userA.user.uid]: 0,
        [userB.user.uid]: 0,
      },
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });

    for (const message of seed.messages) {
      const messageRef = db.collection('messages').doc();
      const receiver = message.sender.user.uid === userA.user.uid ? userB : userA;

      await messageRef.set({
        id: messageRef.id,
        conversationId: convoRef.id,
        senderId: message.sender.user.uid,
        senderName: message.sender.user.displayName || message.sender.user.email,
        receiverId: receiver.user.uid,
        text: message.text,
        type: 'text',
        timestamp: FieldValue.serverTimestamp(),
        createdAt: FieldValue.serverTimestamp(),
        isRead: message.sender.user.uid !== receiver.user.uid,
      });
    }

    console.log(`   • ${userA.user.email} <> ${userB.user.email}`);
  }
}

async function updateUserMetrics(users, items, trades) {
  const socialBlueprint = {};

  const baseFollowers = [
    { followersCount: 1820, followingCount: 245, trustScore: 97 },
    { followersCount: 1345, followingCount: 188, trustScore: 93 },
    { followersCount: 980, followingCount: 205, trustScore: 89 },
  ];

  users.forEach((cfg, index) => {
    socialBlueprint[cfg.user.uid] = baseFollowers[index];
  });

  for (const cfg of users) {
    const uid = cfg.user.uid;
    const ownerItems = items.filter((item) => item.ownerId === uid);
    const completedTrades = trades.filter(
      (trade) =>
        trade.status === 'completed' &&
        (trade.from.user.uid === uid || trade.to.user.uid === uid)
    ).length;
    const pendingTrades = trades.filter(
      (trade) =>
        trade.status === 'pending' &&
        (trade.from.user.uid === uid || trade.to.user.uid === uid)
    ).length;

    const socialStats = socialBlueprint[uid] || {
      followersCount: Math.floor(Math.random() * 500) + 200,
      followingCount: Math.floor(Math.random() * 120) + 40,
      trustScore: 85,
    };

    const positiveReviews = Math.max(12, Math.floor(socialStats.followersCount * 0.035));

    await db.collection('users').doc(uid).set(
      {
        stats: {
          completedTrades,
          positiveReviews,
          listingCount: ownerItems.length,
          pendingTrades,
        },
        social: {
          followersCount: socialStats.followersCount,
          followingCount: socialStats.followingCount,
        },
        trustScore: socialStats.trustScore,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
  }
}

async function main() {
  console.log('🚀 Firebase yönetim temizleme & seed işlemi başlıyor...');

  const { googleUsers, nonGoogleUsers } = await listUsers();
  console.log(`   • Google girişli kullanıcı: ${googleUsers.length}`);
  console.log(`   • Diğer kullanıcı: ${nonGoogleUsers.length}`);

  const deletedUids = await deleteNonGoogleUsers(nonGoogleUsers);
  if (deletedUids.length) {
    console.log(`✅ ${deletedUids.length} kullanıcı ve ilişkili verileri silindi.`);
  }

  const refreshed = await listUsers();
  const googleOnly = refreshed.googleUsers;

  const adminEmail = 'turhanhamza@gmail.com';
  const adminUserRecord = googleOnly.find(
    (user) => (user.email || '').toLowerCase() === adminEmail
  );

  if (!adminUserRecord) {
    console.error('❌ turhanhamza@gmail.com kullanıcısı bulunamadı. İşlem sonlandırılıyor.');
    process.exit(1);
  }

  const otherGoogleUsers = googleOnly.filter((user) => user.uid !== adminUserRecord.uid);
  if (otherGoogleUsers.length < 2) {
    console.error('❌ En az 3 Google kullanıcısı gereklidir. Lütfen ek Google hesabı oluşturun.');
    process.exit(1);
  }

  const activeUsers = [
    { user: adminUserRecord },
    { user: otherGoogleUsers[0] },
    { user: otherGoogleUsers[1] },
  ];

  await promoteToAdmin(adminUserRecord);
  console.log('✅ turhanhamza@gmail.com süper admin olarak atandı.');

  const ownersWithLocations = buildLocationPresets(activeUsers);
  for (const config of ownersWithLocations) {
    await ensureUserProfile(config.user, config.location);
  }
  console.log('✅ Kullanıcı profilleri güncellendi (konum + profil bilgileri).');

  await purgeInactiveUserDocs(ownersWithLocations.map((cfg) => cfg.user.uid));

  await deleteCollections([
    'items',
    'tradeOffers',
    'conversations',
    'messages',
    'favorites',
    'ratings',
    'moderationRequests',
  ]);

  const items = buildItemPayloads(ownersWithLocations);
  const createdItems = await seedItems(items);

  const trades = buildTrades(ownersWithLocations, createdItems);
  await seedTrades(trades);

  const conversationSeeds = buildConversationSeeds(ownersWithLocations, createdItems);
  await seedConversations(conversationSeeds);

  await updateUserMetrics(ownersWithLocations, createdItems, trades);

  console.log('\n🎯 İşlem tamamlandı!');
  console.log(`   • Aktif kullanıcılar: ${ownersWithLocations.map((cfg) => cfg.user.email).join(', ')}`);
  console.log(`   • Ürün sayısı: ${createdItems.length}`);
  console.log(`   • Trade sayısı: ${trades.length}`);
  console.log(`   • Konuşma sayısı: ${conversationSeeds.length}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error('❌ İşlem sırasında hata oluştu:', error);
    process.exit(1);
  });
