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
import '../../widgets/barter/barter_condition_selector.dart';
import '../../../domain/entities/barter_condition_entity.dart';

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
  
  // Barter fields
  ItemTier _selectedTier = ItemTier.medium;
  double? _estimatedValue;
  BarterConditionType _barterConditionType = BarterConditionType.flexible;
  double? _cashAmount;
  List<String> _acceptedCategories = [];

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
    if (index < _selectedImages.length) {
      setState(() {
        _selectedImages.removeAt(index);
      });
    }
  }

  void _handleCreate() async {
    if (_formKey.currentState?.validate() != true) return;
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

    final barterCondition = BarterConditionEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _barterConditionType,
      cashDifferential: _cashAmount,
      paymentDirection: _barterConditionType == BarterConditionType.cashPlus
          ? CashPaymentDirection.fromMe
          : _barterConditionType == BarterConditionType.cashMinus
              ? CashPaymentDirection.toMe
              : null,
      acceptedCategories: _acceptedCategories.isNotEmpty ? _acceptedCategories : null,
      createdAt: DateTime.now(),
    );

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
      // New barter fields
      tier: _selectedTier,
      price: _estimatedValue, // Using price field as estimatedValue
      monetaryValue: _estimatedValue,
      barterCondition: barterCondition,
      moderationStatus: ModerationStatus.pending,
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

                const SizedBox(height: AppDimensions.spacing24),

                // Item Tier Section
                Text(
                  'Ürün Boyutu',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing12),
                _buildTierSelector(),

                const SizedBox(height: AppDimensions.spacing24),

                // Estimated Value
                Text(
                  'Tahmini Değer',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing12),
                _buildMonetaryValueInput(),

                const SizedBox(height: AppDimensions.spacing24),

                // Barter Conditions
                BarterConditionSelector(
                  selectedType: _barterConditionType,
                  onTypeChanged: (type) {
                    setState(() => _barterConditionType = type);
                  },
                  cashAmount: _cashAmount,
                  onCashAmountChanged: (amount) {
                    setState(() => _cashAmount = amount);
                  },
                  selectedCategories: _acceptedCategories,
                  onCategoriesChanged: (categories) {
                    setState(() => _acceptedCategories = categories);
                  },
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

  Widget _buildMonetaryValueInput() {
    return TextFormField(
      initialValue: _estimatedValue?.toStringAsFixed(0),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Ürününüzün tahmini değeri (TL)',
        hintText: '0',
        prefixText: '₺ ',
        suffixText: 'TL',
        prefixIcon: const Icon(Icons.attach_money),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
      ),
      onChanged: (value) {
        final amount = double.tryParse(value);
        setState(() => _estimatedValue = amount);
      },
    );
  }

  Widget _buildTierSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderDefault),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: Row(
        children: ItemTier.values.map((tier) {
          final isSelected = _selectedTier == tier;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                onTap: () => setState(() => _selectedTier = tier),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.spacing12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.borderLight,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTierIcon(tier, isSelected),
                      const SizedBox(height: 4),
                      Text(
                        tier.displayName,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTierIcon(ItemTier tier, bool isSelected) {
    IconData icon;
    Color color;

    switch (tier) {
      case ItemTier.small:
        icon = Icons.shopping_bag_outlined;
        color = Colors.green;
        break;
      case ItemTier.medium:
        icon = Icons.shopping_basket_outlined;
        color = Colors.orange;
        break;
      case ItemTier.large:
        icon = Icons.shopping_cart_outlined;
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 32,
        color: isSelected ? color : AppColors.textSecondary,
      ),
    );
  }
}
