#!/usr/bin/env node

/**
 * Firebase Test Data Seeder
 * Creates sample items for all categories with specifications
 * 
 * Usage:
 *   node scripts/seed_test_items.js
 * 
 * Note: This creates TEST data. Mark items as test with isTestData: true
 */

const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Test user IDs (replace with real test users)
const TEST_USERS = [
  {
    id: 'test-user-1',
    name: 'Ahmet Yılmaz',
    photoUrl: null
  },
  {
    id: 'test-user-2',
    name: 'Ayşe Demir',
    photoUrl: null
  },
  {
    id: 'test-user-3',
    name: 'Mehmet Kaya',
    photoUrl: null
  }
];

// Turkish cities for location
const CITIES = [
  'İstanbul', 'Ankara', 'İzmir', 'Bursa', 'Antalya',
  'Adana', 'Konya', 'Gaziantep', 'Mersin', 'Diyarbakır'
];

// Sample items with specifications for each category
const SAMPLE_ITEMS = [
  // ELECTRONICS
  {
    title: 'iPhone 14 Pro 256GB Space Black',
    description: 'Sıfır ayarında iPhone 14 Pro. Hiç kullanılmadı, kutusunda tüm aksesuarlar mevcut. 6 ay Apple garantisi var.',
    category: 'Electronics',
    subcategory: 'Smartphones & Tablets',
    condition: 'Like New',
    price: 35000,
    monetaryValue: 35000,
    tier: 'large',
    images: ['https://via.placeholder.com/800x600?text=iPhone+14+Pro'],
    specifications: {
      brand: 'Apple',
      model: 'iPhone 14 Pro',
      storage: '256GB',
      ram: '6GB',
      processor: 'A16 Bionic',
      screen_size: '6.1"',
      battery_health: '100%',
      warranty_months: '6',
      color: 'Space Black'
    },
    tags: ['apple', 'iphone', 'smartphone', 'ios']
  },
  {
    title: 'MacBook Pro 2021 M1 Pro',
    description: 'MacBook Pro 14" M1 Pro çip, 16GB RAM, 512GB SSD. Video editing için kullanıldı, tertemiz durumda.',
    category: 'Electronics',
    subcategory: 'Laptops & Computers',
    condition: 'Good',
    price: 42000,
    monetaryValue: 42000,
    tier: 'large',
    images: ['https://via.placeholder.com/800x600?text=MacBook+Pro'],
    specifications: {
      brand: 'Apple',
      model: 'MacBook Pro 14" (2021)',
      storage: '512GB',
      ram: '16GB',
      processor: 'Apple M1 Pro',
      screen_size: '14"',
      warranty_months: '3',
      release_year: '2021'
    },
    tags: ['macbook', 'laptop', 'apple', 'm1']
  },
  
  // FASHION
  {
    title: 'Nike Air Max 270 Erkek Spor Ayakkabı',
    description: 'Orijinal Nike Air Max 270. 2-3 kez giyildi, tertemiz. Kutusu ve faturası mevcut.',
    category: 'Fashion',
    subcategory: 'Shoes & Sneakers',
    condition: 'Like New',
    price: 2800,
    monetaryValue: 2800,
    tier: 'medium',
    images: ['https://via.placeholder.com/800x600?text=Nike+Air+Max'],
    specifications: {
      brand: 'Nike',
      size: '43',
      material: 'Mixed Materials',
      season: 'All Seasons',
      gender: 'Men',
      style: 'Sporty'
    },
    tags: ['nike', 'sneakers', 'shoes', 'sporty']
  },
  {
    title: 'Zara Kadın Ceket - Siyah',
    description: 'Zara marka kadın ceket, M beden. Geçen sezon aldım, birkaç kez giydim.',
    category: 'Fashion',
    subcategory: 'Women\'s Clothing',
    condition: 'Good',
    price: 450,
    monetaryValue: 450,
    tier: 'small',
    images: ['https://via.placeholder.com/800x600?text=Zara+Jacket'],
    specifications: {
      brand: 'Zara',
      size: 'M',
      material: 'Polyester',
      season: 'Fall',
      gender: 'Women',
      style: 'Casual'
    },
    tags: ['zara', 'jacket', 'women', 'fashion']
  },

  // BOOKS
  {
    title: 'Tutunamayanlar - Oğuz Atay',
    description: 'İletişim Yayınları, 2023 baskısı. Hiç okunmadı, yeni gibi.',
    category: 'Books',
    subcategory: 'Fiction',
    condition: 'Brand New',
    price: 120,
    monetaryValue: 120,
    tier: 'small',
    images: ['https://via.placeholder.com/800x600?text=Tutunamayanlar'],
    specifications: {
      author: 'Oğuz Atay',
      publisher: 'İletişim Yayınları',
      isbn: '978-975-05-1234-5',
      language: 'Türkçe',
      publication_year: '2023',
      pages: '724',
      edition: '50. Baskı',
      format: 'Paperback'
    },
    tags: ['oğuz atay', 'roman', 'türk edebiyatı']
  },

  // FURNITURE
  {
    title: 'IKEA MALM Yatak Odası Takımı',
    description: 'IKEA MALM serisi yatak, komodin ve şifonyer. Beyaz renk, 2 yıllık kullanılmış, iyi durumda.',
    category: 'Furniture',
    subcategory: 'Bedroom',
    condition: 'Good',
    price: 5500,
    monetaryValue: 5500,
    tier: 'large',
    images: ['https://via.placeholder.com/800x600?text=IKEA+MALM'],
    specifications: {
      brand: 'IKEA',
      material: 'Wood',
      dimensions: '160cm x 200cm (yatak)',
      color: 'White',
      assembly_required: true,
      style: 'Modern',
      room: 'Bedroom'
    },
    tags: ['ikea', 'malm', 'bedroom', 'furniture']
  },

  // TOYS
  {
    title: 'LEGO Star Wars Millennium Falcon',
    description: 'LEGO Star Wars Millennium Falcon 75192. Hiç açılmadı, orijinal kutusunda.',
    category: 'Toys',
    subcategory: 'Building Blocks',
    condition: 'Brand New',
    price: 12000,
    monetaryValue: 12000,
    tier: 'large',
    images: ['https://via.placeholder.com/800x600?text=LEGO+Millennium+Falcon'],
    specifications: {
      brand: 'LEGO',
      age_range: '13+ years',
      material: 'Plastic',
      battery_required: false,
      safety_certified: true,
      dimensions: '84cm x 56cm x 21cm'
    },
    tags: ['lego', 'star wars', 'collectible']
  },

  // SPORTS
  {
    title: 'Decathlon Trekking Bisikleti',
    description: 'Rockrider ST100 trekking bisikleti. 21 vites, alüminyum şasi. Az kullanıldı.',
    category: 'Sports',
    subcategory: 'Bicycles & Scooters',
    condition: 'Good',
    price: 3200,
    monetaryValue: 3200,
    tier: 'medium',
    images: ['https://via.placeholder.com/800x600?text=Trekking+Bike'],
    specifications: {
      brand: 'Decathlon',
      size: 'L',
      weight: '14kg',
      material: 'Aluminum',
      sport_type: 'Cycling',
      gender: 'Unisex',
      level: 'Beginner'
    },
    tags: ['bisiklet', 'bicycle', 'decathlon', 'trekking']
  },

  // HOME & GARDEN
  {
    title: 'Bosch Çamaşır Makinesi 9kg',
    description: 'Bosch Serie 6 çamaşır makinesi, 9kg kapasiteli. 3 yıllık, çalışır durumda.',
    category: 'Home & Garden',
    subcategory: 'Kitchen Appliances',
    condition: 'Good',
    price: 8500,
    monetaryValue: 8500,
    tier: 'large',
    images: ['https://via.placeholder.com/800x600?text=Bosch+Washing+Machine'],
    specifications: {
      brand: 'Bosch',
      material: 'Stainless Steel',
      dimensions: '60cm x 85cm x 60cm',
      power: '2300W',
      energy_rating: 'A+++',
      warranty_months: '0'
    },
    tags: ['bosch', 'çamaşır makinesi', 'white goods']
  },

  // BEAUTY
  {
    title: 'Chanel No 5 Eau de Parfum 100ml',
    description: 'Chanel No 5 parfüm, 100ml. Yarısı kullanılmış, orijinal kutusu mevcut.',
    category: 'Beauty',
    subcategory: 'Perfumes & Fragrances',
    condition: 'Good',
    price: 1800,
    monetaryValue: 1800,
    tier: 'medium',
    images: ['https://via.placeholder.com/800x600?text=Chanel+No+5'],
    specifications: {
      brand: 'Chanel',
      volume: '100ml',
      expiry_date: '2026-12',
      skin_type: 'All',
      scent: 'Floral',
      opened: true
    },
    tags: ['chanel', 'perfume', 'fragrance', 'luxury']
  },

  // AUTOMOTIVE
  {
    title: 'Original BMW F30 Far Takımı',
    description: 'BMW F30 3 Serisi için orijinal far takımı. Hiç kullanılmadı, yeni.',
    category: 'Automotive',
    subcategory: 'Car Parts',
    condition: 'Brand New',
    price: 4500,
    monetaryValue: 4500,
    tier: 'medium',
    images: ['https://via.placeholder.com/800x600?text=BMW+Headlight'],
    specifications: {
      brand: 'BMW',
      model: 'F30 3 Series',
      part_number: '63117338699',
      compatibility: 'BMW F30 2012-2019',
      year: '2015',
      oem_number: '63117338699'
    },
    tags: ['bmw', 'f30', 'headlight', 'original']
  },

  // COLLECTIBLES
  {
    title: 'Pokemon Kartları - Charizard Holographic',
    description: 'Pokemon Charizard holographic kart, 1999 basım. Mint condition, sertifikalı.',
    category: 'Collectibles',
    subcategory: 'Trading Cards',
    condition: 'Brand New',
    price: 15000,
    monetaryValue: 15000,
    tier: 'large',
    images: ['https://via.placeholder.com/800x600?text=Charizard+Card'],
    specifications: {
      brand: 'Pokemon',
      year: '1999',
      edition: 'Base Set',
      rarity: 'Rare Holo',
      authenticated: true,
      certificate_number: 'PSA-123456',
      grading: 'PSA 9'
    },
    tags: ['pokemon', 'charizard', 'collectible', 'trading card']
  },

  // MUSIC & INSTRUMENTS
  {
    title: 'Fender Stratocaster Elektro Gitar',
    description: 'Fender Stratocaster American Professional II. 2022 model, az kullanılmış.',
    category: 'Music & Instruments',
    subcategory: 'Guitars',
    condition: 'Like New',
    price: 28000,
    monetaryValue: 28000,
    tier: 'large',
    images: ['https://via.placeholder.com/800x600?text=Fender+Stratocaster'],
    specifications: {
      brand: 'Fender',
      model: 'Stratocaster American Professional II',
      type: 'Electric Guitar',
      material: 'Alder Body, Maple Neck',
      year: '2022',
      includes_case: true,
      includes_accessories: true
    },
    tags: ['fender', 'stratocaster', 'guitar', 'electric']
  },

  // PET SUPPLIES
  {
    title: 'Royal Canin Köpek Maması 15kg',
    description: 'Royal Canin Medium Adult köpek maması. Açılmamış, son kullanma tarihi 2025.',
    category: 'Pet Supplies',
    subcategory: 'Dog Supplies',
    condition: 'Brand New',
    price: 1200,
    monetaryValue: 1200,
    tier: 'medium',
    images: ['https://via.placeholder.com/800x600?text=Royal+Canin'],
    specifications: {
      brand: 'Royal Canin',
      pet_type: 'Dog',
      size: 'Medium',
      age_range: '1-2 years',
      material: 'Dry Food',
      weight: '15kg'
    },
    tags: ['royal canin', 'dog food', 'pet']
  },

  // BABY & KIDS
  {
    title: 'Chicco Bebek Arabası Travel System',
    description: 'Chicco Trio Love bebek arabası seti. Ana kasa, puset ve oto koltuğu. Tertemiz.',
    category: 'Baby & Kids',
    subcategory: 'Baby Gear & Furniture',
    condition: 'Like New',
    price: 3500,
    monetaryValue: 3500,
    tier: 'medium',
    images: ['https://via.placeholder.com/800x600?text=Chicco+Stroller'],
    specifications: {
      brand: 'Chicco',
      age_range: '0-6 months',
      size: 'One Size',
      material: 'Fabric',
      safety_certified: true,
      gender: 'Unisex'
    },
    tags: ['chicco', 'stroller', 'baby', 'travel system']
  },

  // OFFICE SUPPLIES
  {
    title: 'Herman Miller Aeron Ofis Koltuğu',
    description: 'Herman Miller Aeron ergonomik ofis koltuğu. Size B (medium), siyah mesh.',
    category: 'Office Supplies',
    subcategory: 'Desks & Chairs',
    condition: 'Good',
    price: 12000,
    monetaryValue: 12000,
    tier: 'large',
    images: ['https://via.placeholder.com/800x600?text=Herman+Miller+Aeron'],
    specifications: {
      brand: 'Herman Miller',
      dimensions: '68cm x 65cm x 95-104cm',
      material: 'Mesh',
      color: 'Black',
      quantity: '1'
    },
    tags: ['herman miller', 'aeron', 'office chair', 'ergonomic']
  }
];

async function createTestItem(itemData, userIndex) {
  const user = TEST_USERS[userIndex % TEST_USERS.length];
  const city = CITIES[Math.floor(Math.random() * CITIES.length)];
  
  const item = {
    ...itemData,
    ownerId: user.id,
    ownerName: user.name,
    ownerPhotoUrl: user.photoUrl,
    city: city,
    location: city,
    status: 'active',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: null,
    viewCount: Math.floor(Math.random() * 100),
    favoriteCount: Math.floor(Math.random() * 20),
    isFeatured: false,
    moderationStatus: 'approved', // Auto-approve test items
    requiresDelivery: false,
    isTestData: true, // Mark as test data for easy cleanup
  };

  const docRef = await db.collection('items').add(item);
  console.log(`✅ Created: ${item.title} (${docRef.id})`);
  return docRef.id;
}

async function seedDatabase() {
  console.log('🌱 Starting database seeding...\n');
  console.log(`📦 Creating ${SAMPLE_ITEMS.length} test items...\n`);

  try {
    for (let i = 0; i < SAMPLE_ITEMS.length; i++) {
      await createTestItem(SAMPLE_ITEMS[i], i);
      // Small delay to avoid rate limiting
      await new Promise(resolve => setTimeout(resolve, 100));
    }

    console.log('\n✅ Database seeding completed!');
    console.log(`\n📊 Summary:`);
    console.log(`   - Total items created: ${SAMPLE_ITEMS.length}`);
    console.log(`   - Test users: ${TEST_USERS.length}`);
    console.log(`   - Cities: ${CITIES.length}`);
    console.log(`\n⚠️  Note: All items marked with isTestData: true`);
    console.log(`   Use this to clean up test data later:\n`);
    console.log(`   db.collection('items').where('isTestData', '==', true).get()\n`);

  } catch (error) {
    console.error('❌ Error seeding database:', error);
  } finally {
    process.exit(0);
  }
}

// Run seeder
seedDatabase();
