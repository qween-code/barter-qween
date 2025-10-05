const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin
const serviceAccount = require('../serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Sample images from various sources (free to use)
const SAMPLE_IMAGES = {
  electronics: [
    'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800',
    'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=800',
    'https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=800',
    'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800',
  ],
  fashion: [
    'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?w=800',
    'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800',
    'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?w=800',
    'https://images.unsplash.com/photo-1581655353564-df123a1eb820?w=800',
  ],
  books: [
    'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=800',
    'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=800',
    'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=800',
    'https://images.unsplash.com/photo-1491841573634-28140fc7ced7?w=800',
  ],
  furniture: [
    'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800',
    'https://images.unsplash.com/photo-1567016432779-094069958ea5?w=800',
    'https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=800',
    'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800',
  ],
  toys: [
    'https://images.unsplash.com/photo-1558060370-d644479cb6f7?w=800',
    'https://images.unsplash.com/photo-1587912781852-74b8e1428c17?w=800',
    'https://images.unsplash.com/photo-1596461404969-9ae70f2830c1?w=800',
    'https://images.unsplash.com/photo-1566793067651-c4edeeca168b?w=800',
  ],
  sports: [
    'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=800',
    'https://images.unsplash.com/photo-1517649763962-0c623066013b?w=800',
    'https://images.unsplash.com/photo-1511067007398-8c1b3c7d4f4f?w=800',
    'https://images.unsplash.com/photo-1592656094267-764a45160876?w=800',
  ],
};

// Turkish cities
const CITIES = [
  'İstanbul', 'Ankara', 'İzmir', 'Bursa', 'Antalya',
  'Adana', 'Konya', 'Gaziantep', 'Kayseri', 'Eskişehir'
];

// Item conditions
const CONDITIONS = ['Brand New', 'Like New', 'Good', 'Fair'];

// Sample items data
const SAMPLE_ITEMS = [
  {
    title: 'iPhone 13 Pro Max 256GB',
    description: 'Kusursuz durumdaki iPhone 13 Pro Max. Sadece 6 ay kullanıldı, tüm aksesuarları mevcut. Garantisi devam ediyor. Hiç düşürülmedi, ekran koruyucu ile kullanıldı.',
    category: 'Electronics',
    subcategory: 'Smartphones & Tablets',
    condition: 'Like New',
    price: 25000,
    color: 'Sierra Blue',
    tags: ['apple', 'iphone', 'smartphone', 'pro max'],
    tradePreference: 'MacBook Air veya iPad Pro ile takas edilebilir',
  },
  {
    title: 'Sony WH-1000XM5 Kulaklık',
    description: 'Piyasanın en iyi noise cancelling kulaklığı. Orjinal kutusunda, az kullanılmış durumda. Tüm aksesuarlar eksiksiz.',
    category: 'Electronics',
    subcategory: 'Audio & Headphones',
    condition: 'Like New',
    price: 8500,
    color: 'Black',
    tags: ['sony', 'headphones', 'wireless', 'anc'],
    tradePreference: 'Bose QuietComfort veya AirPods Max',
  },
  {
    title: 'Nike Air Jordan 1 High - Size 42',
    description: 'Koleksiyonluk Nike Air Jordan 1 High. Sadece birkaç kez giyildi, neredeyse yeni gibi. Orijinal kutusu ve etiketleriyle.',
    category: 'Fashion',
    subcategory: 'Shoes & Sneakers',
    condition: 'Like New',
    price: 4500,
    color: 'Chicago',
    tags: ['nike', 'jordan', 'sneakers', 'collectible'],
    tradePreference: 'Diğer sneaker modelleri',
  },
  {
    title: 'MacBook Pro 14" M1 Pro 16GB',
    description: 'Apple Silicon M1 Pro işlemcili MacBook Pro. 16GB RAM, 512GB SSD. Yazılım geliştirme için ideal. Görünüm ve performans mükemmel.',
    category: 'Electronics',
    subcategory: 'Laptops & Computers',
    condition: 'Good',
    price: 35000,
    color: 'Space Gray',
    tags: ['apple', 'macbook', 'laptop', 'm1'],
    tradePreference: 'Windows laptop + nakit fark',
  },
  {
    title: 'PlayStation 5 Disk Edition',
    description: 'PlayStation 5 konsol, orijinal kol ve tüm kablolarıyla. 3 oyun hediye (FIFA 23, Spider-Man, Horizon). Gayet temiz durumda.',
    category: 'Electronics',
    subcategory: 'Gaming Consoles',
    condition: 'Good',
    price: 12000,
    color: 'White',
    tags: ['playstation', 'ps5', 'gaming', 'console'],
    tradePreference: 'Xbox Series X veya gaming PC',
  },
  {
    title: 'IKEA HEMNES Kitaplık - Beyaz',
    description: 'Geniş ve şık IKEA HEMNES kitaplık. Montajı yapılmış, kullanıma hazır. Çok az kullanıldı, leke yok.',
    category: 'Furniture',
    subcategory: 'Living Room',
    condition: 'Like New',
    price: 3500,
    color: 'White',
    tags: ['ikea', 'bookshelf', 'furniture', 'hemnes'],
    tradePreference: 'Çalışma masası',
  },
  {
    title: 'Canon EOS R6 Body',
    description: 'Profesyonel fotoğrafçılık için Canon EOS R6. Sadece body, objektif dahil değil. Deklanşör sayısı çok düşük.',
    category: 'Electronics',
    subcategory: 'Cameras & Photography',
    condition: 'Like New',
    price: 42000,
    color: 'Black',
    tags: ['canon', 'camera', 'photography', 'mirrorless'],
    tradePreference: 'Sony Alpha serisi',
  },
  {
    title: 'Haruki Murakami Kitap Seti (10 Kitap)',
    description: 'Haruki Murakami\'nin en sevilen 10 romanı. Hepsi Türkçe çeviri, yayınevi baskısı. Çok temiz durumda.',
    category: 'Books',
    subcategory: 'Fiction',
    condition: 'Like New',
    price: 800,
    tags: ['books', 'murakami', 'fiction', 'turkish'],
    tradePreference: 'Başka kitap setleri',
  },
  {
    title: 'Zara Erkek Deri Ceket - M Beden',
    description: 'Gerçek deri Zara ceket. Sadece bir sezon giyildi. Stil değişikliği nedeniyle satılık. M beden ama L bedene de uyar.',
    category: 'Fashion',
    subcategory: 'Men\'s Clothing',
    condition: 'Good',
    price: 1200,
    color: 'Brown',
    tags: ['zara', 'leather', 'jacket', 'men'],
    tradePreference: 'Farklı stil deri ceket',
  },
  {
    title: 'LEGO Star Wars Millennium Falcon',
    description: 'Koleksiyonluk LEGO Star Wars set. 7500+ parça. Eksiksiz, tüm parçalar mevcut. Kutusu ve talimatları da var.',
    category: 'Toys',
    subcategory: 'Building Blocks',
    condition: 'Like New',
    price: 6500,
    tags: ['lego', 'star wars', 'collectible', 'building'],
    tradePreference: 'Diğer LEGO setleri',
  },
  {
    title: 'Trek Mountain Bike - 27.5"',
    description: 'Trek marka dağ bisikleti. Shimano vites sistemi, hidrolik disk fren. Servis yeni yapıldı, her yere hazır.',
    category: 'Sports',
    subcategory: 'Bicycles & Scooters',
    condition: 'Good',
    price: 8500,
    color: 'Red',
    tags: ['trek', 'bicycle', 'mountain bike', 'sports'],
    tradePreference: 'Şehir bisikleti + fark',
  },
  {
    title: 'Apple Watch Series 8 - 45mm GPS',
    description: 'Apple Watch Series 8, büyük ekran. Sadece 3 ay kullanıldı. Ekran koruyucu ve kılıf hediye. Orijinal kayışı ve şarj kablosu mevcut.',
    category: 'Electronics',
    subcategory: 'Wearables & Accessories',
    condition: 'Like New',
    price: 9500,
    color: 'Midnight',
    tags: ['apple', 'watch', 'smartwatch', 'fitness'],
    tradePreference: 'Samsung Galaxy Watch',
  },
  {
    title: 'L-Shaped Gaming Desk - RGB',
    description: 'RGB ışıklı modern gaming masası. Cable management sistemi var. Çok geniş, 2 monitör rahatça sığıyor.',
    category: 'Furniture',
    subcategory: 'Office Furniture',
    condition: 'Good',
    price: 4200,
    color: 'Black',
    tags: ['gaming', 'desk', 'rgb', 'furniture'],
    tradePreference: 'Klasik ofis masası',
  },
  {
    title: 'Adidas Ultraboost 22 - Size 43',
    description: 'Koşu için ideal Adidas Ultraboost. Çok rahat ve şık. Az kullanıldı, hala çok temiz.',
    category: 'Sports',
    subcategory: 'Fitness Equipment',
    condition: 'Like New',
    price: 2800,
    color: 'Core Black',
    tags: ['adidas', 'running', 'shoes', 'ultraboost'],
    tradePreference: 'Nike running shoes',
  },
  {
    title: 'Samsung Galaxy Tab S8+ 256GB',
    description: 'Premium Android tablet. S-Pen dahil, klavye kılıfı ile birlikte. Grafik tasarım ve not alma için harika.',
    category: 'Electronics',
    subcategory: 'Smartphones & Tablets',
    condition: 'Like New',
    price: 15000,
    color: 'Graphite',
    tags: ['samsung', 'tablet', 'android', 's-pen'],
    tradePreference: 'iPad Air veya iPad Pro',
  },
];

async function seedItems() {
  console.log('🌱 Starting to seed items data...\n');

  try {
    // First, create a test user if not exists
    const testUserId = 'test_user_001';
    const testUserRef = db.collection('users').doc(testUserId);
    const testUserDoc = await testUserRef.get();

    if (!testUserDoc.exists) {
      console.log('Creating test user...');
      await testUserRef.set({
        uid: testUserId,
        email: 'test@barterqween.com',
        displayName: 'Test User',
        photoURL: 'https://i.pravatar.cc/300?img=1',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        phoneNumber: '+905551234567',
        bio: 'Passionate trader on Barter Qween! Looking for great deals.',
        city: 'İstanbul',
        rating: 4.8,
        totalTrades: 15,
        verified: true,
      });
      console.log('✅ Test user created\n');
    } else {
      console.log('✅ Test user already exists\n');
    }

    // Seed items
    let successCount = 0;
    let errorCount = 0;

    for (let i = 0; i < SAMPLE_ITEMS.length; i++) {
      const itemData = SAMPLE_ITEMS[i];
      
      try {
        // Get random images based on category
        const categoryLower = itemData.category.toLowerCase();
        const availableImages = SAMPLE_IMAGES[categoryLower] || SAMPLE_IMAGES.electronics;
        const numImages = Math.floor(Math.random() * 2) + 2; // 2-3 images
        const selectedImages = [];
        
        for (let j = 0; j < numImages; j++) {
          const randomIndex = Math.floor(Math.random() * availableImages.length);
          selectedImages.push(availableImages[randomIndex]);
        }

        // Random city
        const randomCity = CITIES[Math.floor(Math.random() * CITIES.length)];

        // Create item document
        const itemRef = db.collection('items').doc();
        const itemId = itemRef.id;

        const item = {
          id: itemId,
          title: itemData.title,
          description: itemData.description,
          category: itemData.category,
          subcategory: itemData.subcategory || null,
          images: selectedImages,
          condition: itemData.condition,
          price: itemData.price,
          estimatedValue: itemData.price, // Alias
          monetaryValue: itemData.price,
          color: itemData.color || null,
          ownerId: testUserId,
          ownerName: 'Test User',
          ownerPhotoUrl: 'https://i.pravatar.cc/300?img=1',
          location: randomCity,
          city: randomCity,
          status: 'active',
          createdAt: admin.firestore.Timestamp.now(),
          updatedAt: admin.firestore.Timestamp.now(),
          viewCount: Math.floor(Math.random() * 100) + 10,
          favoriteCount: Math.floor(Math.random() * 20),
          tags: itemData.tags || [],
          isFeatured: i < 3, // First 3 items are featured
          tradePreference: itemData.tradePreference || null,
          
          // New fields
          tier: itemData.price > 20000 ? 'large' : itemData.price > 2000 ? 'medium' : 'small',
          moderationStatus: 'approved',
          approvedAt: admin.firestore.Timestamp.now(),
          requiresDelivery: false,
          latitude: null,
          longitude: null,
          fullAddress: null,
          specifications: {},
          videoUrls: [],
          
          // Barter condition (for some items)
          barterCondition: i % 3 === 0 ? {
            allowMoneyDifference: true,
            maxMoneyDifference: 5000,
            preferredCategories: ['Electronics', 'Fashion'],
            description: 'Benzer değerdeki ürünlerle takas edilebilir'
          } : null,
        };

        await itemRef.set(item);
        
        successCount++;
        console.log(`✅ [${i + 1}/${SAMPLE_ITEMS.length}] Created: ${itemData.title}`);
        
      } catch (error) {
        errorCount++;
        console.error(`❌ [${i + 1}/${SAMPLE_ITEMS.length}] Failed: ${itemData.title}`);
        console.error(`   Error: ${error.message}`);
      }
    }

    console.log('\n' + '='.repeat(60));
    console.log('📊 SEEDING SUMMARY');
    console.log('='.repeat(60));
    console.log(`✅ Success: ${successCount} items`);
    console.log(`❌ Failed: ${errorCount} items`);
    console.log(`📦 Total: ${SAMPLE_ITEMS.length} items`);
    console.log('='.repeat(60));
    console.log('\n🎉 Seeding completed!\n');

  } catch (error) {
    console.error('❌ Fatal error during seeding:', error);
    process.exit(1);
  }

  process.exit(0);
}

// Run the seeding
seedItems();
