import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/admin_service.dart';
import 'order_invoice_generator.dart';

// A constant for defining the breakpoint between mobile and tablet/desktop layouts.
const double kTabletBreakpoint = 768.0;

// ----------- MODELS -----------

class SellerRequest {
  final String id;
  final String userName;
  final String userEmail;
  final String storeName;
  final String storeAddress;
  final String? businessLicense;
  final String status;
  final DateTime requestedAt;

  SellerRequest({
    required this.id,
    required this.userName,
    required this.userEmail,
    required this.storeName,
    required this.storeAddress,
    this.businessLicense,
    required this.status,
    required this.requestedAt,
  });

  factory SellerRequest.fromJson(Map<String, dynamic> json) {
    return SellerRequest(
      id: json['_id'] ?? '',
      userName: json['userName'] ?? json['userId']?['name'] ?? 'N/A',
      userEmail: json['userEmail'] ?? json['userId']?['email'] ?? 'N/A',
      storeName: json['storeName'] ?? 'N/A',
      storeAddress: json['storeAddress'] ?? 'N/A',
      businessLicense: json['businessLicense'],
      status: json['status'] ?? 'pending',
      requestedAt:
          DateTime.tryParse(json['requestedAt'] ?? json['createdAt'] ?? '') ??
              DateTime.now(),
    );
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool isActive;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'N/A',
      email: json['email'] ?? 'N/A',
      phone: json['phone'] ?? 'N/A',
      role: json['role'] ?? 'user',
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class Seller {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String storeName;
  final String storeAddress;
  final bool isActive;
  final DateTime createdAt;

  Seller({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.storeName,
    required this.storeAddress,
    required this.isActive,
    required this.createdAt,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['_id'] ?? '',
      name: json['name'] ?? json['userId']?['name'] ?? 'N/A',
      email: json['email'] ?? json['userId']?['email'] ?? 'N/A',
      phone: json['phone'] ?? json['userId']?['phone'] ?? 'N/A',
      storeName: json['storeName'] ?? 'N/A',
      storeAddress: json['storeAddress'] ?? 'N/A',
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String? imageUrl;
  final bool isAvailable;
  final String sellerId;
  final String? sellerName;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.imageUrl,
    required this.isAvailable,
    required this.sellerId,
    this.sellerName,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Safely access nested properties
    final sellerInfo = json['seller'] as Map<String, dynamic>?;
    final images = json['images'] as List<dynamic>?;

    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unnamed Product',
      description: json['description'] ?? 'No description available.',
      price: (json['price'] ?? 0.0).toDouble(),
      category: json['category'] ?? 'Uncategorized',
      imageUrl: json['imageUrl'] ??
          (images != null && images.isNotEmpty ? images[0] : null),
      isAvailable: json['isAvailable'] ?? true,
      sellerId: json['sellerId'] ?? sellerInfo?['_id'] ?? 'N/A',
      sellerName: sellerInfo?['storeName'] ?? json['sellerName'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    bool? isAvailable,
    String? sellerId,
    String? sellerName,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class OrderItem {
  final String productId;
  final int quantity;
  final double price;

  OrderItem(
      {required this.productId, required this.quantity, required this.price});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0.0).toDouble(),
    );
  }
}

class UserDetails {
  final String id;
  final String name;
  final String email;
  final String phone;
  final bool isActive;
  final int totalOrders;
  final double totalSpent;

  UserDetails({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.isActive,
    required this.totalOrders,
    required this.totalSpent,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    return UserDetails(
      id: user['_id'] ?? '',
      name: user['name'] ?? 'N/A',
      email: user['email'] ?? 'N/A',
      phone: user['phone'] ?? 'N/A',
      isActive: user['isActive'] ?? false,
      totalOrders: json['totalOrders'] ?? 0,
      totalSpent: (json['totalSpent'] ?? 0.0).toDouble(),
    );
  }
}

// ----------- MAIN DASHBOARD WIDGET -----------

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // API BASE URL
  static const String _baseUrl =
      "https://backend-ecommerce-app-co1r.onrender.com/api";

  // Dashboard stats
  int _totalUsers = 0;
  int _totalSellers = 0;
  int _totalProducts = 0;
  int _availableProducts = 0;
  int _hiddenProducts = 0;

  // Data Lists
  List<SellerRequest> _pendingRequests = [];
  List<User> _users = [];
  List<Seller> _sellers = [];
  List<Product> _products = [];
  List<Orders> _orders = [];
  List<Order> _order = [];
  // Filtered Lists
  List<Product> _filteredProducts = [];
  List<Order> _filteredOrders = [];

  // Search & Filter State
  String _userSearchQuery = '';
  String _sellerSearchQuery = '';
  String _productSearchQuery = '';
  String _productFilter = 'all';
  String _orderSearchQuery = '';
  String _orderFilter = 'all';

  // Product Management Form
  final _productFormKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _productDescriptionController = TextEditingController();
  final _productPriceController = TextEditingController();
  final _productQuantityController = TextEditingController();
  final _productImageUrlController = TextEditingController();
  String _selectedProductCategory = 'Fruits';
  String _selectedProductUnit = 'kg';
  bool _isEditProductMode = false;
  String? _editingProductId;

  // UI State
  bool _isLoading = true;
  int _tabIndex = 0;
  bool _isSidebarExpanded = true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _userSearchController = TextEditingController();
  final TextEditingController _sellerSearchController = TextEditingController();
  final TextEditingController _productSearchController =
      TextEditingController();
  final TextEditingController _orderSearchController = TextEditingController();

  // --- INIT & LIFECYCLE METHODS ---
  @override
  void initState() {
    super.initState();
    _loadAllData();
    _userSearchController.addListener(() => setState(() => _fetchUsers()));
    _sellerSearchController.addListener(() => setState(() => _fetchSellers()));
    _productSearchController
        .addListener(() => setState(() => _filterProducts()));
    _orderSearchController.addListener(() => setState(() => _filterOrders()));
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _productDescriptionController.dispose();
    _productPriceController.dispose();
    _productQuantityController.dispose();
    _productImageUrlController.dispose();
    _userSearchController.dispose();
    _sellerSearchController.dispose();
    _productSearchController.dispose();
    _orderSearchController.dispose();
    super.dispose();
  }

  // --- DATA FETCHING AND MANAGEMENT ---

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchProducts(),
      _fetchSellerRequests(),
      _fetchUsers(),
      _fetchSellers(),
      _fetchOrders(),
    ]);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _calculateStats() {
    if (!mounted) return;
    setState(() {
      _totalProducts = _products.length;
      _availableProducts = _products.where((p) => p.isAvailable).length;
      _hiddenProducts = _products.where((p) => !p.isAvailable).length;
      _totalUsers = _users.length;
      _totalSellers = _sellers.length;
    });
  }

  // Generic helper for API calls
  Future<dynamic> _apiCall(String endpoint,
      {String method = 'GET', Map<String, dynamic>? body}) async {
    final token = await _getToken();
    if (token == null) throw Exception('Authentication token not found.');

    final uri = Uri.parse('$_baseUrl/$endpoint');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    http.Response res;
    try {
      switch (method.toUpperCase()) {
        case 'POST':
          res = await http.post(uri, headers: headers, body: jsonEncode(body));
          break;
        case 'PUT':
          res = await http.put(uri, headers: headers, body: jsonEncode(body));
          break;
        case 'PATCH':
          res = await http.patch(uri, headers: headers, body: jsonEncode(body));
          break;
        case 'DELETE':
          res = await http.delete(uri, headers: headers);
          break;
        default: // GET
          res = await http.get(uri, headers: headers);
      }

      final responseBody = jsonDecode(res.body);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return responseBody;
      } else {
        throw Exception(
            responseBody['message'] ?? 'API Error: ${res.statusCode}');
      }
    } catch (e) {
      print('API call failed for $endpoint: $e');
      _showErrorSnackBar(e.toString());
      rethrow;
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    });
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _fetchSellerRequests() async {
    try {
      final data =
          await _apiCall('admin/seller-requests?status=pending&limit=100');
      if (mounted) {
        setState(() {
          _pendingRequests = (data['requests'] as List)
              .map((e) => SellerRequest.fromJson(e))
              .toList();
        });
      }
    } catch (e) {/* Error handled in _apiCall */}
  }

  Future<void> _fetchUsers() async {
    try {
      _userSearchQuery = _userSearchController.text;
      final data = await _apiCall(
          'admin/users?limit=100&search=${Uri.encodeComponent(_userSearchQuery)}');
      if (mounted) {
        setState(() {
          _users =
              (data['users'] as List).map((e) => User.fromJson(e)).toList();
        });
        _calculateStats();
      }
    } catch (e) {/* Error handled in _apiCall */}
  }

  Future<void> _fetchSellers() async {
    try {
      _sellerSearchQuery = _sellerSearchController.text;
      final data = await _apiCall(
          'admin/sellers?limit=100&search=${Uri.encodeComponent(_sellerSearchQuery)}');
      if (mounted) {
        setState(() {
          _sellers =
              (data['sellers'] as List).map((e) => Seller.fromJson(e)).toList();
        });
        _calculateStats();
      }
    } catch (e) {/* Error handled in _apiCall */}
  }

  Future<void> _fetchProducts() async {
    try {
      final data = await _apiCall('items?limit=1000');
      if (mounted) {
        List<dynamic> itemsList =
            data['items'] ?? data['products'] ?? data['data'] ?? [];
        setState(() {
          _products = itemsList.map((e) => Product.fromJson(e)).toList();
          _filterProducts();
        });
        _calculateStats();
      }
    } catch (e) {/* Error handled in _apiCall */}
  }

  void _filterProducts() {
    if (!mounted) return;
    setState(() {
      _filteredProducts = _products.where((product) {
        final query = _productSearchController.text.toLowerCase();
        bool matchesSearch = query.isEmpty ||
            product.name.toLowerCase().contains(query) ||
            product.category.toLowerCase().contains(query) ||
            (product.sellerName?.toLowerCase().contains(query) ?? false);

        bool matchesFilter = _productFilter == 'all' ||
            (_productFilter == 'available' && product.isAvailable) ||
            (_productFilter == 'hidden' && !product.isAvailable);

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  Future<void> _fetchOrders() async {
    try {
      // Using the placeholder AdminService. You should replace this with a direct _apiCall.
      final orders = await AdminService.getAllOrders();
      if (mounted) {
        setState(() {
          _order = orders;
          _filterOrders();
        });
      }
    } catch (e) {
      _showErrorSnackBar("Failed to fetch orders: $e");
    }
  }

  void _filterOrders() {
    if (!mounted) return;
    setState(() {
      _filteredOrders = _order.where((order) {
        final query = _orderSearchController.text.toLowerCase();
        bool matchesSearch = query.isEmpty ||
            order.userName.toLowerCase().contains(query) ||
            order.userEmail.toLowerCase().contains(query) ||
            order.id.toLowerCase().contains(query);

        bool matchesFilter =
            _orderFilter == 'all' || order.status == _orderFilter;

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  Future<void> _approveSellerRequest(String requestId) async {
    try {
      await _apiCall('admin/seller-requests/$requestId/approve',
          method: 'POST');
      _showSuccessSnackBar('Seller request approved');
      _loadAllData();
    } catch (e) {/* Error handled */}
  }

  Future<void> _rejectSellerRequest(String requestId, String reason) async {
    try {
      await _apiCall('admin/seller-requests/$requestId/reject',
          method: 'POST', body: {'reason': reason});
      _showSuccessSnackBar('Seller request rejected');
      _loadAllData();
    } catch (e) {/* Error handled */}
  }

  Future<void> _toggleUserStatus(String userId, bool isActive) async {
    try {
      await _apiCall('admin/users/$userId/status',
          method: 'PATCH', body: {'isActive': isActive});
      _showSuccessSnackBar('User status updated');
      _fetchUsers();
    } catch (e) {/* Error handled */}
  }

  Future<void> _toggleSellerStatus(String sellerId, bool isActive) async {
    try {
      await _apiCall('admin/sellers/$sellerId/status',
          method: 'PATCH', body: {'isActive': isActive});
      _showSuccessSnackBar('Seller status updated');
      _fetchSellers();
    } catch (e) {/* Error handled */}
  }

  Future<void> _toggleProductAvailability(
      String productId, bool isAvailable) async {
    try {
      await _apiCall('admin/items/$productId/status',
          method: 'PATCH', body: {'isAvailable': isAvailable});
      _showSuccessSnackBar('Product status updated');
      _fetchProducts(); // Refresh the whole list
    } catch (e) {/* Error handled */}
  }

  Future<void> _submitProduct() async {
    if (!_productFormKey.currentState!.validate()) return;

    final productData = {
      'name': _productNameController.text,
      'description': _productDescriptionController.text,
      'price': double.parse(_productPriceController.text),
      'category': _selectedProductCategory,
      'imageUrl': _productImageUrlController.text.isNotEmpty
          ? _productImageUrlController.text
          : null,
      'quantity': int.parse(_productQuantityController
          .text), // Assuming quantity is part of your model
      'unit': _selectedProductUnit,
    };

    try {
      if (_isEditProductMode) {
        await _apiCall('items/$_editingProductId',
            method: 'PUT', body: productData);
        _showSuccessSnackBar('Product updated successfully!');
      } else {
        await _apiCall('items', method: 'POST', body: productData);
        _showSuccessSnackBar('Product added successfully!');
      }
      _clearProductForm();
      await _fetchProducts();
      setState(() => _tabIndex = 4); // Switch to products tab
    } catch (e) {/* Error handled */}
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await _apiCall('items/$productId', method: 'DELETE');
      _showSuccessSnackBar('Product deleted successfully!');
      _fetchProducts();
    } catch (e) {/* Error handled */}
  }

  void _editProduct(Product product) {
    _productNameController.text = product.name;
    _productDescriptionController.text = product.description;
    _productPriceController.text = product.price.toString();
    _productQuantityController.text = '1'; // Default quantity for edit
    _productImageUrlController.text = product.imageUrl ?? '';
    _selectedProductCategory = product.category;

    setState(() {
      _isEditProductMode = true;
      _editingProductId = product.id;
      _tabIndex = 6; // Switch to add/edit product tab
    });
  }

  void _clearProductForm() {
    _productFormKey.currentState?.reset();
    _productNameController.clear();
    _productDescriptionController.clear();
    _productPriceController.clear();
    _productQuantityController.clear();
    _productImageUrlController.clear();
    setState(() {
      _selectedProductCategory = 'Fruits';
      _selectedProductUnit = 'kg';
      _isEditProductMode = false;
      _editingProductId = null;
    });
  }

  // --- UI BUILD ---

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF151A24),
        cardColor: const Color(0xFF23293A),
        dividerColor: Colors.grey[700],
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.blueAccent,
        ),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF23293A)),
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < kTabletBreakpoint;

            return Scaffold(
              key: _scaffoldKey,
              drawer: isMobile ? _buildDrawer() : null,
              body: Row(
                children: [
                  if (!isMobile) _buildSidebar(),
                  Expanded(
                    child: Column(
                      children: [
                        _buildTopBar(isMobile: isMobile),
                        Expanded(
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _buildCurrentTab(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_tabIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildRequestsTab();
      case 2:
        return _buildSellersTab();
      case 3:
        return _buildUsersTab();
      case 4:
        return _buildProductsTab();
      case 5:
        return _buildOrdersTab();
      case 6:
        return _buildAddProductTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildTopBar({required bool isMobile}) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(color: Color(0xFF23293A)),
      child: Row(
        children: [
          IconButton(
            icon: Icon(isMobile
                ? Icons.menu
                : (_isSidebarExpanded ? Icons.menu_open : Icons.menu)),
            onPressed: () {
              if (isMobile) {
                _scaffoldKey.currentState?.openDrawer();
              } else {
                setState(() => _isSidebarExpanded = !_isSidebarExpanded);
              }
            },
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text("Admin Dashboard",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllData,
            tooltip: "Refresh Data",
          ),
        ],
      ),
    );
  }

  // --- RESPONSIVE NAVIGATION ---

  Widget _buildSidebar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _isSidebarExpanded ? 250.0 : 70.0,
      color: const Color(0xFF23293A),
      child: _buildNavRail(isExpanded: _isSidebarExpanded),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF23293A),
      child: _buildNavRail(isExpanded: true, isMobile: true),
    );
  }

  Widget _buildNavRail({required bool isExpanded, bool isMobile = false}) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
      children: [
        if (isExpanded)
          const Row(
            children: [
              Icon(Icons.shopping_cart, color: Colors.blueAccent, size: 28),
              SizedBox(width: 8),
              Text("GroceryAdmin",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          )
        else
          const Center(
              child: Icon(Icons.shopping_cart,
                  color: Colors.blueAccent, size: 28)),
        const SizedBox(height: 40),
        _sidebarNavItem(Icons.dashboard, "Dashboard", 0, isExpanded,
            isMobile: isMobile),
        _sidebarNavItem(Icons.people, "Users", 3, isExpanded,
            isMobile: isMobile),
        _sidebarNavItem(Icons.inventory, "Products", 4, isExpanded,
            isMobile: isMobile),
        _sidebarNavItem(Icons.receipt_long, "Orders", 5, isExpanded,
            isMobile: isMobile),
        _sidebarNavItem(
            Icons.add_shopping_cart, "Add/Edit Product", 6, isExpanded,
            isMobile: isMobile),
      ],
    );
  }

  Widget _sidebarNavItem(IconData icon, String text, int index, bool showText,
      {bool isMobile = false}) {
    final bool selected = _tabIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        setState(() => _tabIndex = index);
        if (isMobile) Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selected
              ? Colors.blueAccent.withOpacity(0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: selected ? Colors.blueAccent : Colors.grey[400]),
            if (showText) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: selected ? Colors.blueAccent : Colors.grey[300],
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- RESPONSIVE TABS ---

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Overview",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _statCard("Total Users", _totalUsers.toString(), Icons.people),
              _statCard("Total Sellers", _totalSellers.toString(),
                  Icons.store_rounded),
              _statCard(
                  "Total Products", _totalProducts.toString(), Icons.inventory),
              _statCard("Available Products", _availableProducts.toString(),
                  Icons.visibility, Colors.green),
              _statCard("Hidden Products", _hiddenProducts.toString(),
                  Icons.visibility_off, Colors.orange),
            ],
          )
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon,
      [Color? iconColor]) {
    return LayoutBuilder(builder: (context, constraints) {
      double cardWidth =
          constraints.maxWidth > 350 ? 300 : constraints.maxWidth;
      return SizedBox(
        width: cardWidth,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, size: 36, color: iconColor ?? Colors.blueAccent),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(value,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24)),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  // --- ADD PRODUCT TAB (RESPONSIVE) ---
  Widget _buildAddProductTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_isEditProductMode ? "Edit Product" : "Add New Product",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 28)),
              const Spacer(),
              if (_isEditProductMode)
                TextButton.icon(
                  onPressed: _clearProductForm,
                  icon: const Icon(Icons.add, color: Colors.grey),
                  label: const Text("Add New Instead",
                      style: TextStyle(color: Colors.grey)),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _productFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormTextField(
                      controller: _productNameController,
                      label: "Product Name *",
                      hint: "Enter product name"),
                  const SizedBox(height: 20),
                  _buildFormTextField(
                      controller: _productDescriptionController,
                      label: "Description *",
                      hint: "Enter product description",
                      maxLines: 3),
                  const SizedBox(height: 20),

                  // RESPONSIVE: Price and Quantity Row
                  LayoutBuilder(builder: (context, constraints) {
                    bool isNarrow = constraints.maxWidth < 500;
                    return Flex(
                      direction: isNarrow ? Axis.vertical : Axis.horizontal,
                      crossAxisAlignment: isNarrow
                          ? CrossAxisAlignment.stretch
                          : CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: _buildFormTextField(
                              controller: _productPriceController,
                              label: "Price *",
                              hint: "0.00",
                              keyboardType: TextInputType.number),
                        ),
                        SizedBox(
                            width: isNarrow ? 0 : 20,
                            height: isNarrow ? 20 : 0),
                        Flexible(
                          child: _buildFormTextField(
                              controller: _productQuantityController,
                              label: "Quantity *",
                              hint: "0",
                              keyboardType: TextInputType.number),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 20),

                  // RESPONSIVE: Category and Unit Row
                  LayoutBuilder(builder: (context, constraints) {
                    bool isNarrow = constraints.maxWidth < 500;
                    return Flex(
                      direction: isNarrow ? Axis.vertical : Axis.horizontal,
                      crossAxisAlignment: isNarrow
                          ? CrossAxisAlignment.stretch
                          : CrossAxisAlignment.start,
                      children: [
                        Flexible(
                            child: _buildDropdownField(
                                label: "Category *",
                                value: _selectedProductCategory,
                                items: [
                                  'Fruits',
                                  'Vegetables',
                                  'Dairy',
                                  'Bakery',
                                  'Meat',
                                  'Other'
                                ],
                                onChanged: (v) => setState(
                                    () => _selectedProductCategory = v!))),
                        SizedBox(
                            width: isNarrow ? 0 : 20,
                            height: isNarrow ? 20 : 0),
                        Flexible(
                            child: _buildDropdownField(
                                label: "Unit *",
                                value: _selectedProductUnit,
                                items: ['kg', 'g', 'piece', 'pack', 'L', 'mL'],
                                onChanged: (v) =>
                                    setState(() => _selectedProductUnit = v!))),
                      ],
                    );
                  }),
                  const SizedBox(height: 20),
                  _buildFormTextField(
                      controller: _productImageUrlController,
                      label: "Image URL (Optional)",
                      hint: "https://..."),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(_isEditProductMode
                          ? 'Update Product'
                          : 'Add Product'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormTextField(
      {required TextEditingController controller,
      required String label,
      required String hint,
      int maxLines = 1,
      TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF151A24),
            hintText: hint,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
          validator: (v) =>
              (v == null || v.isEmpty) ? 'This field is required' : null,
        ),
      ],
    );
  }

  Widget _buildDropdownField(
      {required String label,
      required String value,
      required List<String> items,
      required ValueChanged<String?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          dropdownColor: const Color(0xFF23293A),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF151A24),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  // --- OTHER TABS (Sellers, Users, Products, Orders) ---
  // These tabs are composed of a title, a search/filter bar, and a list of responsive cards.

  Widget _buildGenericListTab({
    required String title,
    required Widget searchAndFilterBar,
    required int itemCount,
    required String emptyListMessage,
    required IndexedWidgetBuilder itemBuilder,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
          const SizedBox(height: 20),
          searchAndFilterBar,
          const SizedBox(height: 20),
          Expanded(
            child: itemCount == 0
                ? Center(
                    child: Text(emptyListMessage,
                        style: const TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: itemCount,
                    itemBuilder: itemBuilder,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsTab() {
    return _buildGenericListTab(
      title: "Pending Seller Requests",
      searchAndFilterBar: const SizedBox.shrink(), // No search for requests
      itemCount: _pendingRequests.length,
      emptyListMessage: "No pending seller requests.",
      itemBuilder: (context, index) =>
          _sellerRequestCard(_pendingRequests[index]),
    );
  }

  Widget _buildSellersTab() {
    return _buildGenericListTab(
      title: "Sellers",
      searchAndFilterBar:
          _buildSearchBar(_sellerSearchController, "Search sellers..."),
      itemCount: _sellers.length,
      emptyListMessage: "No sellers found.",
      itemBuilder: (context, index) => _sellerCard(_sellers[index]),
    );
  }

  Widget _buildUsersTab() {
    return _buildGenericListTab(
      title: "Users",
      searchAndFilterBar:
          _buildSearchBar(_userSearchController, "Search users..."),
      itemCount: _users.length,
      emptyListMessage: "No users found.",
      itemBuilder: (context, index) => _userCard(_users[index]),
    );
  }

  Widget _buildProductsTab() {
    return _buildGenericListTab(
      title: "Products",
      searchAndFilterBar: Row(
        children: [
          Expanded(
              child: _buildSearchBar(
                  _productSearchController, "Search products...")),
          const SizedBox(width: 16),
          _productFilterDropdown(),
        ],
      ),
      itemCount: _filteredProducts.length,
      emptyListMessage: "No products found for the current filter.",
      itemBuilder: (context, index) => _productCard(_filteredProducts[index]),
    );
  }

  Widget _buildOrdersTab() {
    return _buildGenericListTab(
      title: "Orders",
      searchAndFilterBar: Row(
        children: [
          Expanded(
              child:
                  _buildSearchBar(_orderSearchController, "Search orders...")),
          const SizedBox(width: 16),
          _orderFilterDropdown(),
        ],
      ),
      itemCount: _filteredOrders.length,
      emptyListMessage: "No orders found for the current filter.",
      itemBuilder: (context, index) => _orderCard(_filteredOrders[index]),
    );
  }

  Widget _buildSearchBar(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF151A24),
        hintText: hint,
        prefixIcon: const Icon(Icons.search, size: 20),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
    );
  }

  // --- RESPONSIVE CARD WIDGETS ---

  Widget _sellerRequestCard(SellerRequest req) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(req.storeName,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            Text('Owner: ${req.userName} (${req.userEmail})',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Text('Address: ${req.storeAddress}',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            LayoutBuilder(builder: (context, constraints) {
              bool isNarrow = constraints.maxWidth < 350;
              return Flex(
                direction: isNarrow ? Axis.vertical : Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: ElevatedButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text("Approve"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          onPressed: () => _approveSellerRequest(req.id))),
                  SizedBox(width: isNarrow ? 0 : 12, height: isNarrow ? 8 : 0),
                  Expanded(
                      child: ElevatedButton.icon(
                          icon: const Icon(Icons.close),
                          label: const Text("Reject"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          onPressed: () => _showRejectDialog(req.id))),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(String requestId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF23293A),
        title: const Text('Reason for rejection'),
        content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(hintText: 'Enter reason')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () {
                if (reasonController.text.isNotEmpty) {
                  _rejectSellerRequest(requestId, reasonController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text("Reject")),
        ],
      ),
    );
  }

  Widget _sellerCard(Seller seller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isNarrow = constraints.maxWidth < 450;
            return Flex(
              direction: isNarrow ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: isNarrow
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                    backgroundColor:
                        seller.isActive ? Colors.green : Colors.red,
                    child: const Icon(Icons.store, color: Colors.white)),
                SizedBox(width: isNarrow ? 0 : 16, height: isNarrow ? 12 : 0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(seller.storeName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('${seller.name} (${seller.email})',
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                Switch(
                    value: seller.isActive,
                    onChanged: (value) =>
                        _toggleSellerStatus(seller.id, value)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _userCard(User user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isNarrow = constraints.maxWidth < 450;
            return Flex(
              direction: isNarrow ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: isNarrow
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                    backgroundColor: user.isActive ? Colors.green : Colors.red,
                    child: const Icon(Icons.person, color: Colors.white)),
                SizedBox(width: isNarrow ? 0 : 16, height: isNarrow ? 12 : 0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(user.email,
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                Switch(
                    value: user.isActive,
                    onChanged: (value) => _toggleUserStatus(user.id, value)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _productCard(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isNarrow = constraints.maxWidth < 550;
            return Flex(
              direction: isNarrow ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: isNarrow
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                _buildProductImage(product.imageUrl),
                SizedBox(width: isNarrow ? 0 : 16, height: isNarrow ? 12 : 0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(product.description,
                          style: const TextStyle(color: Colors.grey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                SizedBox(width: isNarrow ? 0 : 16, height: isNarrow ? 12 : 0),
                Column(
                  crossAxisAlignment: isNarrow
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Visible:"),
                        Switch(
                            value: product.isAvailable,
                            onChanged: (value) =>
                                _toggleProductAvailability(product.id, value)),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editProduct(product)),
                        IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteConfirmation(product)),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF23293A),
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () {
                _deleteProduct(product.id);
                Navigator.pop(context);
              },
              child: const Text("Delete"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildProductImage(String? imageUrl) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: (imageUrl != null && Uri.tryParse(imageUrl)?.isAbsolute == true)
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.inventory, size: 40),
              ),
            )
          : const Icon(Icons.inventory, size: 40),
    );
  }

  Widget _orderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text('Order #${order.id.substring(0, 8)}...',
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                Text('\$${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Customer: ${order.userName} (${order.userEmail})',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Text('Status: ${order.status}',
                style: TextStyle(color: _getStatusColor(order.status))),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.receipt, size: 16),
              label: const Text("Download Invoice"),
              onPressed: () {
                // Placeholder for invoice download functionality
                _showSuccessSnackBar("Invoice download not implemented yet.");
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _productFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: const Color(0xFF151A24),
          borderRadius: BorderRadius.circular(12)),
      child: DropdownButton<String>(
        value: _productFilter,
        dropdownColor: const Color(0xFF23293A),
        underline: Container(),
        icon: const Icon(Icons.filter_list, size: 20),
        items: const [
          DropdownMenuItem(value: 'all', child: Text('All Products')),
          DropdownMenuItem(value: 'available', child: Text('Available')),
          DropdownMenuItem(value: 'hidden', child: Text('Hidden')),
        ],
        onChanged: (value) => setState(() {
          if (value != null) {
            _productFilter = value;
            _filterProducts();
          }
        }),
      ),
    );
  }

  Widget _orderFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: const Color(0xFF151A24),
          borderRadius: BorderRadius.circular(12)),
      child: DropdownButton<String>(
        value: _orderFilter,
        dropdownColor: const Color(0xFF23293A),
        underline: Container(),
        icon: const Icon(Icons.filter_list, size: 20),
        items: const [
          DropdownMenuItem(value: 'all', child: Text('All Orders')),
          DropdownMenuItem(value: 'pending', child: Text('Pending')),
          DropdownMenuItem(value: 'completed', child: Text('Completed')),
          DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
        ],
        onChanged: (value) => setState(() {
          if (value != null) {
            _orderFilter = value;
            _filterOrders();
          }
        }),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
