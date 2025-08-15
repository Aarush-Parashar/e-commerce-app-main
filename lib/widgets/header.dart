import 'package:flutter/material.dart';
import '/models/user_model.dart';
import '/services/auth_service.dart';
import '/services/cart_service.dart';

class Header extends StatefulWidget implements PreferredSizeWidget {
  final int cartItemCount;
  final UserModel? currentUser;
  final bool isLoggedIn;
  final VoidCallback onCartTap;
  final VoidCallback onProfileTap;
  final VoidCallback onSellerTap;
  final VoidCallback? onSearchTap; // Made optional
  final VoidCallback onLogout;

  const Header({
    Key? key,
    required this.cartItemCount,
    this.currentUser,
    this.isLoggedIn = false,
    required this.onCartTap,
    required this.onProfileTap,
    required this.onSellerTap,
    this.onSearchTap, // Made optional
    required this.onLogout,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  int _realTimeCartCount = 0;
  bool _isLoadingCart = false;

  @override
  void initState() {
    super.initState();
    if (widget.isLoggedIn) {
      _loadRealTimeCartCount();
    }
  }

  @override
  void didUpdateWidget(Header oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update real-time count when widget updates
    if (widget.isLoggedIn && oldWidget.cartItemCount != widget.cartItemCount) {
      _loadRealTimeCartCount();
    }
  }

  Future<void> _loadRealTimeCartCount() async {
    if (_isLoadingCart || !widget.isLoggedIn) return;
    
    setState(() {
      _isLoadingCart = true;
    });

    try {
      final count = await CartService.getCartItemCount();
      if (mounted) {
        setState(() {
          _realTimeCartCount = count;
          _isLoadingCart = false;
        });
      }
    } catch (e) {
      print('Error loading cart count: $e');
      if (mounted) {
        setState(() {
          _realTimeCartCount = widget.cartItemCount; // Fallback to passed count
          _isLoadingCart = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;
    final isMobile = screenWidth < 768;

    return AppBar(
      backgroundColor: Colors.white, // Changed to white background
      elevation: 2, // Added slight elevation for better visibility
      automaticallyImplyLeading: false, // Remove hamburger menu
      title: _buildTitle(isDesktop, isTablet, isMobile),
      actions: _buildActions(isDesktop, isTablet, isMobile, context),
      centerTitle: true, // Center the title
      leading: _buildLeadingLogo(isDesktop, isTablet, isMobile), // Logo on the left
    );
  }

  // New method to build leading logo
  Widget _buildLeadingLogo(bool isDesktop, bool isTablet, bool isMobile) {
    double logoSize = isDesktop ? 32 : (isTablet ? 28 : 24);
    
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Image.asset(
        'images/logo.png',
        width: logoSize,
        height: logoSize,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTitle(bool isDesktop, bool isTablet, bool isMobile) {
    // Smaller responsive font sizes
    double fontSize = isDesktop ? 20 : (isTablet ? 18 : 16);

    return Text(
      'Fruits and Vegetables',
      style: TextStyle(
        color: Colors.green.shade700, // Changed text color to green for contrast
        fontWeight: FontWeight.w600, // Slightly less bold
        fontSize: fontSize, // Smaller font size
        letterSpacing: 0.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  List<Widget> _buildActions(bool isDesktop, bool isTablet, bool isMobile, BuildContext context) {
    List<Widget> actions = [];

    if (!widget.isLoggedIn) {
      // When not logged in, show only login button
      actions.add(
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            icon: Icon(Icons.login, color: Colors.green.shade700, size: 20), // Changed icon color
            label: Text(
              'Login',
              style: TextStyle(
                color: Colors.green.shade700, // Changed text color
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.green.shade50, // Light green background
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.green.shade300), // Added border
              ),
            ),
          ),
        ),
      );
      return actions;
    }

    // Right side - Cart and Profile icons with proper spacing
    actions.addAll([
      const SizedBox(width: 8), // Added space before icons
      _buildCartButton(),
      const SizedBox(width: 12), // Space between cart and profile
      _buildProfileButton(context),
      const SizedBox(width: 16), // Space after profile
    ]);

    return actions;
  }

  Widget _buildCartButton() {
    // Use real-time count if available, otherwise fallback to passed count
    final displayCount = widget.isLoggedIn ? (_realTimeCartCount > 0 ? _realTimeCartCount : widget.cartItemCount) : 0;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart),
          color: Colors.green.shade700, // Changed icon color for contrast
          onPressed: () {
            widget.onCartTap();
            // Refresh cart count when cart is accessed
            if (widget.isLoggedIn) {
              _loadRealTimeCartCount();
            }
          },
          tooltip: 'Cart',
          iconSize: 28,
        ),
        if (displayCount > 0 && widget.isLoggedIn)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1),
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: _isLoadingCart
                  ? SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      displayCount > 99 ? '99+' : '$displayCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.person, color: Colors.green.shade700), // Changed icon color
      onPressed: widget.onProfileTap,
      tooltip: 'Profile',
      iconSize: 28,
    );
  }
}