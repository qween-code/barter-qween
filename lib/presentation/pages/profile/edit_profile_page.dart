import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/profile/profile_event.dart';
import '../../blocs/profile/profile_state.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/user_avatar_widget.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();
  
  File? _selectedImage;
  String? _currentPhotoUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  void _loadCurrentProfile() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;
      _displayNameController.text = user.displayName ?? '';
      _phoneController.text = user.phoneNumber ?? '';
      _cityController.text = user.city ?? '';
      _addressController.text = user.address ?? '';
      _bioController.text = user.bio ?? '';
      _currentPhotoUrl = user.photoUrl;
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final user = authState.user;

    // Upload avatar first if image selected
    if (_selectedImage != null) {
      context.read<ProfileBloc>().add(
        UploadAvatar(
          userId: user.uid,
          imageFile: _selectedImage!,
        ),
      );
      
      // Wait a bit for upload to complete
      await Future.delayed(const Duration(seconds: 2));
    }

    // Update profile
    final updatedUser = user.copyWith(
      displayName: _displayNameController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty 
          ? null 
          : _phoneController.text.trim(),
      city: _cityController.text.trim().isEmpty 
          ? null 
          : _cityController.text.trim(),
      address: _addressController.text.trim().isEmpty 
          ? null 
          : _addressController.text.trim(),
      bio: _bioController.text.trim().isEmpty 
          ? null 
          : _bioController.text.trim(),
    );

    context.read<ProfileBloc>().add(UpdateProfile(updatedUser));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Edit Profile', style: AppTextStyles.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdated || state is AvatarUploaded) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is ProfileError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spacing24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Avatar with edit button
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        if (_selectedImage != null)
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surface,
                                width: 3,
                              ),
                              image: DecorationImage(
                                image: FileImage(_selectedImage!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        else
                          UserAvatarWidget(
                            photoUrl: _currentPhotoUrl,
                            displayName: _displayNameController.text,
                            size: 120,
                            showEditButton: true,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacing8),
                  
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Change Photo'),
                  ),

                  const SizedBox(height: AppDimensions.spacing32),

                  // Display Name
                  CustomTextField(
                    controller: _displayNameController,
                    labelText: 'Display Name',
                    hintText: 'Enter your display name',
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your display name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppDimensions.spacing16),

                  // Phone
                  CustomTextField(
                    controller: _phoneController,
                    labelText: 'Phone',
                    hintText: 'Enter your phone number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: AppDimensions.spacing16),

                  // City
                  CustomTextField(
                    controller: _cityController,
                    labelText: 'City',
                    hintText: 'Enter your city',
                    prefixIcon: Icons.location_city_outlined,
                  ),

                  const SizedBox(height: AppDimensions.spacing16),

                  // Address
                  CustomTextField(
                    controller: _addressController,
                    labelText: 'Address',
                    hintText: 'Enter your address',
                    prefixIcon: Icons.home_outlined,
                    maxLines: 2,
                  ),

                  const SizedBox(height: AppDimensions.spacing16),

                  // Bio
                  CustomTextField(
                    controller: _bioController,
                    labelText: 'Bio',
                    hintText: 'Tell us about yourself',
                    prefixIcon: Icons.info_outline,
                    maxLines: 3,
                    maxLength: 200,
                  ),

                  const SizedBox(height: AppDimensions.spacing32),

                  // Save Button
                  PrimaryButton(
                    text: 'Save Changes',
                    onPressed: _isLoading ? null : _handleSave,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
