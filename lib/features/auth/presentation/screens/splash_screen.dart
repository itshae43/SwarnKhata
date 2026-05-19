import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swarn_khata/features/navigation/presentation/screens/auth_wrapper.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _loaderOpacity;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Entrance animation controller (1.8 seconds)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // 2. Pulse controller for continuous glowing effect (2 seconds, looping)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // 3. Entrance animations
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    _loaderOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    // 4. Pulse/Glow animation
    _pulseAnimation = Tween<double>(begin: 15.0, end: 35.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Start entrance animations
    _entranceController.forward();

    // Wait and then transition to AuthWrapper
    Timer(const Duration(milliseconds: 3000), _navigateToNext);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _navigateToNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const AuthWrapper(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Color(0xFF1B4027), // Shimmering green in center
                  Color(0xFF0A1F13), // Deep forest black at edges
                ],
              ),
            ),
          ),

          // Custom Background Geometric & Floral Patterns
          Positioned.fill(
            child: CustomPaint(
              painter: SplashPatternPainter(),
            ),
          ),

          // Center Logo and Branding Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                // Animated Logo
                AnimatedBuilder(
                  animation: Listenable.merge([_entranceController, _pulseController]),
                  builder: (context, child) {
                    return Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: const Color(0xFF13331E),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFD4B13B),
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4B13B).withOpacity(0.3),
                                blurRadius: _pulseAnimation.value,
                                spreadRadius: _pulseAnimation.value * 0.2,
                              ),
                              BoxShadow(
                                color: const Color(0xFFD4B13B).withOpacity(0.15),
                                blurRadius: _pulseAnimation.value * 2,
                                spreadRadius: _pulseAnimation.value * 0.4,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 84,
                              height: 84,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.diamond_outlined,
                                color: Color(0xFFD4B13B),
                                size: 68,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 36),

                // Animated Text
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textOpacity,
                    child: Column(
                      children: [
                        Text(
                          'Swastik',
                          style: GoogleFonts.cinzel(
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFD4B13B),
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(0, 3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'JEWELS',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFD4B13B).withOpacity(0.8),
                            letterSpacing: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Loading Spinner at Bottom
                FadeTransition(
                  opacity: _loaderOpacity,
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Color(0xFFD4B13B)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A custom painter to draw premium golden background patterns (like lotus outlines)
class SplashPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4B13B).withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw stylized floral patterns in corners
    _drawLotusPattern(canvas, paint, Offset(0, 0), size.width * 0.45);
    _drawLotusPattern(canvas, paint, Offset(size.width, 0), size.width * 0.45);
    _drawLotusPattern(canvas, paint, Offset(0, size.height), size.width * 0.45);
    _drawLotusPattern(canvas, paint, Offset(size.width, size.height), size.width * 0.45);
  }

  void _drawLotusPattern(Canvas canvas, Paint paint, Offset center, double radius) {
    // Draw concentric circles
    canvas.drawCircle(center, radius * 0.15, paint);
    canvas.drawCircle(center, radius * 0.4, paint);
    canvas.drawCircle(center, radius * 0.7, paint);

    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (i * pi / 4);
      final x1 = center.dx + radius * 0.15 * cos(angle);
      final y1 = center.dy + radius * 0.15 * sin(angle);
      final x2 = center.dx + radius * cos(angle);
      final y2 = center.dy + radius * sin(angle);
      
      // Control point for curvy petal
      final cx = center.dx + radius * 0.55 * cos(angle + 0.22);
      final cy = center.dy + radius * 0.55 * sin(angle + 0.22);
      
      path.moveTo(x1, y1);
      path.quadraticBezierTo(cx, cy, x2, y2);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
