import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/analytics_service.dart';
import '../../../domain/entities/item_entity.dart';
import '../../../domain/entities/barter_match_entity.dart';
import '../../blocs/barter/barter_match_cubit.dart';
import '../../widgets/barter/barter_match_card.dart';
import '../../widgets/barter/barter_match_filters.dart';
import '../../widgets/loading/skeleton_loading.dart';
import '../items/item_detail_page.dart';
import '../../../core/services/barter_matching_service.dart';
import '../../../core/theme/minimal_design_system.dart';
import '../../blocs/item/item_bloc.dart';
import '../../blocs/favorite/favorite_bloc.dart';

/// Real Barter Matches Page
/// Shows actual barter matches calculated by Cloud Functions
class BarterMatchesPage extends StatefulWidget {
  final ItemEntity sourceItem;

  const BarterMatchesPage({
    super.key,
    required this.sourceItem,
  });

  @override
  State<BarterMatchesPage> createState() => _BarterMatchesPageState();
}

class _BarterMatchesPageState extends State<BarterMatchesPage> {
  late BarterMatchCubit _barterMatchCubit;
  late BarterMatchingService _matchingService;
  List<BarterMatchEntity> _filteredMatches = [];
  bool _hasFilters = false;

  @override
  void initState() {
    super.initState();
    _barterMatchCubit = getIt<BarterMatchCubit>();
    _matchingService = getIt<BarterMatchingService>();
    
    // Load barter matches for this item
    _barterMatchCubit.add(LoadBarterMatches(widget.sourceItem.id));
    
    // Track analytics
    getIt<AnalyticsService>().logBarterMatchesViewed(
      sourceItemId: widget.sourceItem.id,
      matchCount: 0, // Will be updated when matches load
      source: 'barter_matches_page',
    );
  }

  @override
  void dispose() {
    _barterMatchCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Barter Matches',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: MinimalDesignSystem.ultraDark,
          ),
        ),
        backgroundColor: MinimalDesignSystem.baseColor,
        elevation: 0,
        actions: [
          if (_hasFilters)
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: MinimalDesignSystem.baseColor,
                boxShadow: MinimalDesignSystem.neumorphismOutsetShadow,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _clearFilters,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.clear_all,
                      color: MinimalDesignSystem.softDark,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      backgroundColor: MinimalDesignSystem.baseColor,
      body: BlocProvider.value(
        value: _barterMatchCubit,
        child: BlocBuilder<BarterMatchCubit, BarterMatchState>(
          builder: (context, state) {
            if (state is BarterMatchLoading) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: MinimalDesignSystem.baseColor,
                    boxShadow: MinimalDesignSystem.neumorphismOutsetShadow,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: MinimalDesignSystem.baseColor,
                          boxShadow: MinimalDesignSystem.neumorphismInsetShadow,
                        ),
                        child: CircularProgressIndicator(
                          color: MinimalDesignSystem.primaryColor,
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Finding Perfect Matches',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: MinimalDesignSystem.ultraDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Analyzing compatibility and calculating scores...',
                        style: TextStyle(
                          color: MinimalDesignSystem.softDark,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is BarterMatchError) {
              return Center(
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: MinimalDesignSystem.baseColor,
                    boxShadow: MinimalDesignSystem.neumorphismOutsetShadow,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          color: MinimalDesignSystem.baseColor,
                          boxShadow: MinimalDesignSystem.neumorphismInsetShadow,
                        ),
                        child: Icon(
                          Icons.error_outline,
                          size: 40,
                          color: Colors.red[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Failed to Load Matches',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: MinimalDesignSystem.ultraDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        style: TextStyle(
                          color: MinimalDesignSystem.softDark,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: MinimalDesignSystem.primaryColor,
                          boxShadow: [
                            BoxShadow(
                              color: MinimalDesignSystem.primaryColor.withOpacity(0.3),
                              offset: const Offset(-4, -4),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: MinimalDesignSystem.primaryColor.withOpacity(0.1),
                              offset: const Offset(4, 4),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              _barterMatchCubit.add(LoadBarterMatches(widget.sourceItem.id));
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Retry',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is BarterMatchLoaded) {
              // Initialize filtered matches if not set
              if (_filteredMatches.isEmpty) {
                _filteredMatches = state.matches;
              }
              
              if (_filteredMatches.isEmpty) {
                return _buildEmptyState();
              }
              
              return Column(
                children: [
                  // Advanced filters
                  BarterMatchFilters(
                    matches: state.matches,
                    matchingService: _matchingService,
                    onFiltersChanged: (filteredMatches) {
                      setState(() {
                        _filteredMatches = filteredMatches;
                        _hasFilters = filteredMatches.length != state.matches.length;
                      });
                    },
                  ),
                  
                  // Neuromorphic Header with match count
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: MinimalDesignSystem.baseColor,
                      boxShadow: MinimalDesignSystem.neumorphismOutsetShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: MinimalDesignSystem.baseColor,
                            boxShadow: MinimalDesignSystem.neumorphismInsetShadow,
                          ),
                          child: Icon(
                            Icons.swap_horiz,
                            color: MinimalDesignSystem.primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_filteredMatches.length} Matches Found',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: MinimalDesignSystem.ultraDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Perfect barter opportunities waiting for you',
                                style: TextStyle(
                                  color: MinimalDesignSystem.softDark,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_hasFilters)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: MinimalDesignSystem.primaryColor,
                              boxShadow: [
                                BoxShadow(
                                  color: MinimalDesignSystem.primaryColor.withOpacity(0.3),
                                  offset: const Offset(-4, -4),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                ),
                                BoxShadow(
                                  color: MinimalDesignSystem.primaryColor.withOpacity(0.1),
                                  offset: const Offset(4, 4),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Text(
                              'FILTERED',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Matches list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredMatches.length,
                      itemBuilder: (context, index) {
                        final match = _filteredMatches[index];
                        return BarterMatchCard(
                          match: match,
                          onTap: () => _viewMatchDetails(context, match),
                          onSendOffer: () => _sendOffer(context, match),
                          onDismiss: () => _dismissMatch(context, match),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: MinimalDesignSystem.baseColor,
          boxShadow: MinimalDesignSystem.neumorphismOutsetShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: MinimalDesignSystem.baseColor,
                boxShadow: MinimalDesignSystem.neumorphismInsetShadow,
              ),
              child: Icon(
                Icons.search_off,
                size: 40,
                color: MinimalDesignSystem.softDark,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Matches Found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: MinimalDesignSystem.ultraDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try adjusting your barter conditions or check back later for new items.',
              style: TextStyle(
                color: MinimalDesignSystem.softDark,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: MinimalDesignSystem.baseColor,
                boxShadow: MinimalDesignSystem.neumorphismOutsetShadow,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back,
                          color: MinimalDesignSystem.softDark,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Back to Item',
                          style: TextStyle(
                            color: MinimalDesignSystem.softDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _filteredMatches = [];
      _hasFilters = false;
    });
  }

  void _viewMatchDetails(BuildContext context, BarterMatchEntity match) {
    // Navigate to target item details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<ItemBloc>()),
            BlocProvider(create: (_) => getIt<FavoriteBloc>()),
          ],
          child: ItemDetailPage(itemId: match.targetItemId),
        ),
      ),
    );
  }

  void _sendOffer(BuildContext context, BarterMatchEntity match) {
    // TODO: Navigate to send offer page with match context
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Send offer functionality coming in Sprint 2!'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _dismissMatch(BuildContext context, BarterMatchEntity match) {
    // Mark match as dismissed
    _barterMatchCubit.add(DismissBarterMatch(match.id));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Match dismissed'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
