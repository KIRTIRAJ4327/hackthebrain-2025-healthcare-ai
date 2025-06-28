import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';

/// Splash Screen for Healthcare AI App
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _loadingMessage = 'Initializing Healthcare Services...';

  @override
  void initState() {
    super.initState();

    // Initialize animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start animation
    _animationController.forward();

    _initializeApp();
    _startLoadingMessages();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Show splash screen for at least 4 seconds for better branding experience
    await Future.delayed(const Duration(seconds: 4));

    if (!mounted) return;

    // Check authentication state
    final authState = ref.read(authStateProvider);

    if (authState is AuthAuthenticated) {
      context.go('/home');
    } else if (authState is AuthUnauthenticated) {
      context.go('/auth/login');
    } else {
      // Still loading, wait a bit more
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        final newAuthState = ref.read(authStateProvider);
        if (newAuthState is AuthAuthenticated) {
          context.go('/home');
        } else {
          context.go('/auth/login');
        }
      }
    }
  }

  /// 🔄 Progressive loading messages for better UX
  void _startLoadingMessages() {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _loadingMessage = 'Connecting to AI Medical Services...';
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _loadingMessage = 'Loading GTA Healthcare Network...';
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        setState(() {
          _loadingMessage = 'Optimizing Wait Time Algorithms...';
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        setState(() {
          _loadingMessage = 'Ready to Reduce Wait Times!';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes during splash
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      // Don't navigate immediately, let the timer handle it for proper branding display
    });

    return Scaffold(
      backgroundColor: const Color(0xFF2563EB), // Beautiful blue background
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Icon with glowing effect
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.medical_services,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // App Title with fade-in effect
                  const Text(
                    'Healthcare AI',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Inter',
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  const Text(
                    'Reducing Wait Times',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontFamily: 'Inter',
                      letterSpacing: 0.2,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Animated Loading Indicator
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3.0,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // HackTheBrain Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      '🚀 Built for HackTheBrain 2025',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Loading status
                  Text(
                    _loadingMessage,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white60,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
