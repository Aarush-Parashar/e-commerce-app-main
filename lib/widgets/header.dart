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

  void _handleSearchTap() {
    if (widget.onSearchTap != null) {
      widget.onSearchTap!();
    } else {
      // Default behavior: navigate to search screen
      Navigator.pushNamed(context, '/search');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;
    final isMobile = screenWidth < 768;

    return AppBar(
      backgroundColor: Colors.green.shade700,
      elevation: 0,
      automaticallyImplyLeading: isMobile && widget.isLoggedIn, // Show hamburger menu only on mobile when logged in
      title: _buildTitle(isDesktop, isTablet, isMobile),
      actions: _buildActions(isDesktop, isTablet, isMobile, context),
      centerTitle: false, // Center title on mobile
    );
  }

  Widget _buildTitle(bool isDesktop, bool isTablet, bool isMobile) {
    // Responsive logo and text sizes
    double logoSize = isDesktop ? 36 : (isTablet ? 32 : 28);
    double fontSize = isDesktop ? 32 : (isTablet ? 28 : 24);
    double spacing = isDesktop ? 12 : (isTablet ? 10 : 8);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Image
        Image.asset(
          'images/logo.png',
          width: logoSize,
          height: logoSize,
          fit: BoxFit.contain,
          // Optional: Add color filter to make logo white if needed
          // color: Colors.white,
          // colorBlendMode: BlendMode.srcIn,
        ),
        SizedBox(width: spacing),
        Flexible(
          child: Text(
            'Tazaj',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
              letterSpacing: isMobile ? 0.8 : 1.2,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
            icon: const Icon(Icons.login, color: Colors.white, size: 20),
            label: const Text(
              'Login',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.green.shade800,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      );
      return actions;
    }

    if (isDesktop) {
      // Desktop: Show all actions in the app bar
      actions.addAll([
        _buildSearchButton(context),
        const SizedBox(width: 8),
        _buildCartButton(),
        const SizedBox(width: 8),
        _buildProfileMenu(context),
        const SizedBox(width: 16),
      ]);
    } else if (isTablet) {
      // Tablet: Show essential actions, group some in menu
      actions.addAll([
        _buildSearchButton(context),
        const SizedBox(width: 4),
        _buildCartButton(),
        const SizedBox(width: 4),
        _buildProfileMenu(context),
        const SizedBox(width: 8),
      ]);
    } else {
      // Mobile: Minimal actions, most in drawer/menu
      actions.addAll([
        _buildCartButton(),
        const SizedBox(width: 4),
        _buildMobileMenu(context),
        const SizedBox(width: 8),
      ]);
    }

    return actions;
  }

  Widget _buildSearchButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.search),
      color: Colors.white,
      onPressed: _handleSearchTap,
      tooltip: 'Search',
    );
  }

  Widget _buildCartButton() {
    // Use real-time count if available, otherwise fallback to passed count
    final displayCount = widget.isLoggedIn ? (_realTimeCartCount > 0 ? _realTimeCartCount : widget.cartItemCount) : 0;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart),
          color: Colors.white,
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

  Widget _buildProfileMenu(BuildContext context) {
    return PopupMenuButton<int>(
      icon: const Icon(Icons.person, color: Colors.white),
      color: Colors.white,
      elevation: 8,
      onSelected: (value) async {
        switch (value) {
          case 0:
            widget.onProfileTap();
            break;
          case 1:
            widget.onSellerTap();
            break;
          case 2:
            widget.onLogout();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<int>(
          value: 0,
          child: ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Profile'),
            dense: true,
          ),
        ),
        PopupMenuItem<int>(
          value: 1,
          child: ListTile(
            leading: Icon(
              widget.currentUser?.userType == UserType.seller
                  ? Icons.dashboard
                  : Icons.store,
            ),
            title: Text(
              widget.currentUser?.userType == UserType.seller
                  ? 'Seller Dashboard'
                  : 'Become a Seller',
            ),
            dense: true,
          ),
        ),
        const PopupMenuItem<int>(
          value: 2,
          child: ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            dense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileMenu(BuildContext context) {
    return PopupMenuButton<int>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      color: Colors.white,
      elevation: 8,
      onSelected: (value) async {
        switch (value) {
          case 0:
            _handleSearchTap();
            break;
          case 1:
            widget.onProfileTap();
            break;
          case 2:
            widget.onSellerTap();
            break;
          case 3:
            widget.onLogout();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<int>(
          value: 0,
          child: ListTile(
            leading: Icon(Icons.search),
            title: Text('Search'),
            dense: true,
          ),
        ),
        const PopupMenuItem<int>(
          value: 1,
          child: ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Profile'),
            dense: true,
          ),
        ),
        PopupMenuItem<int>(
          value: 2,
          child: ListTile(
            leading: Icon(
              widget.currentUser?.userType == UserType.seller
                  ? Icons.dashboard
                  : Icons.store,
            ),
            title: Text(
              widget.currentUser?.userType == UserType.seller
                  ? 'Seller Dashboard'
                  : 'Become a Seller',
            ),
            dense: true,
          ),
        ),
        const PopupMenuItem<int>(
          value: 3,
          child: ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            dense: true,
          ),
        ),
      ],
    );
  }
}