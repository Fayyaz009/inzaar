import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:inzaar/features/home/main_nav_screen.dart';
import 'package:inzaar/features/onboarding/onboarding_bloc.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingBloc(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  final PageController _pageController = PageController();

  final List<OnboardingSlide> _slides = const [
    OnboardingSlide(
      title: 'A calmer library',
      description: 'Move through books, magazines, and articles with clearer structure and stronger visual rhythm.',
      icon: Icons.auto_stories_rounded,
    ),
    OnboardingSlide(
      title: 'A richer reading screen',
      description: 'Adjust fonts, change themes, and keep your place without clutter getting in the way.',
      icon: Icons.chrome_reader_mode_rounded,
    ),
    OnboardingSlide(
      title: 'Built for offline focus',
      description: 'Core content stays available from bundled assets so reading continues without interruption.',
      icon: Icons.offline_bolt_rounded,
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainNavScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  void _nextPage() {
    final page = context.read<OnboardingBloc>().state.currentPage;
    if (page < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.brightness == Brightness.light
                ? [const Color(0xFFFDFDFD), const Color(0xFFF5F5F5)]
                : [const Color(0xFF121212), const Color(0xFF0A0A0A)],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<OnboardingBloc, OnboardingState>(
            builder: (context, state) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Row(
                      children: [
                        Text('Inzaar',
                            style: theme.textTheme.headlineMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5)),
                        const Spacer(),
                        TextButton(
                          onPressed: _completeOnboarding,
                          child: Text('Skip',
                              style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (page) => context.read<OnboardingBloc>().add(OnboardingPageChanged(page)),
                      itemCount: _slides.length,
                      itemBuilder: (context, index) {
                        final slide = _slides[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height * 0.25,
                                width: MediaQuery.of(context).size.height * 0.25,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.colorScheme.primary
                                          .withValues(alpha: 0.12),
                                      theme.colorScheme.surface
                                          .withValues(alpha: 0.95)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.12),
                                      blurRadius: 40,
                                      offset: const Offset(0, 20),
                                    ),
                                  ],
                                ),
                                child: Icon(slide.icon,
                                    size:
                                        MediaQuery.of(context).size.height * 0.1,
                                    color: theme.colorScheme.primary),
                              )
                                  .animate(key: ValueKey(index))
                                  .scale(duration: 420.ms, curve: Curves.easeOutBack)
                                  .fadeIn(),
                              const Spacer(),
                              Text(
                                slide.title,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.displaySmall?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1),
                              )
                                  .animate(key: ValueKey('title_$index'))
                                  .slideY(
                                      begin: 0.12, end: 0, duration: 300.ms)
                                  .fadeIn(),
                              Flexible(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Text(
                                    slide.description,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      height: 1.7,
                                    ),
                                  )
                                      .animate(key: ValueKey('desc_$index'))
                                      .slideY(
                                          begin: 0.08,
                                          end: 0,
                                          duration: 320.ms,
                                          delay: 80.ms)
                                      .fadeIn(delay: 80.ms),
                                ),
                              ),
                              const Spacer(flex: 2),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Row(
                      children: [
                        ...List.generate(
                          _slides.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            margin: const EdgeInsets.only(right: 8),
                            height: 6,
                            width: state.currentPage == index ? 24 : 6,
                            decoration: BoxDecoration(
                              color: state.currentPage == index
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.primary
                                      .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const Spacer(),
                         ElevatedButton.icon(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: Icon(
                              state.currentPage == _slides.length - 1
                                  ? Icons.check_rounded
                                  : Icons.arrow_forward_rounded,
                              size: 18),
                          label: Text(
                            state.currentPage == _slides.length - 1
                                ? 'Get Started'
                                : 'Continue',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class OnboardingSlide {
  final String title;
  final String description;
  final IconData icon;

  const OnboardingSlide({required this.title, required this.description, required this.icon});
}
