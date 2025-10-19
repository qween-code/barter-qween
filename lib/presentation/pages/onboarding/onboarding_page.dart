import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/world_class_design_system.dart';
import '../auth/login_page.dart';

/// 🌟 WORLD-CLASS ONBOARDING PAGE
///
/// Features:
/// - 3-step introduction slides
/// - Smooth page transitions
/// - Interactive elements
/// - Skip option
/// - Progress indicator
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentPage = 0;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      icon: Icons.swap_horiz_rounded,
      title: 'Welcome to Barter Queen',
      description:
          'Trade items you no longer need with people nearby. Give your unused items a second life!',
      color: WorldClassDesignSystem.primaryColor,
      features: ['Smart Matching', 'Safe Trading', 'Real-time Chat'],
    ),
    OnboardingSlide(
      icon: Icons.favorite_rounded,
      title: 'Find What You Want',
      description:
          'Browse thousands of items, save your favorites, and chat with owners to make great trades.',
      color: WorldClassDesignSystem.secondaryColor,
      features: ['Advanced Search', 'Smart Filters', 'Location-based'],
    ),
    OnboardingSlide(
      icon: Icons.handshake_rounded,
      title: 'Trade Safely',
      description:
          'Make offers, negotiate, and complete trades with confidence. Build your reputation and join our community.',
      color: WorldClassDesignSystem.accentColor,
      features: ['Secure Payments', 'Rating System', 'Dispute Resolution'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: WorldClassDesignSystem.animationNormal,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: WorldClassDesignSystem.animationNormal,
        ),
      );
    }
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: WorldClassDesignSystem.animationNormal,
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WorldClassDesignSystem.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: const EdgeInsets.all(WorldClassDesignSystem.spacingM),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      'Skip',
                      style: WorldClassDesignSystem.labelMedium.copyWith(
                        color: WorldClassDesignSystem.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                  _animationController.reset();
                  _animationController.forward();
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  return _buildSlide(_slides[index]);
                },
              ),
            ),

            // Progress Indicator
            Padding(
              padding: const EdgeInsets.all(WorldClassDesignSystem.spacingM),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: WorldClassDesignSystem.spacingXS,
                    ),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? WorldClassDesignSystem.primaryColor
                          : WorldClassDesignSystem.borderColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(WorldClassDesignSystem.spacingM),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: WorldClassDesignSystem.animationNormal,
                            curve: Curves.easeInOut,
                          );
                        },
                        style: WorldClassDesignSystem.secondaryButtonStyle,
                        child: const Text('Previous'),
                      ),
                    ),

                  if (_currentPage > 0)
                    const SizedBox(width: WorldClassDesignSystem.spacingM),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: WorldClassDesignSystem.primaryButtonStyle,
                      child: Text(
                        _currentPage == _slides.length - 1
                            ? 'Get Started'
                            : 'Next',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(OnboardingSlide slide) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(WorldClassDesignSystem.spacingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [slide.color, slide.color.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(
                    WorldClassDesignSystem.radiusXXL,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: slide.color.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  slide.icon,
                  size: 60,
                  color: WorldClassDesignSystem.primaryWhite,
                ),
              ),

              const SizedBox(height: WorldClassDesignSystem.spacingXXL),

              // Title
              Text(
                slide.title,
                style: WorldClassDesignSystem.heading1.copyWith(
                  color: WorldClassDesignSystem.primaryText,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: WorldClassDesignSystem.spacingL),

              // Description
              Text(
                slide.description,
                style: WorldClassDesignSystem.bodyLarge.copyWith(
                  color: WorldClassDesignSystem.secondaryText,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: WorldClassDesignSystem.spacingXL),

              // Features
              ...slide.features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: WorldClassDesignSystem.spacingM,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: WorldClassDesignSystem.successColor,
                        size: WorldClassDesignSystem.iconM,
                      ),
                      const SizedBox(width: WorldClassDesignSystem.spacingM),
                      Text(
                        feature,
                        style: WorldClassDesignSystem.bodyMedium.copyWith(
                          color: WorldClassDesignSystem.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingSlide {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final List<String> features;

  const OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.features,
  });
}
