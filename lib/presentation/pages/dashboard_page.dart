import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection.dart';
import '../../core/routes/route_names.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/chat/chat_bloc.dart';
import '../blocs/favorite/favorite_bloc.dart';
import '../blocs/item/item_bloc.dart';
import '../blocs/profile/profile_bloc.dart';
import '../blocs/trade/trade_bloc.dart';
import '../blocs/trade/trade_event.dart';
import '../blocs/trade/trade_state.dart';
import '../blocs/search/search_bloc.dart';
import 'chat/conversations_list_page.dart';
import 'explore/explore_page.dart';
import 'items/create_item_page.dart';
import 'items/item_list_page.dart';
import 'profile/profile_page.dart';
import 'search/search_page.dart';
import 'trades/trades_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<TradeBloc>()),
        BlocProvider(create: (_) => getIt<ChatBloc>()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.of(context).pushReplacementNamed(RouteNames.login);
          }
        },
        child: const DashboardView(),
      ),
    );
  }
}

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _currentIndex = 0;
  int _pendingTradeCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPendingTradeCount();
  }

  void _loadPendingTradeCount() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<TradeBloc>().add(LoadPendingReceivedCount(authState.user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TradeBloc, TradeState>(
      listener: (context, state) {
        if (state is PendingCountLoaded) {
          setState(() {
            _pendingTradeCount = state.count;
          });
        }
      },
      child: Scaffold(
        body: IndexedStack(
        index: _currentIndex,
        children: [
          MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<ItemBloc>()),
              BlocProvider(create: (_) => getIt<FavoriteBloc>()),
            ],
            child: const ItemListPage(),
          ),
          MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<ItemBloc>()),
              BlocProvider(create: (_) => getIt<FavoriteBloc>()),
            ],
            child: const ExplorePage(),
          ),
          const TradesPage(), // Uses TradeBloc from Dashboard level
          const ConversationsListPage(),
          BlocProvider(
            create: (_) => getIt<ProfileBloc>(),
            child: const ProfilePage(),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          const NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explore'),
          NavigationDestination(
            icon: _pendingTradeCount > 0
                ? Badge(
                    label: Text('$_pendingTradeCount'),
                    child: const Icon(Icons.swap_horiz_outlined),
                  )
                : const Icon(Icons.swap_horiz_outlined),
            selectedIcon: _pendingTradeCount > 0
                ? Badge(
                    label: Text('$_pendingTradeCount'),
                    child: const Icon(Icons.swap_horiz),
                  )
                : const Icon(Icons.swap_horiz),
            label: 'Trades',
          ),
          const NavigationDestination(icon: Icon(Icons.message_outlined), selectedIcon: Icon(Icons.message), label: 'Messages'),
          const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: null, // FAB moved to ItemListPage
      ),
    );
  }
}

// HOME TAB
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: const Text('Barter Qween'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (_) => getIt<SearchBloc>(),
                      child: const SearchPage(),
                    ),
                  ),
                );
              },
            ),
            IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [Icon(Icons.celebration, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 8), const Expanded(child: Text('Welcome to Barter Qween!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))]),
                      const SizedBox(height: 8),
                      const Text('Start trading by creating your first listing or exploring items from other users.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Recent Listings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...List.generate(5, (index) => _buildListingCard(context, 'Item ${index + 1}', 'Category ${index % 3 + 1}', '${(index + 1) * 10}\$')),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildListingCard(BuildContext context, String title, String category, String price) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.image, size: 32, color: Colors.grey)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(category),
        trailing: Text(price, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Clicked on $title'))),
      ),
    );
  }
}

// EXPLORE TAB
class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Electronics', 'icon': Icons.devices, 'color': Colors.blue},
      {'name': 'Fashion', 'icon': Icons.checkroom, 'color': Colors.pink},
      {'name': 'Home & Garden', 'icon': Icons.home, 'color': Colors.green},
      {'name': 'Books', 'icon': Icons.book, 'color': Colors.orange},
      {'name': 'Sports', 'icon': Icons.sports_soccer, 'color': Colors.red},
      {'name': 'Toys & Games', 'icon': Icons.toys, 'color': Colors.purple},
      {'name': 'Music', 'icon': Icons.music_note, 'color': Colors.indigo},
      {'name': 'Art & Crafts', 'icon': Icons.palette, 'color': Colors.teal},
    ];

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          expandedHeight: 120,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text(
              'Explore Categories',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.1),
                    Theme.of(context).primaryColor.withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ),
          backgroundColor: Colors.white,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category = categories[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () {
                      // Navigate to category items
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Browsing ${category['name']}')),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            (category['color'] as Color).withOpacity(0.1),
                            (category['color'] as Color).withOpacity(0.05),
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              category['icon'] as IconData,
                              size: 32,
                              color: category['color'] as Color,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            category['name'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: categories.length,
            ),
          ),
        ),
      ],
    );
  }
}

// MESSAGES TAB
class MessagesTab extends StatelessWidget {
  const MessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(floating: true, title: const Text('Messages')),
        SliverFillRemaining(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.message_outlined, size: 80, color: Colors.grey[400]), const SizedBox(height: 16), Text('No messages yet', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey[600])), const SizedBox(height: 8), const Text('Start trading to connect with others')]))),
      ],
    );
  }
}

