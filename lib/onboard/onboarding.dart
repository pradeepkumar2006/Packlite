import 'package:flutter/material.dart';
import '../auth/login.dart';
import '../core/theme.dart';
import '../core/widgets/packlite_logo.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  late AnimationController _contentCtrl;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _contentFade = CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut);
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic));

    _contentCtrl.forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _contentCtrl.reset();
    _contentCtrl.forward();
  }

  void _nextPage() {
    PackLiteTheme.haptic();
    if (_currentPage < 3) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _navToLogin();
    }
  }

  void _skip() {
    PackLiteTheme.haptic();
    _navToLogin();
  }

  void _navToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim, secondary) => const LoginScreen(),
        transitionsBuilder: (context, anim, secondary, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const PackLiteLogo(size: 20),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'PACKLITE',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                      ),
                    ],
                  ),
                  if (_currentPage < 3)
                    Tappable(
                      onTap: _skip,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: PackLiteTheme.mutedText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                onPageChanged: _onPageChanged,
                children: [
                  _OnboardPage(
                    icon: Icons.luggage_rounded,
                    counterText: '1 of 4',
                    title: 'Welcome to PACKLITE',
                    subtitle: 'Smart packing for every journey',
                    description: 'Never forget an item again. Our smart catalogue helps you build the perfect list based on your trip type.',
                    features: ['Free to use','Works offline'],
                    fade: _contentFade,
                    slide: _contentSlide,
                  ),
                   _OnboardPage(
                    icon: Icons.person_rounded,
                    counterText: '2 of 4',
                    title: 'Solo Trip Packing',
                    subtitle: 'Precision and tracking',
                    description: 'Pick items from categories like Clothing, Electronics, or Documents. Keep track of what\'s in your bag.',
                    features: ['Travel catalogue', 'Custom items', 'Progress tracking'],
                    fade: _contentFade,
                    slide: _contentSlide,
                  ),
                   _OnboardPage(
                    icon: Icons.group_rounded,
                    counterText: '3 of 4',
                    title: 'Group Trip Collaboration',
                    subtitle: 'The ultimate team prep',
                    description: 'Invite friends with a code. Claim items to pack, nudge slackers, and chat in real-time about gear.',
                    features: ['Invite code', 'Claim items', 'Group chat'],
                    fade: _contentFade,
                    slide: _contentSlide,
                  ),
                   _OnboardPage(
                    icon: Icons.check_circle_rounded,
                    counterText: '4 of 4',
                    title: 'You\'re All Set!',
                    subtitle: 'Ready to wander',
                    description: 'Create your first trip and start packing. PackLite is always ready to go whenever you are.',
                    features: ['Solo trips', 'Group trips', 'Always ready'],
                    fade: _contentFade,
                    slide: _contentSlide,
                    isLast: true,
                  ),
                ],
              ),
            ),

            // Bottom Nav
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? Colors.black : PackLiteTheme.mutedText2,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                  ),
                  const SizedBox(height: 32),
                  Tappable(
                    onTap: _nextPage,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentPage == 3 ? 'Get Started' : 'Next',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                            ),
                            if (_currentPage == 3) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.rocket_launch_rounded, color: Colors.white),
                            ]
                          ],
                        ),
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
}

class _OnboardPage extends StatelessWidget {
  final IconData icon;
  final String counterText;
  final String title;
  final String subtitle;
  final String description;
  final List<String> features;
  final Animation<double> fade;
  final Animation<Offset> slide;
  final bool isLast;

  const _OnboardPage({
    required this.icon,
    required this.counterText,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.features,
    required this.fade,
    required this.slide,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(34),
                  ),
                  child: Icon(icon, color: Colors.white, size: 64),
                ),
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: PackLiteTheme.cardBorder,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  counterText,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: PackLiteTheme.mutedText),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 34, height: 1.1),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: PackLiteTheme.mutedText),
              ),
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16, height: 1.5, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: features.map((f) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: PackLiteTheme.cardBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    f,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
