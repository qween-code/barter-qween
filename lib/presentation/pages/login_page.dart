import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection.dart';
import '../../core/routes/route_names.dart';
import '../../core/theme/minimal_design_system.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MinimalDesignSystem.primaryWhite,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthLoading) {
              setState(() => _isLoading = true);
            } else if (state is AuthAuthenticated) {
              setState(() => _isLoading = false);
              Navigator.of(context).pushReplacementNamed(RouteNames.dashboard);
            } else if (state is AuthError) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: MinimalDesignSystem.errorColor,
                ),
              );
            } else {
              setState(() => _isLoading = false);
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(MinimalDesignSystem.spacingL),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: MinimalDesignSystem.spacingXL),
                  
                  // Logo
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: MinimalDesignSystem.primaryBlack,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.swap_horiz_rounded,
                        size: 40,
                        color: MinimalDesignSystem.primaryWhite,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: MinimalDesignSystem.spacingXL),
                  
                  // Title
                  Text(
                    'Hoş Geldiniz',
                    style: MinimalDesignSystem.heading1.copyWith(
                      color: MinimalDesignSystem.primaryBlack,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: MinimalDesignSystem.spacingS),
                  
                  Text(
                    'Hesabınıza giriş yapın',
                    style: MinimalDesignSystem.bodyLarge.copyWith(
                      color: MinimalDesignSystem.secondaryGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: MinimalDesignSystem.spacingXL),
                  
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'E-posta',
                      hintText: 'ornek@email.com',
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: MinimalDesignSystem.secondaryGray,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: MinimalDesignSystem.lightGray,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: MinimalDesignSystem.lightGray,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: MinimalDesignSystem.primaryBlack,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'E-posta adresi gerekli';
                      }
                      if (!value.contains('@')) {
                        return 'Geçerli bir e-posta adresi girin';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: MinimalDesignSystem.spacingL),
                  
                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      hintText: 'Şifrenizi girin',
                      prefixIcon: Icon(
                        Icons.lock_outlined,
                        color: MinimalDesignSystem.secondaryGray,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible 
                            ? Icons.visibility_off_outlined 
                            : Icons.visibility_outlined,
                          color: MinimalDesignSystem.secondaryGray,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: MinimalDesignSystem.lightGray,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: MinimalDesignSystem.lightGray,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: MinimalDesignSystem.primaryBlack,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Şifre gerekli';
                      }
                      if (value.length < 6) {
                        return 'Şifre en az 6 karakter olmalı';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: MinimalDesignSystem.spacingL),
                  
                  // Login Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MinimalDesignSystem.primaryBlack,
                        foregroundColor: MinimalDesignSystem.primaryWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                MinimalDesignSystem.primaryWhite,
                              ),
                            ),
                          )
                        : Text(
                            'Giriş Yap',
                            style: MinimalDesignSystem.buttonText.copyWith(
                              color: MinimalDesignSystem.primaryWhite,
                            ),
                          ),
                    ),
                  ),
                  
                  const SizedBox(height: MinimalDesignSystem.spacingL),
                  
                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hesabınız yok mu? ',
                        style: MinimalDesignSystem.bodyMedium.copyWith(
                          color: MinimalDesignSystem.secondaryGray,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(RouteNames.register);
                        },
                        child: Text(
                          'Kayıt Ol',
                          style: MinimalDesignSystem.bodyMedium.copyWith(
                            color: MinimalDesignSystem.primaryBlack,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: MinimalDesignSystem.spacingL),
                  
                  // Test User Info
                  Container(
                    padding: const EdgeInsets.all(MinimalDesignSystem.spacingM),
                    decoration: BoxDecoration(
                      color: MinimalDesignSystem.lightGray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Test Kullanıcısı',
                          style: MinimalDesignSystem.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: MinimalDesignSystem.primaryBlack,
                          ),
                        ),
                        const SizedBox(height: MinimalDesignSystem.spacingXS),
                        Text(
                          'alice.johnson@example.com',
                          style: MinimalDesignSystem.bodySmall.copyWith(
                            color: MinimalDesignSystem.secondaryGray,
                          ),
                        ),
                        Text(
                          'Test123!',
                          style: MinimalDesignSystem.bodySmall.copyWith(
                            color: MinimalDesignSystem.secondaryGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }
}