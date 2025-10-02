import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../auth/login_page.dart';

/// Onboarding page with 3 slides introducing the app
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = const [
    OnboardingSlide(
      icon: Icons.swap_horiz_rounded,
      title: 'Welcome to Barter Queen',
      description:
          'Trade items you no longer need with people nearby. Give your unused items a second life!',
      color: AppColors.primary,
    ),
    OnboardingSlide(
      icon: Icons.favorite_rounded,
      title: 'Find What You Want',
      description:
          'Browse thousands of items, save your favorites, and chat with owners to make great trades.',
      color: AppColors.secondary,
    ),
    OnboardingSlide(
      icon: Icons.handshake_rounded,
      title: 'Trade Safely',
      description:
          'Make offers, negotiate, and complete trades with confidence. Build your reputation and join our community.',
      color: AppColors.accent,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    'Skip',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _OnboardingSlideWidget(
                    slide: _slides[index],
                    isActive: _currentPage == index,
                  );
                },
              ),
            ),

            // Page indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 32 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? _slides[index].color
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _slides[_currentPage].color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentPage == _slides.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _currentPage == _slides.length - 1
                            ? Icons.check_circle_outline
                            : Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying a single onboarding slide
class _OnboardingSlideWidget extends StatelessWidget {
  final OnboardingSlide slide;
  final bool isActive;

  const _OnboardingSlideWidget({
    required this.slide,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isActive ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: isActive ? 1.0 : 0.8),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: slide.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      slide.icon,
                      size: 80,
                      color: slide.color,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 48),

            // Title
            Text(
              slide.title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              slide.description,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Model for onboarding slide data
class OnboardingSlide {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
