const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin
const serviceAccount = require('../serviceAccountKey.json');

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();

// Turkish cities with coordinates
const CITIES = [
  { name: 'İstanbul', lat: 41.0082, lon: 28.9784, districts: ['Kadıköy', 'Beşiktaş', 'Şişli', 'Üsküdar'] },
  { name: 'Ankara', lat: 39.9334, lon: 32.8597, districts: ['Çankaya', 'Kızılay', 'Ulus', 'Keçiören'] },
  { name: 'İzmir', lat: 38.4237, lon: 27.1428, districts: ['Konak', 'Bornova', 'Karşıyaka', 'Alsancak'] },
  { name: 'Bursa', lat: 40.1826, lon: 29.0665, districts: ['Osmangazi', 'Nilüfer', 'Yıldırım'] },
  { name: 'Antalya', lat: 36.8969, lon: 30.7133, districts: ['Muratpaşa', 'Kepez', 'Konyaaltı'] },
];

// ========================================
// WORLD-CLASS USERS DATA (15 Users)
// ========================================

const WORLD_CLASS_USERS = [
  // ===== EXCELLENT TRUST SCORE USERS =====
  {
    displayName: 'Ayşe Yılmaz',
    email: 'ayse.yilmaz@barterqween.com',
    bio: 'Fashion lover 👗 Selling my closet! Fast shipper, happy customers ✨',
    city: 'İstanbul',
    district: 'Kadıköy',
    
    // Verification - FULL
    isPhoneVerified: true,
    isEmailVerified: true,
    isIdVerified: true,
    isSelfieVerified: true,
    verificationLevel: 'verified',
    verifiedAt: new Date('2023-03-15'),
    
    // Stats - EXCELLENT
    totalSales: 127,
    totalPurchases: 45,
    totalEarnings: 38500,
    activeListings: 28,
    soldListings: 127,
    firstSaleDate: new Date('2023-03-20'),
    lastSaleDate: new Date('2025-01-03'),
    
    // Ratings - EXCELLENT
    averageRating: 4.9,
    totalReviews: 98,
    fiveStarReviews: 92,
    fourStarReviews: 5,
    threeStarReviews: 1,
    twoStarReviews: 0,
    oneStarReviews: 0,
    timelyCount: 78,
    friendlyCount: 85,
    reliableCount: 90,
    asDescribedCount: 88,
    
    // Response & Shipping - EXCELLENT
    responseTimeCategory: 'instant',
    averageResponseTime: 'Within 1 hour',
    averageResponseMinutes: 45,
    replyRate: 95,
    messagesReceived: 450,
    messagesReplied: 428,
    shippingSpeedCategory: 'fast',
    averageShippingDays: 2.5,
    itemsShippedOnTime: 120,
    totalItemsShipped: 127,
    fastShipper: true,
    
    // Social
    followersCount: 342,
    followingCount: 156,
    
    // Badges - ALL
    isTopSeller: true,
    isTrustedSeller: true,
    isVerifiedSeller: true,
    hasReplyRateBadge: true,
    hasFastShipperBadge: true,
    hasTopRatedBadge: true,
    badges: ['verified', 'top_seller', 'trusted', 'fast_shipper', 'reply_rate_95', 'top_rated'],
    trustScore: 'excellent',
  },

  {
    displayName: 'Mehmet Demir',
    email: 'mehmet.demir@barterqween.com',
    bio: 'Tech enthusiast 💻 Selling electronics & gadgets. Original boxes included!',
    city: 'Ankara',
    district: 'Çankaya',
    
    isPhoneVerified: true,
    isEmailVerified: true,
    isIdVerified: true,
    isSelfieVerified: true,
    verificationLevel: 'verified',
    verifiedAt: new Date('2023-05-10'),
    
    totalSales: 85,
    totalPurchases: 62,
    totalEarnings: 125000,
    activeListings: 15,
    soldListings: 85,
    firstSaleDate: new Date('2023-05-20'),
    lastSaleDate: new Date('2025-01-04'),
    
    averageRating: 4.8,
    totalReviews: 72,
    fiveStarReviews: 65,
    fourStarReviews: 6,
    threeStarReviews: 1,
    timelyCount: 60,
    friendlyCount: 55,
    reliableCount: 68,
    asDescribedCount: 70,
    
    responseTimeCategory: 'veryfast',
    averageResponseTime: 'Within 2 hours',
    averageResponseMinutes: 90,
    replyRate: 92,
    messagesReceived: 320,
    messagesReplied: 294,
    shippingSpeedCategory: 'fast',
    averageShippingDays: 3,
    itemsShippedOnTime: 80,
    totalItemsShipped: 85,
    fastShipper: true,
    
    followersCount: 245,
    followingCount: 89,
    
    isTopSeller: true,
    isTrustedSeller: true,
    isVerifiedSeller: true,
    hasReplyRateBadge: true,
    hasFastShipperBadge: true,
    hasTopRatedBadge: true,
    badges: ['verified', 'top_seller', 'trusted', 'fast_shipper', 'reply_rate_90', 'top_rated'],
    trustScore: 'excellent',
  },

  // ===== VERY GOOD TRUST SCORE USERS =====
  {
    displayName: 'Zeynep Kaya',
    email: 'zeynep.kaya@barterqween.com',
    bio: 'Home decor & furniture 🏠 Local pickup available in Izmir',
    city: 'İzmir',
    district: 'Bornova',
    
    isPhoneVerified: true,
    isEmailVerified: true,
    isIdVerified: true,
    isSelfieVerified: false,
    verificationLevel: 'standard',
    verifiedAt: new Date('2023-08-01'),
    
    totalSales: 56,
    totalPurchases: 23,
    totalEarnings: 42000,
    activeListings: 18,
    soldListings: 56,
    firstSaleDate: new Date('2023-08-15'),
    lastSaleDate: new Date('2024-12-28'),
    
    averageRating: 4.7,
    totalReviews: 48,
    fiveStarReviews: 40,
    fourStarReviews: 7,
    threeStarReviews: 1,
    timelyCount: 35,
    friendlyCount: 42,
    reliableCount: 45,
    asDescribedCount: 38,
    
    responseTimeCategory: 'fast',
    averageResponseTime: 'Within 6 hours',
    averageResponseMinutes: 280,
    replyRate: 88,
    messagesReceived: 180,
    messagesReplied: 158,
    shippingSpeedCategory: 'standard',
    averageShippingDays: 4,
    itemsShippedOnTime: 48,
    totalItemsShipped: 56,
    fastShipper: false,
    
    followersCount: 178,
    followingCount: 92,
    
    isTopSeller: false,
    isTrustedSeller: true,
    isVerifiedSeller: true,
    hasReplyRateBadge: false,
    hasFastShipperBadge: false,
    hasTopRatedBadge: true,
    badges: ['verified', 'trusted', 'top_rated'],
    trustScore: 'verygood',
  },

  {
    displayName: 'Can Özdemir',
    email: 'can.ozdemir@barterqween.com',
    bio: 'Sneaker collector 👟 Authentic only! Original receipts available',
    city: 'İstanbul',
    district: 'Beşiktaş',
    
    isPhoneVerified: true,
    isEmailVerified: true,
    isIdVerified: true,
    isSelfieVerified: false,
    verificationLevel: 'standard',
    verifiedAt: new Date('2024-01-20'),
    
    totalSales: 38,
    totalPurchases: 67,
    totalEarnings: 28000,
    activeListings: 22,
    soldListings: 38,
    firstSaleDate: new Date('2024-02-01'),
    lastSaleDate: new Date('2025-01-02'),
    
    averageRating: 4.6,
    totalReviews: 32,
    fiveStarReviews: 26,
    fourStarReviews: 5,
    threeStarReviews: 1,
    timelyCount: 22,
    friendlyCount: 18,
    reliableCount: 28,
    asDescribedCount: 30,
    
    responseTimeCategory: 'veryfast',
    averageResponseTime: 'Within 3 hours',
    averageResponseMinutes: 150,
    replyRate: 85,
    messagesReceived: 140,
    messagesReplied: 119,
    shippingSpeedCategory: 'fast',
    averageShippingDays: 3,
    itemsShippedOnTime: 34,
    totalItemsShipped: 38,
    fastShipper: true,
    
    followersCount: 156,
    followingCount: 234,
    
    isTopSeller: false,
    isTrustedSeller: true,
    isVerifiedSeller: true,
    hasReplyRateBadge: false,
    hasFastShipperBadge: true,
    hasTopRatedBadge: true,
    badges: ['verified', 'trusted', 'fast_shipper', 'top_rated'],
    trustScore: 'verygood',
  },

  // ===== GOOD TRUST SCORE USERS =====
  {
    displayName: 'Elif Şahin',
    email: 'elif.sahin@barterqween.com',
    bio: 'Books & collectibles 📚 Bundle deals available!',
    city: 'Bursa',
    district: 'Nilüfer',
    
    isPhoneVerified: true,
    isEmailVerified: true,
    isIdVerified: false,
    isSelfieVerified: false,
    verificationLevel: 'basic',
    
    totalSales: 24,
    totalPurchases: 18,
    totalEarnings: 8500,
    activeListings: 16,
    soldListings: 24,
    firstSaleDate: new Date('2024-06-10'),
    lastSaleDate: new Date('2024-12-20'),
    
    averageRating: 4.5,
    totalReviews: 20,
    fiveStarReviews: 15,
    fourStarReviews: 4,
    threeStarReviews: 1,
    timelyCount: 12,
    friendlyCount: 16,
    reliableCount: 14,
    asDescribedCount: 15,
    
    responseTimeCategory: 'moderate',
    averageResponseTime: 'Within 1 day',
    averageResponseMinutes: 600,
    replyRate: 75,
    messagesReceived: 80,
    messagesReplied: 60,
    shippingSpeedCategory: 'standard',
    averageShippingDays: 5,
    itemsShippedOnTime: 20,
    totalItemsShipped: 24,
    fastShipper: false,
    
    followersCount: 89,
    followingCount: 145,
    
    isTopSeller: false,
    isTrustedSeller: false,
    isVerifiedSeller: false,
    hasReplyRateBadge: false,
    hasFastShipperBadge: false,
    hasTopRatedBadge: false,
    badges: [],
    trustScore: 'good',
  },

  {
    displayName: 'Burak Yıldız',
    email: 'burak.yildiz@barterqween.com',
    bio: 'Sports equipment & gear ⚽ Used but well maintained',
    city: 'Antalya',
    district: 'Muratpaşa',
    
    isPhoneVerified: true,
    isEmailVerified: true,
    isIdVerified: false,
    isSelfieVerified: false,
    verificationLevel: 'basic',
    
    totalSales: 18,
    totalPurchases: 12,
    totalEarnings: 12000,
    activeListings: 12,
    soldListings: 18,
    firstSaleDate: new Date('2024-07-15'),
    lastSaleDate: new Date('2024-12-15'),
    
    averageRating: 4.3,
    totalReviews: 15,
    fiveStarReviews: 10,
    fourStarReviews: 4,
    threeStarReviews: 1,
    timelyCount: 8,
    friendlyCount: 10,
    reliableCount: 12,
    asDescribedCount: 9,
    
    responseTimeCategory: 'moderate',
    averageResponseTime: 'Within 1 day',
    averageResponseMinutes: 720,
    replyRate: 70,
    messagesReceived: 60,
    messagesReplied: 42,
    shippingSpeedCategory: 'standard',
    averageShippingDays: 6,
    itemsShippedOnTime: 14,
    totalItemsShipped: 18,
    fastShipper: false,
    
    followersCount: 56,
    followingCount: 78,
    
    isTopSeller: false,
    isTrustedSeller: false,
    isVerifiedSeller: false,
    hasReplyRateBadge: false,
    hasFastShipperBadge: false,
    hasTopRatedBadge: false,
    badges: [],
    trustScore: 'good',
  },

  // ===== FAIR TRUST SCORE USERS =====
  {
    displayName: 'Selin Arslan',
    email: 'selin.arslan@barterqween.com',
    bio: 'Baby & kids items 👶 Gently used, clean and safe',
    city: 'İstanbul',
    district: 'Şişli',
    
    isPhoneVerified: true,
    isEmailVerified: false,
    isIdVerified: false,
    isSelfieVerified: false,
    verificationLevel: 'none',
    
    totalSales: 8,
    totalPurchases: 5,
    totalEarnings: 3200,
    activeListings: 10,
    soldListings: 8,
    firstSaleDate: new Date('2024-10-01'),
    lastSaleDate: new Date('2024-12-10'),
    
    averageRating: 4.0,
    totalReviews: 7,
    fiveStarReviews: 4,
    fourStarReviews: 2,
    threeStarReviews: 1,
    timelyCount: 3,
    friendlyCount: 5,
    reliableCount: 4,
    asDescribedCount: 5,
    
    responseTimeCategory: 'slow',
    averageResponseTime: 'Within 2 days',
    averageResponseMinutes: 1200,
    replyRate: 60,
    messagesReceived: 30,
    messagesReplied: 18,
    shippingSpeedCategory: 'slow',
    averageShippingDays: 7,
    itemsShippedOnTime: 5,
    totalItemsShipped: 8,
    fastShipper: false,
    
    followersCount: 23,
    followingCount: 45,
    
    isTopSeller: false,
    isTrustedSeller: false,
    isVerifiedSeller: false,
    hasReplyRateBadge: false,
    hasFastShipperBadge: false,
    hasTopRatedBadge: false,
    badges: [],
    trustScore: 'fair',
  },

  // ===== NEW USERS (No sales yet) =====
  {
    displayName: 'Emre Çelik',
    email: 'emre.celik@barterqween.com',
    bio: 'New to Barter Qween! Looking to sell my old stuff',
    city: 'Ankara',
    district: 'Keçiören',
    
    isPhoneVerified: false,
    isEmailVerified: true,
    isIdVerified: false,
    isSelfieVerified: false,
    verificationLevel: 'none',
    
    totalSales: 0,
    totalPurchases: 2,
    totalEarnings: 0,
    activeListings: 5,
    soldListings: 0,
    
    averageRating: 0,
    totalReviews: 0,
    
    responseTimeCategory: 'notAvailable',
    replyRate: 0,
    messagesReceived: 8,
    messagesReplied: 0,
    
    followersCount: 2,
    followingCount: 12,
    
    isTopSeller: false,
    isTrustedSeller: false,
    isVerifiedSeller: false,
    badges: [],
    trustScore: 'new',
  },

  {
    displayName: 'Deniz Koç',
    email: 'deniz.koc@barterqween.com',
    bio: 'Just joined! Excited to start selling 🎉',
    city: 'İzmir',
    district: 'Karşıyaka',
    
    isPhoneVerified: true,
    isEmailVerified: true,
    isIdVerified: false,
    isSelfieVerified: false,
    verificationLevel: 'none',
    
    totalSales: 1,
    totalPurchases: 0,
    totalEarnings: 450,
    activeListings: 8,
    soldListings: 1,
    firstSaleDate: new Date('2024-12-28'),
    lastSaleDate: new Date('2024-12-28'),
    
    averageRating: 5.0,
    totalReviews: 1,
    fiveStarReviews: 1,
    timelyCount: 1,
    friendlyCount: 1,
    
    responseTimeCategory: 'notAvailable',
    replyRate: 0,
    messagesReceived: 5,
    messagesReplied: 0,
    
    followersCount: 5,
    followingCount: 8,
    
    isTopSeller: false,
    isTrustedSeller: false,
    isVerifiedSeller: false,
    badges: [],
    trustScore: 'new',
  },

  // ===== MORE DIVERSE USERS =====
  {
    displayName: 'Merve Aydın',
    email: 'merve.aydin@barterqween.com',
    bio: 'Vintage clothing enthusiast 🕰️ Unique pieces from the 90s',
    city: 'İstanbul',
    district: 'Üsküdar',
    
    isPhoneVerified: true,
    isEmailVerified: true,
    isIdVerified: true,
    isSelfieVerified: true,
    verificationLevel: 'verified',
    verifiedAt: new Date('2023-11-05'),
    
    totalSales: 64,
    totalPurchases: 38,
    totalEarnings: 22000,
    activeListings: 20,
    soldListings: 64,
    firstSaleDate: new Date('2023-11-15'),
    lastSaleDate: new Date('2025-01-01'),
    
    averageRating: 4.8,
    totalReviews: 55,
    fiveStarReviews: 50,
    fourStarReviews: 4,
    threeStarReviews: 1,
    timelyCount: 42,
    friendlyCount: 48,
    reliableCount: 50,
    asDescribedCount: 52,
    
    responseTimeCategory: 'instant',
    averageResponseTime: 'Within 30 minutes',
    averageResponseMinutes: 25,
    replyRate: 98,
    messagesReceived: 250,
    messagesReplied: 245,
    shippingSpeedCategory: 'fast',
    averageShippingDays: 2,
    itemsShippedOnTime: 62,
    totalItemsShipped: 64,
    fastShipper: true,
    
    followersCount: 289,
    followingCount: 134,
    
    isTopSeller: true,
    isTrustedSeller: true,
    isVerifiedSeller: true,
    hasReplyRateBadge: true,
    hasFastShipperBadge: true,
    hasTopRatedBadge: true,
    badges: ['verified', 'top_seller', 'trusted', 'fast_shipper', 'reply_rate_95', 'top_rated'],
    trustScore: 'excellent',
  },

  {
    displayName: 'Ahmet Kılıç',
    email: 'ahmet.kilic@barterqween.com',
    bio: 'Car accessories & parts 🚗 All tested and working',
    city: 'Bursa',
    district: 'Osmangazi',
    
    isPhoneVerified: true,
    isEmailVerified: true,
    isIdVerified: false,
    isSelfieVerified: false,
    verificationLevel: 'basic',
    
    totalSales: 31,
    totalPurchases: 8,
    totalEarnings: 18500,
    activeListings: 14,
    soldListings: 31,
    firstSaleDate: new Date('2024-04-10'),
    lastSaleDate: new Date('2024-12-22'),
    
    averageRating: 4.4,
    totalReviews: 26,
    fiveStarReviews: 18,
    fourStarReviews: 7,
    threeStarReviews: 1,
    timelyCount: 15,
    friendlyCount: 12,
    reliableCount: 20,
    asDescribedCount: 22,
    
    responseTimeCategory: 'fast',
    averageResponseTime: 'Within 8 hours',
    averageResponseMinutes: 420,
    replyRate: 78,
    messagesReceived: 100,
    messagesReplied: 78,
    shippingSpeedCategory: 'standard',
    averageShippingDays: 5,
    itemsShippedOnTime: 26,
    totalItemsShipped: 31,
    fastShipper: false,
    
    followersCount: 98,
    followingCount: 67,
    
    isTopSeller: false,
    isTrustedSeller: false,
    isVerifiedSeller: false,
    hasReplyRateBadge: false,
    hasFastShipperBadge: false,
    hasTopRatedBadge: false,
    badges: [],
    trustScore: 'good',
  },

  {
    displayName: 'Gizem Özkan',
    email: 'gizem.ozkan@barterqween.com',
    bio: 'Handmade jewelry & accessories ✨ Custom orders welcome',
    city: 'İzmir',
    district: 'Konak',
    
    isPhoneVerified: true,
    isEmailVerified: true,
    isIdVerified: true,
    isSelfieVerified: false,
    verificationLevel: 'standard',
    verifiedAt: new Date('2024-03-20'),
    
    totalSales: 42,
    totalPurchases: 15,
    totalEarnings: 15000,
    activeListings: 25,
    soldListings: 42,
    firstSaleDate: new Date('2024-04-01'),
    lastSaleDate: new Date('2024-12-30'),
    
    averageRating: 4.7,
    totalReviews: 38,
    fiveStarReviews: 32,
    fourStarReviews: 5,
    threeStarReviews: 1,
    timelyCount: 28,
    friendlyCount: 35,
    reliableCount: 30,
    asDescribedCount: 34,
    
    responseTimeCategory: 'veryfast',
    averageResponseTime: 'Within 2 hours',
    averageResponseMinutes: 100,
    replyRate: 90,
    messagesReceived: 160,
    messagesReplied: 144,
    shippingSpeedCategory: 'fast',
    averageShippingDays: 3,
    itemsShippedOnTime: 39,
    totalItemsShipped: 42,
    fastShipper: true,
    
    followersCount: 198,
    followingCount: 112,
    
    isTopSeller: false,
    isTrustedSeller: true,
    isVerifiedSeller: true,
    hasReplyRateBadge: true,
    hasFastShipperBadge: true,
    hasTopRatedBadge: true,
    badges: ['verified', 'trusted', 'fast_shipper', 'reply_rate_90', 'top_rated'],
    trustScore: 'verygood',
  },

  {
    displayName: 'Cem Güneş',
    email: 'cem.gunes@barterqween.com',
    bio: 'Board games & puzzles 🎲 All complete, no missing pieces',
    city: 'Ankara',
    district: 'Ulus',
    
    isPhoneVerified: true,
    isEmailVerified: true,
    isIdVerified: false,
    isSelfieVerified: false,
    verificationLevel: 'basic',
    
    totalSales: 15,
    totalPurchases: 28,
    totalEarnings: 5400,
    activeListings: 9,
    soldListings: 15,
    firstSaleDate: new Date('2024-08-12'),
    lastSaleDate: new Date('2024-12-05'),
    
    averageRating: 4.2,
    totalReviews: 12,
    fiveStarReviews: 8,
    fourStarReviews: 3,
    threeStarReviews: 1,
    timelyCount: 6,
    friendlyCount: 9,
    reliableCount: 7,
    asDescribedCount: 10,
    
    responseTimeCategory: 'moderate',
    averageResponseTime: 'Within 18 hours',
    averageResponseMinutes: 900,
    replyRate: 68,
    messagesReceived: 45,
    messagesReplied: 30,
    shippingSpeedCategory: 'standard',
    averageShippingDays: 6,
    itemsShippedOnTime: 11,
    totalItemsShipped: 15,
    fastShipper: false,
    
    followersCount: 45,
    followingCount: 156,
    
    isTopSeller: false,
    isTrustedSeller: false,
    isVerifiedSeller: false,
    hasReplyRateBadge: false,
    hasFastShipperBadge: false,
    hasTopRatedBadge: false,
    badges: [],
    trustScore: 'good',
  },

  {
    displayName: 'Fatma Yavuz',
    email: 'fatma.yavuz@barterqween.com',
    bio: 'Kitchen appliances & cookware 🍳 Used but in great condition',
    city: 'Antalya',
    district: 'Kepez',
    
    isPhoneVerified: true,
    isEmailVerified: true,
    isIdVerified: false,
    isSelfieVerified: false,
    verificationLevel: 'basic',
    
    totalSales: 12,
    totalPurchases: 6,
    totalEarnings: 7800,
    activeListings: 7,
    soldListings: 12,
    firstSaleDate: new Date('2024-09-05'),
    lastSaleDate: new Date('2024-11-28'),
    
    averageRating: 4.1,
    totalReviews: 10,
    fiveStarReviews: 6,
    fourStarReviews: 3,
    threeStarReviews: 1,
    timelyCount: 5,
    friendlyCount: 7,
    reliableCount: 6,
    asDescribedCount: 7,
    
    responseTimeCategory: 'slow',
    averageResponseTime: 'Within 2 days',
    averageResponseMinutes: 1500,
    replyRate: 55,
    messagesReceived: 35,
    messagesReplied: 19,
    shippingSpeedCategory: 'slow',
    averageShippingDays: 8,
    itemsShippedOnTime: 8,
    totalItemsShipped: 12,
    fastShipper: false,
    
    followersCount: 28,
    followingCount: 42,
    
    isTopSeller: false,
    isTrustedSeller: false,
    isVerifiedSeller: false,
    hasReplyRateBadge: false,
    hasFastShipperBadge: false,
    hasTopRatedBadge: false,
    badges: [],
    trustScore: 'fair',
  },

  {
    displayName: 'Kerem Öztürk',
    email: 'kerem.ozturk@barterqween.com',
    bio: 'Photography gear 📷 Canon & Nikon lenses, well maintained',
    city: 'İstanbul',
    district: 'Kadıköy',
    
    isPhoneVerified: true,
    isEmailVerified: true,
    isIdVerified: true,
    isSelfieVerified: true,
    verificationLevel: 'verified',
    verifiedAt: new Date('2024-02-14'),
    
    totalSales: 28,
    totalPurchases: 35,
    totalEarnings: 52000,
    activeListings: 11,
    soldListings: 28,
    firstSaleDate: new Date('2024-03-01'),
    lastSaleDate: new Date('2024-12-18'),
    
    averageRating: 4.9,
    totalReviews: 25,
    fiveStarReviews: 24,
    fourStarReviews: 1,
    timelyCount: 20,
    friendlyCount: 22,
    reliableCount: 24,
    asDescribedCount: 25,
    
    responseTimeCategory: 'instant',
    averageResponseTime: 'Within 15 minutes',
    averageResponseMinutes: 12,
    replyRate: 100,
    messagesReceived: 95,
    messagesReplied: 95,
    shippingSpeedCategory: 'nextDay',
    averageShippingDays: 1,
    itemsShippedOnTime: 28,
    totalItemsShipped: 28,
    fastShipper: true,
    
    followersCount: 167,
    followingCount: 89,
    
    isTopSeller: false,
    isTrustedSeller: true,
    isVerifiedSeller: true,
    hasReplyRateBadge: true,
    hasFastShipperBadge: true,
    hasTopRatedBadge: true,
    badges: ['verified', 'trusted', 'fast_shipper', 'reply_rate_100', 'top_rated', 'next_day_shipping'],
    trustScore: 'verygood',
  },
];

// ========================================
// SEED FUNCTION
// ========================================

async function seedWorldClassUsers() {
  console.log('🚀 Starting world-class users seeding...\n');
  
  const batch = db.batch();
  let seededCount = 0;
  let errorCount = 0;
  
  for (const userData of WORLD_CLASS_USERS) {
    try {
      // Generate user ID
      const userId = `user_${userData.email.split('@')[0].replace('.', '_')}`;
      const userRef = db.collection('users').doc(userId);
      
      // Get city data
      const cityData = CITIES.find(c => c.name === userData.city) || CITIES[0];
      const latOffset = (Math.random() - 0.5) * 0.02;
      const lonOffset = (Math.random() - 0.5) * 0.02;
      
      // Prepare complete user data
      const completeUser = {
        uid: userId,
        ...userData,
        latitude: cityData.lat + latOffset,
        longitude: cityData.lon + lonOffset,
        fullAddress: `${userData.district || cityData.districts[0]}, ${userData.city}, Türkiye`,
        photoUrl: `https://api.dicebear.com/7.x/avataaars/svg?seed=${userData.displayName}`,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        lastActiveAt: admin.firestore.FieldValue.serverTimestamp(),
        
        // Default values
        isPremium: false,
        notificationsEnabled: true,
        emailNotificationsEnabled: true,
        smsNotificationsEnabled: false,
        isSuspended: false,
        isBanned: false,
        warningsCount: 0,
        reportedCount: 0,
        reportsFiledCount: 0,
      };
      
      batch.set(userRef, completeUser);
      seededCount++;
      console.log(`✅ [${seededCount}/${WORLD_CLASS_USERS.length}] ${userData.displayName} (${userData.trustScore})`);
      
    } catch (error) {
      errorCount++;
      console.error(`❌ Error seeding ${userData.displayName}:`, error.message);
    }
  }
  
  // Commit batch
  console.log('\n📤 Committing batch to Firestore...');
  await batch.commit();
  
  console.log('\n' + '='.repeat(60));
  console.log('✨ SEEDING COMPLETE!');
  console.log('='.repeat(60));
  console.log(`✅ Successfully seeded: ${seededCount} users`);
  console.log(`❌ Errors: ${errorCount} users`);
  console.log(`📊 Total users in database: ${seededCount}`);
  console.log('='.repeat(60));
  
  // Print trust score distribution
  console.log('\n📊 TRUST SCORE DISTRIBUTION:');
  const distribution = {
    excellent: WORLD_CLASS_USERS.filter(u => u.trustScore === 'excellent').length,
    verygood: WORLD_CLASS_USERS.filter(u => u.trustScore === 'verygood').length,
    good: WORLD_CLASS_USERS.filter(u => u.trustScore === 'good').length,
    fair: WORLD_CLASS_USERS.filter(u => u.trustScore === 'fair').length,
    new: WORLD_CLASS_USERS.filter(u => u.trustScore === 'new').length,
  };
  console.log(`🌟 Excellent: ${distribution.excellent} users`);
  console.log(`⭐ Very Good: ${distribution.verygood} users`);
  console.log(`✨ Good: ${distribution.good} users`);
  console.log(`💫 Fair: ${distribution.fair} users`);
  console.log(`🆕 New: ${distribution.new} users`);
  console.log('='.repeat(60) + '\n');
}

// Run seeding
seedWorldClassUsers()
  .then(() => {
    console.log('✅ Seeding script completed successfully!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Seeding script failed:', error);
    process.exit(1);
  });
