import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/world_class_design_system.dart';
import '../../blocs/item/item_bloc.dart';
import '../../blocs/item/item_event.dart';
import '../../blocs/item/item_state.dart';

class WorldClassAddItemPage extends StatefulWidget {
  const WorldClassAddItemPage({Key? key}) : super(key: key);

  @override
  State<WorldClassAddItemPage> createState() => _WorldClassAddItemPageState();
}

class _WorldClassAddItemPageState extends State<WorldClassAddItemPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  int _currentStep = 0;
  final int _totalSteps = 4;
  
  // Form data
  String _title = '';
  String _description = '';
  String _category = '';
  double _price = 0.0;
  String _condition = 'excellent';
  String _location = '';
  List<File> _images = [];
  
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: WorldClassDesignSystem.animationSlow,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: WorldClassDesignSystem.animationMedium,
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: WorldClassDesignSystem.animationMedium,
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      setState(() {
        _images = images.map((image) => File(image.path)).toList();
      });
    } catch (e) {
      _showErrorSnackBar('Failed to pick images: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _images.add(File(image.path));
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: WorldClassDesignSystem.errorColor,
      ),
    );
  }

  void _submitItem() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement item creation
      _showSuccessSnackBar('Item created successfully!');
      Navigator.of(context).pop();
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: WorldClassDesignSystem.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WorldClassDesignSystem.primaryBackground,
      appBar: AppBar(
        backgroundColor: WorldClassDesignSystem.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: WorldClassDesignSystem.primaryText,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Add New Item',
          style: WorldClassDesignSystem.headingMedium.copyWith(
            color: WorldClassDesignSystem.primaryText,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: Form(
                key: _formKey,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1(),
                    _buildStep2(),
                    _buildStep3(),
                    _buildStep4(),
                  ],
                ),
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: List.generate(_totalSteps, (index) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: index < _totalSteps - 1 ? 8 : 0,
                  ),
                  height: 4,
                  decoration: BoxDecoration(
                    color: index <= _currentStep
                        ? WorldClassDesignSystem.primaryColor
                        : WorldClassDesignSystem.cardBackground,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Text(
            'Step ${_currentStep + 1} of $_totalSteps',
            style: WorldClassDesignSystem.bodyMedium.copyWith(
              color: WorldClassDesignSystem.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: WorldClassDesignSystem.headingLarge.copyWith(
              color: WorldClassDesignSystem.primaryText,
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            label: 'Item Title',
            hint: 'Enter item title',
            value: _title,
            onChanged: (value) => setState(() => _title = value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter item title';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          _buildTextField(
            label: 'Description',
            hint: 'Describe your item',
            value: _description,
            onChanged: (value) => setState(() => _description = value),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter description';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          _buildDropdownField(
            label: 'Category',
            value: _category,
            items: const [
              'Electronics',
              'Clothing',
              'Home & Garden',
              'Sports',
              'Books',
              'Toys',
              'Other',
            ],
            onChanged: (value) => setState(() => _category = value ?? ''),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select category';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price & Condition',
            style: WorldClassDesignSystem.headingLarge.copyWith(
              color: WorldClassDesignSystem.primaryText,
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            label: 'Price (₺)',
            hint: '0.00',
            value: _price.toString(),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _price = double.tryParse(value) ?? 0.0;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter price';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter valid price';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          _buildDropdownField(
            label: 'Condition',
            value: _condition,
            items: const [
              'excellent',
              'good',
              'fair',
              'poor',
            ],
            onChanged: (value) => setState(() => _condition = value ?? 'excellent'),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            label: 'Location',
            hint: 'Enter location',
            value: _location,
            onChanged: (value) => setState(() => _location = value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter location';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Photos',
            style: WorldClassDesignSystem.headingLarge.copyWith(
              color: WorldClassDesignSystem.primaryText,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Add photos of your item (up to 10)',
            style: WorldClassDesignSystem.bodyMedium.copyWith(
              color: WorldClassDesignSystem.secondaryText,
            ),
          ),
          const SizedBox(height: 24),
          _buildImageGrid(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildImageButton(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onPressed: _pickImages,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildImageButton(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onPressed: _pickImage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Submit',
            style: WorldClassDesignSystem.headingLarge.copyWith(
              color: WorldClassDesignSystem.primaryText,
            ),
          ),
          const SizedBox(height: 24),
          _buildReviewCard(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required String value,
    required ValueChanged<String> onChanged,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: WorldClassDesignSystem.bodyMedium.copyWith(
            color: WorldClassDesignSystem.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: WorldClassDesignSystem.bodyMedium.copyWith(
            color: WorldClassDesignSystem.primaryText,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: WorldClassDesignSystem.bodyMedium.copyWith(
              color: WorldClassDesignSystem.secondaryText,
            ),
            filled: true,
            fillColor: WorldClassDesignSystem.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
              borderSide: BorderSide(
                color: WorldClassDesignSystem.primaryColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: WorldClassDesignSystem.bodyMedium.copyWith(
            color: WorldClassDesignSystem.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value.isEmpty ? null : value,
          onChanged: onChanged,
          validator: validator,
          style: WorldClassDesignSystem.bodyMedium.copyWith(
            color: WorldClassDesignSystem.primaryText,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: WorldClassDesignSystem.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
              borderSide: BorderSide(
                color: WorldClassDesignSystem.primaryColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImageGrid() {
    return Container(
      height: 200,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 8,
        ),
        itemCount: _images.length + 1,
        itemBuilder: (context, index) {
          if (index == _images.length) {
            return _buildAddImageButton();
          }
          return _buildImageItem(_images[index], index);
        },
      ),
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        decoration: BoxDecoration(
          color: WorldClassDesignSystem.cardBackground,
          borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
          border: Border.all(
            color: WorldClassDesignSystem.borderColor,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 32,
              color: WorldClassDesignSystem.secondaryText,
            ),
            const SizedBox(height: 8),
            Text(
              'Add Photo',
              style: WorldClassDesignSystem.bodySmall.copyWith(
                color: WorldClassDesignSystem.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(File image, int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
            image: DecorationImage(
              image: FileImage(image),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: WorldClassDesignSystem.errorColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 16,
                color: WorldClassDesignSystem.primaryWhite,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: WorldClassDesignSystem.cardBackground,
        foregroundColor: WorldClassDesignSystem.primaryText,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
        ),
      ),
    );
  }

  Widget _buildReviewCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: WorldClassDesignSystem.cardBackground,
        borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusLarge),
        boxShadow: [WorldClassDesignSystem.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Item Details',
            style: WorldClassDesignSystem.headingMedium.copyWith(
              color: WorldClassDesignSystem.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          _buildReviewItem('Title', _title),
          _buildReviewItem('Category', _category),
          _buildReviewItem('Condition', _condition),
          _buildReviewItem('Price', '₺${_price.toStringAsFixed(2)}'),
          _buildReviewItem('Location', _location),
          const SizedBox(height: 16),
          Text(
            'Description',
            style: WorldClassDesignSystem.bodyMedium.copyWith(
              color: WorldClassDesignSystem.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _description,
            style: WorldClassDesignSystem.bodyMedium.copyWith(
              color: WorldClassDesignSystem.secondaryText,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Photos (${_images.length})',
            style: WorldClassDesignSystem.bodyMedium.copyWith(
              color: WorldClassDesignSystem.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: WorldClassDesignSystem.bodyMedium.copyWith(
                color: WorldClassDesignSystem.secondaryText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: WorldClassDesignSystem.bodyMedium.copyWith(
                color: WorldClassDesignSystem.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: ElevatedButton(
                onPressed: _previousStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: WorldClassDesignSystem.cardBackground,
                  foregroundColor: WorldClassDesignSystem.primaryText,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
                  ),
                ),
                child: Text('Previous'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentStep == _totalSteps - 1 ? _submitItem : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: WorldClassDesignSystem.primaryColor,
                foregroundColor: WorldClassDesignSystem.primaryWhite,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
                ),
              ),
              child: Text(_currentStep == _totalSteps - 1 ? 'Submit' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }
}