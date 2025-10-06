// 📦 WORLD CLASS ADD ITEM PAGE
// 4-step wizard: Photos → Details → Barter Preferences → Preview

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class WorldClassAddItemPage extends StatefulWidget {
  const WorldClassAddItemPage({Key? key}) : super(key: key);

  @override
  State<WorldClassAddItemPage> createState() => _WorldClassAddItemPageState();
}

class _WorldClassAddItemPageState extends State<WorldClassAddItemPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form data
  final List<File> _images = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _originalPriceController = TextEditingController();
  String? _selectedCategory;
  String? _selectedCondition;
  final List<String> _wantToTradeFor = [];
  bool _isOpenToCash = false;

  final List<String> _categories = [
    'Electronics',
    'Fashion',
    'Books',
    'Gaming',
    'Home',
    'Sports',
    'Art',
    'Music',
  ];

  final List<String> _conditions = [
    'Brand New',
    'Like New',
    'Good',
    'Fair',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _originalPriceController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitListing();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    
    if (images.isNotEmpty) {
      setState(() {
        _images.addAll(images.map((e) => File(e.path)));
      });
    }
  }

  void _submitListing() {
    // Validate and submit
    if (_images.isEmpty) {
      _showError('Please add at least one photo');
      return;
    }
    if (_titleController.text.isEmpty) {
      _showError('Please enter a title');
      return;
    }
    
    // TODO: Submit to Firebase
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Item listed successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    
    Navigator.of(context).pop();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List New Item'),
        elevation: 0,
        actions: [
          if (_currentStep > 0)
            TextButton(
              onPressed: () => setState(() {
                _currentStep = 0;
                _pageController.jumpToPage(0);
              }),
              child: const Text('Start Over'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: List.generate(4, (index) {
                final isActive = index <= _currentStep;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPhotosStep(),
                _buildDetailsStep(),
                _buildBarterPreferencesStep(),
                _buildPreviewStep(),
              ],
            ),
          ),

          // Bottom Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(_currentStep == 3 ? 'Publish' : 'Continue'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Photos',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Add up to 10 photos. First photo will be the cover image.',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),

          const SizedBox(height: 24),

          // Photo Grid
          if (_images.isEmpty)
            InkWell(
              onTap: _pickImages,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!, width: 2, style: BorderStyle.solid),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Tap to add photos',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _images.length + 1,
              itemBuilder: (context, index) {
                if (index == _images.length) {
                  return InkWell(
                    onTap: _pickImages,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Icon(Icons.add, size: 32, color: Colors.grey[400]),
                    ),
                  );
                }

                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _images[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    if (index == 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'COVER',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: InkWell(
                        onTap: () => setState(() => _images.removeAt(index)),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

          const SizedBox(height: 24),

          // Tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Photo Tips',
                      style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• Use natural lighting\n• Show all angles\n• Include close-ups of details\n• Show any defects clearly',
                  style: TextStyle(color: Colors.blue[900], fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Item Details',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Title
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Title *',
              hintText: 'e.g., iPhone 13 Pro 256GB',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            maxLength: 60,
          ),

          const SizedBox(height: 16),

          // Category
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Category *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            items: _categories.map((cat) {
              return DropdownMenuItem(value: cat, child: Text(cat));
            }).toList(),
            onChanged: (value) => setState(() => _selectedCategory = value),
          ),

          const SizedBox(height: 16),

          // Condition
          DropdownButtonFormField<String>(
            value: _selectedCondition,
            decoration: InputDecoration(
              labelText: 'Condition *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            items: _conditions.map((cond) {
              return DropdownMenuItem(value: cond, child: Text(cond));
            }).toList(),
            onChanged: (value) => setState(() => _selectedCondition = value),
          ),

          const SizedBox(height: 16),

          // Original Price
          TextField(
            controller: _originalPriceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Original Price (optional)',
              hintText: '₺1,000',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[50],
              prefixText: '₺ ',
            ),
          ),

          const SizedBox(height: 16),

          // Description
          TextField(
            controller: _descriptionController,
            maxLines: 5,
            maxLength: 500,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Describe your item, including any defects...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarterPreferencesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What do you want?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Select categories you\'re interested in trading for',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),

          const SizedBox(height: 24),

          // Category Selection
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _categories.map((category) {
              final isSelected = _wantToTradeFor.contains(category);
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _wantToTradeFor.add(category);
                    } else {
                      _wantToTradeFor.remove(category);
                    }
                  });
                },
                selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                checkmarkColor: Theme.of(context).primaryColor,
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // Cash Option
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: const Text('Open to cash difference'),
              subtitle: const Text('I can add or receive cash for the trade'),
              value: _isOpenToCash,
              onChanged: (value) => setState(() => _isOpenToCash = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'This is how your listing will appear',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),

          const SizedBox(height: 24),

          // Preview Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                if (_images.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: AspectRatio(
                      aspectRatio: 1.5,
                      child: Image.file(_images.first, fit: BoxFit.cover),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        _titleController.text.isEmpty ? 'Item Title' : _titleController.text,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 8),

                      // Category & Condition
                      Row(
                        children: [
                          if (_selectedCategory != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _selectedCategory!,
                                style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                              ),
                            ),
                          if (_selectedCondition != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _selectedCondition!,
                                style: TextStyle(fontSize: 12, color: Colors.green[700]),
                              ),
                            ),
                          ],
                        ],
                      ),

                      if (_descriptionController.text.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          _descriptionController.text,
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],

                      if (_wantToTradeFor.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Looking to trade for:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _wantToTradeFor.map((cat) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.purple[50],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(fontSize: 11, color: Colors.purple[700]),
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      if (_isOpenToCash) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.attach_money, size: 16, color: Colors.green[700]),
                            const SizedBox(width: 4),
                            Text(
                              'Open to cash difference',
                              style: TextStyle(fontSize: 12, color: Colors.green[700]),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
