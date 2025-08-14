import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _showSliderBox = true;
  
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      color: Color(0xFFFAE54A),
      title: 'Welcome to\ntazaj',
      description: 'Buy Fresh. Eat Well',
      subtitle: 'Fruits & Vegetables',
      lottiePath: 'assets/animations/pineapple.json',
      buttonText: 'Direction Location',
      buttonColor: Color(0xFF27C96C),
      locationText: 'Start needs your location?',
    ),
    OnboardingSlide(
      color: Color(0xFF27C96C),
      title: 'LOGIN',
      description: 'Enter your phone number to proceed',
      subtitle: '',
      lottiePath: 'assets/animations/apple.json',
      buttonText: 'Enter phone number',
      buttonColor: Color(0xFFF30201),
      locationText: '',
    ),
    OnboardingSlide(
      color: Color(0xFFF15230),
      title: 'delivery to\nYour Doorstep',
      description: 'Fresh, quality products delivered fast. Easy, reliable, and right to your doorstep.',
      subtitle: '',
      lottiePath: 'assets/animations/delivery.json',
      buttonText: 'Get Started',
      buttonColor: Color(0xFFF15230),
      locationText: '',
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );
    
    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    _slideController.forward();
    
    // Auto-slide every 5 seconds
    Future.delayed(Duration.zero, () {
      _startAutoSlide();
    });
    _showSliderBox = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSliderBoxWithDelay();
    });
  }

  void _showSliderBoxWithDelay() async {
    setState(() {
      _showSliderBox = false;
    });
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() {
        _showSliderBox = true;
      });
      _slideController.reset();
      _slideController.forward();
    }
  }

  void _startAutoSlide() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted) return false;
      int nextPage = (_currentPage + 1) % _slides.length;
      _pageController.animateToPage(
        nextPage,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage = nextPage;
      });
      _showSliderBoxWithDelay();
      return true;
    });
  }

  void _navigateToGuestHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView for slides
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              _showSliderBoxWithDelay();
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              if (index == 0) {
                // First slide with custom layout
                return Container(
                  color: _slides[index].color,
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Top area with big heading
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: EdgeInsets.only(top: 60, bottom: 0, left: 30, right: 30),
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                                position: _slideAnimation,
                                child: Text(
                                  _slides[index].title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    height: 1.1,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        // Pineapple image - reduced scale from 1.15 to 0.85
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: EdgeInsets.only(top: 0, bottom: 0, left: 30, right: 30),
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: Transform.scale(
                                scale: 0.85,
                                child: Lottie.asset(slide.lottiePath, fit: BoxFit.contain),
                              ),
                            ),
                          ),
                        ),
                        
                        // Bottom text area
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(height: 40),
                                FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Text(
                                    _slides[index].description,
                                    style: GoogleFonts.poppins(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                      height: 1.3,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(height: 8),
                                FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Text(
                                    _slides[index].subtitle,
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      color: Colors.grey[700],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (index == 1) {
                // Second slide with login layout
                return Container(
                  color: _slides[index].color,
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Apple image in center - reduced scale from 0.8 to 0.6
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: Transform.scale(
                                scale: 0.6,
                                child: Lottie.asset(slide.lottiePath, fit: BoxFit.contain),
                              ),
                            ),
                          ),
                        ),
                        
                        // Bottom area for white box content
                        Expanded(
                          flex: 2,
                          child: Container(),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (index == 2) {
                // Third slide with delivery layout
                return Container(
                  color: _slides[index].color,
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Delivery image in center - reduced scale from 0.8 to 0.6
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: Transform.scale(
                                scale: 0.6,
                                child: Lottie.asset(slide.lottiePath, fit: BoxFit.contain),
                              ),
                            ),
                          ),
                        ),
                        
                        // Bottom area for white box content
                        Expanded(
                          flex: 2,
                          child: Container(),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                // Other slides with original layout
                return Container(
                  color: _slides[index].color,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Icon(
                            Icons.shopping_cart,
                            size: 100,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 30),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            _slides[index].title,
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              _slides[index].description,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
          
          // Bottom section with white rounded corner layer (fade in after 2s)
          if (_showSliderBox)
            Positioned(
              bottom: 60,
              left: 20,
              right: 20,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_currentPage == 0) ...[
                          // Location text (only for first slide)
                          if (_slides[_currentPage].locationText.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(bottom: 15),
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: Text(
                                  _slides[_currentPage].locationText,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          // Button for first slide
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: 50,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: ElevatedButton(
                                onPressed: _navigateToGuestHome, // Updated navigation
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _slides[_currentPage].buttonColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 5,
                                ),
                                child: Text(
                                  _slides[_currentPage].buttonText,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ] else if (_currentPage == 1) ...[
                          // Login content for second slide
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              _slides[_currentPage].title,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          SizedBox(height: 4),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              _slides[_currentPage].description,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 10),
                          // Phone number text field
                          SlideTransition(
                            position: _slideAnimation,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey[400]!, width: 1),
                                ),
                              ),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: '+973',
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.grey[500],
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                                ),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 25),
                          // Button for second slide - increased height from 40 to 50 and improved text styling
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: 50,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: ElevatedButton(
                                onPressed: _navigateToGuestHome, // Updated navigation
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _slides[_currentPage].buttonColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 5,
                                ),
                                child: Text(
                                  _slides[_currentPage].buttonText,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          // Divider with "or"
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child: Text(
                                    'or',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          // Social login buttons
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: _navigateToGuestHome, // Updated navigation
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    child: Image.asset(
                                      'assets/images/facebook.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20),
                                GestureDetector(
                                  onTap: _navigateToGuestHome, // Updated navigation
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    child: Image.asset(
                                      'assets/images/google.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else if (_currentPage == 2) ...[
                          // Third slide content with location image
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              width: 72,
                              height: 72,
                              child: Image.asset(
                                'assets/images/location.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          // Heading in two lines
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              _slides[_currentPage].title,
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey[700],
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 15),
                          // Subheading in small font
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              _slides[_currentPage].description,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 25),
                          // Button removed for third slide
                        ] else ...[
                          // Default button for other slides
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: 50,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: ElevatedButton(
                                onPressed: _navigateToGuestHome, // Updated navigation
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _slides[_currentPage].buttonColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 5,
                                ),
                                child: Text(
                                  _slides[_currentPage].buttonText,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          
          // Page indicators below the white box
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    width: _currentPage == index ? 25 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _currentPage == index 
                          ? _slides[_currentPage].buttonColor 
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Skip button in top right (at the very top layer)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 15,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 58,
                decoration: BoxDecoration(
                  color: _slides[_currentPage].color,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _currentPage == 0 ? Colors.black : Colors.white,
                    width: 1.5,
                  ),
                ),
                child: TextButton(
                  onPressed: _navigateToGuestHome, // Updated navigation
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    minimumSize: Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Skip',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _currentPage == 0 ? Colors.black : Colors.white,
                    ),
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
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingSlide {
  final Color color;
  final String title;
  final String description;
  final String subtitle;
  final String lottiePath; 
  final String buttonText;
  final Color buttonColor;
  final String locationText;

  OnboardingSlide({
    required this.color,
    required this.title,
    required this.description,
    required this.subtitle,
    required this.lottiePath,
    required this.buttonText,
    required this.buttonColor,
    required this.locationText,
  });
}
