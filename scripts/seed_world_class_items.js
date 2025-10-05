const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin
const serviceAccount = require('../serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Turkish cities
const CITIES = [
  'İstanbul', 'Ankara', 'İzmir', 'Bursa', 'Antalya',
  'Adana', 'Konya', 'Gaziantep', 'Kayseri', 'Eskişehir',
  'Mersin', 'Diyarbakır', 'Samsun', 'Denizli', 'Trabzon'
];

// Test user
const TEST_USER = {
  id: 'test_user_world_class',
  name: 'Barter Qween Test User',
  email: 'test@barterqween.com',
  photoUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=test'
};

// ========================================
// WORLD-CLASS ITEMS DATA (50 Items)
// ========================================

const WORLD_CLASS_ITEMS = [
  // ===== FASHION ITEMS =====
  {
    title: 'Nike Air Jordan 1 High "Chicago" EU 42',
    description: 'Koleksiyonluk Nike Air Jordan 1 High Chicago colorway. Sadece 2-3 kez giyildi, neredeyse kusursuz durumda. Orijinal kutusu, ekstra kırmızı ve beyaz bağcıklar dahil. 2015 yılında Nike Store\'dan alındı.',
    category: 'Shoes',
    subcategory: "Men's Sneakers",
    
    // Product ID
    brand: 'Nike',
    styleName: 'Air Jordan 1 High',
    modelNumber: '555088-101',
    
    // Size & Fit
    size: '42',
    sizeSystem: 'EU',
    gender: 'Unisex',
    fitType: 'Regular',
    measurements: {
      insoleLength: '28cm',
      width: '10cm'
    },
    
    // Material
    material: 'Genuine Leather',
    materials: ['Leather upper', 'Rubber sole'],
    careInstructions: 'Clean with damp cloth, air dry',
    
    // Condition
    condition: 'Like New',
    conditionDescription: 'Sadece 2-3 kez giyildi. Küçük bir kreaslaşma toe box\'ta var (normal), başka kusur yok.',
    defects: ['Minor creasing on toe box'],
    conditionRating: 9,
    wearLevel: 'Worn 2-3 times',
    
    // Purchase History
    originalPrice: 7000,
    originalCurrency: 'TRY',
    purchaseDate: new Date('2015-08-15'),
    purchaseLocation: 'Nike Store Istanbul',
    hasReceipt: true,
    
    // Pricing
    price: 4500,
    discountPercentage: 36,
    firmPrice: false,
    lowestAcceptedOffer: 4000,
    freeShipping: true,
    
    // Shipping
    itemWeight: 1.2,
    packageDimensions: { length: 35, width: 25, height: 15 },
    packageSize: 'Medium',
    shippingAvailable: true,
    localPickupOnly: false,
    estimatedShippingDays: 3,
    meetupLocation: 'Public place, metro station',
    preferredMeetupPoints: ['Kadıköy Metro', 'Starbucks Kadıköy'],
    
    // Features
    features: ['Iconic Chicago colorway', 'Premium leather', 'Air cushioning'],
    accessories: ['Original box', 'Red laces', 'White laces', 'Hangtag'],
    functionalStatus: 'Perfect condition',
    
    // Lifestyle
    season: 'All Season',
    occasion: 'Casual',
    style: 'Vintage Sneaker',
    era: '2015',
    aesthetics: ['Streetwear', 'Retro'],
    
    // Seller Environment
    petFreeHome: true,
    smokeFreeHome: true,
    storageCondition: 'Climate controlled',
    
    // Policies
    returnsAccepted: true,
    returnWindowDays: 7,
    returnPolicy: 'Returns accepted within 7 days if not as described',
    
    // SEO
    tags: ['nike', 'jordan', 'sneakers', 'chicago', 'retro', 'basketball'],
    seoKeywords: ['air jordan 1', 'retro sneakers', 'nike chicago', 'collectible shoes'],
    hashtags: ['#nike', '#jordan', '#sneakers', '#streetwear'],
    
    // Sustainability
    isSecondHand: true,
    sustainabilityScore: 'Saves 2.5kg CO2',
    sustainabilityBadges: ['Circular Fashion'],
    
    images: [
      'https://images.unsplash.com/photo-1542291026-7eec264c27ff',
      'https://images.unsplash.com/photo-1605348532760-6753d2c43329',
      'https://images.unsplash.com/photo-1552346154-21d32810aba3'
    ],
    tradePreference: 'Adidas Yeezy, Nike Dunk, Off-White Nike',
  },

  {
    title: 'Zara Kadın Deri Ceket - Siyah - M',
    description: 'Zara\'dan alınmış %100 hakiki deri ceket. Sadece bir sezon giyildi, mükemmel durumda. Klasik siyah renk, her kombine uyum sağlar.',
    category: "Women's Fashion",
    subcategory: 'Leather Jackets',
    
    brand: 'Zara',
    styleName: 'Classic Leather Biker Jacket',
    
    size: 'M',
    sizeSystem: 'EU',
    gender: 'Women',
    fitType: 'Regular',
    measurements: {
      shoulders: '42cm',
      chest: '98cm',
      length: '58cm',
      sleeves: '62cm'
    },
    
    material: '100% Genuine Leather',
    careInstructions: 'Professional leather cleaning only',
    
    condition: 'Like New',
    conditionDescription: 'Bir sezon giyildi, hiçbir kusur yok',
    conditionRating: 9,
    wearLevel: 'Worn one season',
    
    originalPrice: 1800,
    originalCurrency: 'TRY',
    purchaseDate: new Date('2023-09-10'),
    purchaseLocation: 'Zara Istanbul',
    hasReceipt: false,
    
    price: 1200,
    discountPercentage: 33,
    firmPrice: false,
    lowestAcceptedOffer: 1000,
    freeShipping: false,
    shippingCost: 50,
    
    itemWeight: 1.5,
    packageDimensions: { length: 40, width: 35, height: 10 },
    packageSize: 'Medium',
    shippingAvailable: true,
    localPickupOnly: false,
    estimatedShippingDays: 5,
    
    features: ['Zipper closure', 'Zippered pockets', 'Belt detail'],
    functionalStatus: 'Perfect condition',
    
    season: 'Autumn/Winter',
    occasion: 'Casual',
    style: 'Classic',
    targetAudience: 'Young Adults',
    
    petFreeHome: true,
    smokeFreeHome: true,
    
    returnsAccepted: true,
    returnWindowDays: 3,
    
    tags: ['zara', 'leather jacket', 'womens fashion', 'black', 'biker jacket'],
    seoKeywords: ['zara leather jacket', 'womens biker jacket', 'genuine leather'],
    hashtags: ['#zara', '#leatherjacket', '#fashion'],
    
    isSecondHand: true,
    sustainabilityScore: 'Saves 15kg CO2',
    
    images: [
      'https://images.unsplash.com/photo-1551028719-00167b16eac5',
      'https://images.unsplash.com/photo-1520975661595-6453be3f7070'
    ],
    tradePreference: 'Designer bags, boots, winter coat',
  },

  // ===== ELECTRONICS =====
  {
    title: 'iPhone 13 Pro Max 256GB Sierra Blue Unlocked',
    description: 'Mükemmel durumdaki iPhone 13 Pro Max. Sadece 6 ay kullanıldı, batarya sağlığı %98. Tüm aksesuarları mevcut, AppleCare+ Mart 2025\'e kadar devam ediyor.',
    category: 'Electronics',
    subcategory: 'Smartphones',
    
    brand: 'Apple',
    styleName: 'iPhone 13 Pro Max',
    modelNumber: 'A2484',
    serialNumber: 'DMPRXXXXXXX',
    
    condition: 'Like New',
    conditionDescription: 'Hiç düşürülmedi, ekran koruyucu ile kullanıldı. Batarya sağlığı %98.',
    conditionRating: 10,
    wearLevel: 'Used for 6 months',
    
    originalPrice: 35000,
    originalCurrency: 'TRY',
    purchaseDate: new Date('2023-06-15'),
    purchaseLocation: 'Apple Store Zorlu',
    hasReceipt: true,
    
    price: 25000,
    discountPercentage: 29,
    firmPrice: false,
    lowestAcceptedOffer: 24000,
    freeShipping: true,
    
    itemWeight: 0.5,
    packageDimensions: { length: 20, width: 15, height: 5 },
    packageSize: 'Small',
    shippingAvailable: true,
    localPickupOnly: false,
    estimatedShippingDays: 2,
    
    features: ['5G', 'A15 Bionic chip', 'ProMotion display', 'Triple camera'],
    accessories: ['Original box', 'USB-C to Lightning cable', 'SIM ejector', 'Case'],
    warranty: 'AppleCare+ until March 2025',
    batteryHealth: '98%',
    functionalStatus: 'Fully working',
    
    specifications: {
      storage: '256GB',
      color: 'Sierra Blue',
      carrier: 'Unlocked',
      ios: '17.2',
      screenSize: '6.7 inch'
    },
    
    petFreeHome: true,
    smokeFreeHome: true,
    
    returnsAccepted: true,
    returnWindowDays: 3,
    returnPolicy: 'Returns accepted within 3 days, must be in same condition',
    
    tags: ['apple', 'iphone', 'smartphone', '13 pro max', 'unlocked'],
    seoKeywords: ['iphone 13 pro max', 'apple phone', 'sierra blue'],
    hashtags: ['#iphone', '#apple', '#smartphone'],
    
    isSecondHand: true,
    isEcoFriendly: true,
    
    images: [
      'https://images.unsplash.com/photo-1632661674359-e4f45ff1e6e6',
      'https://images.unsplash.com/photo-1591337676887-a217a6970a8a'
    ],
    tradePreference: 'MacBook Air M1, iPad Pro, Apple Watch Ultra',
  },

  {
    title: 'Sony WH-1000XM5 Noise Cancelling Kulaklık - Siyah',
    description: 'Piyasanın en iyi noise cancelling kulaklığı. Az kullanılmış, orijinal kutusunda. Tüm aksesuarlar eksiksiz.',
    category: 'Electronics',
    subcategory: 'Headphones & Earbuds',
    
    brand: 'Sony',
    styleName: 'WH-1000XM5',
    modelNumber: 'WH1000XM5/B',
    
    condition: 'Like New',
    conditionDescription: 'Hafif kullanım izleri var, kulaklık pedleri mükemmel',
    conditionRating: 9,
    wearLevel: 'Lightly used',
    
    originalPrice: 12000,
    purchaseDate: new Date('2023-11-20'),
    purchaseLocation: 'Media Markt',
    hasReceipt: true,
    
    price: 8500,
    discountPercentage: 29,
    firmPrice: false,
    lowestAcceptedOffer: 8000,
    freeShipping: true,
    
    itemWeight: 0.6,
    packageSize: 'Medium',
    shippingAvailable: true,
    estimatedShippingDays: 3,
    
    features: ['Industry-leading ANC', '30hr battery', 'Bluetooth 5.2', 'Touch controls'],
    accessories: ['Original box', 'USB-C cable', 'Audio cable', 'Carrying case'],
    warranty: '1 year warranty remaining',
    batteryHealth: '100%',
    functionalStatus: 'Fully working',
    
    specifications: {
      color: 'Black',
      connectivity: 'Bluetooth 5.2',
      batteryLife: '30 hours'
    },
    
    petFreeHome: true,
    smokeFreeHome: true,
    
    returnsAccepted: true,
    returnWindowDays: 7,
    
    tags: ['sony', 'headphones', 'noise cancelling', 'wireless', 'bluetooth'],
    seoKeywords: ['sony wh-1000xm5', 'anc headphones', 'premium audio'],
    hashtags: ['#sony', '#headphones', '#anc'],
    
    isSecondHand: true,
    
    images: [
      'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb',
      'https://images.unsplash.com/photo-1484704849700-f032a568e944'
    ],
    tradePreference: 'Bose QC45, AirPods Max, Audio equipment',
  },

  // ===== HOME & LIVING =====
  {
    title: 'IKEA HEMNES Kitaplık - Beyaz - 2 Adet',
    description: 'IKEA HEMNES kitaplık, çok az kullanılmış, neredeyse yeni gibi. Beyaz renk, her dekorasyona uygun. 2 adet bir arada satılıyor.',
    category: 'Home & Living',
    subcategory: 'Shelves & Storage',
    
    brand: 'IKEA',
    styleName: 'HEMNES Bookcase',
    
    condition: 'Good',
    conditionDescription: 'Hafif kullanım izleri var ama çok iyi durumda',
    conditionRating: 8,
    wearLevel: 'Lightly used',
    
    originalPrice: 5000,
    purchaseDate: new Date('2022-05-10'),
    purchaseLocation: 'IKEA Istanbul',
    
    price: 3500,
    discountPercentage: 30,
    firmPrice: false,
    lowestAcceptedOffer: 3000,
    freeShipping: false,
    shippingCost: 150,
    
    itemWeight: 45,
    packageDimensions: { length: 200, width: 85, height: 35 },
    packageSize: 'XL',
    shippingAvailable: false,
    localPickupOnly: true,
    
    meetupLocation: 'Kadıköy - can help with transport',
    preferredMeetupPoints: ['Kadıköy', 'Moda'],
    
    features: ['Solid wood', 'Adjustable shelves', 'White finish'],
    
    measurements: {
      height: '197cm',
      width: '82cm',
      depth: '30cm'
    },
    
    material: 'Solid Pine Wood',
    
    season: 'All Season',
    occasion: 'Everyday',
    
    petFreeHome: true,
    smokeFreeHome: true,
    
    tags: ['ikea', 'bookcase', 'furniture', 'storage', 'hemnes'],
    seoKeywords: ['ikea hemnes', 'white bookcase', 'home storage'],
    
    isSecondHand: true,
    sustainabilityScore: 'Saves 25kg CO2',
    
    images: [
      'https://images.unsplash.com/photo-1594620302200-9a762244a156',
      'https://images.unsplash.com/photo-1595428774223-ef52624120d2'
    ],
    tradePreference: 'Desk, office chair, lighting',
  },

  // ===== KIDS & BABY =====
  {
    title: 'LEGO Star Wars Millennium Falcon 75192',
    description: 'Koleksiyonluk LEGO Millennium Falcon seti. 7541 parça, kutusu açılmamış sealed durumda. 2017 yılı limited edition.',
    category: 'Kids & Baby',
    subcategory: 'Building Blocks (LEGO, etc.)',
    
    brand: 'LEGO',
    styleName: 'Star Wars Millennium Falcon',
    modelNumber: '75192',
    upc: '673419282018',
    
    condition: 'Brand New',
    conditionDescription: 'Kutusun açılmamış, sealed durumda',
    conditionRating: 10,
    wearLevel: 'Never used',
    
    originalPrice: 8000,
    purchaseDate: new Date('2017-09-15'),
    purchaseLocation: 'LEGO Store',
    hasReceipt: true,
    
    price: 6500,
    discountPercentage: 19,
    firmPrice: true,
    freeShipping: false,
    shippingCost: 80,
    
    itemWeight: 15,
    packageDimensions: { length: 60, width: 50, height: 25 },
    packageSize: 'Large',
    shippingAvailable: true,
    estimatedShippingDays: 5,
    
    features: ['7541 pieces', 'Detailed interior', 'Minifigures included'],
    ageGroup: 'Adult',
    targetAudience: 'Collectors',
    
    specifications: {
      pieceCount: '7541',
      ageRange: '16+',
      releaseYear: '2017'
    },
    
    petFreeHome: true,
    smokeFreeHome: true,
    storageCondition: 'Climate controlled storage',
    
    returnsAccepted: false,
    
    tags: ['lego', 'star wars', 'millennium falcon', 'collectible', 'sealed'],
    seoKeywords: ['lego star wars', 'millennium falcon 75192', 'lego collectible'],
    hashtags: ['#lego', '#starwars', '#collectible'],
    
    vintageCollectibles: true,
    
    images: [
      'https://images.unsplash.com/photo-1587912781852-74b8e1428c17',
      'https://images.unsplash.com/photo-1566793067651-c4edeeca168b'
    ],
    tradePreference: 'Other LEGO sets, collectibles',
  },

  // ===== SPORTS =====
  {
    title: 'Trek Mountain Bike - 26" - Siyah/Mavi',
    description: 'Trek marka dağ bisikleti, az kullanılmış çok iyi durumda. Son bakımı yapıldı, hemen kullanıma hazır.',
    category: 'Sports & Outdoors',
    subcategory: 'Cycling',
    
    brand: 'Trek',
    
    condition: 'Good',
    conditionDescription: 'Hafif çizikler var ama mekanik olarak mükemmel',
    conditionRating: 7,
    wearLevel: 'Used regularly',
    
    originalPrice: 12000,
    purchaseDate: new Date('2021-04-20'),
    
    price: 8500,
    discountPercentage: 29,
    firmPrice: false,
    lowestAcceptedOffer: 8000,
    
    shippingAvailable: false,
    localPickupOnly: true,
    meetupLocation: 'Kadıköy, public area',
    
    features: ['26 inch wheels', 'Disc brakes', 'Shimano gears', 'Recently serviced'],
    functionalStatus: 'Fully working',
    
    measurements: {
      wheelSize: '26 inch',
      frameSize: 'M'
    },
    
    season: 'All Season',
    occasion: 'Sport',
    
    petFreeHome: true,
    
    tags: ['trek', 'mountain bike', 'bicycle', 'cycling', 'sports'],
    seoKeywords: ['trek mountain bike', 'dağ bisikleti', 'bicycle'],
    
    isSecondHand: true,
    sustainabilityScore: 'Saves 50kg CO2',
    
    images: [
      'https://images.unsplash.com/photo-1576435728678-68d0fbf94e91',
      'https://images.unsplash.com/photo-1511994298241-608e28f14fde'
    ],
    tradePreference: 'Gym equipment, sports gear',
  },

  // Add more items to reach 50...
  // (For brevity, showing representative samples)
];

// ========================================
// SEED FUNCTION
// ========================================

async function seedWorldClassItems() {
  console.log('🚀 Starting world-class items seeding...\n');
  
  const batch = db.batch();
  let seededCount = 0;
  let errorCount = 0;
  
  for (const itemData of WORLD_CLASS_ITEMS) {
    try {
      // Generate item ID
      const itemRef = db.collection('items').doc();
      
      // Prepare complete item data
      const completeItem = {
        ...itemData,
        ownerId: TEST_USER.id,
        ownerName: TEST_USER.name,
        ownerPhotoUrl: TEST_USER.photoUrl,
        status: 'active',
        moderationStatus: 'approved',
        viewCount: Math.floor(Math.random() * 200) + 10,
        favoriteCount: Math.floor(Math.random() * 50),
        shareCount: Math.floor(Math.random() * 20),
        inquiryCount: Math.floor(Math.random() * 15),
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        
        // Random city
        city: CITIES[Math.floor(Math.random() * CITIES.length)],
        location: CITIES[Math.floor(Math.random() * CITIES.length)],
        
        // Seller info
        sellerResponseTime: 'Usually responds within 1 hour',
        sellerRating: 4.8,
        sellerTotalSales: Math.floor(Math.random() * 50) + 5,
        fastShipping: Math.random() > 0.5,
        topRatedSeller: Math.random() > 0.7,
      };
      
      batch.set(itemRef, completeItem);
      seededCount++;
      console.log(`✅ [${seededCount}/${WORLD_CLASS_ITEMS.length}] ${itemData.title}`);
      
    } catch (error) {
      errorCount++;
      console.error(`❌ Error seeding ${itemData.title}:`, error.message);
    }
  }
  
  // Commit batch
  console.log('\n📤 Committing batch to Firestore...');
  await batch.commit();
  
  console.log('\n' + '='.repeat(60));
  console.log('✨ SEEDING COMPLETE!');
  console.log('='.repeat(60));
  console.log(`✅ Successfully seeded: ${seededCount} items`);
  console.log(`❌ Errors: ${errorCount} items`);
  console.log(`📊 Total items in database: ${seededCount}`);
  console.log('='.repeat(60) + '\n');
}

// Run seeding
seedWorldClassItems()
  .then(() => {
    console.log('✅ Seeding script completed successfully!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Seeding script failed:', error);
    process.exit(1);
  });
