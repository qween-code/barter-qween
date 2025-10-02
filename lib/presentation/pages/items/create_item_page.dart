import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/item_entity.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/item/item_bloc.dart';
import '../../blocs/item/item_event.dart';
import '../../blocs/item/item_state.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/custom_text_field.dart';

class CreateItemPage extends StatelessWidget {
  const CreateItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CreateItemView();
  }
}

class CreateItemView extends StatefulWidget {
  const CreateItemView({super.key});

  @override
  State<CreateItemView> createState() => _CreateItemViewState();
}

class _CreateItemViewState extends State<CreateItemView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tradePreferenceController = TextEditingController();
  final _picker = ImagePicker();
  
  List<File> _selectedImages = [];
  String? _selectedCategory;
  String? _selectedCondition;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tradePreferenceController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFiles != null) {
      setState(() {
        _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one image'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() => _isLoading = true);

    final item = ItemEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory!,
      images: [],
      condition: _selectedCondition,
      ownerId: authState.user.uid,
      ownerName: authState.user.displayName ?? 'User',
      ownerPhotoUrl: authState.user.photoUrl,
      city: authState.user.city,
      status: ItemStatus.active,
      createdAt: DateTime.now(),
      tradePreference: _tradePreferenceController.text.trim().isEmpty
          ? null
          : _tradePreferenceController.text.trim(),
    );

    context.read<ItemBloc>().add(CreateItem(item, images: _selectedImages));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Create Listing', style: AppTextStyles.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<ItemBloc, ItemState>(
        listener: (context, state) {
          if (state is ItemCreated) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Item created successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is ItemError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spacing24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Images Section
                Text(
                  'Photos',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing12),
                
                _buildImagePicker(),
                
                const SizedBox(height: AppDimensions.spacing24),

                // Title
                CustomTextField(
                  controller: _titleController,
                  labelText: 'Title',
                  hintText: 'What are you trading?',
                  prefixIcon: Icons.title_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppDimensions.spacing16),

                // Category
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    prefixIcon: const Icon(Icons.category_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    ),
                  ),
                  items: ItemCategory.all
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedCategory = value),
                  validator: (value) {
                    if (value == null) return 'Please select a category';
                    return null;
                  },
                ),

                const SizedBox(height: AppDimensions.spacing16),

                // Condition
                DropdownButtonFormField<String>(
                  value: _selectedCondition,
                  decoration: InputDecoration(
                    labelText: 'Condition',
                    prefixIcon: const Icon(Icons.star_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    ),
                  ),
                  items: ItemCondition.all
                      .map((cond) => DropdownMenuItem(value: cond, child: Text(cond)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedCondition = value),
                ),

                const SizedBox(height: AppDimensions.spacing16),

                // Description
                CustomTextField(
                  controller: _descriptionController,
                  labelText: 'Description',
                  hintText: 'Describe your item in detail',
                  prefixIcon: Icons.description_outlined,
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppDimensions.spacing16),

                // Trade Preference
                CustomTextField(
                  controller: _tradePreferenceController,
                  labelText: 'What do you want in exchange? (Optional)',
                  hintText: 'e.g. Books, Electronics, etc.',
                  prefixIcon: Icons.swap_horiz,
                  maxLines: 2,
                ),

                const SizedBox(height: AppDimensions.spacing32),

                // Create Button
                PrimaryButton(
                  text: 'Create Listing',
                  onPressed: _isLoading ? null : _handleCreate,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderDefault),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: Column(
        children: [
          if (_selectedImages.isEmpty)
            InkWell(
              onTap: _pickImages,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  border: Border.all(
                    color: AppColors.borderLight,
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 64,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: AppDimensions.spacing12),
                      Text(
                        'Add Photos',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacing4),
                      Text(
                        'Tap to select images',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(_selectedImages[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppDimensions.spacing12),
                OutlinedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('Add More Photos'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
