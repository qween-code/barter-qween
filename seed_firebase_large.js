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
    { title: 'iPhone 15 Pro Max - 512GB Natural Titanium', price: 75000, images: ['https://images.unsplash.com/photo-1695048064583-5faf9f0b5e6f?w=800'], condition: 'Brand New' },
    { title: 'iPhone 14 Pro - 256GB Deep Purple', price: 55000, images: ['https://images.unsplash.com/photo-1663499482523-1c0f6c8c5f8a?w=800'], condition: 'Like New' },
    { title: 'iPhone 13 - 128GB Midnight', price: 38000, images: ['https://images.unsplash.com/photo-1632661674596-df8be070a5c5?w=800'], condition: 'Good' },
    { title: 'Samsung Galaxy S24 Ultra - 512GB', price: 65000, images: ['https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=800'], condition: 'Brand New' },
    { title: 'Samsung Galaxy S23 - 256GB', price: 42000, images: ['https://images.unsplash.com/photo-1610792516307-ea5acd9c3b00?w=800'], condition: 'Like New' },
    { title: 'Google Pixel 8 Pro - 256GB', price: 48000, images: ['https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=800'], condition: 'Like New' },
    { title: 'Xiaomi 13 Pro - 256GB', price: 35000, images: ['https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=800'], condition: 'Good' },
    { title: 'OnePlus 11 - 256GB', price: 32000, images: ['https://images.unsplash.com/photo-1565849904461-04a3b6c2eb2f?w=800'], condition: 'Like New' },
    { title: 'Oppo Find X6 Pro', price: 38000, images: ['https://images.unsplash.com/photo-1574944985070-8f3ebc6b79d2?w=800'], condition: 'Brand New' },
    { title: 'Realme GT 3 - 256GB', price: 25000, images: ['https://images.unsplash.com/photo-1585060544812-6b45742d762f?w=800'], condition: 'Like New' },
    { title: 'iPhone SE 2022 - 128GB', price: 22000, images: ['https://images.unsplash.com/photo-1605236453806-6ff36851218e?w=800'], condition: 'Good' },
    { title: 'Samsung Galaxy A54 - 256GB', price: 18000, images: ['https://images.unsplash.com/photo-1610945264803-c22b62d2a7b6?w=800'], condition: 'Brand New' },
    { title: 'Xiaomi Redmi Note 12 Pro', price: 15000, images: ['https://images.unsplash.com/photo-1598507778696-a71db8043a45?w=800'], condition: 'Like New' },
    { title: 'Huawei P60 Pro', price: 40000, images: ['https://images.unsplash.com/photo-1574944985070-8f3ebc6b79d2?w=800'], condition: 'Brand New' },
    { title: 'Nothing Phone 2', price: 28000, images: ['https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=800'], condition: 'Like New' },
    
    // Laptops (15 items)
    { title: 'MacBook Pro M3 Max - 16" 1TB', price: 120000, images: ['https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800'], condition: 'Brand New' },
    { title: 'MacBook Air M2 - 512GB', price: 62000, images: ['https://images.unsplash.com/photo-1611186871348-b1ce696e52c9?w=800'], condition: 'Like New' },
    { title: 'Dell XPS 15 - i7 32GB RAM', price: 85000, images: ['https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=800'], condition: 'Like New' },
    { title: 'HP Spectre x360 - i7 16GB', price: 52000, images: ['https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=800'], condition: 'Good' },
    { title: 'Lenovo ThinkPad X1 Carbon', price: 68000, images: ['https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=800'], condition: 'Like New' },
    { title: 'ASUS ROG Zephyrus G14 Gaming', price: 75000, images: ['https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=800'], condition: 'Brand New' },
    { title: 'MSI GE76 Raider Gaming Laptop', price: 82000, images: ['https://images.unsplash.com/photo-1625225233840-695456021cde?w=800'], condition: 'Like New' },
    { title: 'Acer Predator Helios 300', price: 48000, images: ['https://images.unsplash.com/photo-1587202372634-32705e3bf49c?w=800'], condition: 'Good' },
    { title: 'Microsoft Surface Laptop 5', price: 58000, images: ['https://images.unsplash.com/photo-1604589167198-eb3fdc233648?w=800'], condition: 'Brand New' },
    { title: 'Razer Blade 15 Advanced', price: 95000, images: ['https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=800'], condition: 'Like New' },
    { title: 'LG Gram 17" Ultra-light', price: 55000, images: ['https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=800'], condition: 'Good' },
    { title: 'Samsung Galaxy Book Pro 360', price: 45000, images: ['https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=800'], condition: 'Like New' },
    { title: 'HP Envy 13 - i5 16GB', price: 38000, images: ['https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=800'], condition: 'Good' },
    { title: 'Huawei MateBook X Pro', price: 48000, images: ['https://images.unsplash.com/photo-1611186871348-b1ce696e52c9?w=800'], condition: 'Brand New' },
    { title: 'Lenovo Yoga 9i - 2-in-1', price: 52000, images: ['https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=800'], condition: 'Like New' },
    
    // Tablets (10 items)
    { title: 'iPad Pro 12.9" M2 - 512GB', price: 58000, images: ['https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=800'], condition: 'Brand New' },
    { title: 'iPad Air 5th Gen - 256GB', price: 35000, images: ['https://images.unsplash.com/photo-1561154464-82e9adf32764?w=800'], condition: 'Like New' },
    { title: 'iPad 10th Gen - 256GB', price: 22000, images: ['https://images.unsplash.com/photo-1585790050230-5dd28404f1bb?w=800'], condition: 'Brand New' },
    { title: 'Samsung Galaxy Tab S9 Ultra', price: 52000, images: ['https://images.unsplash.com/photo-1611532736597-de2d4265fba3?w=800'], condition: 'Like New' },
    { title: 'Samsung Galaxy Tab S8+ 256GB', price: 32000, images: ['https://images.unsplash.com/photo-1585790050230-5dd28404f1bb?w=800'], condition: 'Good' },
    { title: 'Microsoft Surface Pro 9', price: 48000, images: ['https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=800'], condition: 'Brand New' },
    { title: 'Lenovo Tab P12 Pro', price: 28000, images: ['https://images.unsplash.com/photo-1611532736597-de2d4265fba3?w=800'], condition: 'Like New' },
    { title: 'Huawei MatePad Pro', price: 25000, images: ['https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=800'], condition: 'Good' },
    { title: 'Xiaomi Pad 6 Pro', price: 18000, images: ['https://images.unsplash.com/photo-1585790050230-5dd28404f1bb?w=800'], condition: 'Brand New' },
    { title: 'Amazon Fire HD 10 Plus', price: 8500, images: ['https://images.unsplash.com/photo-1561154464-82e9adf32764?w=800'], condition: 'Like New' },
    
    // Headphones & Audio (10 items)
    { title: 'AirPods Pro 2nd Gen', price: 12000, images: ['https://images.unsplash.com/photo-1606841837239-c5a1a4a07af7?w=800'], condition: 'Brand New' },
    { title: 'Sony WH-1000XM5 Headphones', price: 16000, images: ['https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=800'], condition: 'Like New' },
    { title: 'Bose QuietComfort 45', price: 14000, images: ['https://images.unsplash.com/photo-1484704849700-f032a568e944?w=800'], condition: 'Good' },
    { title: 'Sennheiser Momentum 4', price: 15000, images: ['https://images.unsplash.com/photo-1545127398-14699f92334b?w=800'], condition: 'Brand New' },
    { title: 'Apple AirPods Max', price: 25000, images: ['https://images.unsplash.com/photo-1625738415213-86a9e6c8c58e?w=800'], condition: 'Like New' },
    { title: 'Samsung Galaxy Buds2 Pro', price: 6500, images: ['https://images.unsplash.com/photo-1606841837239-c5a1a4a07af7?w=800'], condition: 'Brand New' },
    { title: 'Jabra Elite 85h', price: 8500, images: ['https://images.unsplash.com/photo-1484704849700-f032a568e944?w=800'], condition: 'Good' },
    { title: 'Beats Studio Pro', price: 11000, images: ['https://images.unsplash.com/photo-1545127398-14699f92334b?w=800'], condition: 'Like New' },
    { title: 'JBL Tune 750BTNC', price: 4500, images: ['https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=800'], condition: 'Good' },
    { title: 'Anker Soundcore Life Q30', price: 3200, images: ['https://images.unsplash.com/photo-1484704849700-f032a568e944?w=800'], condition: 'Brand New' },
    
    // Smartwatches (10 items)
    { title: 'Apple Watch Series 9 - 45mm GPS', price: 22000, images: ['https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=800'], condition: 'Brand New' },
    { title: 'Apple Watch Ultra 2', price: 42000, images: ['https://images.unsplash.com/photo-1434494878577-86c23bcb06b9?w=800'], condition: 'Like New' },
    { title: 'Samsung Galaxy Watch 6 Classic', price: 15000, images: ['https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800'], condition: 'Brand New' },
    { title: 'Garmin Fenix 7X Sapphire', price: 28000, images: ['https://images.unsplash.com/photo-1617625802912-cde586faf331?w=800'], condition: 'Like New' },
    { title: 'Fitbit Sense 2', price: 8500, images: ['https://images.unsplash.com/photo-1575311373937-040b8e1fd5b6?w=800'], condition: 'Good' },
    { title: 'Huawei Watch GT 3 Pro', price: 10000, images: ['https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800'], condition: 'Brand New' },
    { title: 'Amazfit GTR 4', price: 6500, images: ['https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=800'], condition: 'Like New' },
    { title: 'Fossil Gen 6', price: 9500, images: ['https://images.unsplash.com/photo-1617625802912-cde586faf331?w=800'], condition: 'Good' },
    { title: 'TicWatch Pro 5', price: 12000, images: ['https://images.unsplash.com/photo-1575311373937-040b8e1fd5b6?w=800'], condition: 'Brand New' },
    { title: 'Withings ScanWatch Horizon', price: 14000, images: ['https://images.unsplash.com/photo-1434494878577-86c23bcb06b9?w=800'], condition: 'Like New' },
  ],
  
  fashion: [
    // Designer Bags (10 items)
    { title: 'Louis Vuitton Neverfull MM', price: 45000, images: ['https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=800'], condition: 'Like New' },
    { title: 'Gucci Marmont Medium', price: 38000, images: ['https://images.unsplash.com/photo-1566150905458-1bf1fc113f0d?w=800'], condition: 'Good' },
    { title: 'Prada Galleria Saffiano', price: 42000, images: ['https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=800'], condition: 'Like New' },
    { title: 'Michael Kors Jet Set Travel', price: 8500, images: ['https://images.unsplash.com/photo-1591561954557-26941169b49e?w=800'], condition: 'Good' },
    { title: 'Coach Tabby Shoulder Bag', price: 12000, images: ['https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=800'], condition: 'Brand New' },
    { title: 'Kate Spade Cameron Street', price: 6500, images: ['https://images.unsplash.com/photo-1566150905458-1bf1fc113f0d?w=800'], condition: 'Like New' },
    { title: 'Furla Metropolis Mini', price: 9500, images: ['https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=800'], condition: 'Good' },
    { title: 'Longchamp Le Pliage Large', price: 5500, images: ['https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=800'], condition: 'Brand New' },
    { title: 'Ted Baker Icon Bag', price: 7500, images: ['https://images.unsplash.com/photo-1591561954557-26941169b49e?w=800'], condition: 'Like New' },
    { title: 'Tommy Hilfiger Crossbody', price: 4200, images: ['https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=800'], condition: 'Good' },
    
    // Sneakers (15 items)
    { title: 'Nike Air Jordan 1 High OG', price: 9500, images: ['https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800'], condition: 'Brand New' },
    { title: 'Adidas Yeezy Boost 350 V2', price: 8500, images: ['https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=800'], condition: 'Like New' },
    { title: 'Nike Air Max 270', price: 4500, images: ['https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=800'], condition: 'Good' },
    { title: 'New Balance 550', price: 5200, images: ['https://images.unsplash.com/photo-1539185441755-769473a23570?w=800'], condition: 'Brand New' },
    { title: 'Puma RS-X', price: 3800, images: ['https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=800'], condition: 'Like New' },
    { title: 'Converse Chuck 70 High', price: 2500, images: ['https://images.unsplash.com/photo-1605348532760-6753d2c43329?w=800'], condition: 'Good' },
    { title: 'Vans Old Skool', price: 2200, images: ['https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?w=800'], condition: 'Brand New' },
    { title: 'Reebok Club C 85', price: 3200, images: ['https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=800'], condition: 'Like New' },
    { title: 'Asics Gel-Lyte III', price: 4200, images: ['https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=800'], condition: 'Good' },
    { title: 'Nike Dunk Low Retro', price: 5500, images: ['https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800'], condition: 'Brand New' },
    { title: 'Adidas Ultraboost 22', price: 6500, images: ['https://images.unsplash.com/photo-1539185441755-769473a23570?w=800'], condition: 'Like New' },
    { title: 'On Cloud X', price: 5800, images: ['https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=800'], condition: 'Good' },
    { title: 'Salomon Speedcross 5', price: 4500, images: ['https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=800'], condition: 'Brand New' },
    { title: 'Hoka One One Clifton 9', price: 6200, images: ['https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=800'], condition: 'Like New' },
    { title: 'Brooks Ghost 15', price: 5200, images: ['https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800'], condition: 'Good' },
    
    // Clothing (10 items)
    { title: 'Zara Premium Wool Coat', price: 3200, images: ['https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=800'], condition: 'Brand New' },
    { title: 'H&M Studio Collection Dress', price: 1200, images: ['https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=800'], condition: 'Like New' },
    { title: 'Mango Leather Jacket', price: 2800, images: ['https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800'], condition: 'Good' },
    { title: 'Massimo Dutti Blazer', price: 1800, images: ['https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=800'], condition: 'Brand New' },
    { title: 'COS Minimalist Trench Coat', price: 2500, images: ['https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=800'], condition: 'Like New' },
    { title: 'Uniqlo U Collection Sweater', price: 850, images: ['https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=800'], condition: 'Good' },
    { title: 'Pull&Bear Denim Jacket', price: 950, images: ['https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800'], condition: 'Brand New' },
    { title: 'Bershka Cargo Pants', price: 750, images: ['https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=800'], condition: 'Like New' },
    { title: 'Stradivarius Midi Skirt', price: 650, images: ['https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?w=800'], condition: 'Good' },
    { title: 'Reserved Oversized Hoodie', price: 950, images: ['https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800'], condition: 'Brand New' },
  ],
  
  books: [
    { title: 'Harry Potter Complete Series (7 books)', price: 1200, images: ['https://images.unsplash.com/photo-1618365908648-e71bd5716cba?w=800'], condition: 'Good' },
    { title: 'The Lord of the Rings Trilogy Boxset', price: 950, images: ['https://images.unsplash.com/photo-1621351183012-e2f9972dd9bf?w=800'], condition: 'Like New' },
    { title: 'Atomic Habits by James Clear', price: 250, images: ['https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=800'], condition: 'Brand New' },
    { title: 'Sapiens by Yuval Noah Harari', price: 280, images: ['https://images.unsplash.com/photo-1589998059171-988d887df646?w=800'], condition: 'Like New' },
    { title: '1984 by George Orwell', price: 180, images: ['https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=800'], condition: 'Good' },
    { title: 'The Alchemist by Paulo Coelho', price: 220, images: ['https://images.unsplash.com/photo-1512820790803-83ca734da794?w=800'], condition: 'Brand New' },
    { title: 'Think and Grow Rich - Napoleon Hill', price: 240, images: ['https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=800'], condition: 'Like New' },
    { title: 'Rich Dad Poor Dad', price: 260, images: ['https://images.unsplash.com/photo-1589998059171-988d887df646?w=800'], condition: 'Good' },
    { title: 'The Subtle Art of Not Giving a F*ck', price: 235, images: ['https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=800'], condition: 'Brand New' },
    { title: 'Zero to One - Peter Thiel', price: 270, images: ['https://images.unsplash.com/photo-1512820790803-83ca734da794?w=800'], condition: 'Like New' },
  ],
  
  home: [
    { title: 'IKEA SÖDERHAMN 3-Seat Sofa', price: 12000, images: ['https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800'], condition: 'Good' },
    { title: 'Modern Coffee Table - Oak Wood', price: 3500, images: ['https://images.unsplash.com/photo-1532372320572-cda25653a26d?w=800'], condition: 'Brand New' },
    { title: 'Philips Hue Smart Bulb Set (4 pcs)', price: 1800, images: ['https://images.unsplash.com/photo-1543198126-a8ea833d46fc?w=800'], condition: 'Brand New' },
    { title: 'Dyson V15 Vacuum Cleaner', price: 22000, images: ['https://images.unsplash.com/photo-1558317374-067fb5f30001?w=800'], condition: 'Like New' },
    { title: 'KitchenAid Stand Mixer', price: 8500, images: ['https://images.unsplash.com/photo-1570222094114-d054a817e56b?w=800'], condition: 'Good' },
    { title: 'Nespresso Vertuo Coffee Machine', price: 6500, images: ['https://images.unsplash.com/photo-1517668808822-9ebb02f2a0e6?w=800'], condition: 'Brand New' },
    { title: 'Philips Air Fryer XXL', price: 4200, images: ['https://images.unsplash.com/photo-1585771724684-38269d6639fd?w=800'], condition: 'Like New' },
    { title: 'Samsung 55" 4K Smart TV', price: 28000, images: ['https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?w=800'], condition: 'Good' },
    { title: 'Herman Miller Aeron Chair', price: 18000, images: ['https://images.unsplash.com/photo-1592078615290-033ee584e267?w=800'], condition: 'Like New' },
    { title: 'West Elm Mid-Century Desk', price: 9500, images: ['https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=800'], condition: 'Good' },
  ],
  
  sports: [
    { title: 'Trek Domane SL 5 Road Bike', price: 45000, images: ['https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=800'], condition: 'Like New' },
    { title: 'Giant TCR Advanced Pro', price: 38000, images: ['https://images.unsplash.com/photo-1532298229144-0ec0c57515c7?w=800'], condition: 'Good' },
    { title: 'Bowflex SelectTech Dumbbells', price: 8500, images: ['https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800'], condition: 'Brand New' },
    { title: 'Peloton Bike+', price: 65000, images: ['https://images.unsplash.com/photo-1551958219-acbc608c6377?w=800'], condition: 'Like New' },
    { title: 'Wilson Pro Staff Tennis Racket', price: 4500, images: ['https://images.unsplash.com/photo-1622163642998-1ea32b0bbc67?w=800'], condition: 'Good' },
    { title: 'Yoga Mat Premium Set', price: 850, images: ['https://images.unsplash.com/photo-1601925260368-ae2f83cf8b7f?w=800'], condition: 'Brand New' },
    { title: 'Garmin Edge 1040 GPS Bike Computer', price: 12000, images: ['https://images.unsplash.com/photo-1561391657-5b0b8f0d8c25?w=800'], condition: 'Like New' },
    { title: 'TRX Suspension Training Kit', price: 2200, images: ['https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800'], condition: 'Good' },
    { title: 'NordicTrack Treadmill T Series', price: 32000, images: ['https://images.unsplash.com/photo-1576678927484-cc907957088c?w=800'], condition: 'Brand New' },
    { title: 'Kettlebell Set 8-24kg', price: 3500, images: ['https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800'], condition: 'Like New' },
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
