import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
<<<<<<< HEAD
import 'dart:math';

// Assuming you have an AppRoutes utility for navigation
import '../utils/app_routes.dart';

// Define a simple data model for each splash slide
class SplashSlide {
  final Color color;
  final String title;
  final String description;
  final IconData icon; // Using icons instead of Lottie

  SplashSlide({
    required this.color,
    required this.title,
    required this.description,
    required this.icon,
  });
}

// Particle class for background animation
class Particle {
  double x, y;
  double vx, vy;
  double size;
  Color color;
  double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.opacity,
  });
}
=======
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';
import '../services/auth_service.dart';
>>>>>>> be825a70c5afb5e83a7c90247b4e5c684e899249

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
<<<<<<< HEAD
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _showBottomBox = false;
  bool _isNavigating = false;

  // Animation controllers
  late AnimationController _logoAnimationController;
  late AnimationController _particleAnimationController;
  late AnimationController _slideAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _bounceAnimationController;
  late AnimationController _glowAnimationController;

  // Animations
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _glowAnimation;

  // Particle system
  List<Particle> particles = [];

  // Define your splash screens data
  final List<SplashSlide> _slides = [
    SplashSlide(
      color: const Color(0xFFFAE54A), // Yellow
      title: 'Welcome to\nTazaj',
      description: 'Buy Fresh. Eat Well',
      icon: Icons.shopping_cart_rounded,
    ),
    SplashSlide(
      color: const Color(0xFF27C96C), // Green
      title: 'Fast Delivery',
      description: 'Fresh products delivered fast.',
      icon: Icons.local_shipping_rounded,
    ),
    SplashSlide(
      color: const Color(0xFFF15230), // Orange
      title: 'Easy & Reliable',
      description: 'Your daily essentials',
      icon: Icons.touch_app_rounded,
    ),
  ];
=======
  late AnimationController _logoController;
  late AnimationController _dotsController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
>>>>>>> be825a70c5afb5e83a7c90247b4e5c684e899249

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _initAnimations();
    _initParticles();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showBottomBoxWithDelay();
      _startAutoSlide();
    });
  }

  void _initAnimations() {
    // Logo animations
    _logoAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    _logoRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.easeInOut,
    ));

    // Particle animation
    _particleAnimationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    // Slide transition animation
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutBack,
    ));

    // Pulse animation for button
    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));

    // Bounce animation for icons
    _bounceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 15.0,
    ).animate(CurvedAnimation(
      parent: _bounceAnimationController,
      curve: Curves.easeInOut,
    ));

    // Glow animation
    _glowAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _glowAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _logoAnimationController.forward();
    _slideAnimationController.forward();
  }

  void _initParticles() {
    final random = Random();
    particles = List.generate(25, (index) {
      return Particle(
        x: random.nextDouble() * 400,
        y: random.nextDouble() * 800,
        vx: (random.nextDouble() - 0.5) * 3,
        vy: (random.nextDouble() - 0.5) * 3,
        size: random.nextDouble() * 5 + 2,
        color: _slides[_currentPage].color.withOpacity(0.4),
        opacity: random.nextDouble() * 0.6 + 0.3,
      );
    });
  }

  void _showBottomBoxWithDelay() async {
    setState(() {
      _showBottomBox = false;
    });
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() {
        _showBottomBox = true;
      });
    }
  }

  void _startAutoSlide() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted || _isNavigating) return false;

      if (_currentPage < _slides.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        );
        return true;
      } else {
        _navigateToLogin();
        return false;
      }
    });
  }

  void _navigateToLogin() {
    if (!_isNavigating && mounted) {
      setState(() {
        _isNavigating = true;
      });
=======
    _initializeAnimations();
    _navigateToNext();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _rotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );

    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _logoController.forward();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;

    final bool isLoggedIn = await AuthService.isLoggedIn();
    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
>>>>>>> be825a70c5afb5e83a7c90247b4e5c684e899249
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

<<<<<<< HEAD
  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    
    // Reset and restart logo animation for new page
    _logoAnimationController.reset();
    _logoAnimationController.forward();
    
    // Update particle colors
    _updateParticleColors();
    _showBottomBoxWithDelay();
  }

  void _updateParticleColors() {
    final random = Random();
    for (var particle in particles) {
      particle.color = _slides[_currentPage].color.withOpacity(random.nextDouble() * 0.5 + 0.2);
    }
=======
  @override
  void dispose() {
    _logoController.dispose();
    _dotsController.dispose();
    super.dispose();
>>>>>>> be825a70c5afb5e83a7c90247b4e5c684e899249
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      body: Stack(
        children: [
          // Animated background with particles
          AnimatedBuilder(
            animation: _particleAnimationController,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(particles),
                size: MediaQuery.of(context).size,
              );
            },
          ),

          // PageView for splash slides
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      slide.color,
                      slide.color.withOpacity(0.8),
                      slide.color.withOpacity(0.6),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Logo and icon section with enhanced animations
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Your logo image with glow effect
                              AnimatedBuilder(
                                animation: Listenable.merge([_logoAnimationController, _glowAnimationController]),
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _logoScaleAnimation.value,
                                    child: Transform.rotate(
                                      angle: _logoRotationAnimation.value * 0.1,
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white.withOpacity(_glowAnimation.value * 0.5),
                                              blurRadius: 30,
                                              spreadRadius: 5,
                                            ),
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              blurRadius: 20,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: Image.asset(
                                            'assets/logo.png',
                                            fit: BoxFit.contain,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Icon(
                                                  slide.icon,
                                                  size: 60,
                                                  color: slide.color,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 30),
                              
                              // Floating icon animation with bounce
                              AnimatedBuilder(
                                animation: Listenable.merge([_slideAnimationController, _bounceAnimationController]),
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      sin(_particleAnimationController.value * 2 * pi) * 8,
                                      -_bounceAnimation.value + sin(_particleAnimationController.value * 2 * pi) * 5,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.25),
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.4),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.3),
                                            blurRadius: 15,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        slide.icon,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Text content section with slide animation
                      Expanded(
                        flex: 2,
                        child: AnimatedBuilder(
                          animation: _slideAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, (1 - _slideAnimation.value) * 50),
                              child: Opacity(
                                opacity: _slideAnimation.value,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 30),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 40),
                                      Text(
                                        slide.title,
                                        style: GoogleFonts.poppins(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          height: 1.1,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(0.3),
                                              offset: const Offset(0, 2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        slide.description,
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          color: Colors.white.withOpacity(0.9),
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(0.2),
                                              offset: const Offset(0, 1),
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
=======
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _logoController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Image.asset(
                              'assets/images/App-logo.jpg',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // App Name
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            'Tazaj',
                            style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Tagline
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            'Fresh groceries at your doorstep',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Loading Dots Animation
                        AnimatedBuilder(
                          animation: _dotsController,
                          builder: (_, __) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Transform.translate(
                                    offset: Offset(
                                      0,
                                      _dotsController.value *
                                          (index == 1 ? -5 : 0),
                                    ),
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      ],
                    ),
>>>>>>> be825a70c5afb5e83a7c90247b4e5c684e899249
                  ),
                ),
              );
            },
          ),
<<<<<<< HEAD

          // Compact bottom section with enhanced animations
          if (_showBottomBox)
            Positioned(
              bottom: 100,
              left: 30,
              right: 30,
              child: AnimatedSlide(
                offset: _showBottomBox ? Offset.zero : const Offset(0, 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.elasticOut,
                child: AnimatedOpacity(
                  opacity: _showBottomBox ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                          spreadRadius: -3,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _currentPage == _slides.length - 1 ? _pulseAnimation.value : 1.0,
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_currentPage < _slides.length - 1) {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 600),
                                    curve: Curves.easeOutCubic,
                                  );
                                } else {
                                  _navigateToLogin();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _slides[_currentPage].color,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 8,
                                shadowColor: _slides[_currentPage].color.withOpacity(0.5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _currentPage == _slides.length - 1 ? 'Get Started' : 'Continue',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Icon(
                                      _currentPage == _slides.length - 1 
                                          ? Icons.rocket_launch_rounded 
                                          : Icons.arrow_forward_rounded,
                                      key: ValueKey(_currentPage),
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

          // Enhanced page indicators with smoother animation
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: _currentPage == index ? 40 : 12,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: _currentPage == index
                        ? [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.6),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
          ),

          // Skip button for better UX
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: AnimatedOpacity(
              opacity: _currentPage < _slides.length - 1 ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: TextButton(
                onPressed: _currentPage < _slides.length - 1 ? _navigateToLogin : null,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white.withOpacity(0.8),
                  backgroundColor: Colors.white.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Skip',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _particleAnimationController.dispose();
    _slideAnimationController.dispose();
    _pulseAnimationController.dispose();
    _bounceAnimationController.dispose();
    _glowAnimationController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}

// Enhanced particle painter with more dynamic effects
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    for (var particle in particles) {
      // Update particle position with slight randomness
      particle.x += particle.vx + (Random().nextDouble() - 0.5) * 0.2;
      particle.y += particle.vy + (Random().nextDouble() - 0.5) * 0.2;
      
      // Wrap around screen
      if (particle.x < -particle.size) particle.x = size.width + particle.size;
      if (particle.x > size.width + particle.size) particle.x = -particle.size;
      if (particle.y < -particle.size) particle.y = size.height + particle.size;
      if (particle.y > size.height + particle.size) particle.y = -particle.size;
      
      // Add subtle pulsing effect
      final pulseFactor = sin(DateTime.now().millisecondsSinceEpoch / 1000.0 + particle.x / 100) * 0.3 + 1.0;
      
      paint.color = particle.color.withOpacity(particle.opacity * pulseFactor.clamp(0.5, 1.0));
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size * pulseFactor.clamp(0.8, 1.2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
=======
        ),
      ),
    );
  }
}
>>>>>>> be825a70c5afb5e83a7c90247b4e5c684e899249
