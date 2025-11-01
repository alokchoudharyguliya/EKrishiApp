import '../utils/imports.dart';
import '../models/vendor.dart';
import '../models/supply.dart';
import '../models/order.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class SupplyService {
  static const String baseUrl = '$BASE_URL/api/supplies';
  static const _storage = FlutterSecureStorage();

  // Get authorization headers for dio
  static Future<Options> _getDioOptions() async {
    final token = await _storage.read(key: 'token');
    return Options(
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  // Vendor methods
  static Future<List<Vendor>> getVendors({
    String? category,
    String? city,
    String? search,
  }) async {
    try {
      final dio = Dio();
      final queryParams = <String, dynamic>{};
      if (category != null) queryParams['category'] = category;
      if (city != null) queryParams['city'] = city;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await dio.get(
        '$baseUrl/vendors',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: await _getDioOptions(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        if (response.data['data'] != null) {
          final List<dynamic> vendorsJson = response.data['data'];
          return vendorsJson.map((json) => Vendor.fromJson(json)).toList();
        }
        return [];
      } else {
        throw Exception('Failed to load vendors: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting vendors: $e');
      rethrow;
    }
  }

  static Future<Vendor> getVendorById(String id) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        '$baseUrl/vendors/$id',
        options: await _getDioOptions(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        if (response.data['data'] != null) {
          return Vendor.fromJson(response.data['data']);
        }
        throw Exception('Vendor not found');
      } else {
        throw Exception('Failed to load vendor: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting vendor: $e');
      rethrow;
    }
  }

  // Supply methods
  static Future<List<Supply>> getSupplies({
    String? category,
    String? vendorId,
    String? search,
    bool? isAvailable,
  }) async {
    try {
      final dio = Dio();
      final queryParams = <String, dynamic>{};
      if (category != null) queryParams['category'] = category;
      if (vendorId != null) queryParams['vendorId'] = vendorId;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (isAvailable != null) queryParams['isAvailable'] = isAvailable.toString();

      final response = await dio.get(
        baseUrl,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: await _getDioOptions(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        if (response.data['data'] != null) {
          final List<dynamic> suppliesJson = response.data['data'];
          return suppliesJson.map((json) => Supply.fromJson(json)).toList();
        }
        return [];
      } else {
        throw Exception('Failed to load supplies: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting supplies: $e');
      rethrow;
    }
  }

  static Future<Supply> getSupplyById(String id) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        '$baseUrl/$id',
        options: await _getDioOptions(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        if (response.data['data'] != null) {
          return Supply.fromJson(response.data['data']);
        }
        throw Exception('Supply not found');
      } else {
        throw Exception('Failed to load supply: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting supply: $e');
      rethrow;
    }
  }

  static Future<List<Supply>> getSuppliesByCategory(String category) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        '$baseUrl/category/$category',
        options: await _getDioOptions(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        if (response.data['data'] != null) {
          final List<dynamic> suppliesJson = response.data['data'];
          return suppliesJson.map((json) => Supply.fromJson(json)).toList();
        }
        return [];
      } else {
        throw Exception('Failed to load supplies: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting supplies by category: $e');
      rethrow;
    }
  }

  static Future<List<Supply>> getSuppliesByVendor(String vendorId) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        '$baseUrl/vendor/$vendorId',
        options: await _getDioOptions(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        if (response.data['data'] != null) {
          final List<dynamic> suppliesJson = response.data['data'];
          return suppliesJson.map((json) => Supply.fromJson(json)).toList();
        }
        return [];
      } else {
        throw Exception('Failed to load supplies: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting supplies by vendor: $e');
      rethrow;
    }
  }

  // Order methods
  static Future<Order> createOrder({
    required List<Map<String, dynamic>> items, // [{supplyId, quantity}]
    required String vendorId,
    DateTime? expectedPickupDate,
    String? notes,
  }) async {
    try {
      final dio = Dio();
      final response = await dio.post(
        '$baseUrl/orders',
        data: {
          'items': items,
          'vendorId': vendorId,
          'expectedPickupDate': expectedPickupDate?.toIso8601String(),
          'notes': notes,
        },
        options: await _getDioOptions(),
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        if (response.data['data'] != null) {
          return Order.fromJson(response.data['data']);
        }
        throw Exception('Failed to create order');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create order');
      }
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  static Future<List<Order>> getFarmerOrders({String? status}) async {
    try {
      final dio = Dio();
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;

      final response = await dio.get(
        '$baseUrl/orders',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: await _getDioOptions(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        if (response.data['data'] != null) {
          final List<dynamic> ordersJson = response.data['data'];
          return ordersJson.map((json) => Order.fromJson(json)).toList();
        }
        return [];
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting farmer orders: $e');
      rethrow;
    }
  }

  static Future<Order> getOrderById(String id) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        '$baseUrl/orders/$id',
        options: await _getDioOptions(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        if (response.data['data'] != null) {
          return Order.fromJson(response.data['data']);
        }
        throw Exception('Order not found');
      } else {
        throw Exception('Failed to load order: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting order: $e');
      rethrow;
    }
  }

  static Future<void> cancelOrder(String orderId) async {
    try {
      final dio = Dio();
      final response = await dio.put(
        '$baseUrl/orders/$orderId/cancel',
        options: await _getDioOptions(),
      );

      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to cancel order');
      }
    } catch (e) {
      print('Error cancelling order: $e');
      rethrow;
    }
  }
}

