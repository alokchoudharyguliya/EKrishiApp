import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _bubbleController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  final List<Bubble> _bubbles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateBubbles();
    _initializeApp();
  }

  void _initializeAnimations() {
    // Logo animation controller
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Text animation controller
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Bubble animation controller (continuous)
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Logo animations
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    // Text animations
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    // Start animations
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _textController.forward();
    });
  }

  void _generateBubbles() {
    for (int i = 0; i < 12; i++) {
      _bubbles.add(
        Bubble(
          x: _random.nextDouble(),
          y: 1.0 + (_random.nextDouble() * 0.5),
          size: 20.0 + (_random.nextDouble() * 40.0),
          speed: 0.3 + (_random.nextDouble() * 0.4),
          delay: _random.nextDouble() * 2.0,
        ),
      );
    }
  }

  Future<void> _initializeApp() async {
    // Check authentication status first
    try {
      await Provider.of<AuthService>(context, listen: false).checkAuthStatus();
    } catch (e) {
      debugPrint('Error checking auth status: $e');
    }

    // Wait for splash screen display (minimum 2 seconds)
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Navigate to Wrapper which handles authentication routing
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Wrapper()),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_screen.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Gradient overlay for better text readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.4),
                  ],
                ),
              ),
            ),
          ),

          // Animated bubbles
          AnimatedBuilder(
            animation: _bubbleController,
            builder: (context, child) {
              return CustomPaint(
                painter: BubblePainter(
                  bubbles: _bubbles,
                  animationValue: _bubbleController.value,
                ),
                size: size,
              );
            },
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated logo
                FadeTransition(
                  opacity: _logoFadeAnimation,
                  child: ScaleTransition(
                    scale: _logoScaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.agriculture,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Animated app name
                SlideTransition(
                  position: _textSlideAnimation,
                  child: FadeTransition(
                    opacity: _textFadeAnimation,
                    child: Text(
                      'EKrishi',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 42,
                        shadows: [
                          Shadow(
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                FadeTransition(
                  opacity: _textFadeAnimation,
                  child: Text(
                    'Your Farming Companion',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      shadows: [
                        Shadow(
                          offset: const Offset(1, 1),
                          blurRadius: 3,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Custom loading indicator
                FadeTransition(
                  opacity: _textFadeAnimation,
                  child: Container(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
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

// Bubble model class
class Bubble {
  final double x;
  double y;
  final double size;
  final double speed;
  final double delay;
  double opacity;

  Bubble({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.delay,
    this.opacity = 0.6,
  });
}

// Custom painter for bubbles
class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  final double animationValue;

  BubblePainter({required this.bubbles, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.fill
          ..strokeWidth = 2;

    for (var bubble in bubbles) {
      // Calculate bubble position based on animation
      final currentTime = (animationValue * 3.0) + bubble.delay;
      final bubbleY = (bubble.y - (currentTime * bubble.speed)) % 1.5;

      // Skip if bubble is off screen
      if (bubbleY < -0.1 || bubbleY > 1.1) continue;

      // Calculate opacity (fade in/out)
      double opacity;
      if (bubbleY < 0.2) {
        opacity = (bubbleY / 0.2) * bubble.opacity;
      } else if (bubbleY > 0.8) {
        opacity = ((1.0 - bubbleY) / 0.2) * bubble.opacity;
      } else {
        opacity = bubble.opacity;
      }

      // Draw bubble
      final x = bubble.x * size.width;
      final y = bubbleY * size.height;

      paint.color = Colors.white.withOpacity(opacity * 0.4);
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), bubble.size / 2, paint);

      // Draw bubble highlight
      paint.color = Colors.white.withOpacity(opacity * 0.6);
      canvas.drawCircle(
        Offset(x - bubble.size * 0.15, y - bubble.size * 0.15),
        bubble.size * 0.3,
        paint,
      );

      // Draw bubble border
      paint.color = Colors.white.withOpacity(opacity * 0.5);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 1.5;
      canvas.drawCircle(Offset(x, y), bubble.size / 2, paint);
    }
  }

  @override
  bool shouldRepaint(BubblePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
