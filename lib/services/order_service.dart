import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import 'storage_service.dart';

class OrderService extends ChangeNotifier {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal() {
    _initMockOrders();
  }

  final StorageService _storage = StorageService();

  // จัดเก็บคำสั่งซื้อทั้งหมดในหน่วยความจำ (Mock State)
  final Map<int, OrderModel> _orders = {};

  int _orderIdCounter = 33;
  int _dailyQueueCounter = 11;

  // เริ่มต้น Mock Order เล็กน้อยเพื่อทดสอบ Queues Ahead ที่สมจริง
  void _initMockOrders() {
    // ออเดอร์ก่อนหน้าในคิว (PENDING / PREPARING)
    final priorOrder1 = OrderModel(
      id: 31,
      orderNumber: 'Order #31',
      queueNumber: 9,
      customerName: 'คุณกานต์',
      customerPhone: '0812345678',
      totalPrice: 120.0,
      status: 'PREPARING',
      paymentMethod: 'counter',
      paymentStatus: 'pending',
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)).toString().substring(0, 19),
      items: [
        OrderItemModel(productId: 2, name: 'Americano', quantity: 1, price: 55.0, options: 'เย็น, ไม่หวาน 0%'),
        OrderItemModel(productId: 5, name: 'Caramel Macchiato', quantity: 1, price: 65.0, options: 'เย็น, หวาน 50%'),
      ],
    );

    final priorOrder2 = OrderModel(
      id: 32,
      orderNumber: 'Order #32',
      queueNumber: 10,
      customerName: 'คุณพลอย',
      customerPhone: '0898765432',
      totalPrice: 65.0,
      status: 'PENDING',
      paymentMethod: 'counter',
      paymentStatus: 'pending',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)).toString().substring(0, 19),
      items: [
        OrderItemModel(productId: 9, name: 'Matcha Latte', quantity: 1, price: 65.0, options: 'เย็น, หวาน 50%'),
      ],
    );

    _orders[priorOrder1.id] = priorOrder1;
    _orders[priorOrder2.id] = priorOrder2;
  }

  // คำนวณ Queues Ahead: นับเฉพาะออเดอร์ที่อยู่ในคิวเตรียม (PENDING และ PREPARING) ที่มี queueNumber น้อยกว่า
  int calculateQueuesAhead(int targetQueueNumber) {
    int count = 0;
    for (var order in _orders.values) {
      if (order.queueNumber < targetQueueNumber) {
        if (order.status == 'PENDING' || order.status == 'PREPARING') {
          count++;
        }
      }
    }
    return max(0, count);
  }

  // สร้างคำสั่งซื้อใหม่ (ตรงตาม Requirement ข้อ 8, 9, 10, 11, 12, 13)
  Future<OrderModel> createOrder({
    required String customerName,
    required String customerPhone,
    required List<CartItem> cartItems,
    String? note,
  }) async {
    final int newId = _orderIdCounter++;
    final int newQueue = _dailyQueueCounter++;
    final String orderNum = 'Order #$newId';

    final double total = cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

    final orderItems = cartItems.map((c) => OrderItemModel(
      productId: c.product.id,
      name: c.product.name,
      quantity: c.quantity,
      price: c.unitPrice,
      options: c.optionsSummary,
    )).toList();

    final order = OrderModel(
      id: newId,
      orderNumber: orderNum,
      queueNumber: newQueue,
      customerName: customerName.trim(),
      customerPhone: customerPhone.trim(),
      totalPrice: total,
      status: 'PENDING', // ล็อก: "รอยืนยันออเดอร์"
      paymentMethod: 'counter',
      paymentStatus: 'pending',
      paidAt: null,
      note: note?.trim(),
      queueAhead: calculateQueuesAhead(newQueue),
      createdAt: DateTime.now().toString().substring(0, 19),
      items: orderItems,
    );

    _orders[newId] = order;

    // บันทึก Active Order ID และข้อมูลลูกค้าลง LocalStorage
    await _storage.saveActiveOrderId(newId);
    await _storage.saveCustomerInfo(customerName.trim(), customerPhone.trim());
    await _storage.clearCart();

    notifyListeners();
    return order;
  }

  // ดึงข้อมูลคำสั่งซื้อตาม ID
  Future<OrderModel?> getOrderById(int orderId) async {
    final order = _orders[orderId];
    if (order != null) {
      // อัปเดต queuesAhead ให้เป็นค่าปัจจุบันสดใหม่
      order.queueAhead = calculateQueuesAhead(order.queueNumber);
    }
    return order;
  }

  // ดึงคำสั่งซื้อที่กำลัง Active ล่าสุด
  Future<OrderModel?> getActiveOrder() async {
    final activeId = await _storage.loadActiveOrderId();
    if (activeId != null && _orders.containsKey(activeId)) {
      return getOrderById(activeId);
    }
    // หากไม่มี activeId ให้คืนค่าออเดอร์ล่าสุดของร้านถ้ามี
    if (_orders.isNotEmpty) {
      final latest = _orders.values.last;
      return getOrderById(latest.id);
    }
    return null;
  }

  // จำลองการเปลี่ยนสถานะสำหรับ Development Mode / Test
  void updateOrderStatus(int orderId, String newStatus) {
    if (_orders.containsKey(orderId)) {
      _orders[orderId]!.status = newStatus;
      _orders[orderId]!.queueAhead = calculateQueuesAhead(_orders[orderId]!.queueNumber);
      notifyListeners();
    }
  }

  // เลื่อนสถานะไปสเต็ปถัดไปสำหรับ Dev Demo
  void advanceOrderStatus(int orderId) {
    final order = _orders[orderId];
    if (order == null) return;

    switch (order.status) {
      case 'PENDING':
        updateOrderStatus(orderId, 'PREPARING');
        break;
      case 'PREPARING':
        updateOrderStatus(orderId, 'READY');
        break;
      case 'READY':
        updateOrderStatus(orderId, 'COMPLETED');
        break;
      case 'COMPLETED':
        // วนกลับมา PENDING เพื่อให้ทดสอบต่อได้
        updateOrderStatus(orderId, 'PENDING');
        break;
      default:
        updateOrderStatus(orderId, 'PENDING');
    }
  }

  // เคลียร์ Active Order
  Future<void> clearActiveOrder() async {
    await _storage.clearActiveOrderId();
    notifyListeners();
  }
}
