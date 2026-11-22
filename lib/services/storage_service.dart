import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _keyCart = 'banchong_cart';
  static const String _keyActiveOrderId = 'banchong_active_order_id';
  static const String _keyCustomerName = 'banchong_customer_name';
  static const String _keyCustomerPhone = 'banchong_customer_phone';

  // --- Cart Persistence ---
  Future<void> saveCart(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((i) => i.toJson()).toList();
    await prefs.setString(_keyCart, json.encode(jsonList));
  }

  Future<List<CartItem>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartStr = prefs.getString(_keyCart);
    if (cartStr == null || cartStr.isEmpty) return [];
    try {
      final List list = json.decode(cartStr);
      return list.map((item) => CartItem.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCart);
  }

  // --- Active Order Persistence ---
  Future<void> saveActiveOrderId(int orderId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyActiveOrderId, orderId);
  }

  Future<int?> loadActiveOrderId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyActiveOrderId);
  }

  Future<void> clearActiveOrderId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyActiveOrderId);
  }

  // --- Customer Info Persistence ---
  Future<void> saveCustomerInfo(String name, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCustomerName, name);
    await prefs.setString(_keyCustomerPhone, phone);
  }

  Future<Map<String, String>> loadCustomerInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_keyCustomerName) ?? '',
      'phone': prefs.getString(_keyCustomerPhone) ?? '',
    };
  }
}
