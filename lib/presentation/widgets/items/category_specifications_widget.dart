import 'package:flutter/material.dart';
import '../../../domain/entities/item_specifications.dart';

/// Dynamic widget for category-specific item specifications
class CategorySpecificationsWidget extends StatefulWidget {
  final String category;
  final Map<String, dynamic>? initialSpecifications;
  final Function(Map<String, dynamic>) onSpecificationsChanged;

  const CategorySpecificationsWidget({
    Key? key,
    required this.category,
    this.initialSpecifications,
    required this.onSpecificationsChanged,
  }) : super(key: key);

  @override
  State<CategorySpecificationsWidget> createState() =>
      _CategorySpecificationsWidgetState();
}

class _CategorySpecificationsWidgetState
    extends State<CategorySpecificationsWidget> {
  final Map<String, TextEditingController> _controllers = {};
  Map<String, dynamic> _specifications = {};

  @override
  void initState() {
    super.initState();
    _specifications = widget.initialSpecifications ?? {};
    _initializeControllers();
  }

  void _initializeControllers() {
    final specs = ItemSpecifications.getSpecsForCategory(widget.category);
    for (final key in specs.keys) {
      final controller = TextEditingController(
        text: _specifications[key]?.toString() ?? '',
      );
      controller.addListener(() {
        _specifications[key] = controller.text;
        widget.onSpecificationsChanged(_specifications);
      });
      _controllers[key] = controller;
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final specs = ItemSpecifications.getSpecsForCategory(widget.category);
    final requiredSpecs = ItemSpecifications.getRequiredSpecsForCategory(widget.category);

    if (specs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Ürün Özellikleri',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Ürününüz hakkında daha fazla bilgi verin',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            ...specs.entries.map((entry) {
              final isRequired = requiredSpecs.contains(entry.key);
              return _buildSpecField(
                entry.key,
                entry.value,
                isRequired: isRequired,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecField(String key, String label, {required bool isRequired}) {
    // Special handling for specific fields
    switch (key) {
      case 'size':
        if (widget.category == 'Fashion') {
          return _buildDropdownField(
            key,
            label,
            ItemSpecifications.fashionSizes,
            isRequired: isRequired,
          );
        }
        break;
      case 'material':
        return _buildDropdownField(
          key,
          label,
          ItemSpecifications.commonMaterials,
          isRequired: isRequired,
        );
      case 'gender':
        return _buildDropdownField(
          key,
          label,
          ItemSpecifications.genders,
          isRequired: isRequired,
        );
      case 'season':
        return _buildDropdownField(
          key,
          label,
          ItemSpecifications.seasons,
          isRequired: isRequired,
        );
      case 'pet_type':
        return _buildDropdownField(
          key,
          label,
          ItemSpecifications.petTypes,
          isRequired: isRequired,
        );
      case 'age_range':
        return _buildDropdownField(
          key,
          label,
          ItemSpecifications.ageRanges,
          isRequired: isRequired,
        );
      case 'assembly_required':
      case 'battery_required':
      case 'safety_certified':
      case 'authenticated':
      case 'includes_case':
      case 'includes_accessories':
      case 'opened':
        return _buildBooleanField(key, label, isRequired: isRequired);
    }

    // Default text field
    return _buildTextField(key, label, isRequired: isRequired);
  }

  Widget _buildTextField(String key, String label, {required bool isRequired}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: _controllers[key],
        decoration: InputDecoration(
          labelText: label + (isRequired ? ' *' : ''),
          hintText: 'Örn: ${_getHintForKey(key)}',
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: isRequired ? Colors.blue.withOpacity(0.05) : null,
        ),
        maxLines: key.contains('description') || key.contains('instructions') ? 3 : 1,
      ),
    );
  }

  Widget _buildDropdownField(
    String key,
    String label,
    List<String> options, {
    required bool isRequired,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: _specifications[key]?.toString(),
        decoration: InputDecoration(
          labelText: label + (isRequired ? ' *' : ''),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: isRequired ? Colors.blue.withOpacity(0.05) : null,
        ),
        items: [
          const DropdownMenuItem<String>(
            value: null,
            child: Text('Seçiniz'),
          ),
          ...options.map((option) => DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              )),
        ],
        onChanged: (value) {
          setState(() {
            if (value != null) {
              _specifications[key] = value;
              _controllers[key]?.text = value;
            }
          });
          widget.onSpecificationsChanged(_specifications);
        },
      ),
    );
  }

  Widget _buildBooleanField(String key, String label, {required bool isRequired}) {
    final value = _specifications[key];
    final boolValue = value == true || value == 'true' || value == 'yes';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: CheckboxListTile(
        title: Text(label + (isRequired ? ' *' : '')),
        value: boolValue,
        onChanged: (newValue) {
          setState(() {
            _specifications[key] = newValue ?? false;
          });
          widget.onSpecificationsChanged(_specifications);
        },
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  String _getHintForKey(String key) {
    switch (key) {
      case 'brand':
        return 'Apple, Samsung, Nike';
      case 'model':
        return 'iPhone 14 Pro, Galaxy S23';
      case 'storage':
        return '256GB, 512GB';
      case 'ram':
        return '8GB, 16GB';
      case 'processor':
        return 'A16 Bionic, Snapdragon 8 Gen 2';
      case 'screen_size':
        return '6.1", 6.7"';
      case 'battery_health':
        return '85%, 95%';
      case 'warranty_months':
        return '6, 12, 24';
      case 'dimensions':
        return '100cm x 80cm x 50cm';
      case 'weight':
        return '5kg, 10kg';
      case 'author':
        return 'Orhan Pamuk, Elif Şafak';
      case 'publisher':
        return 'Can Yayınları, İletişim';
      case 'isbn':
        return '978-3-16-148410-0';
      case 'pages':
        return '250, 500';
      case 'publication_year':
      case 'release_year':
      case 'year':
        return '2023, 2024';
      case 'volume':
        return '50ml, 100ml';
      case 'power':
        return '1000W, 2000W';
      default:
        return 'Bilgi giriniz';
    }
  }
}

/// Display-only widget for showing specifications
class SpecificationsDisplayWidget extends StatelessWidget {
  final String category;
  final Map<String, dynamic> specifications;

  const SpecificationsDisplayWidget({
    Key? key,
    required this.category,
    required this.specifications,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (specifications.isEmpty) {
      return const SizedBox.shrink();
    }

    final specs = ItemSpecifications.getSpecsForCategory(category);
    final requiredSpecs = ItemSpecifications.getRequiredSpecsForCategory(category);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Ürün Özellikleri',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...specifications.entries.map((entry) {
              final specLabel = specs[entry.key] ?? ItemSpecifications.getDisplayName(entry.key);
              final isRequired = requiredSpecs.contains(entry.key);
              final value = entry.value.toString();

              if (value.isEmpty) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        specLabel + (isRequired ? ' *' : ''),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        _formatValue(entry.key, value),
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  String _formatValue(String key, String value) {
    // Boolean fields
    if (key.contains('required') || key.contains('certified') || 
        key.contains('authenticated') || key.contains('includes') || 
        key.contains('opened')) {
      if (value == 'true' || value == 'yes') return 'Evet';
      if (value == 'false' || value == 'no') return 'Hayır';
    }
    
    return value;
  }
}
