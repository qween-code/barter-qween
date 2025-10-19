import 'package:flutter/material.dart';
import '../../../domain/entities/barter_match_entity.dart';
import '../../../core/services/barter_matching_service.dart';
import '../../../core/theme/minimal_design_system.dart';

/// Advanced Barter Match Filters Widget
///
/// Provides sophisticated filtering options for barter matches
/// with real-time filtering and sorting capabilities.
class BarterMatchFilters extends StatefulWidget {
  final List<BarterMatchEntity> matches;
  final Function(List<BarterMatchEntity>) onFiltersChanged;
  final BarterMatchingService matchingService;

  const BarterMatchFilters({
    super.key,
    required this.matches,
    required this.onFiltersChanged,
    required this.matchingService,
  });

  @override
  State<BarterMatchFilters> createState() => _BarterMatchFiltersState();
}

class _BarterMatchFiltersState extends State<BarterMatchFilters> {
  // Filter states
  MatchQuality? _qualityFilter;
  double? _minScore;
  double? _maxDistance;
  final List<String> _categoryFilter = [];
  bool? _hasCashDifferential;
  CashDirection? _cashDirection;
  DateTime? _fromDate;
  DateTime? _toDate;
  final List<String> _excludeUsers = [];

  // Sort state
  BarterSortCriteria _sortCriteria = BarterSortCriteria.bestMatch;
  bool _sortAscending = false;

  // UI state
  bool _isExpanded = false;
  int _activeFiltersCount = 0;

  @override
  void initState() {
    super.initState();
    _updateActiveFiltersCount();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: MinimalDesignSystem.baseColor,
        boxShadow: MinimalDesignSystem.neumorphismOutsetShadow,
      ),
      child: Column(
        children: [
          // Neuromorphic Header with filter count
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              color: MinimalDesignSystem.baseColor,
              boxShadow: MinimalDesignSystem.neumorphismInsetShadow,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: MinimalDesignSystem.baseColor,
                    boxShadow: MinimalDesignSystem.neumorphismOutsetShadow,
                  ),
                  child: Icon(
                    Icons.tune,
                    color: _activeFiltersCount > 0
                        ? MinimalDesignSystem.primaryColor
                        : MinimalDesignSystem.softDark,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Advanced Filters & Sort',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: MinimalDesignSystem.ultraDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _activeFiltersCount > 0
                            ? '$_activeFiltersCount active filters'
                            : 'No filters applied',
                        style: TextStyle(
                          color: _activeFiltersCount > 0
                              ? MinimalDesignSystem.primaryColor
                              : MinimalDesignSystem.softDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_activeFiltersCount > 0)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: MinimalDesignSystem.baseColor,
                          boxShadow:
                              MinimalDesignSystem.neumorphismOutsetShadow,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _clearAllFilters,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Text(
                                'Clear All',
                                style: TextStyle(
                                  color: MinimalDesignSystem.softDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: MinimalDesignSystem.baseColor,
                        boxShadow: MinimalDesignSystem.neumorphismOutsetShadow,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              _isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: MinimalDesignSystem.softDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Expanded filters
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Quality filter
                  _buildQualityFilter(),
                  const SizedBox(height: 16),

                  // Score range filter
                  _buildScoreRangeFilter(),
                  const SizedBox(height: 16),

                  // Distance filter
                  _buildDistanceFilter(),
                  const SizedBox(height: 16),

                  // Cash differential filter
                  _buildCashDifferentialFilter(),
                  const SizedBox(height: 16),

                  // Date range filter
                  _buildDateRangeFilter(),
                  const SizedBox(height: 16),

                  // Sort options
                  _buildSortOptions(),
                  const SizedBox(height: 16),

                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _applyFilters,
                      icon: Icon(Icons.search),
                      label: Text('Apply Filters'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQualityFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Match Quality',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: Text('All'),
              selected: _qualityFilter == null,
              onSelected: (selected) {
                setState(() {
                  _qualityFilter = null;
                  _updateActiveFiltersCount();
                });
              },
            ),
            ...MatchQuality.values.map(
              (quality) => FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getQualityColor(quality),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(quality.name),
                  ],
                ),
                selected: _qualityFilter == quality,
                onSelected: (selected) {
                  setState(() {
                    _qualityFilter = selected ? quality : null;
                    _updateActiveFiltersCount();
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Minimum Match Score',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _minScore ?? 0,
                min: 0,
                max: 100,
                divisions: 20,
                label: '${(_minScore ?? 0).round()}%',
                onChanged: (value) {
                  setState(() {
                    _minScore = value;
                    _updateActiveFiltersCount();
                  });
                },
              ),
            ),
            SizedBox(
              width: 60,
              child: Text(
                '${(_minScore ?? 0).round()}%',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDistanceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Maximum Distance (km)',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _maxDistance ?? 50,
                min: 5,
                max: 100,
                divisions: 19,
                label: '${(_maxDistance ?? 50).round()} km',
                onChanged: (value) {
                  setState(() {
                    _maxDistance = value;
                    _updateActiveFiltersCount();
                  });
                },
              ),
            ),
            SizedBox(
              width: 60,
              child: Text(
                '${(_maxDistance ?? 50).round()} km',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCashDifferentialFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cash Differential',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: Text('Any'),
              selected: _hasCashDifferential == null,
              onSelected: (selected) {
                setState(() {
                  _hasCashDifferential = null;
                  _cashDirection = null;
                  _updateActiveFiltersCount();
                });
              },
            ),
            FilterChip(
              label: Text('With Cash'),
              selected: _hasCashDifferential == true,
              onSelected: (selected) {
                setState(() {
                  _hasCashDifferential = selected ? true : null;
                  _updateActiveFiltersCount();
                });
              },
            ),
            FilterChip(
              label: Text('No Cash'),
              selected: _hasCashDifferential == false,
              onSelected: (selected) {
                setState(() {
                  _hasCashDifferential = selected ? false : null;
                  _updateActiveFiltersCount();
                });
              },
            ),
          ],
        ),
        if (_hasCashDifferential == true) ...[
          const SizedBox(height: 8),
          Text('Cash Direction', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: Text('Any Direction'),
                selected: _cashDirection == null,
                onSelected: (selected) {
                  setState(() {
                    _cashDirection = null;
                    _updateActiveFiltersCount();
                  });
                },
              ),
              FilterChip(
                label: Text('I Pay Extra'),
                selected: _cashDirection == CashDirection.fromInitiator,
                onSelected: (selected) {
                  setState(() {
                    _cashDirection = selected
                        ? CashDirection.fromInitiator
                        : null;
                    _updateActiveFiltersCount();
                  });
                },
              ),
              FilterChip(
                label: Text('They Pay Extra'),
                selected: _cashDirection == CashDirection.toInitiator,
                onSelected: (selected) {
                  setState(() {
                    _cashDirection = selected
                        ? CashDirection.toInitiator
                        : null;
                    _updateActiveFiltersCount();
                  });
                },
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate:
                        _fromDate ??
                        DateTime.now().subtract(const Duration(days: 30)),
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _fromDate = date;
                      _updateActiveFiltersCount();
                    });
                  }
                },
                icon: Icon(Icons.calendar_today, size: 16),
                label: Text(
                  _fromDate != null
                      ? '${_fromDate!.day}/${_fromDate!.month}/${_fromDate!.year}'
                      : 'From Date',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _toDate ?? DateTime.now(),
                    firstDate:
                        _fromDate ??
                        DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _toDate = date;
                      _updateActiveFiltersCount();
                    });
                  }
                },
                icon: Icon(Icons.calendar_today, size: 16),
                label: Text(
                  _toDate != null
                      ? '${_toDate!.day}/${_toDate!.month}/${_toDate!.year}'
                      : 'To Date',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSortOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<BarterSortCriteria>(
                value: _sortCriteria,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: BarterSortCriteria.values.map((criteria) {
                  return DropdownMenuItem(
                    value: criteria,
                    child: Text(_getSortCriteriaLabel(criteria)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _sortCriteria = value;
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                setState(() {
                  _sortAscending = !_sortAscending;
                });
              },
              icon: Icon(
                _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              ),
              tooltip: _sortAscending ? 'Ascending' : 'Descending',
            ),
          ],
        ),
      ],
    );
  }

  void _updateActiveFiltersCount() {
    int count = 0;

    if (_qualityFilter != null) count++;
    if (_minScore != null && _minScore! > 0) count++;
    if (_maxDistance != null && _maxDistance! < 100) count++;
    if (_hasCashDifferential != null) count++;
    if (_cashDirection != null) count++;
    if (_fromDate != null) count++;
    if (_toDate != null) count++;

    setState(() {
      _activeFiltersCount = count;
    });
  }

  void _clearAllFilters() {
    setState(() {
      _qualityFilter = null;
      _minScore = null;
      _maxDistance = null;
      _categoryFilter.clear();
      _hasCashDifferential = null;
      _cashDirection = null;
      _fromDate = null;
      _toDate = null;
      _excludeUsers.clear();
      _activeFiltersCount = 0;
    });

    _applyFilters();
  }

  void _applyFilters() {
    // Apply filters
    var filteredMatches = widget.matchingService.filterMatches(
      matches: widget.matches,
      qualityFilter: _qualityFilter,
      minScore: _minScore,
      maxDistance: _maxDistance,
      categoryFilter: _categoryFilter.isNotEmpty ? _categoryFilter : null,
      hasCashDifferential: _hasCashDifferential,
      cashDirection: null, // TODO: Fix CashDirection mapping
      fromDate: _fromDate,
      toDate: _toDate,
      excludeUsers: _excludeUsers.isNotEmpty ? _excludeUsers : null,
    );

    // Apply sorting
    filteredMatches = widget.matchingService.sortMatches(
      matches: filteredMatches,
      criteria: _sortCriteria,
      ascending: _sortAscending,
    );

    // Notify parent
    widget.onFiltersChanged(filteredMatches);
  }

  Color _getQualityColor(MatchQuality quality) {
    switch (quality) {
      case MatchQuality.excellent:
        return Colors.green;
      case MatchQuality.veryGood:
        return Colors.lightGreen;
      case MatchQuality.good:
        return Colors.blue;
      case MatchQuality.fair:
        return Colors.orange;
      case MatchQuality.poor:
        return Colors.red;
    }
  }

  String _getSortCriteriaLabel(BarterSortCriteria criteria) {
    switch (criteria) {
      case BarterSortCriteria.bestMatch:
        return 'Best Match';
      case BarterSortCriteria.newest:
        return 'Newest';
      case BarterSortCriteria.distance:
        return 'Distance';
      case BarterSortCriteria.priceDifference:
        return 'Price Difference';
      case BarterSortCriteria.trustScore:
        return 'Trust Score';
    }
  }
}
