// 🔍 WORLD CLASS EXPLORE PAGE
// Visual Search + Voice Search + Smart Filters

import 'package:flutter/material.dart';
import '../../../core/theme/world_class_components.dart';

class WorldClassExplorePage extends StatefulWidget {
  const WorldClassExplorePage({Key? key}) : super(key: key);

  @override
  State<WorldClassExplorePage> createState() => _WorldClassExplorePageState();
}

class _WorldClassExplorePageState extends State<WorldClassExplorePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  String _selectedCategory = 'All';
  String _selectedCondition = 'All';
  String _sortBy = 'Recent';

  final List<String> _categories = [
    'All',
    'Electronics',
    'Fashion',
    'Books',
    'Gaming',
    'Home',
    'Sports',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: SmartSearchBar(
                controller: _searchController,
                onVoiceSearch: () {
                  // Voice search
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🎤 Voice search coming soon!')),
                  );
                },
                onCameraSearch: () {
                  // Visual search
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('📸 Visual search coming soon!')),
                  );
                },
                onFilterTap: () {
                  _showFilters();
                },
              ),
            ),

            // Category Tabs
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _selectedCategory;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedCategory = category);
                      },
                      selectedColor: Theme.of(context).primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Sort Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${_getMockItemCount()} items',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const Spacer(),
                  DropdownButton<String>(
                    value: _sortBy,
                    underline: const SizedBox(),
                    items: ['Recent', 'Popular', 'Distance', 'Match Score']
                        .map((sort) => DropdownMenuItem(value: sort, child: Text(sort)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _sortBy = value);
                      }
                    },
                  ),
                ],
              ),
            ),

            // Items Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 20, // Mock data
                itemBuilder: (context, index) {
                  return PremiumItemCard(
                    username: 'User ${index + 1}',
                    title: 'Item ${index + 1}',
                    imageUrl: 'https://via.placeholder.com/300',
                    price: (index + 1) * 100.0,
                    matchScore: 85 + (index % 15),
                    distance: '${(index % 5) + 1}.${index % 10}km',
                    condition: ['Brand New', 'Like New', 'Good'][index % 3],
                    viewCount: (index + 1) * 47,
                    isVerified: index % 3 == 0,
                    isFavorited: false,
                    onTap: () {
                      Navigator.of(context).pushNamed('/item-detail', arguments: 'item_$index');
                    },
                    onFavorite: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('❤️ Added to favorites')),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: PulsingFAB(
        onPressed: () {
          Navigator.of(context).pushNamed('/add-item');
        },
        icon: Icons.add,
      ),
    );
  }

  int _getMockItemCount() {
    if (_selectedCategory == 'All') return 247;
    return 20 + (_selectedCategory.length * 3);
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = 'All';
                            _selectedCondition = 'All';
                            _sortBy = 'Recent';
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Condition
                  const Text('Condition', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['All', 'Brand New', 'Like New', 'Good', 'Fair'].map((condition) {
                      return FilterChip(
                        label: Text(condition),
                        selected: _selectedCondition == condition,
                        onSelected: (selected) {
                          setState(() => _selectedCondition = condition);
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Distance
                  const Text('Distance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Slider(
                    value: 5,
                    min: 1,
                    max: 20,
                    divisions: 19,
                    label: '5km',
                    onChanged: (value) {},
                  ),
                  Text('Within 5km', style: TextStyle(color: Colors.grey[600])),

                  const SizedBox(height: 24),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
