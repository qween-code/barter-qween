// 🔄 BARTER MATCHES PAGE
// AI-powered trade matches

import 'package:flutter/material.dart';
import '../../../core/theme/world_class_components.dart';

class BarterMatchesPage extends StatefulWidget {
  const BarterMatchesPage({Key? key}) : super(key: key);

  @override
  State<BarterMatchesPage> createState() => _BarterMatchesPageState();
}

class _BarterMatchesPageState extends State<BarterMatchesPage> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barter Matches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ['All', 'High Match', 'Nearby', 'New'].map((filter) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: _selectedFilter == filter,
                    onSelected: (selected) {
                      setState(() => _selectedFilter = filter);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Matches List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 10,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: MatchCard(
                    yourItemTitle: 'My iPhone 13',
                    yourItemImage: 'https://via.placeholder.com/200',
                    theirItemTitle: 'MacBook Air M1',
                    theirItemImage: 'https://via.placeholder.com/200',
                    matchScore: 92 - (index * 2).toDouble(),
                    matchReasons: const [
                      'Similar value electronics',
                      'Both in excellent condition',
                      'Good category match',
                    ],
                    distance: '${index + 2} km',
                    onViewDetails: () {},
                    onMakeOffer: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Opening offer dialog...'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Match Filters',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // Match Score Threshold
            const Text('Minimum Match Score'),
            Slider(
              value: 70,
              min: 50,
              max: 100,
              divisions: 10,
              label: '70%',
              onChanged: (value) {},
            ),

            const SizedBox(height: 16),

            // Distance
            const Text('Maximum Distance'),
            Slider(
              value: 10,
              min: 1,
              max: 50,
              divisions: 49,
              label: '10km',
              onChanged: (value) {},
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
