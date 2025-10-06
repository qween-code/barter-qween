// ❤️ FAVORITES PAGE

import 'package:flutter/material.dart';
import '../../../core/theme/world_class_components.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {},
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          return PremiumItemCard(
            title: 'Favorited Item ${index + 1}',
            imageUrl: 'https://via.placeholder.com/300',
            price: (index + 1) * 100.0,
            originalPrice: (index + 1) * 150.0,
            matchScore: 85 + (index % 15),
            distance: '${(index % 5) + 1}.${index % 10}km',
            condition: ['Brand New', 'Like New', 'Good'][index % 3],
            viewCount: (index + 1) * 47,
            badge: index % 5 == 0 ? 'HOT' : null,
            isFavorite: true,
            onTap: () {
              Navigator.of(context).pushNamed('/item-detail', arguments: 'item_$index');
            },
            onFavorite: () {},
          );
        },
      ),
    );
  }
}
