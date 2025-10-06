import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/neuromorphic_effects.dart';
import '../widgets/neumorphism/neumorphism_container.dart';

/// Shadow Preset Gallery
/// Browse and test all neuromorphic shadow presets

class ShadowPresetGalleryPage extends StatelessWidget {
  const ShadowPresetGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Shadow Preset Gallery'),
        backgroundColor: AppColors.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionTitle('Button Presets'),
          const SizedBox(height: 20),
          _buildButtonPresets(),
          const SizedBox(height: 40),
          
          _buildSectionTitle('Card Presets'),
          const SizedBox(height: 20),
          _buildCardPresets(),
          const SizedBox(height: 40),
          
          _buildSectionTitle('Input Presets'),
          const SizedBox(height: 20),
          _buildInputPresets(),
          const SizedBox(height: 40),
          
          _buildSectionTitle('Navigation Presets'),
          const SizedBox(height: 20),
          _buildNavigationPresets(),
          const SizedBox(height: 40),
          
          _buildSectionTitle('Icon Presets'),
          const SizedBox(height: 20),
          _buildIconPresets(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.headlineMedium.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildButtonPresets() {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        _buildPresetCard(
          'Primary',
          '12 layers',
          NeuromorphicPresets.ButtonPresets.primary(),
        ),
        _buildPresetCard(
          'Primary (Hover)',
          '12 layers',
          NeuromorphicPresets.ButtonPresets.primary(isHovered: true),
        ),
        _buildPresetCard(
          'Primary (Pressed)',
          '12 layers',
          NeuromorphicPresets.ButtonPresets.primary(isPressed: true),
        ),
        _buildPresetCard(
          'Secondary',
          '8 layers',
          NeuromorphicPresets.ButtonPresets.secondary(),
        ),
        _buildPresetCard(
          'Secondary (Hover)',
          '8 layers',
          NeuromorphicPresets.ButtonPresets.secondary(isHovered: true),
        ),
        _buildPresetCard(
          'Icon',
          '6 layers',
          NeuromorphicPresets.ButtonPresets.icon(),
        ),
        _buildPresetCard(
          'FAB',
          '16 layers + glow',
          NeuromorphicPresets.ButtonPresets.fab(),
        ),
      ],
    );
  }

  Widget _buildCardPresets() {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        _buildPresetCard(
          'Standard',
          '12 layers',
          NeuromorphicPresets.CardPresets.standard(),
        ),
        _buildPresetCard(
          'Standard (Hover)',
          '12 layers',
          NeuromorphicPresets.CardPresets.standard(isHovered: true),
        ),
        _buildPresetCard(
          'Hero',
          '20 layers',
          NeuromorphicPresets.CardPresets.hero(),
        ),
        _buildPresetCard(
          'Hero (Hover)',
          '20 layers',
          NeuromorphicPresets.CardPresets.hero(isHovered: true),
        ),
        _buildPresetCard(
          'Product',
          '16 layers',
          NeuromorphicPresets.CardPresets.product(),
        ),
        _buildPresetCard(
          'Product (Hover)',
          '16 layers',
          NeuromorphicPresets.CardPresets.product(isHovered: true),
        ),
        _buildPresetCard(
          'Floating',
          '10 layers + shadow',
          NeuromorphicPresets.CardPresets.floating(),
        ),
      ],
    );
  }

  Widget _buildInputPresets() {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        _buildPresetCard(
          'TextField',
          '8 layers (inset)',
          NeuromorphicPresets.InputPresets.textField(),
        ),
        _buildPresetCard(
          'TextField (Focused)',
          '8 layers + glow',
          NeuromorphicPresets.InputPresets.textField(isFocused: true),
        ),
        _buildPresetCard(
          'SearchBar',
          '10 layers (inset)',
          NeuromorphicPresets.InputPresets.searchBar(),
        ),
        _buildPresetCard(
          'SearchBar (Focused)',
          '10 layers + glow',
          NeuromorphicPresets.InputPresets.searchBar(isFocused: true),
        ),
      ],
    );
  }

  Widget _buildNavigationPresets() {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        _buildPresetCard(
          'Bottom Nav',
          '16 layers',
          NeuromorphicPresets.NavigationPresets.bottomNav(),
        ),
        _buildPresetCard(
          'App Bar',
          '12 layers',
          NeuromorphicPresets.NavigationPresets.appBar(),
        ),
        _buildPresetCard(
          'Tab Bar',
          '8 layers',
          NeuromorphicPresets.NavigationPresets.tabBar(),
        ),
      ],
    );
  }

  Widget _buildIconPresets() {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        _buildPresetCard(
          'Standard',
          '4 layers',
          NeuromorphicPresets.IconPresets.standard(),
        ),
        _buildPresetCard(
          'Standard (Active)',
          '4 layers',
          NeuromorphicPresets.IconPresets.standard(isActive: true),
        ),
        _buildPresetCard(
          'Circular',
          '6 layers',
          NeuromorphicPresets.IconPresets.circular(),
        ),
        _buildPresetCard(
          'Circular (Active)',
          '6 layers + glow',
          NeuromorphicPresets.IconPresets.circular(
            isActive: true,
            glowColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildPresetCard(String name, String description, List<BoxShadow> shadows) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: shadows,
            ),
            child: Center(
              child: Text(
                '${shadows.length}\nLayers',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              _showShadowDetails(name, shadows);
            },
            child: const Text('View Code'),
          ),
        ],
      ),
    );
  }

  void _showShadowDetails(String name, List<BoxShadow> shadows) {
    // Generate code for the shadows
    final code = _generateShadowCode(shadows);
    
    // Show dialog with code
    showDialog(
      context: null!,
      builder: (context) => AlertDialog(
        title: Text(name),
        content: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              code,
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _generateShadowCode(List<BoxShadow> shadows) {
    final buffer = StringBuffer('boxShadow: [\n');
    
    for (var i = 0; i < shadows.length; i++) {
      final shadow = shadows[i];
      buffer.writeln('  BoxShadow(');
      buffer.writeln('    color: Color(0x${shadow.color.value.toRadixString(16).padLeft(8, '0')}),');
      buffer.writeln('    offset: Offset(${shadow.offset.dx.toStringAsFixed(1)}, ${shadow.offset.dy.toStringAsFixed(1)}),');
      buffer.writeln('    blurRadius: ${shadow.blurRadius.toStringAsFixed(1)},');
      buffer.writeln('    spreadRadius: ${shadow.spreadRadius.toStringAsFixed(1)},');
      buffer.write('  )');
      if (i < shadows.length - 1) {
        buffer.writeln(',');
      } else {
        buffer.writeln();
      }
    }
    
    buffer.writeln(']');
    return buffer.toString();
  }
}
