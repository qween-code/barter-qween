const admin = require('firebase-admin');

// Initialize Firebase Admin
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: 'bogazici-barter.appspot.com'
});

const db = admin.firestore();
const auth = admin.auth();

console.log('🚀 Starting Large Firebase seed script (100+ items)...\n');

// Turkish cities
const cities = [
  'Istanbul', 'Ankara', 'Izmir', 'Bursa', 'Antalya', 
  'Adana', 'Konya', 'Gaziantep', 'Mersin', 'Kayseri'
];

// Expanded user data
const additionalUsers = [
  { email: 'mehmet.yilmaz@example.com', name: 'Mehmet Yılmaz', city: 'Istanbul' },
  { email: 'ayse.kaya@example.com', name: 'Ayşe Kaya', city: 'Ankara' },
  { email: 'ahmet.demir@example.com', name: 'Ahmet Demir', city: 'Izmir' },
  { email: 'fatma.celik@example.com', name: 'Fatma Çelik', city: 'Bursa' },
  { email: 'mustafa.sahin@example.com', name: 'Mustafa Şahin', city: 'Antalya' },
];

// Comprehensive product database (100+ items)
const productDatabase = {
  electronics: [
    // Smartphones (15 items)
    { title: 'iPhone 15 Pro Max - 512GB Natural Titanium', price: 75000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'iPhone 14 Pro - 256GB Deep Purple', price: 55000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'iPhone 13 - 128GB Midnight', price: 38000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'Samsung Galaxy S24 Ultra - 512GB', price: 65000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Samsung Galaxy S23 - 256GB', price: 42000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'Google Pixel 8 Pro - 256GB', price: 48000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'Xiaomi 13 Pro - 256GB', price: 35000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'OnePlus 11 - 256GB', price: 32000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'Oppo Find X6 Pro', price: 38000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Realme GT 3 - 256GB', price: 25000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'iPhone SE 2022 - 128GB', price: 22000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'Samsung Galaxy A54 - 256GB', price: 18000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Xiaomi Redmi Note 12 Pro', price: 15000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'Huawei P60 Pro', price: 40000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Nothing Phone 2', price: 28000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    
    // Laptops (15 items)
    { title: 'MacBook Pro M3 Max - 16" 1TB', price: 120000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'MacBook Air M2 - 512GB', price: 62000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'Dell XPS 15 - i7 32GB RAM', price: 85000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'HP Spectre x360 - i7 16GB', price: 52000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'Lenovo ThinkPad X1 Carbon', price: 68000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'ASUS ROG Zephyrus G14 Gaming', price: 75000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'MSI GE76 Raider Gaming Laptop', price: 82000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'Acer Predator Helios 300', price: 48000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'Microsoft Surface Laptop 5', price: 58000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Razer Blade 15 Advanced', price: 95000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'LG Gram 17" Ultra-light', price: 55000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'Samsung Galaxy Book Pro 360', price: 45000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'HP Envy 13 - i5 16GB', price: 38000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'Huawei MateBook X Pro', price: 48000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Lenovo Yoga 9i - 2-in-1', price: 52000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    
    // Tablets (10 items)
    { title: 'iPad Pro 12.9" M2 - 512GB', price: 58000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'iPad Air 5th Gen - 256GB', price: 35000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'iPad 10th Gen - 256GB', price: 22000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Samsung Galaxy Tab S9 Ultra', price: 52000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'Samsung Galaxy Tab S8+ 256GB', price: 32000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'Microsoft Surface Pro 9', price: 48000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Lenovo Tab P12 Pro', price: 28000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'Huawei MatePad Pro', price: 25000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'Xiaomi Pad 6 Pro', price: 18000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Amazon Fire HD 10 Plus', price: 8500, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    
    // Headphones & Audio (10 items)
    { title: 'AirPods Pro 2nd Gen', price: 12000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Sony WH-1000XM5 Headphones', price: 16000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'Bose QuietComfort 45', price: 14000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'Sennheiser Momentum 4', price: 15000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Apple AirPods Max', price: 25000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'Samsung Galaxy Buds2 Pro', price: 6500, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Jabra Elite 85h', price: 8500, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'Beats Studio Pro', price: 11000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'JBL Tune 750BTNC', price: 4500, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'Anker Soundcore Life Q30', price: 3200, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    
    // Smartwatches (10 items)
    { title: 'Apple Watch Series 9 - 45mm GPS', price: 22000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Apple Watch Ultra 2', price: 42000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'Samsung Galaxy Watch 6 Classic', price: 15000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Garmin Fenix 7X Sapphire', price: 28000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'Fitbit Sense 2', price: 8500, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'Huawei Watch GT 3 Pro', price: 10000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Amazfit GTR 4', price: 6500, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'Fossil Gen 6', price: 9500, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'TicWatch Pro 5', price: 12000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Withings ScanWatch Horizon', price: 14000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
  ],
  
  fashion: [
    // Designer Bags (10 items)
    { title: 'Louis Vuitton Neverfull MM', price: 45000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'Gucci Marmont Medium', price: 38000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'Prada Galleria Saffiano', price: 42000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'Michael Kors Jet Set Travel', price: 8500, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'Coach Tabby Shoulder Bag', price: 12000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Kate Spade Cameron Street', price: 6500, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'Furla Metropolis Mini', price: 9500, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'Longchamp Le Pliage Large', price: 5500, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Ted Baker Icon Bag', price: 7500, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'Tommy Hilfiger Crossbody', price: 4200, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    
    // Sneakers (15 items)
    { title: 'Nike Air Jordan 1 High OG', price: 9500, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Adidas Yeezy Boost 350 V2', price: 8500, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'Nike Air Max 270', price: 4500, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'New Balance 550', price: 5200, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Puma RS-X', price: 3800, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'Converse Chuck 70 High', price: 2500, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'Vans Old Skool', price: 2200, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Reebok Club C 85', price: 3200, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'Asics Gel-Lyte III', price: 4200, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'Nike Dunk Low Retro', price: 5500, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Adidas Ultraboost 22', price: 6500, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'On Cloud X', price: 5800, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'Salomon Speedcross 5', price: 4500, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Hoka One One Clifton 9', price: 6200, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'Brooks Ghost 15', price: 5200, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    
    // Clothing (10 items)
    { title: 'Zara Premium Wool Coat', price: 3200, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'H&M Studio Collection Dress', price: 1200, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'Mango Leather Jacket', price: 2800, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'Massimo Dutti Blazer', price: 1800, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'COS Minimalist Trench Coat', price: 2500, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'Uniqlo U Collection Sweater', price: 850, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'Pull&Bear Denim Jacket', price: 950, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Bershka Cargo Pants', price: 750, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'Stradivarius Midi Skirt', price: 650, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'Reserved Oversized Hoodie', price: 950, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
  ],
  
  books: [
    { title: 'Harry Potter Complete Series (7 books)', price: 1200, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'The Lord of the Rings Trilogy Boxset', price: 950, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'Atomic Habits by James Clear', price: 250, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Sapiens by Yuval Noah Harari', price: 280, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: '1984 by George Orwell', price: 180, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'The Alchemist by Paulo Coelho', price: 220, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Think and Grow Rich - Napoleon Hill', price: 240, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'Rich Dad Poor Dad', price: 260, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'The Subtle Art of Not Giving a F*ck', price: 235, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Zero to One - Peter Thiel', price: 270, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
  ],
  
  home: [
    { title: 'IKEA SÖDERHAMN 3-Seat Sofa', price: 12000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'Modern Coffee Table - Oak Wood', price: 3500, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Philips Hue Smart Bulb Set (4 pcs)', price: 1800, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Dyson V15 Vacuum Cleaner', price: 22000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'KitchenAid Stand Mixer', price: 8500, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'Nespresso Vertuo Coffee Machine', price: 6500, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Philips Air Fryer XXL', price: 4200, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'Samsung 55" 4K Smart TV', price: 28000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'Herman Miller Aeron Chair', price: 18000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'West Elm Mid-Century Desk', price: 9500, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
  ],
  
  sports: [
    { title: 'Trek Domane SL 5 Road Bike', price: 45000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'Giant TCR Advanced Pro', price: 38000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'Bowflex SelectTech Dumbbells', price: 8500, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Peloton Bike+', price: 65000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'Wilson Pro Staff Tennis Racket', price: 4500, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'Yoga Mat Premium Set', price: 850, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Garmin Edge 1040 GPS Bike Computer', price: 12000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
    { title: 'TRX Suspension Training Kit', price: 2200, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Good' },
    { title: 'NordicTrack Treadmill T Series', price: 32000, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Brand New' },
    { title: 'Kettlebell Set 8-24kg', price: 3500, images: ['https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg'], condition: 'Like New' },
  ],
};

// Helper function to get random item from array
const randomItem = (arr) => arr[Math.floor(Math.random() * arr.length)];

// Helper to generate location with coordinates
const locationData = {
  'Istanbul': { lat: 41.0082, lng: 28.9784, districts: ['Kadıköy', 'Beşiktaş', 'Şişli', 'Üsküdar'] },
  'Ankara': { lat: 39.9334, lng: 32.8597, districts: ['Çankaya', 'Keçiören', 'Mamak', 'Yenimahalle'] },
  'Izmir': { lat: 38.4237, lng: 27.1428, districts: ['Konak', 'Bornova', 'Karşıyaka', 'Buca'] },
  'Bursa': { lat: 40.1826, lng: 29.0665, districts: ['Osmangazi', 'Yıldırım', 'Nilüfer', 'Gemlik'] },
  'Antalya': { lat: 36.8969, lng: 30.7133, districts: ['Muratpaşa', 'Kepez', 'Konyaaltı', 'Alanya'] },
  'Adana': { lat: 37.0000, lng: 35.3213, districts: ['Seyhan', 'Yüreğir', 'Çukurova', 'Sarıçam'] },
  'Konya': { lat: 37.8746, lng: 32.4932, districts: ['Meram', 'Selçuklu', 'Karatay', 'Ereğli'] },
  'Gaziantep': { lat: 37.0662, lng: 37.3833, districts: ['Şahinbey', 'Şehitkamil', 'Oğuzeli', 'Nizip'] },
  'Mersin': { lat: 36.8121, lng: 34.6415, districts: ['Akdeniz', 'Toroslar', 'Mezitli', 'Yenişehir'] },
  'Kayseri': { lat: 38.7312, lng: 35.4787, districts: ['Kocasinan', 'Melikgazi', 'Talas', 'Develi'] },
};

async function ensureUserProfile(userId, displayName, preferredCity) {
  const userRef = db.collection('users').doc(userId);
  const snapshot = await userRef.get();
  const data = snapshot.data() || {};
  const hasLocation =
    data.city &&
    data.location &&
    typeof data.latitude === 'number' &&
    typeof data.longitude === 'number';

  if (hasLocation) {
    return;
  }

  const availableCities = Object.keys(locationData);
  const city = preferredCity && locationData[preferredCity]
    ? preferredCity
    : availableCities[Math.floor(Math.random() * availableCities.length)];

  const cityMeta = locationData[city];
  const district = cityMeta.districts[Math.floor(Math.random() * cityMeta.districts.length)];
  const lat = cityMeta.lat + (Math.random() * 0.02 - 0.01);
  const lng = cityMeta.lng + (Math.random() * 0.02 - 0.01);

  await userRef.set({
    uid: userId,
    displayName: data.displayName || displayName || 'Trader',
    city,
    district,
    location: `${district}, ${city}`,
    latitude: Number(lat.toFixed(6)),
    longitude: Number(lng.toFixed(6)),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });

  console.log(`📍 Seeded location for ${displayName || userId}: ${district}, ${city}`);
}

// Seed function
async function seedDatabase() {
  const userIds = [];

  // Step 1: Create users
  console.log('🔑 Creating users...');
  
  const existingUsers = ['alice.johnson@example.com', 'bob.smith@example.com', 
    'carol.white@example.com', 'david.brown@example.com', 'emma.davis@example.com',
    'frank.miller@example.com', 'grace.lee@example.com', 'henry.wilson@example.com',
    'isabel.garcia@example.com', 'jack.taylor@example.com'];
  
  for (const email of existingUsers) {
    try {
      const user = await auth.getUserByEmail(email);
      userIds.push(user.uid);
      console.log(`✅ User exists: ${email}`);
      await ensureUserProfile(user.uid, user.displayName, null);
    } catch (error) {
      console.log(`⚠️  User not found: ${email}`);
    }
  }
  
  // Create additional users
  for (const userData of additionalUsers) {
    try {
      const user = await auth.getUserByEmail(userData.email);
      userIds.push(user.uid);
      console.log(`✅ User exists: ${userData.name}`);
      await ensureUserProfile(user.uid, userData.name, userData.city);
    } catch (error) {
      // Create new user
      try {
        const newUser = await auth.createUser({
          email: userData.email,
          password: 'Test123!',
          displayName: userData.name,
        });
        userIds.push(newUser.uid);
        console.log(`✅ Created user: ${userData.name}`);
        await ensureUserProfile(newUser.uid, userData.name, userData.city);
      } catch (createError) {
        console.log(`⚠️  Could not create: ${userData.name}`);
      }
    }
  }

  // Step 2: Create 100+ items
  console.log('\n📦 Creating 100+ items...');
  
  let itemCount = 0;
  const categories = Object.keys(productDatabase);
  
  for (const category of categories) {
    const products = productDatabase[category];
    
    for (const product of products) {
      const randomUserId = randomItem(userIds);
      const randomCity = randomItem(cities);
      const cityData = locationData[randomCity];
      const randomDistrict = randomItem(cityData.districts);
      
      // Add some variance to coordinates (±0.01 degrees)
      const lat = cityData.lat + (Math.random() * 0.02 - 0.01);
      const lng = cityData.lng + (Math.random() * 0.02 - 0.01);
      
      const itemData = {
        title: product.title,
        description: `${product.title} - Excellent condition. ${category === 'electronics' ? 'All accessories included.' : 'Original packaging available.'}`,
        category: category.charAt(0).toUpperCase() + category.slice(0, -1), // Electronics, Fashion, etc.
        images: product.images,
        price: product.price,
        condition: product.condition,
        location: `${randomDistrict}, ${randomCity}`,
        city: randomCity,
        district: randomDistrict,
        latitude: lat,
        longitude: lng,
        status: 'active',
        isFeatured: Math.random() > 0.7, // 30% featured
        ownerId: randomUserId,
        ownerName: 'User',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        viewCount: Math.floor(Math.random() * 100),
        favoriteCount: Math.floor(Math.random() * 20),
        moderationStatus: 'approved',
      };
      
      // Add barter conditions for some items
      if (category === 'electronics' && Math.random() > 0.5) {
        itemData.barterCondition = {
          acceptedCategories: ['Electronics', 'Fashion'],
          minimumValue: product.price * 0.7,
        };
      }
      
      await db.collection('items').add(itemData);
      itemCount++;
      
      if (itemCount % 10 === 0) {
        console.log(`✅ Created ${itemCount} items...`);
      }
    }
  }
  
  console.log(`\n✅ ✅ ✅ Total ${itemCount} items created successfully!\n`);
  console.log('📊 Summary:');
  console.log(`   Users: ${userIds.length}`);
  console.log(`   Items: ${itemCount}`);
  console.log(`\n🎉 You can now test the app with 100+ items!`);
}

// Run seed
seedDatabase()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error('Error seeding database:', error);
    process.exit(1);
  });


