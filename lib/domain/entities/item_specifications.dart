/// Category-specific item specifications
/// Her kategori için özel alan tanımları ve validasyonları
class ItemSpecifications {
  // Electronics Specifications
  static const electronicsSpecs = {
    'brand': 'Brand',
    'model': 'Model',
    'storage': 'Storage',
    'ram': 'RAM',
    'processor': 'Processor',
    'screen_size': 'Screen Size',
    'battery_health': 'Battery Health (%)',
    'warranty_months': 'Warranty (months)',
    'imei': 'IMEI',
    'serial_number': 'Serial Number',
    'release_year': 'Release Year',
  };

  // Fashion Specifications
  static const fashionSpecs = {
    'brand': 'Brand',
    'size': 'Size',
    'material': 'Material',
    'season': 'Season',
    'gender': 'Gender',
    'style': 'Style',
    'fabric_composition': 'Fabric Composition',
    'care_instructions': 'Care Instructions',
  };

  // Books Specifications
  static const booksSpecs = {
    'author': 'Author',
    'publisher': 'Publisher',
    'isbn': 'ISBN',
    'language': 'Language',
    'publication_year': 'Publication Year',
    'pages': 'Pages',
    'edition': 'Edition',
    'format': 'Format', // Hardcover, Paperback, etc.
  };

  // Furniture Specifications
  static const furnitureSpecs = {
    'material': 'Material',
    'dimensions': 'Dimensions (L x W x H)',
    'weight': 'Weight (kg)',
    'color': 'Color',
    'assembly_required': 'Assembly Required',
    'style': 'Style',
    'brand': 'Brand',
    'room': 'Room',
  };

  // Toys Specifications
  static const toysSpecs = {
    'brand': 'Brand',
    'age_range': 'Age Range',
    'material': 'Material',
    'battery_required': 'Battery Required',
    'safety_certified': 'Safety Certified',
    'dimensions': 'Dimensions',
  };

  // Sports Specifications
  static const sportsSpecs = {
    'brand': 'Brand',
    'size': 'Size',
    'weight': 'Weight',
    'material': 'Material',
    'sport_type': 'Sport Type',
    'gender': 'Gender',
    'level': 'Level', // Beginner, Intermediate, Professional
  };

  // Home & Garden Specifications
  static const homeSpecs = {
    'brand': 'Brand',
    'material': 'Material',
    'dimensions': 'Dimensions',
    'power': 'Power (W)',
    'energy_rating': 'Energy Rating',
    'warranty_months': 'Warranty (months)',
  };

  // Beauty Specifications
  static const beautySpecs = {
    'brand': 'Brand',
    'volume': 'Volume (ml)',
    'expiry_date': 'Expiry Date',
    'skin_type': 'Skin Type',
    'scent': 'Scent',
    'ingredients': 'Key Ingredients',
    'opened': 'Opened',
  };

  // Automotive Specifications
  static const automotiveSpecs = {
    'brand': 'Brand',
    'model': 'Model',
    'part_number': 'Part Number',
    'compatibility': 'Compatibility',
    'year': 'Year',
    'oem_number': 'OEM Number',
  };

  // Collectibles Specifications
  static const collectiblesSpecs = {
    'brand': 'Brand',
    'year': 'Year',
    'edition': 'Edition',
    'rarity': 'Rarity',
    'authenticated': 'Authenticated',
    'certificate_number': 'Certificate Number',
    'grading': 'Grading',
  };

  // Hobbies & Crafts Specifications
  static const hobbiesSpecs = {
    'brand': 'Brand',
    'type': 'Type',
    'material': 'Material',
    'difficulty_level': 'Difficulty Level',
    'dimensions': 'Dimensions',
  };

  // Music & Instruments Specifications
  static const musicSpecs = {
    'brand': 'Brand',
    'model': 'Model',
    'type': 'Type',
    'material': 'Material',
    'year': 'Year',
    'includes_case': 'Includes Case',
    'includes_accessories': 'Includes Accessories',
  };

  // Pet Supplies Specifications
  static const petsSpecs = {
    'brand': 'Brand',
    'pet_type': 'Pet Type',
    'size': 'Size',
    'age_range': 'Age Range',
    'material': 'Material',
    'weight': 'Weight',
  };

  // Baby & Kids Specifications
  static const babySpecs = {
    'brand': 'Brand',
    'age_range': 'Age Range',
    'size': 'Size',
    'material': 'Material',
    'safety_certified': 'Safety Certified',
    'gender': 'Gender',
  };

  // Office Supplies Specifications
  static const officeSpecs = {
    'brand': 'Brand',
    'dimensions': 'Dimensions',
    'material': 'Material',
    'color': 'Color',
    'quantity': 'Quantity',
  };

  /// Get specifications for a category
  static Map<String, String> getSpecsForCategory(String category) {
    switch (category) {
      case 'Electronics':
        return electronicsSpecs;
      case 'Fashion':
        return fashionSpecs;
      case 'Books':
        return booksSpecs;
      case 'Furniture':
        return furnitureSpecs;
      case 'Toys':
        return toysSpecs;
      case 'Sports':
        return sportsSpecs;
      case 'Home & Garden':
        return homeSpecs;
      case 'Beauty':
        return beautySpecs;
      case 'Automotive':
        return automotiveSpecs;
      case 'Collectibles':
        return collectiblesSpecs;
      case 'Hobbies & Crafts':
        return hobbiesSpecs;
      case 'Music & Instruments':
        return musicSpecs;
      case 'Pet Supplies':
        return petsSpecs;
      case 'Baby & Kids':
        return babySpecs;
      case 'Office Supplies':
        return officeSpecs;
      default:
        return {};
    }
  }

  /// Get required specifications for a category (minimum required fields)
  static List<String> getRequiredSpecsForCategory(String category) {
    switch (category) {
      case 'Electronics':
        return ['brand', 'model'];
      case 'Fashion':
        return ['brand', 'size'];
      case 'Books':
        return ['author', 'language'];
      case 'Furniture':
        return ['material', 'dimensions'];
      case 'Toys':
        return ['brand', 'age_range'];
      case 'Sports':
        return ['brand', 'sport_type'];
      case 'Home & Garden':
        return ['brand'];
      case 'Beauty':
        return ['brand', 'volume'];
      case 'Automotive':
        return ['brand', 'model'];
      case 'Collectibles':
        return ['year'];
      case 'Hobbies & Crafts':
        return ['type'];
      case 'Music & Instruments':
        return ['brand', 'type'];
      case 'Pet Supplies':
        return ['brand', 'pet_type'];
      case 'Baby & Kids':
        return ['brand', 'age_range'];
      case 'Office Supplies':
        return ['brand'];
      default:
        return [];
    }
  }

  /// Common size options for fashion
  static const fashionSizes = [
    'XXS',
    'XS',
    'S',
    'M',
    'L',
    'XL',
    'XXL',
    'XXXL',
    '34',
    '36',
    '38',
    '40',
    '42',
    '44',
    '46',
    '48',
    '50',
    'Free Size',
  ];

  /// Common materials
  static const commonMaterials = [
    'Cotton',
    'Polyester',
    'Leather',
    'Wood',
    'Metal',
    'Plastic',
    'Glass',
    'Fabric',
    'Ceramic',
    'Stainless Steel',
    'Aluminum',
    'Rubber',
    'Silicone',
    'Mixed Materials',
  ];

  /// Common genders
  static const genders = [
    'Men',
    'Women',
    'Unisex',
    'Boys',
    'Girls',
    'Kids',
  ];

  /// Common seasons
  static const seasons = [
    'Spring',
    'Summer',
    'Fall',
    'Winter',
    'All Seasons',
  ];

  /// Common pet types
  static const petTypes = [
    'Dog',
    'Cat',
    'Bird',
    'Fish',
    'Rabbit',
    'Hamster',
    'Other',
  ];

  /// Common age ranges
  static const ageRanges = [
    '0-6 months',
    '6-12 months',
    '1-2 years',
    '3-5 years',
    '6-8 years',
    '9-12 years',
    '13+ years',
  ];

  /// Validate specifications
  static bool validateSpecs(String category, Map<String, dynamic> specs) {
    final requiredSpecs = getRequiredSpecsForCategory(category);
    
    // Check if all required fields are present and not empty
    for (final required in requiredSpecs) {
      if (!specs.containsKey(required) || 
          specs[required] == null || 
          specs[required].toString().trim().isEmpty) {
        return false;
      }
    }
    
    return true;
  }

  /// Get display name for spec key
  static String getDisplayName(String specKey) {
    return specKey
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
