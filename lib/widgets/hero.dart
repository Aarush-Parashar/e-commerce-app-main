import 'package:flutter/material.dart';
import 'dart:async';

class HeroSection extends StatefulWidget {
  const HeroSection({Key? key}) : super(key: key);

  @override
  _HeroSectionState createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  late PageController _pageController;
  late Timer _timer;
  int _currentPage = 0;
  final int _totalPages = 3; // Changed to 3 for the 3 images

  // List of your asset images
  final List<String> _images = [
    'assets/images/slider.png', // Replace with your actual image names
    'assets/images/slider.png',
    'assets/images/slider.png',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % _totalPages;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Image Slider with Auto-scroll
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: PageView.builder(
                controller: _pageController,
                itemCount: null, // Infinite scroll
                itemBuilder: (context, index) {
                  final imageIndex = index % _totalPages;
                  return _buildImageSlide(imageIndex);
                },
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index % _totalPages;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalPages, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 12 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? Colors.green.shade700
                      : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSlide(int index) {
    return Container(
      width: double.infinity,
      child: Image.asset(
        _images[index],
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback widget if image fails to load
          return Container(
            color: Colors.grey.shade200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  size: 50,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(height: 8),
                Text(
                  'Image ${index + 1}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
