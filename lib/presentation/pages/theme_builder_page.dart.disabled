import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/neuromorphic_effects.dart';
import '../widgets/neumorphism/neumorphism_container.dart';
import '../widgets/primary_button.dart';

/// Custom Theme Builder UI
/// Interactive tool for creating custom neuromorphic themes

class ThemeBuilderPage extends StatefulWidget {
  const ThemeBuilderPage({super.key});

  @override
  State<ThemeBuilderPage> createState() => _ThemeBuilderPageState();
}

class _ThemeBuilderPageState extends State<ThemeBuilderPage> {
  // Theme parameters
  Color _backgroundColor = AppColors.background;
  Color _surfaceColor = AppColors.surface;
  Color _primaryColor = AppColors.primary;
  
  // Shadow parameters
  double _depth = 3.0;
  double _lightIntensity = 0.95;
  double _darkIntensity = 0.3;
  double _blurRadius = 20.0;
  double _spreadRadius = -2.0;
  
  // Glow parameters
  bool _enableGlow = true;
  Color _glowColor = AppColors.primary;
  double _glowIntensity = 0.6;
  double _glowRadius = 25.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Theme Builder'),
        backgroundColor: _surfaceColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTheme,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _exportTheme,
          ),
        ],
      ),
      body: Row(
        children: [
          // Controls Panel
          Expanded(
            flex: 2,
            child: _buildControlsPanel(),
          ),
          
          // Preview Panel
          Expanded(
            flex: 3,
            child: _buildPreviewPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsPanel() {
    return Container(
      color: _surfaceColor,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionTitle('Colors'),
          _buildColorPicker(
            'Background',
            _backgroundColor,
            (color) => setState(() => _backgroundColor = color),
          ),
          _buildColorPicker(
            'Surface',
            _surfaceColor,
            (color) => setState(() => _surfaceColor = color),
          ),
          _buildColorPicker(
            'Primary',
            _primaryColor,
            (color) => setState(() => _primaryColor = color),
          ),
          
          const Divider(height: 40),
          
          _buildSectionTitle('Shadow Settings'),
          _buildSlider(
            'Depth',
            _depth,
            0.5,
            6.0,
            (value) => setState(() => _depth = value),
          ),
          _buildSlider(
            'Light Intensity',
            _lightIntensity,
            0.0,
            1.0,
            (value) => setState(() => _lightIntensity = value),
          ),
          _buildSlider(
            'Dark Intensity',
            _darkIntensity,
            0.0,
            1.0,
            (value) => setState(() => _darkIntensity = value),
          ),
          _buildSlider(
            'Blur Radius',
            _blurRadius,
            4.0,
            40.0,
            (value) => setState(() => _blurRadius = value),
          ),
          _buildSlider(
            'Spread Radius',
            _spreadRadius,
            -10.0,
            10.0,
            (value) => setState(() => _spreadRadius = value),
          ),
          
          const Divider(height: 40),
          
          _buildSectionTitle('Glow Settings'),
          SwitchListTile(
            title: const Text('Enable Glow'),
            value: _enableGlow,
            onChanged: (value) => setState(() => _enableGlow = value),
          ),
          if (_enableGlow) ...[
            _buildColorPicker(
              'Glow Color',
              _glowColor,
              (color) => setState(() => _glowColor = color),
            ),
            _buildSlider(
              'Glow Intensity',
              _glowIntensity,
              0.0,
              1.0,
              (value) => setState(() => _glowIntensity = value),
            ),
            _buildSlider(
              'Glow Radius',
              _glowRadius,
              10.0,
              50.0,
              (value) => setState(() => _glowRadius = value),
            ),
          ],
          
          const SizedBox(height: 40),
          
          ElevatedButton.icon(
            onPressed: _resetToDefaults,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset to Defaults'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewPanel() {
    return Container(
      color: _backgroundColor,
      padding: const EdgeInsets.all(40),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Preview',
                style: AppTextStyles.headlineLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              
              // Button Preview
              Container(
                width: 300,
                height: 60,
                decoration: BoxDecoration(
                  color: _surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _buildPreviewShadows(),
                ),
                child: Center(
                  child: Text(
                    'Button Preview',
                    style: TextStyle(
                      color: _primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Card Preview
              Container(
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  color: _surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: _buildPreviewShadows(),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Card Preview',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This is how your custom neuromorphic design will look.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 100,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Action',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Icon Preview
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _surfaceColor,
                  shape: BoxShape.circle,
                  boxShadow: _buildPreviewShadows(),
                ),
                child: Icon(
                  Icons.favorite,
                  size: 40,
                  color: _primaryColor,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Code Preview
              Container(
                width: 400,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Generated Code:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _generateCode(),
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildColorPicker(String label, Color color, Function(Color) onChanged) {
    return ListTile(
      title: Text(label),
      trailing: GestureDetector(
        onTap: () => _showColorPicker(color, onChanged),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
        ),
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              value.toStringAsFixed(2),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }

  List<BoxShadow> _buildPreviewShadows() {
    final shadows = <BoxShadow>[];
    
    // Light shadow
    shadows.add(BoxShadow(
      color: Colors.white.withOpacity(_lightIntensity),
      offset: Offset(-_depth * 4, -_depth * 4),
      blurRadius: _blurRadius,
      spreadRadius: _spreadRadius,
    ));
    
    // Dark shadow
    shadows.add(BoxShadow(
      color: Colors.black.withOpacity(_darkIntensity),
      offset: Offset(_depth * 4, _depth * 4),
      blurRadius: _blurRadius,
      spreadRadius: _spreadRadius,
    ));
    
    // Glow
    if (_enableGlow) {
      shadows.addAll([
        BoxShadow(
          color: _glowColor.withOpacity(_glowIntensity * 0.4),
          offset: Offset.zero,
          blurRadius: _glowRadius,
          spreadRadius: _glowRadius * 0.3,
        ),
        BoxShadow(
          color: _glowColor.withOpacity(_glowIntensity * 0.2),
          offset: Offset.zero,
          blurRadius: _glowRadius * 1.5,
          spreadRadius: _glowRadius * 0.5,
        ),
      ]);
    }
    
    return shadows;
  }

  String _generateCode() {
    return '''
boxShadow: [
  BoxShadow(
    color: Colors.white.withOpacity(${_lightIntensity.toStringAsFixed(2)}),
    offset: Offset(${(-_depth * 4).toStringAsFixed(1)}, ${(-_depth * 4).toStringAsFixed(1)}),
    blurRadius: ${_blurRadius.toStringAsFixed(1)},
    spreadRadius: ${_spreadRadius.toStringAsFixed(1)},
  ),
  BoxShadow(
    color: Colors.black.withOpacity(${_darkIntensity.toStringAsFixed(2)}),
    offset: Offset(${(_depth * 4).toStringAsFixed(1)}, ${(_depth * 4).toStringAsFixed(1)}),
    blurRadius: ${_blurRadius.toStringAsFixed(1)},
    spreadRadius: ${_spreadRadius.toStringAsFixed(1)},
  ),${_enableGlow ? '''
  BoxShadow(
    color: Color(0x${_glowColor.value.toRadixString(16).padLeft(8, '0')}).withOpacity(${_glowIntensity.toStringAsFixed(2)}),
    blurRadius: ${_glowRadius.toStringAsFixed(1)},
  ),''' : ''}
]''';
  }

  void _showColorPicker(Color currentColor, Function(Color) onChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a Color'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Preset colors
              ...Colors.primaries.map((color) {
                return GestureDetector(
                  onTap: () {
                    onChanged(color);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: currentColor == color ? Colors.black : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _resetToDefaults() {
    setState(() {
      _backgroundColor = AppColors.background;
      _surfaceColor = AppColors.surface;
      _primaryColor = AppColors.primary;
      _depth = 3.0;
      _lightIntensity = 0.95;
      _darkIntensity = 0.3;
      _blurRadius = 20.0;
      _spreadRadius = -2.0;
      _enableGlow = true;
      _glowColor = AppColors.primary;
      _glowIntensity = 0.6;
      _glowRadius = 25.0;
    });
  }

  void _saveTheme() {
    // In production, save to SharedPreferences or database
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Theme saved!')),
    );
  }

  void _exportTheme() {
    // In production, export as JSON or code
    final code = _generateCode();
    debugPrint('Exported theme code:\n$code');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Theme code copied!')),
    );
  }
}
