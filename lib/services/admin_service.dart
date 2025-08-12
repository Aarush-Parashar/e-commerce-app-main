import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminResult {
  final bool isAdmin;
  final String? adminLevel; // admin1, admin2, admin3
  final String message;

  AdminResult({
    required this.isAdmin,
    this.adminLevel,
    this.message = '',
  });
}

class AdminService {
  // Admin credentials from environment variables
  static final Map<String, String> _adminCredentials = {
    Platform.environment['ADMIN1_EMAIL'] ?? '': Platform.environment['ADMIN1_PASSWORD'] ?? '',
    Platform.environment['ADMIN2_EMAIL'] ?? '': Platform.environment['ADMIN2_PASSWORD'] ?? '',
    Platform.environment['ADMIN3_EMAIL'] ?? '': Platform.environment['ADMIN3_PASSWORD'] ?? '',
  };

  // Map to identify admin levels
  static final Map<String, String> _adminLevels = {
    Platform.environment['ADMIN1_EMAIL'] ?? '': 'admin1',
    Platform.environment['ADMIN2_EMAIL'] ?? '': 'admin2',
    Platform.environment['ADMIN3_EMAIL'] ?? '': 'admin3',
  };

  static const String _baseUrl = 'https://backend-ecommerce-app-co1r.onrender.com/api';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Check if the provided email and password match any admin credentials
  static Future<AdminResult> checkAdminLogin(String email, String password) async {
    try {
      // Remove empty keys that might exist due to missing env variables
      final validCredentials = Map<String, String>.from(_adminCredentials)
        ..removeWhere((key, value) => key.isEmpty || value.isEmpty);

      if (validCredentials.containsKey(email)) {
        if (validCredentials[email] == password) {
          final adminLevel = _adminLevels[email];
          return AdminResult(
            isAdmin: true,
            adminLevel: adminLevel,
            message: 'Admin authentication successful',
          );
        } else {
          return AdminResult(
            isAdmin: false,
            message: 'Invalid admin password',
          );
        }
      }

      // Not an admin email
      return AdminResult(
        isAdmin: false,
        message: 'Not an admin account',
      );
    } catch (e) {
      return AdminResult(
        isAdmin: false,
        message: 'Admin authentication error: ${e.toString()}',
      );
    }
  }

  /// Check if current user is admin (for route protection)
  static bool isCurrentUserAdmin() {
    // You might want to store admin state in shared preferences
    // or some other persistent storage
    // This is a basic implementation
    return false;
  }

  /// Get all configured admin emails (for debugging purposes)
  static List<String> getConfiguredAdmins() {
    return _adminCredentials.keys
        .where((email) => email.isNotEmpty && _adminCredentials[email]!.isNotEmpty)
        .toList();
  }

  /// Validate environment variables are properly set
  static bool validateAdminConfiguration() {
    final validAdmins = getConfiguredAdmins();
    return validAdmins.isNotEmpty;
  }

  // Get all orders for admin
  static Future<List<Order>> getAllOrders() async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/orders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final orders = (data['orders'] as List)
            .map((order) => Order.fromJson(order))
            .toList();
        return orders;
      } else {
        throw Exception('Failed to fetch orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get user order history
  static Future<List<Order>> getUserOrderHistory(String userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/users/$userId/orders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final orders = (data['orders'] as List)
            .map((order) => Order.fromJson(order))
            .toList();
        return orders;
      } else {
        throw Exception('Failed to fetch user orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get user details
  static Future<UserDetails> getUserDetails(String userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/users/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserDetails.fromJson(data['user']);
      } else {
        throw Exception('Failed to fetch user details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Generate invoice for an order
  static Future<String> generateInvoice(String orderId) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/orders/$orderId/invoice'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['invoiceUrl'] ?? data['pdfUrl'] ?? '';
      } else {
        throw Exception('Failed to generate invoice: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Download invoice
  static Future<List<int>> downloadInvoice(String orderId) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/orders/$orderId/invoice/download'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to download invoice: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

// Order Model
class Order {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final String paymentStatus;
  final String? shippingAddress;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    this.shippingAddress,
    required this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? json['user']?['_id'] ?? '',
      userName: json['userName'] ?? json['user']?['name'] ?? '',
      userEmail: json['userEmail'] ?? json['user']?['email'] ?? '',
      userPhone: json['userPhone'] ?? json['user']?['phone'] ?? '',
      items: (json['items'] as List?)
          ?.map((item) => OrderItem.fromJson(item))
          .toList() ?? [],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      shippingAddress: json['shippingAddress'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'paymentStatus': paymentStatus,
      'shippingAddress': shippingAddress,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

// Order Item Model
class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String? imageUrl;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] ?? json['product']?['_id'] ?? '',
      productName: json['productName'] ?? json['product']?['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      imageUrl: json['imageUrl'] ?? json['product']?['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }

  double get totalPrice => price * quantity;
}

// User Details Model
class UserDetails {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final int totalOrders;
  final double totalSpent;
  final String? profileImage;

  UserDetails({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.totalOrders,
    required this.totalSpent,
    this.profileImage,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'user',
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      totalOrders: json['totalOrders'] ?? 0,
      totalSpent: (json['totalSpent'] ?? 0).toDouble(),
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'totalOrders': totalOrders,
      'totalSpent': totalSpent,
      'profileImage': profileImage,
    };
  }
}