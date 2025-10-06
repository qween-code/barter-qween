import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/world_class_design_system.dart';
import '../../../core/services/analytics_service.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../main/main_dashboard.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';

/// 🌟 WORLD-CLASS LOGIN PAGE
/// 
/// Features:
/// - Email/Password authentication
/// - Social login options
/// - Form validation
/// - Loading states
/// - Error handling
/// - Analytics tracking
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _obscurePassword = true;
  bool _rememberMe = false;

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
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
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

  void _handleGoogleLogin() {
    context.read<AuthBloc>().add(AuthGoogleSignInRequested());
  }

  void _handleAppleLogin() {
    // TODO: Implement Apple Sign In
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Apple Sign In not implemented yet')),
    );
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const RegisterPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        transitionDuration: WorldClassDesignSystem.animationNormal,
      ),
    );
  }

  void _navigateToForgotPassword() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const ForgotPasswordPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: WorldClassDesignSystem.animationNormal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WorldClassDesignSystem.primaryBackground,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const MainDashboard(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  transitionDuration: WorldClassDesignSystem.animationNormal,
                ),
              );
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: WorldClassDesignSystem.errorColor,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(WorldClassDesignSystem.spacingXL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: WorldClassDesignSystem.spacingXXL),
                
                // Logo and Welcome
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              WorldClassDesignSystem.primaryColor,
                              WorldClassDesignSystem.secondaryColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusL),
                          boxShadow: WorldClassDesignSystem.shadowM,
                        ),
                        child: Icon(
                          Icons.swap_horiz_rounded,
                          size: 40,
                          color: WorldClassDesignSystem.primaryWhite,
                        ),
                      ),
                      
                      const SizedBox(height: WorldClassDesignSystem.spacingL),
                      
                      Text(
                        'Welcome Back',
                        style: WorldClassDesignSystem.heading1.copyWith(
                          color: WorldClassDesignSystem.primaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: WorldClassDesignSystem.spacingS),
                      
                      Text(
                        'Sign in to continue trading',
                        style: WorldClassDesignSystem.bodyLarge.copyWith(
                          color: WorldClassDesignSystem.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: WorldClassDesignSystem.spacingXXL),
                
                // Login Form
                SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: WorldClassDesignSystem.inputDecoration.copyWith(
                            labelText: 'Email',
                            hintText: 'Enter your email',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: WorldClassDesignSystem.secondaryText,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: WorldClassDesignSystem.spacingL),
                        
                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: WorldClassDesignSystem.inputDecoration.copyWith(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: Icon(
                              Icons.lock_outlined,
                              color: WorldClassDesignSystem.secondaryText,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: WorldClassDesignSystem.secondaryText,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: WorldClassDesignSystem.spacingM),
                        
                        // Remember Me & Forgot Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  activeColor: WorldClassDesignSystem.primaryColor,
                                ),
                                Text(
                                  'Remember me',
                                  style: WorldClassDesignSystem.bodyMedium.copyWith(
                                    color: WorldClassDesignSystem.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: _navigateToForgotPassword,
                              child: Text(
                                'Forgot Password?',
                                style: WorldClassDesignSystem.labelMedium.copyWith(
                                  color: WorldClassDesignSystem.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: WorldClassDesignSystem.spacingXL),
                        
                        // Login Button
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return ElevatedButton(
                              onPressed: state is AuthLoading ? null : _handleLogin,
                              style: WorldClassDesignSystem.primaryButtonStyle,
                              child: state is AuthLoading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          WorldClassDesignSystem.primaryWhite,
                                        ),
                                      ),
                                    )
                                  : const Text('Sign In'),
                            );
                          },
                        ),
                        
                        const SizedBox(height: WorldClassDesignSystem.spacingXL),
                        
                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: WorldClassDesignSystem.borderColor,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: WorldClassDesignSystem.spacingM,
                              ),
                              child: Text(
                                'or continue with',
                                style: WorldClassDesignSystem.bodySmall.copyWith(
                                  color: WorldClassDesignSystem.secondaryText,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: WorldClassDesignSystem.borderColor,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: WorldClassDesignSystem.spacingXL),
                        
                        // Social Login Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _handleGoogleLogin,
                                icon: Icon(
                                  Icons.g_mobiledata,
                                  color: WorldClassDesignSystem.primaryColor,
                                ),
                                label: Text(
                                  'Google',
                                  style: WorldClassDesignSystem.labelLarge.copyWith(
                                    color: WorldClassDesignSystem.primaryColor,
                                  ),
                                ),
                                style: WorldClassDesignSystem.secondaryButtonStyle,
                              ),
                            ),
                            
                            const SizedBox(width: WorldClassDesignSystem.spacingM),
                            
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _handleAppleLogin,
                                icon: Icon(
                                  Icons.apple,
                                  color: WorldClassDesignSystem.primaryColor,
                                ),
                                label: Text(
                                  'Apple',
                                  style: WorldClassDesignSystem.labelLarge.copyWith(
                                    color: WorldClassDesignSystem.primaryColor,
                                  ),
                                ),
                                style: WorldClassDesignSystem.secondaryButtonStyle,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: WorldClassDesignSystem.spacingXXL),
                        
                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: WorldClassDesignSystem.bodyMedium.copyWith(
                                color: WorldClassDesignSystem.secondaryText,
                              ),
                            ),
                            TextButton(
                              onPressed: _navigateToRegister,
                              child: Text(
                                'Sign Up',
                                style: WorldClassDesignSystem.labelLarge.copyWith(
                                  color: WorldClassDesignSystem.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
