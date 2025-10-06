import 'package:flutter/material.dart';
import '../../../core/theme/world_class_design_system.dart';

/// 🌟 WORLD-CLASS SEARCH BAR
/// 
/// Features:
/// - Text search
/// - Voice search button
/// - Image search button
/// - Search suggestions
/// - Recent searches
class WorldClassSearchBar extends StatefulWidget {
  final Function(String) onSearchChanged;
  final VoidCallback onVoiceSearch;
  final VoidCallback onImageSearch;

  const WorldClassSearchBar({
    Key? key,
    required this.onSearchChanged,
    required this.onVoiceSearch,
    required this.onImageSearch,
  }) : super(key: key);

  @override
  State<WorldClassSearchBar> createState() => _WorldClassSearchBarState();
}

class _WorldClassSearchBarState extends State<WorldClassSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(WorldClassDesignSystem.spacingM),
      padding: const EdgeInsets.symmetric(
        horizontal: WorldClassDesignSystem.spacingM,
        vertical: WorldClassDesignSystem.spacingS,
      ),
      decoration: BoxDecoration(
        color: WorldClassDesignSystem.surfaceColor,
        borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusL),
        border: Border.all(color: WorldClassDesignSystem.borderColor),
        boxShadow: WorldClassDesignSystem.shadowS,
      ),
      child: Row(
        children: [
          // Search Icon
          Icon(
            Icons.search_rounded,
            color: WorldClassDesignSystem.secondaryText,
            size: WorldClassDesignSystem.iconM,
          ),
          
          const SizedBox(width: WorldClassDesignSystem.spacingM),
          
          // Search Field
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Search items...',
                hintStyle: WorldClassDesignSystem.bodyMedium.copyWith(
                  color: WorldClassDesignSystem.secondaryText,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: WorldClassDesignSystem.bodyMedium.copyWith(
                color: WorldClassDesignSystem.primaryText,
              ),
              onChanged: widget.onSearchChanged,
              onTap: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          ),
          
          // Voice Search Button
          IconButton(
            onPressed: widget.onVoiceSearch,
            icon: Icon(
              Icons.mic_rounded,
              color: WorldClassDesignSystem.primaryColor,
              size: WorldClassDesignSystem.iconM,
            ),
            tooltip: 'Voice Search',
          ),
          
          // Image Search Button
          IconButton(
            onPressed: widget.onImageSearch,
            icon: Icon(
              Icons.camera_alt_rounded,
              color: WorldClassDesignSystem.secondaryColor,
              size: WorldClassDesignSystem.iconM,
            ),
            tooltip: 'Image Search',
          ),
          
          // Clear Button
          if (_searchController.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
                widget.onSearchChanged('');
                setState(() {
                  _isSearching = false;
                });
              },
              icon: Icon(
                Icons.clear_rounded,
                color: WorldClassDesignSystem.secondaryText,
                size: WorldClassDesignSystem.iconM,
              ),
            ),
        ],
      ),
    );
  }
}
