import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import 'storage_service.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal() {
    _loadFromStorage();
  }

  final StorageService _storage = StorageService();
  List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);

  double get totalAmount => _items.fold(0.0, (sum, i) => sum + i.totalPrice);

  bool get isEmpty => _items.isEmpty;

  Future<void> _loadFromStorage() async {
    _items = await _storage.loadCart();
    notifyListeners();
  }

  Future<void> addItem(CartItem newItem) async {
    // ตรวจสอบว่ามีรายการที่ productId และ Options ตรงกันเป๊ะหรือไม่
    final existingIndex = _items.indexWhere((i) => i.id == newItem.id);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += newItem.quantity;
    } else {
      _items.add(newItem);
    }

    await _storage.saveCart(_items);
    notifyListeners();
  }

  Future<void> updateQuantity(String cartItemId, int delta) async {
    final index = _items.indexWhere((i) => i.id == cartItemId);
    if (index >= 0) {
      _items[index].quantity += delta;
      if (_items[index].quantity <= 0) {
        _items.removeAt(index);
      }
      await _storage.saveCart(_items);
      notifyListeners();
    }
  }

  Future<void> removeItem(String cartItemId) async {
    _items.removeWhere((i) => i.id == cartItemId);
    await _storage.saveCart(_items);
    notifyListeners();
  }

  Future<void> clear() async {
    _items.clear();
    await _storage.clearCart();
    notifyListeners();
  }
}
