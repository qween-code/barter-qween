import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/di/injection.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/preferences_keys.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      icon: Icons.swap_horiz_rounded,
      title: 'Trade with Ease',
      description: 'Exchange items you no longer need for things you want',
    ),
    OnboardingData(
      icon: Icons.security,
      title: 'Safe & Secure',
      description: 'All transactions are protected with our escrow system',
    ),
    OnboardingData(
      icon: Icons.people,
      title: 'Join Community',
      description: 'Connect with thousands of traders in your area',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(page.icon, size: 120, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 48),
                        Text(page.title, style: Theme.of(context).textTheme.headlineLarge, textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        Text(page.description, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index ? Theme.of(context).colorScheme.primary : Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        )),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _currentPage == _pages.length - 1 ? _completeOnboarding : () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48)),
                    child: Text(_currentPage == _pages.length - 1 ? 'Get Started' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    final prefs = getIt<SharedPreferences>();
    await prefs.setBool(PreferencesKeys.onboardingCompleted, true);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(RouteNames.dashboard);
    }
  }
}

class OnboardingData {
  final IconData icon;
  final String title;
  final String description;

  OnboardingData({required this.icon, required this.title, required this.description});
}
