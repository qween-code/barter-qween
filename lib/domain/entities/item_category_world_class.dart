// World-Class Item Categories
// Based on Depop, Vinted, Poshmark, OfferUp, Mercari, Facebook Marketplace
//
// 24 Main Categories | 200+ Subcategories | Size Systems | Measurement Types

class ItemCategory {
  // ========================================
  // MAIN CATEGORIES (24 Categories)
  // ========================================

  static const String womensFashion = "Women's Fashion";
  static const String mensFashion = "Men's Fashion";
  static const String shoes = 'Shoes';
  static const String bagsAccessories = 'Bags & Accessories';
  static const String jewelryWatches = 'Jewelry & Watches';
  static const String beauty = 'Beauty & Personal Care';
  static const String electronics = 'Electronics';
  static const String homeLiving = 'Home & Living';
  static const String kidsBaby = 'Kids & Baby';
  static const String sportsOutdoors = 'Sports & Outdoors';
  static const String entertainment = 'Books, Movies & Music';
  static const String hobbiesCrafts = 'Hobbies & Crafts';
  static const String pets = 'Pets';
  static const String automotive = 'Automotive';
  static const String vintageCollectibles = 'Vintage & Collectibles';
  static const String handmade = 'Handmade';
  static const String officeStationery = 'Office & Stationery';
  static const String healthWellness = 'Health & Wellness';
  static const String gardenOutdoor = 'Garden & Outdoor';
  static const String partyEvents = 'Party & Events';
  static const String foodBeverage = 'Food & Beverage';
  static const String travelLuggage = 'Travel & Luggage';
  static const String services = 'Services';
  static const String freeStuff = 'Free Stuff';

  static List<String> get all => [
    womensFashion,
    mensFashion,
    shoes,
    bagsAccessories,
    jewelryWatches,
    beauty,
    electronics,
    homeLiving,
    kidsBaby,
    sportsOutdoors,
    entertainment,
    hobbiesCrafts,
    pets,
    automotive,
    vintageCollectibles,
    handmade,
    officeStationery,
    healthWellness,
    gardenOutdoor,
    partyEvents,
    foodBeverage,
    travelLuggage,
    services,
    freeStuff,
  ];

  // ========================================
  // CATEGORY ICONS
  // ========================================

  static const Map<String, String> icons = {
    womensFashion: '👗',
    mensFashion: '👔',
    shoes: '👟',
    bagsAccessories: '👜',
    jewelryWatches: '💍',
    beauty: '💄',
    electronics: '📱',
    homeLiving: '🏠',
    kidsBaby: '👶',
    sportsOutdoors: '⚽',
    entertainment: '📚',
    hobbiesCrafts: '🎨',
    pets: '🐾',
    automotive: '🚗',
    vintageCollectibles: '🕰️',
    handmade: '✋',
    officeStationery: '📎',
    healthWellness: '🧘',
    gardenOutdoor: '🌱',
    partyEvents: '🎉',
    foodBeverage: '☕',
    travelLuggage: '✈️',
    services: '🔧',
    freeStuff: '🎁',
  };

  // ========================================
  // SUBCATEGORIES (200+ Subcategories)
  // ========================================

  static const Map<String, List<String>> subcategories = {
    womensFashion: [
      // Tops
      'T-Shirts & Tanks',
      'Blouses & Shirts',
      'Sweaters & Cardigans',
      'Hoodies & Sweatshirts',
      'Crop Tops',
      'Bodysuits',
      'Tunics',
      'Camisoles',
      // Bottoms
      'Jeans',
      'Pants & Trousers',
      'Leggings',
      'Skirts',
      'Shorts',
      'Culottes',
      // Dresses
      'Mini Dresses',
      'Midi Dresses',
      'Maxi Dresses',
      'Evening Dresses',
      'Casual Dresses',
      'Formal Dresses',
      'Party Dresses',
      'Summer Dresses',
      'Wedding Guest Dresses',
      // Outerwear
      'Coats & Jackets',
      'Leather Jackets',
      'Denim Jackets',
      'Bomber Jackets',
      'Blazers',
      'Vests',
      'Puffer Jackets',
      'Trench Coats',
      'Parkas',
      // Activewear
      'Sports Bras',
      'Leggings & Tights',
      'Athletic Shorts',
      'Track Suits',
      'Yoga Wear',
      // Intimates & Sleepwear
      'Bras',
      'Panties',
      'Lingerie Sets',
      'Nightgowns',
      'Pajamas',
      'Robes',
      // Swimwear
      'Bikinis',
      'One-Piece Swimsuits',
      'Cover-Ups',
      // Maternity
      'Maternity Tops',
      'Maternity Dresses',
      'Maternity Pants',
      // Other
      'Jumpsuits & Rompers',
      'Co-ord Sets',
      'Vintage',
      'Plus Size',
    ],

    mensFashion: [
      // Tops
      'T-Shirts',
      'Shirts',
      'Polo Shirts',
      'Sweaters',
      'Hoodies',
      'Tank Tops',
      'Henley Shirts',
      // Bottoms
      'Jeans',
      'Pants',
      'Shorts',
      'Chinos',
      'Sweatpants',
      'Cargo Pants',
      // Outerwear
      'Jackets',
      'Coats',
      'Blazers',
      'Bomber Jackets',
      'Leather Jackets',
      'Denim Jackets',
      'Puffer Jackets',
      'Vests',
      // Suits & Formal
      'Suits',
      'Tuxedos',
      'Dress Shirts',
      'Ties & Bow Ties',
      // Activewear
      'Athletic Shorts',
      'Track Suits',
      'Performance Tops',
      'Compression Wear',
      // Underwear & Sleepwear
      'Boxers & Briefs',
      'Undershirts',
      'Pajamas',
      'Robes',
      // Swimwear
      'Swim Trunks',
      'Board Shorts',
      // Other
      'Big & Tall',
      'Vintage',
    ],

    shoes: [
      // Women's
      "Women's Sneakers",
      "Women's Boots",
      "Women's Heels",
      "Women's Flats",
      "Women's Sandals",
      "Women's Wedges",
      "Women's Loafers",
      "Women's Espadrilles",
      "Women's Mules",
      "Women's Slippers",
      // Men's
      "Men's Sneakers",
      "Men's Boots",
      "Men's Dress Shoes",
      "Men's Loafers",
      "Men's Sandals & Flip-Flops",
      "Men's Athletic Shoes",
      "Men's Slippers",
      // Unisex
      'Athletic Shoes',
      'Running Shoes',
      'Basketball Shoes',
      'Skateboarding Shoes',
      'Hiking Boots',
      // Kids
      "Kids' Sneakers",
      "Kids' Boots",
      "Kids' Sandals",
      // Style Specific
      'Designer Sneakers',
      'Limited Edition',
      'Vintage Sneakers',
      'Y2K Shoes',
    ],

    bagsAccessories: [
      // Bags
      'Shoulder Bags',
      'Crossbody Bags',
      'Tote Bags',
      'Backpacks',
      'Clutches',
      'Handbags',
      'Wallets & Cardholders',
      'Laptop Bags',
      'Travel Bags',
      'Belt Bags & Fanny Packs',
      'Cosmetic Bags',
      'Luxury Designer Bags',
      // Accessories
      'Sunglasses',
      'Belts',
      'Hats & Caps',
      'Scarves & Shawls',
      'Gloves',
      'Hair Accessories',
      'Ties & Bow Ties',
      'Socks & Hosiery',
      'Face Masks',
      'Umbrellas',
      'Phone Cases',
      'Tech Accessories',
    ],

    jewelryWatches: [
      // Jewelry
      'Necklaces',
      'Earrings',
      'Bracelets',
      'Rings',
      'Anklets',
      'Brooches & Pins',
      'Body Jewelry',
      'Jewelry Sets',
      'Engagement & Wedding Rings',
      'Fine Jewelry',
      'Costume Jewelry',
      'Vintage Jewelry',
      // Watches
      "Women's Watches",
      "Men's Watches",
      'Smartwatches',
      'Luxury Watches',
      'Vintage Watches',
      'Sports Watches',
      'Watch Bands & Straps',
    ],

    beauty: [
      // Makeup
      'Face Makeup',
      'Eye Makeup',
      'Lip Makeup',
      'Makeup Tools & Brushes',
      'Makeup Palettes',
      // Skincare
      'Cleansers',
      'Moisturizers',
      'Serums & Treatments',
      'Masks & Peels',
      'Sunscreen',
      'Eye Cream',
      'Toners',
      // Hair Care
      'Shampoo & Conditioner',
      'Hair Styling Products',
      'Hair Tools',
      'Hair Dye',
      'Hair Accessories',
      // Fragrance
      'Perfumes',
      'Colognes',
      'Body Sprays',
      // Bath & Body
      'Body Lotions',
      'Body Wash',
      'Hand Cream',
      'Deodorants',
      // Nails
      'Nail Polish',
      'Nail Tools',
      'Nail Art',
      // Men's Grooming
      'Shaving & Beard Care',
      "Men's Skincare",
      "Men's Fragrance",
    ],

    electronics: [
      // Phones & Tablets
      'Smartphones',
      'Feature Phones',
      'Tablets',
      'E-Readers',
      'Phone Accessories',
      // Computers
      'Laptops',
      'Desktop Computers',
      'Monitors',
      'Keyboards & Mice',
      'Webcams',
      'Computer Parts',
      'Printers & Scanners',
      // Audio
      'Headphones & Earbuds',
      'Speakers',
      'Microphones',
      'Turntables & Record Players',
      'Home Audio Systems',
      // TV & Video
      'Televisions',
      'Streaming Devices',
      'DVD & Blu-ray Players',
      'Projectors',
      // Cameras & Photography
      'Digital Cameras',
      'DSLR Cameras',
      'Action Cameras',
      'Lenses',
      'Tripods & Stabilizers',
      'Camera Accessories',
      // Gaming
      'Gaming Consoles',
      'Video Games',
      'Controllers & Accessories',
      'Gaming Headsets',
      'Gaming Chairs',
      // Wearables
      'Smartwatches',
      'Fitness Trackers',
      'VR Headsets',
      // Smart Home
      'Smart Speakers',
      'Smart Lights',
      'Security Cameras',
      'Smart Thermostats',
      'Smart Plugs',
      // Other
      'Drones',
      'Power Banks',
      'Chargers & Cables',
      'Storage Devices',
    ],

    homeLiving: [
      // Furniture
      'Sofas & Couches',
      'Chairs & Seating',
      'Tables',
      'Beds & Mattresses',
      'Dressers & Wardrobes',
      'Shelves & Storage',
      'Desks',
      'TV Stands',
      'Outdoor Furniture',
      // Decor
      'Wall Art & Posters',
      'Mirrors',
      'Vases & Planters',
      'Candles & Holders',
      'Picture Frames',
      'Clocks',
      'Rugs & Carpets',
      'Curtains & Blinds',
      'Cushions & Throws',
      // Bedding
      'Bed Sheets',
      'Duvet Covers',
      'Pillows',
      'Blankets',
      'Mattress Toppers',
      // Kitchen & Dining
      'Cookware',
      'Dinnerware',
      'Glassware',
      'Cutlery',
      'Kitchen Appliances',
      'Storage Containers',
      'Bakeware',
      // Bathroom
      'Towels',
      'Bath Mats',
      'Shower Curtains',
      'Storage & Organization',
      // Lighting
      'Table Lamps',
      'Floor Lamps',
      'Ceiling Lights',
      'String Lights',
      // Organization
      'Storage Boxes',
      'Hangers',
      'Laundry Baskets',
      'Closet Organizers',
    ],

    kidsBaby: [
      // Baby Clothing (0-24 months)
      'Baby Bodysuits',
      'Baby Sleepwear',
      'Baby Outerwear',
      'Baby Dresses',
      'Baby Sets',
      // Kids Clothing (2-12 years)
      "Boys' Tops",
      "Boys' Bottoms",
      "Boys' Outerwear",
      "Girls' Tops",
      "Girls' Bottoms",
      "Girls' Dresses",
      "Girls' Outerwear",
      "Kids' Sleepwear",
      "Kids' Activewear",
      'School Uniforms',
      // Teens (13+ years)
      "Teen Boys' Clothing",
      "Teen Girls' Clothing",
      // Shoes
      'Baby Shoes',
      "Kids' Sneakers",
      "Kids' Boots",
      "Kids' Sandals",
      // Baby Gear
      'Strollers',
      'Car Seats',
      'High Chairs',
      'Baby Carriers',
      'Cribs & Bassinets',
      'Baby Monitors',
      'Diaper Bags',
      // Toys & Games
      'Action Figures',
      'Dolls',
      'Building Blocks (LEGO, etc.)',
      'Board Games',
      'Puzzles',
      'RC Toys',
      'Educational Toys',
      'Outdoor Toys',
      // Baby Care
      'Bottles & Feeding',
      'Diapers & Wipes',
      'Baby Bath',
      'Baby Health & Safety',
      // Nursery
      'Bedding',
      'Decor',
      'Storage & Organization',
      // Maternity
      'Maternity Clothing',
      'Nursing & Feeding',
    ],

    sportsOutdoors: [
      // Athletic Wear
      'Athletic Tops',
      'Athletic Bottoms',
      'Sports Bras',
      'Compression Wear',
      'Tracksuits',
      'Team Jerseys',
      // Fitness Equipment
      'Weights & Dumbbells',
      'Resistance Bands',
      'Yoga Mats',
      'Exercise Bikes',
      'Treadmills',
      'Gym Bags',
      // Team Sports
      'Football/Soccer',
      'Basketball',
      'Volleyball',
      'Baseball',
      'Tennis & Racquet Sports',
      // Outdoor Activities
      'Camping Gear',
      'Hiking Equipment',
      'Fishing Gear',
      'Cycling',
      'Skateboarding',
      'Scooters',
      // Water Sports
      'Swimming',
      'Surfing',
      'Diving & Snorkeling',
      // Winter Sports
      'Skiing',
      'Snowboarding',
      'Ice Skating',
      // Other
      'Golf',
      'Martial Arts',
      'Gym Accessories',
      'Sports Memorabilia',
    ],

    entertainment: [
      // Books
      'Fiction',
      'Non-Fiction',
      'Romance',
      'Mystery & Thriller',
      'Sci-Fi & Fantasy',
      'Biography & Memoir',
      'Self-Help',
      'Business & Economics',
      'Academic & Textbooks',
      "Children's Books",
      'Comics & Manga',
      'Graphic Novels',
      'Poetry',
      'Cookbooks',
      'Art & Photography Books',
      // Movies & TV
      'DVDs & Blu-rays',
      'Box Sets',
      // Music
      'Vinyl Records',
      'CDs',
      'Music Instruments',
      'DJ Equipment',
      // Magazines
      'Fashion Magazines',
      'Lifestyle Magazines',
      'Tech Magazines',
    ],

    hobbiesCrafts: [
      // Art Supplies
      'Painting Supplies',
      'Drawing & Sketching',
      'Sculpting',
      'Canvas & Paper',
      'Brushes & Tools',
      // Crafts
      'Knitting & Crochet',
      'Sewing & Quilting',
      'Scrapbooking',
      'Jewelry Making',
      'Woodworking',
      // Collectibles
      'Trading Cards',
      'Stamps',
      'Coins',
      'Vintage Items',
      'Memorabilia',
      // Other
      'Model Building',
      'RC Hobbies',
      'Photography',
      'DIY & Tools',
    ],

    pets: [
      // Dogs
      'Dog Food & Treats',
      'Dog Toys',
      'Dog Clothing',
      'Dog Beds & Furniture',
      'Dog Collars & Leashes',
      'Dog Grooming',
      'Dog Health Care',
      // Cats
      'Cat Food & Treats',
      'Cat Toys',
      'Cat Litter & Accessories',
      'Cat Furniture & Scratchers',
      'Cat Collars & Harnesses',
      'Cat Grooming',
      // Other Pets
      'Fish & Aquarium',
      'Birds',
      'Small Animals (Hamsters, Rabbits)',
      'Reptiles',
      // General
      'Pet Carriers & Travel',
      'Pet Clothing & Costumes',
    ],

    automotive: [
      // Car Parts
      'Tires & Wheels',
      'Car Audio',
      'GPS & Navigation',
      'Car Accessories',
      'Tools & Equipment',
      'Maintenance Products',
      'Car Covers',
      // Motorcycle
      'Motorcycle Parts',
      'Motorcycle Accessories',
      'Helmets & Gear',
      // Other
      'Bicycle Parts & Accessories',
    ],

    vintageCollectibles: [
      'Vintage Clothing',
      'Vintage Accessories',
      'Vintage Jewelry',
      'Antique Furniture',
      'Vintage Decor',
      'Collectible Toys',
      'Rare Books',
      'Vintage Electronics',
      'Memorabilia',
      'Art & Prints',
      'Vintage Kitchenware',
    ],

    handmade: [
      'Handmade Clothing',
      'Handmade Jewelry',
      'Handmade Home Decor',
      'Handmade Toys',
      'Handmade Bags',
      'Handmade Art',
      'Upcycled Items',
      'Custom Orders',
    ],

    officeStationery: [
      'Desk Accessories',
      'Office Furniture',
      'Notebooks & Journals',
      'Pens & Pencils',
      'Art Supplies',
      'Planners & Organizers',
      'School Supplies',
      'Filing & Storage',
      'Printers & Scanners',
      'Office Electronics',
    ],

    healthWellness: [
      'Vitamins & Supplements',
      'Fitness Equipment',
      'Yoga & Meditation',
      'Massage & Relaxation',
      'Essential Oils',
      'Health Monitors',
      'First Aid',
      'Personal Care',
    ],

    gardenOutdoor: [
      'Garden Tools',
      'Plants & Seeds',
      'Pots & Planters',
      'Outdoor Furniture',
      'BBQ & Grills',
      'Garden Decor',
      'Lawn Care',
      'Outdoor Lighting',
      'Greenhouses & Grow Tents',
    ],

    partyEvents: [
      'Party Decorations',
      'Costumes',
      'Party Supplies',
      'Balloons',
      'Tableware',
      'Event Planning',
      'Wedding Supplies',
      'Birthday Decorations',
    ],

    foodBeverage: [
      'Coffee & Tea',
      'Snacks & Treats',
      'Specialty Foods',
      'Supplements',
      'Protein & Fitness Foods',
      'Baby Food',
    ],

    travelLuggage: [
      'Suitcases',
      'Backpacks & Daypacks',
      'Travel Accessories',
      'Packing Cubes',
      'Travel Pillows',
      'Passport Holders',
      'Toiletry Bags',
    ],

    services: [
      'Cleaning Services',
      'Tutoring',
      'Pet Services',
      'Home Repair',
      'Moving Services',
      'Event Planning',
      'Photography',
      'Graphic Design',
    ],

    freeStuff: [
      'Free Clothing',
      'Free Furniture',
      'Free Electronics',
      'Free Books',
      'Free Toys',
      'Free Home Items',
      'Free Giveaways',
    ],
  };

  static List<String> getSubcategories(String category) {
    return subcategories[category] ?? [];
  }

  static String? getIcon(String category) {
    return icons[category];
  }

  static bool hasSubcategories(String category) {
    return subcategories.containsKey(category) &&
        subcategories[category]!.isNotEmpty;
  }

  static int getSubcategoryCount(String category) {
    return subcategories[category]?.length ?? 0;
  }
}

// ========================================
// SIZE SYSTEMS (WORLD-CLASS)
// ========================================

class SizeSystem {
  static const String us = 'US';
  static const String eu = 'EU';
  static const String uk = 'UK';
  static const String it = 'IT';
  static const String fr = 'FR';
  static const String oneSize = 'One Size';

  static List<String> get all => [us, eu, uk, it, fr, oneSize];
}

// ========================================
// WOMEN'S CLOTHING SIZES
// ========================================

class WomensSizes {
  static const List<String> us = [
    'XXS',
    'XS',
    'S',
    'M',
    'L',
    'XL',
    'XXL',
    '0',
    '2',
    '4',
    '6',
    '8',
    '10',
    '12',
    '14',
    '16',
    '18',
    '20',
    '22',
    '24',
  ];
  static const List<String> eu = [
    '30',
    '32',
    '34',
    '36',
    '38',
    '40',
    '42',
    '44',
    '46',
    '48',
    '50',
    '52',
  ];
  static const List<String> uk = [
    '2',
    '4',
    '6',
    '8',
    '10',
    '12',
    '14',
    '16',
    '18',
    '20',
    '22',
    '24',
  ];
  static const List<String> plus = ['1X', '2X', '3X', '4X', '5X'];
  static const List<String> oneSize = ['One Size', 'Fits Most', 'OS'];
}

// ========================================
// MEN'S CLOTHING SIZES
// ========================================

class MensSizes {
  static const List<String> us = [
    'XXS',
    'XS',
    'S',
    'M',
    'L',
    'XL',
    'XXL',
    'XXXL',
  ];
  static const List<String> eu = [
    '44',
    '46',
    '48',
    '50',
    '52',
    '54',
    '56',
    '58',
    '60',
  ];
  static const List<String> uk = [
    '32',
    '34',
    '36',
    '38',
    '40',
    '42',
    '44',
    '46',
  ];
  static const List<String> neck = [
    '14',
    '14.5',
    '15',
    '15.5',
    '16',
    '16.5',
    '17',
    '17.5',
    '18',
  ];
  static const List<String> waist = [
    '28',
    '30',
    '32',
    '34',
    '36',
    '38',
    '40',
    '42',
    '44',
  ];
  static const List<String> inseam = ['28', '30', '32', '34', '36'];
}

// ========================================
// SHOE SIZES
// ========================================

class ShoeSizes {
  // Women's Shoes
  static const List<String> womenUS = [
    '5',
    '5.5',
    '6',
    '6.5',
    '7',
    '7.5',
    '8',
    '8.5',
    '9',
    '9.5',
    '10',
    '10.5',
    '11',
    '11.5',
    '12',
  ];
  static const List<String> womenEU = [
    '35',
    '35.5',
    '36',
    '36.5',
    '37',
    '37.5',
    '38',
    '38.5',
    '39',
    '39.5',
    '40',
    '40.5',
    '41',
    '41.5',
    '42',
  ];
  static const List<String> womenUK = [
    '3',
    '3.5',
    '4',
    '4.5',
    '5',
    '5.5',
    '6',
    '6.5',
    '7',
    '7.5',
    '8',
    '8.5',
    '9',
  ];

  // Men's Shoes
  static const List<String> menUS = [
    '6',
    '6.5',
    '7',
    '7.5',
    '8',
    '8.5',
    '9',
    '9.5',
    '10',
    '10.5',
    '11',
    '11.5',
    '12',
    '12.5',
    '13',
    '14',
    '15',
  ];
  static const List<String> menEU = [
    '38',
    '39',
    '40',
    '40.5',
    '41',
    '42',
    '42.5',
    '43',
    '44',
    '44.5',
    '45',
    '46',
    '47',
    '48',
  ];
  static const List<String> menUK = [
    '5',
    '6',
    '6.5',
    '7',
    '7.5',
    '8',
    '8.5',
    '9',
    '9.5',
    '10',
    '10.5',
    '11',
    '12',
    '13',
  ];

  // Kids Shoes
  static const List<String> baby = ['0', '1', '2', '3', '4', '5'];
  static const List<String> toddler = ['6', '7', '8', '9', '10'];
  static const List<String> youth = [
    '11',
    '12',
    '13',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
  ];
}

// ========================================
// KIDS/BABY SIZES
// ========================================

class KidsSizes {
  static const List<String> baby = [
    'Newborn',
    '0-3M',
    '3-6M',
    '6-9M',
    '9-12M',
    '12-18M',
    '18-24M',
  ];
  static const List<String> toddler = ['2T', '3T', '4T'];
  static const List<String> kids = [
    '4',
    '5',
    '6',
    '7',
    '8',
    '10',
    '12',
    '14',
    '16',
  ];
}

// ========================================
// MEASUREMENT TYPES (by category)
// ========================================

class MeasurementTypes {
  static const List<String> clothing = [
    'chest',
    'waist',
    'hips',
    'length',
    'shoulders',
    'sleeves',
    'inseam',
  ];
  static const List<String> shoes = ['insoleLength', 'width', 'heelHeight'];
  static const List<String> bags = ['height', 'width', 'depth', 'strapDrop'];
  static const List<String> furniture = [
    'height',
    'width',
    'depth',
    'diameter',
  ];

  static List<String> getForCategory(String category) {
    if (category.contains('Fashion') || category.contains('fashion')) {
      return clothing;
    } else if (category.contains('Shoes') || category.contains('shoes')) {
      return shoes;
    } else if (category.contains('Bags') || category.contains('bags')) {
      return bags;
    } else if (category.contains('Home') || category.contains('Furniture')) {
      return furniture;
    }
    return [];
  }
}

// ========================================
// GENDER OPTIONS
// ========================================

class GenderOptions {
  static const String men = 'Men';
  static const String women = 'Women';
  static const String unisex = 'Unisex';
  static const String boys = 'Boys';
  static const String girls = 'Girls';
  static const String kids = 'Kids';

  static List<String> get all => [men, women, unisex, boys, girls, kids];
}

// ========================================
// FIT TYPES
// ========================================

class FitTypes {
  static const String slim = 'Slim';
  static const String regular = 'Regular';
  static const String oversized = 'Oversized';
  static const String relaxed = 'Relaxed';
  static const String athletic = 'Athletic';
  static const String petite = 'Petite';
  static const String curvy = 'Curvy';
  static const String tall = 'Tall';

  static List<String> get all => [
    slim,
    regular,
    oversized,
    relaxed,
    athletic,
    petite,
    curvy,
    tall,
  ];
}

// ========================================
// SEASON OPTIONS
// ========================================

class SeasonOptions {
  static const String springSummer = 'Spring/Summer';
  static const String autumnWinter = 'Autumn/Winter';
  static const String allSeason = 'All Season';

  static List<String> get all => [springSummer, autumnWinter, allSeason];
}

// ========================================
// OCCASION OPTIONS
// ========================================

class OccasionOptions {
  static const String casual = 'Casual';
  static const String formal = 'Formal';
  static const String party = 'Party';
  static const String sport = 'Sport';
  static const String work = 'Work';
  static const String beach = 'Beach';
  static const String wedding = 'Wedding';
  static const String everyday = 'Everyday';

  static List<String> get all => [
    casual,
    formal,
    party,
    sport,
    work,
    beach,
    wedding,
    everyday,
  ];
}

// ========================================
// STYLE OPTIONS
// ========================================

class StyleOptions {
  static const String vintage = 'Vintage';
  static const String y2k = 'Y2K';
  static const String minimalist = 'Minimalist';
  static const String streetwear = 'Streetwear';
  static const String bohemian = 'Bohemian';
  static const String grunge = 'Grunge';
  static const String preppy = 'Preppy';
  static const String classic = 'Classic';
  static const String modern = 'Modern';
  static const String retro = 'Retro';

  static List<String> get all => [
    vintage,
    y2k,
    minimalist,
    streetwear,
    bohemian,
    grunge,
    preppy,
    classic,
    modern,
    retro,
  ];
}
