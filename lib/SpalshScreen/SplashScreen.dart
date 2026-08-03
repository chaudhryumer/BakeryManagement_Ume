import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _textVisible = false;

  @override
  void initState() {
    super.initState();

    // Master orchestration timing clock
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Bouncing dynamic scaling curve for the core icon circle base
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    // Smooth opacity reveal for the structural items inside the center container
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    );

    // Fire the background physics timeline immediately on load
    _controller.forward();

    // Stagger the entrance of the textual labels by 600 milliseconds
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _textVisible = true;
        });
      }
    });

    // Auto-navigate forward out of the splash viewport directly into the main app route
    Future.delayed(const Duration(milliseconds: 3200), () {
      Get.offAllNamed('/HomePage');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF111827,
      ), // Deep premium background canvas
      body: Stack(
        children: [
          // Center Core Animated Identity Container
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF16A34A),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF16A34A,
                            ).withValues(alpha: 0.3),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.bakery_dining_rounded,
                          size: 64,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Animated text group block using built-in framework physics hooks
                AnimatedAnimatedOpacityAndSlide(
                  visible: _textVisible,
                  child: const Column(
                    children: [
                      Text(
                        'Smart Bakery',
                        style: TextStyle(
                          fontFamily: 'sans-serif',
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Smart Bakery Management System',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF9CA3AF),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // System Footer Branding
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: Text(
                  'v1.0.0 Stable Build',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.3),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Inline utility widget to handle clean text offsets and transitions smoothly
class AnimatedAnimatedOpacityAndSlide extends StatelessWidget {
  final bool visible;
  final Widget child;

  const AnimatedAnimatedOpacityAndSlide({
    super.key,
    required this.visible,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 600),
      opacity: visible ? 1.0 : 0.0,
      curve: Curves.easeInOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, visible ? 0 : 20, 0),
        child: child,
      ),
    );
  }
}
