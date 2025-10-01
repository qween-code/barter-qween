import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection.dart';
import '../../core/routes/route_names.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeTab(),
    const ExploreTab(),
    const MessagesTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.message_outlined), selectedIcon: Icon(Icons.message), label: 'Messages'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Create Listing - Coming Soon!'))),
              icon: const Icon(Icons.add),
              label: const Text('New Listing'),
            )
          : null,
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
          actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {}), IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {})],
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
    return CustomScrollView(
      slivers: [
        SliverAppBar(floating: true, title: const Text('Explore')),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.8, crossAxisSpacing: 12, mainAxisSpacing: 12),
            delegate: SliverChildBuilderDelegate(
              (context, index) => Card(child: InkWell(onTap: () {}, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.category, size: 48, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 8), Text('Category ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold))]))),
              childCount: 10,
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

// PROFILE TAB
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.of(context).pushReplacementNamed(RouteNames.login);
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(floating: true, title: const Text('Profile')),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          CircleAvatar(radius: 50, backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: Icon(Icons.person, size: 50, color: Theme.of(context).colorScheme.onPrimaryContainer)),
                          const SizedBox(height: 16),
                          const Text('User Name', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('user@example.com', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(child: ListTile(leading: const Icon(Icons.swap_horiz), title: const Text('My Listings'), trailing: const Icon(Icons.chevron_right), onTap: () {})),
                  Card(child: ListTile(leading: const Icon(Icons.favorite_outline), title: const Text('Favorites'), trailing: const Icon(Icons.chevron_right), onTap: () {})),
                  Card(child: ListTile(leading: const Icon(Icons.settings), title: const Text('Settings'), trailing: const Icon(Icons.chevron_right), onTap: () {})),
                  const SizedBox(height: 16),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return OutlinedButton.icon(
                        onPressed: isLoading ? null : () => context.read<AuthBloc>().add(AuthLogoutRequested()),
                        icon: const Icon(Icons.logout),
                        label: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Logout'),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      );
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
