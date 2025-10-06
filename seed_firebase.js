const admin = require('firebase-admin');
const fs = require('fs');

// Initialize Firebase Admin
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: 'bogazici-barter.appspot.com'
});

const db = admin.firestore();
const auth = admin.auth();
const bucket = admin.storage().bucket();

// Test users data with barter conditions
const users = [
  {
    email: 'alice.johnson@example.com',
    password: 'Test123!',
    displayName: 'Alice Johnson',
    photoUrl: 'https://i.pravatar.cc/300?img=1',
    phoneNumber: null,
    bio: 'Tech enthusiast and gadget lover. Always looking for the latest electronics to trade!',
    location: 'Istanbul, Turkey'
  },
  {
    email: 'bob.smith@example.com',
    password: 'Test123!',
    displayName: 'Bob Smith',
    photoUrl: 'https://i.pravatar.cc/300?img=12',
    phoneNumber: null,
    bio: 'Book collector and reader. Love trading books and discovering new titles.',
    location: 'Istanbul, Turkey'
  },
  {
    email: 'carol.white@example.com',
    password: 'Test123!',
    displayName: 'Carol White',
    photoUrl: 'https://i.pravatar.cc/300?img=5',
    phoneNumber: null,
    bio: 'Fashion lover and trendsetter. Trading clothes and accessories is my passion!',
    location: 'Istanbul, Turkey'
  },
  {
    email: 'david.brown@example.com',
    password: 'Test123!',
    displayName: 'David Brown',
    photoUrl: 'https://i.pravatar.cc/300?img=13',
    phoneNumber: null,
    bio: 'Sports equipment collector. Always ready to trade sports gear and equipment.',
    location: 'Istanbul, Turkey'
  },
  {
    email: 'emma.davis@example.com',
    password: 'Test123!',
    displayName: 'Emma Davis',
    photoUrl: 'https://i.pravatar.cc/300?img=9',
    phoneNumber: null,
    bio: 'Home decor enthusiast. Love trading furniture and home accessories.',
    location: 'Istanbul, Turkey'
  },
  {
    email: 'frank.miller@example.com',
    password: 'Test123!',
    displayName: 'Frank Miller',
    photoUrl: 'https://i.pravatar.cc/300?img=15',
    phoneNumber: null,
    bio: 'Vintage collector and antique dealer. Love finding treasures!',
    location: 'Ankara, Turkey'
  },
  {
    email: 'grace.lee@example.com',
    password: 'Test123!',
    displayName: 'Grace Lee',
    photoUrl: 'https://i.pravatar.cc/300?img=20',
    phoneNumber: null,
    bio: 'Art lover and painter. Always looking for art supplies and books.',
    location: 'Izmir, Turkey'
  },
  {
    email: 'henry.wilson@example.com',
    password: 'Test123!',
    displayName: 'Henry Wilson',
    photoUrl: 'https://i.pravatar.cc/300?img=33',
    phoneNumber: null,
    bio: 'Gaming enthusiast and console collector. Trade games all day!',
    location: 'Bursa, Turkey'
  },
  {
    email: 'isabel.garcia@example.com',
    password: 'Test123!',
    displayName: 'Isabel Garcia',
    photoUrl: 'https://i.pravatar.cc/300?img=44',
    phoneNumber: null,
    bio: 'Music lover and vinyl collector. Always searching for rare records.',
    location: 'Antalya, Turkey'
  },
  {
    email: 'jack.taylor@example.com',
    password: 'Test123!',
    displayName: 'Jack Taylor',
    photoUrl: 'https://i.pravatar.cc/300?img=51',
    phoneNumber: null,
    bio: 'Outdoor adventurer and camping gear enthusiast.',
    location: 'Istanbul, Turkey'
  }
];

// High-quality items data with realistic descriptions
const items = [
  {
    title: 'iPhone 15 Pro Max - 512GB',
    description: 'Brand new iPhone 15 Pro Max with 512GB storage. Natural Titanium color. Includes original box, charger, and screen protector. Still sealed in original packaging. Perfect for tech enthusiasts!',
    category: 'Electronics',
    condition: 'Brand New',
    city: 'Besiktas, Istanbul',
    images: [
      'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=800&q=80',
      'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=800&q=80'
    ],
    status: 'active',
    price: 45000,
    barterCondition: {
      enabled: true,
      lookingFor: ['MacBook Pro', 'iPad Pro', 'Samsung Galaxy S24'],
      categories: ['Electronics'],
      condition: 'Brand New',
      maxCashDifferential: 10000,
      meetupLocation: 'Besiktas, Istanbul',
      notes: 'Looking for premium electronics in similar condition'
    }
  },
  {
    title: 'MacBook Pro M3 - 16 inch',
    description: 'Latest MacBook Pro with M3 chip, 16GB RAM, 512GB SSD. Space Gray color. Includes original charger and carrying case. Perfect for professionals and creators.',
    category: 'Electronics',
    condition: 'Like New',
    city: 'Sisli, Istanbul',
    images: [
      'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&q=80',
      'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&q=80'
    ],
    status: 'active',
    price: 55000,
    barterCondition: {
      enabled: true,
      lookingFor: ['iPhone 15 Pro', 'iPad Pro', 'Gaming PC'],
      categories: ['Electronics'],
      condition: 'Like New',
      maxCashDifferential: 15000,
      meetupLocation: 'Sisli, Istanbul',
      notes: 'Looking for high-end electronics or cash'
    }
  },
  {
    title: 'Harry Potter Complete Book Set',
    description: 'Complete Harry Potter series (7 books) in hardcover. All books are in excellent condition with minimal wear. Perfect for any Potter fan or collector. English editions with original covers.',
    category: 'Books',
    condition: 'Good',
    city: 'Kadikoy, Istanbul',
    images: [
      'https://images.unsplash.com/photo-1621351183012-e2f9972dd9bf?w=800',
      'https://images.unsplash.com/photo-1618365908648-e71bd5716cba?w=800'
    ],
    status: 'active'
  },
  {
    title: 'Vintage Leather Jacket',
    description: 'Classic brown leather jacket, size M. Genuine leather with a timeless vintage look. Well-maintained with no tears or major scratches. Perfect for autumn and spring weather.',
    category: 'Fashion',
    condition: 'Good',
    city: 'Sisli, Istanbul',
    images: [
      'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800',
      'https://images.unsplash.com/photo-1520975867597-0af37a22e31e?w=800'
    ],
    status: 'active'
  },
  {
    title: 'Professional Road Bike',
    description: 'High-quality road bike, 21-speed Shimano gears. Carbon fiber frame, lightweight and fast. Recently serviced with new tires and brake pads. Great for serious cyclists or commuters.',
    category: 'Sports',
    condition: 'Good',
    city: 'Maltepe, Istanbul',
    images: [
      'https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=800',
      'https://images.unsplash.com/photo-1571333250630-f0230c320b6d?w=800'
    ],
    status: 'active'
  },
  {
    title: 'Modern Coffee Table',
    description: 'Scandinavian-style coffee table made of solid oak wood. Minimalist design with clean lines. 120cm x 60cm. Perfect condition, no scratches or stains. Matches any modern living room.',
    category: 'Home',
    condition: 'Like New',
    city: 'Uskudar, Istanbul',
    images: [
      'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=800',
      'https://images.unsplash.com/photo-1533090481720-856c6e3c1fdc?w=800'
    ],
    status: 'active'
  },
  {
    title: 'Sony WH-1000XM4 Headphones',
    description: 'Premium noise-cancelling wireless headphones. Black color, barely used. Comes with original case, cables, and adapter. Battery lasts 30+ hours. Amazing sound quality for music lovers!',
    category: 'Electronics',
    condition: 'Like New',
    city: 'Beyoglu, Istanbul',
    images: [
      'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?w=800',
      'https://images.unsplash.com/photo-1545127398-14699f92334b?w=800'
    ],
    status: 'active',
    price: 8000,
    barterCondition: {
      enabled: true,
      lookingFor: ['AirPods Pro', 'iPhone', 'Smart Watch'],
      categories: ['Electronics'],
      condition: 'Like New',
      maxCashDifferential: 2000,
      meetupLocation: 'Beyoglu, Istanbul',
      notes: 'Open to electronics trades'
    }
  },
  {
    title: 'LEGO Architecture Set - Taj Mahal',
    description: 'Unopened LEGO Architecture Taj Mahal set (5923 pieces). Perfect gift for LEGO enthusiasts or architecture lovers. Box is in mint condition. A collector\'s dream!',
    category: 'Toys',
    condition: 'Brand New',
    city: 'Bakirkoy, Istanbul',
    images: [
      'https://images.unsplash.com/photo-1587654780291-39c9404d746b?w=800',
      'https://images.unsplash.com/photo-1558060370-d644479cb6f7?w=800'
    ],
    status: 'active'
  },
  {
    title: 'The Lord of the Rings Trilogy',
    description: 'Special collector\'s edition of The Lord of the Rings trilogy. Leather-bound books with gold foil lettering. Includes maps and illustrations. A must-have for Tolkien fans!',
    category: 'Books',
    condition: 'Like New',
    city: 'Sariyer, Istanbul',
    images: [
      'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=800&q=80',
      'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=800&q=80'
    ],
    status: 'active',
    price: 1500
  },
  {
    title: 'iPad Pro 12.9" M2 - 256GB',
    description: 'Latest iPad Pro with M2 chip, 12.9-inch Liquid Retina XDR display. Space Gray color. Includes Apple Pencil 2nd generation and Magic Keyboard. Perfect for professionals.',
    category: 'Electronics',
    condition: 'Like New',
    city: 'Kadikoy, Istanbul',
    images: [
      'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=800&q=80',
      'https://images.unsplash.com/photo-1561154464-82e9adf32764?w=800&q=80'
    ],
    status: 'active',
    price: 35000,
    barterCondition: {
      enabled: true,
      lookingFor: ['MacBook Air', 'iPhone 15', 'Samsung Tab'],
      categories: ['Electronics'],
      condition: 'Like New',
      maxCashDifferential: 8000,
      meetupLocation: 'Kadikoy, Istanbul',
      notes: 'Looking for premium electronics'
    }
  },
  {
    title: 'Samsung Galaxy S24 Ultra - 512GB',
    description: 'Brand new Samsung Galaxy S24 Ultra with 512GB storage. Titanium Black color. Includes original box, charger, and screen protector. Latest flagship with S Pen.',
    category: 'Electronics',
    condition: 'Brand New',
    city: 'Maltepe, Istanbul',
    images: [
      'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=800&q=80',
      'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=800&q=80'
    ],
    status: 'active',
    price: 42000,
    barterCondition: {
      enabled: true,
      lookingFor: ['iPhone 15 Pro', 'MacBook Air', 'iPad Pro'],
      categories: ['Electronics'],
      condition: 'Brand New',
      maxCashDifferential: 10000,
      meetupLocation: 'Maltepe, Istanbul',
      notes: 'Looking for Apple products or cash'
    }
  },
  {
    title: 'AirPods Pro 2nd Generation',
    description: 'Latest AirPods Pro with USB-C charging case. Active noise cancellation and spatial audio. Includes original box and all accessories. Perfect sound quality.',
    category: 'Electronics',
    condition: 'Like New',
    city: 'Beyoglu, Istanbul',
    images: [
      'https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1?w=800&q=80',
      'https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1?w=800&q=80'
    ],
    status: 'active',
    price: 8500,
    barterCondition: {
      enabled: true,
      lookingFor: ['Sony Headphones', 'Smart Watch', 'iPhone Accessories'],
      categories: ['Electronics'],
      condition: 'Like New',
      maxCashDifferential: 2000,
      meetupLocation: 'Beyoglu, Istanbul',
      notes: 'Open to electronics trades'
    }
  },
  {
    title: 'Apple Watch Series 9 - 45mm',
    description: 'Latest Apple Watch Series 9 with GPS + Cellular. Midnight color. Includes original band and charger. Health monitoring and fitness tracking features.',
    category: 'Electronics',
    condition: 'Like New',
    city: 'Uskudar, Istanbul',
    images: [
      'https://images.unsplash.com/photo-1434493789847-2f02dc6ca35d?w=800&q=80',
      'https://images.unsplash.com/photo-1434493789847-2f02dc6ca35d?w=800&q=80'
    ],
    status: 'active',
    price: 18000,
    barterCondition: {
      enabled: true,
      lookingFor: ['iPhone', 'iPad', 'MacBook'],
      categories: ['Electronics'],
      condition: 'Like New',
      maxCashDifferential: 5000,
      meetupLocation: 'Uskudar, Istanbul',
      notes: 'Looking for Apple ecosystem products'
    }
  },
  {
    title: 'Designer Handbag - Michael Kors',
    description: 'Authentic Michael Kors handbag in tan color. Used but well-maintained. All zippers and clasps work perfectly. Comes with authenticity card and dust bag. Perfect for daily use.',
    category: 'Fashion',
    condition: 'Good',
    city: 'Levent, Istanbul',
    images: [
      'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=800',
      'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=800'
    ],
    status: 'active'
  },
  {
    title: 'Yoga Mat & Block Set',
    description: 'Premium yoga mat (6mm thick) with yoga block and carrying strap. Non-slip surface, eco-friendly material. Used for 3 months, in excellent condition. Perfect for home workouts or yoga classes.',
    category: 'Sports',
    condition: 'Like New',
    city: 'Kadikoy, Istanbul',
    images: [
      'https://images.unsplash.com/photo-1601925260368-ae2f83cf8b7f?w=800',
      'https://images.unsplash.com/photo-1599901860904-17e6ed7083a0?w=800'
    ],
    status: 'active'
  }
];

async function createUsers() {
  console.log('🔑 Creating users...');
  const userIds = [];

  for (const userData of users) {
    try {
      // Create user in Firebase Auth
      const userRecord = await auth.createUser({
        email: userData.email,
        password: userData.password,
        displayName: userData.displayName,
        photoURL: userData.photoUrl,
      });

      console.log(`✅ Created user: ${userData.displayName} (${userRecord.uid})`);

      // Add user profile to Firestore
      await db.collection('users').doc(userRecord.uid).set({
        uid: userRecord.uid,
        email: userData.email,
        displayName: userData.displayName,
        photoUrl: userData.photoUrl,
        phoneNumber: userData.phoneNumber,
        bio: userData.bio,
        location: userData.location,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      userIds.push({ uid: userRecord.uid, name: userData.displayName });
    } catch (error) {
      if (error.code === 'auth/email-already-exists') {
        // Get existing user
        const existingUser = await auth.getUserByEmail(userData.email);
        console.log(`⚠️  User already exists: ${userData.displayName}`);
        userIds.push({ uid: existingUser.uid, name: userData.displayName });
      } else {
        console.error(`❌ Error creating user ${userData.displayName}:`, error.message);
      }
    }
  }

  return userIds;
}

async function createItems(userIds) {
  console.log('\n📦 Creating items...');
  const itemIds = [];

  for (let i = 0; i < items.length; i++) {
    const item = items[i];
    const owner = userIds[i % userIds.length];

    try {
      const itemRef = db.collection('items').doc();
      const itemData = {
        id: itemRef.id,
        title: item.title,
        description: item.description,
        category: item.category,
        images: item.images,
        condition: item.condition,
        ownerId: owner.uid,
        ownerName: owner.name,
        city: item.city,
        status: item.status,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        viewCount: Math.floor(Math.random() * 50),
        favoriteCount: Math.floor(Math.random() * 20),
      };

      await itemRef.set(itemData);
      console.log(`✅ Created item: ${item.title} (Owner: ${owner.name})`);
      
      itemIds.push({
        id: itemRef.id,
        title: item.title,
        ownerId: owner.uid,
        ownerName: owner.name,
        images: item.images
      });
    } catch (error) {
      console.error(`❌ Error creating item ${item.title}:`, error.message);
    }
  }

  return itemIds;
}

async function createTradeOffers(userIds, itemIds) {
  console.log('\n🤝 Creating trade offers...');

  const trades = [
    {
      fromUser: userIds[0], // Alice
      toUser: userIds[1],   // Bob
      offeredItem: itemIds[0], // iPhone
      requestedItem: itemIds[1], // Harry Potter
      message: 'Hi! I\'d love to trade my iPhone for your Harry Potter collection. I\'m a huge fan!',
      status: 'pending'
    },
    {
      fromUser: userIds[2], // Carol
      toUser: userIds[0],   // Alice
      offeredItem: itemIds[2], // Leather Jacket
      requestedItem: itemIds[0], // iPhone
      message: 'Would you be interested in this vintage leather jacket for your iPhone?',
      status: 'pending'
    },
    {
      fromUser: userIds[3], // David
      toUser: userIds[4],   // Emma
      offeredItem: itemIds[3], // Road Bike
      requestedItem: itemIds[4], // Coffee Table
      message: 'I need a new coffee table! Would you trade for my professional road bike?',
      status: 'accepted'
    },
    {
      fromUser: userIds[1], // Bob
      toUser: userIds[2],   // Carol
      offeredItem: itemIds[7], // LOTR Books
      requestedItem: itemIds[8], // Designer Handbag
      message: 'My girlfriend would love this handbag! Can we trade for my LOTR collection?',
      status: 'rejected'
    },
    {
      fromUser: userIds[4], // Emma
      toUser: userIds[3],   // David
      offeredItem: itemIds[9], // Yoga Mat
      requestedItem: itemIds[3], // Road Bike
      message: 'Perfect for staying fit! Want to trade?',
      status: 'cancelled'
    }
  ];

  for (const trade of trades) {
    try {
      const tradeRef = db.collection('tradeOffers').doc();
      
      const tradeData = {
        id: tradeRef.id,
        fromUserId: trade.fromUser.uid,
        toUserId: trade.toUser.uid,
        fromUserName: trade.fromUser.name,
        toUserName: trade.toUser.name,
        offeredItemId: trade.offeredItem.id,
        offeredItemTitle: trade.offeredItem.title,
        offeredItemImages: trade.offeredItem.images,
        requestedItemId: trade.requestedItem.id,
        requestedItemTitle: trade.requestedItem.title,
        requestedItemImages: trade.requestedItem.images,
        message: trade.message,
        status: trade.status,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      await tradeRef.set(tradeData);
      console.log(`✅ Created trade: ${trade.fromUser.name} → ${trade.toUser.name} (${trade.status})`);
    } catch (error) {
      console.error(`❌ Error creating trade:`, error.message);
    }
  }
}

async function createRatings(userIds) {
  console.log('\n⭐ Creating ratings...');
  let ratingsCount = 0;

  // Create some random ratings for users
  const ratingsData = [
    { ratedUserId: userIds[0].uid, rating: 5, comment: 'Great trader! Item was exactly as described.' },
    { ratedUserId: userIds[0].uid, rating: 4, comment: 'Good communication, fast shipping.' },
    { ratedUserId: userIds[1].uid, rating: 5, comment: 'Perfect condition! Highly recommended.' },
    { ratedUserId: userIds[2].uid, rating: 4, comment: 'Nice person to trade with.' },
    { ratedUserId: userIds[3].uid, rating: 5, comment: 'Amazing trade experience!' },
    { ratedUserId: userIds[4].uid, rating: 4, comment: 'Item was great, very happy!' },
  ];

  for (let i = 0; i < ratingsData.length; i++) {
    const rating = ratingsData[i];
    const raterUserId = userIds[(i + 1) % userIds.length].uid;

    try {
      const ratingRef = db.collection('ratings').doc();
      await ratingRef.set({
        id: ratingRef.id,
        ratedUserId: rating.ratedUserId,
        raterUserId: raterUserId,
        rating: rating.rating,
        comment: rating.comment,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      ratingsCount++;
    } catch (error) {
      console.error('❌ Error creating rating:', error.message);
    }
  }

  console.log(`✅ Created ${ratingsCount} ratings`);
  return ratingsCount;
}

async function createFavorites(userIds, itemIds) {
  console.log('\n❤️  Creating favorites...');
  let favoritesCount = 0;

  // Create some random favorites
  const favorites = [
    { userId: userIds[0].uid, itemIds: [1, 2, 3, 4] },
    { userId: userIds[1].uid, itemIds: [0, 3, 5] },
    { userId: userIds[2].uid, itemIds: [0, 1, 6] },
    { userId: userIds[3].uid, itemIds: [2, 4, 7] },
    { userId: userIds[4].uid, itemIds: [1, 3, 8] },
  ];

  for (const fav of favorites) {
    for (const itemIndex of fav.itemIds) {
      if (itemIndex < itemIds.length) {
        try {
          const favoriteRef = db.collection('favorites').doc();
          await favoriteRef.set({
            id: favoriteRef.id,
            userId: fav.userId,
            itemId: itemIds[itemIndex].id,
            itemTitle: itemIds[itemIndex].title,
            itemImages: itemIds[itemIndex].images,
            itemOwnerId: itemIds[itemIndex].ownerId,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          favoritesCount++;
        } catch (error) {
          console.error('❌ Error creating favorite:', error.message);
        }
      }
    }
  }

  console.log(`✅ Created ${favoritesCount} favorites`);
  return favoritesCount;
}

async function main() {
  try {
    console.log('🚀 Starting Firebase seed script...\n');
    
    const userIds = await createUsers();
    const itemIds = await createItems(userIds);
    await createTradeOffers(userIds, itemIds);
    const ratingsCount = await createRatings(userIds);
    const favoritesCount = await createFavorites(userIds, itemIds);
    
    console.log('\n✅ ✅ ✅ All data created successfully!');
    console.log('\n📊 Summary:');
    console.log(`   Users: ${userIds.length}`);
    console.log(`   Items: ${itemIds.length}`);
    console.log(`   Trade Offers: 5`);
    console.log(`   Ratings: ${ratingsCount}`);
    console.log(`   Favorites: ${favoritesCount}`);
    console.log('\n🎉 You can now login with:');
    console.log('   Email: alice.johnson@example.com');
    console.log('   Password: Test123!');
    console.log('\n   or any of the other test users!');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Fatal error:', error);
    process.exit(1);
  }
}

main();
