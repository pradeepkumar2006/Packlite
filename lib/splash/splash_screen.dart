import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../onboard/onboarding.dart';
import '../core/widgets/packlite_logo.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;

  late AnimationController _tagCtrl;
  late Animation<double> _tagFade;
  late Animation<Offset> _tagSlide;

  late AnimationController _barCtrl;
  late Animation<double> _barAnim;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack),
    );
    _logoFade = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut);

    _tagCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _tagFade = CurvedAnimation(parent: _tagCtrl, curve: Curves.easeOut);
    _tagSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _tagCtrl, curve: Curves.easeOutCubic));

    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _barAnim = CurvedAnimation(parent: _barCtrl, curve: Curves.easeInOut);

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _logoCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    _tagCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _barCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    final navigator = Navigator.of(context);
    navigator.pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim, secondary) => const OnboardingScreen(),
        transitionsBuilder: (context, anim, secondary, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _tagCtrl.dispose();
    _barCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _SplashDotPainter(color: Colors.white.withValues(alpha: 0.05))),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _logoScale,
                    child: FadeTransition(
                      opacity: _logoFade,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: const PackLiteLogo(size: 100),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'PACKLITE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeTransition(
                    opacity: _tagFade,
                    child: SlideTransition(
                      position: _tagSlide,
                      child: Text(
                        'Smart Travel Packing',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 80,
              left: 60,
              right: 60,
              child: Column(
                children: [
                  Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: AnimatedBuilder(
                      animation: _barAnim,
                      builder: (context, child) => FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _barAnim.value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'REFINING YOUR JOURNEY',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
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

class _SplashDotPainter extends CustomPainter {
  final Color color;
  _SplashDotPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const gap = 24.0;
    for (double x = 0; x < size.width; x += gap) {
      for (double y = 0; y < size.height; y += gap) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}