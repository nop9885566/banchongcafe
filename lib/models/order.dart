class OrderModel {
  final int id;
  final String orderNumber;      // e.g. "Order #33"
  final int queueNumber;         // Running daily number: 1, 2, 3...
  final String customerName;
  final String customerPhone;
  final double totalPrice;
  String status;                 // PENDING, PREPARING, READY, COMPLETED, CANCELLED
  final String paymentMethod;    // "counter"
  final String paymentStatus;    // "pending"
  final String? paidAt;
  final String? note;
  int queueAhead;
  final String? createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.queueNumber,
    required this.customerName,
    required this.customerPhone,
    required this.totalPrice,
    required this.status,
    this.paymentMethod = 'counter',
    this.paymentStatus = 'pending',
    this.paidAt,
    this.note,
    this.queueAhead = 0,
    this.createdAt,
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'] as List? ?? [];
    List<OrderItemModel> itemsList = rawItems
        .map((i) => OrderItemModel.fromJson(i as Map<String, dynamic>))
        .toList();

    return OrderModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      orderNumber: json['order_number'] ?? '#${json['id'] ?? 0}',
      queueNumber: json['queue_number'] is int
          ? json['queue_number']
          : int.tryParse(json['queue_number'].toString()) ?? (json['id'] ?? 1),
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      totalPrice: (json['total_price'] != null)
          ? double.tryParse(json['total_price'].toString()) ?? 0.0
          : 0.0,
      status: (json['status'] ?? 'PENDING').toString().toUpperCase(),
      paymentMethod: json['payment_method'] ?? 'counter',
      paymentStatus: json['payment_status'] ?? 'pending',
      paidAt: json['paid_at'],
      note: json['note'],
      queueAhead: json['queue_ahead'] is int
          ? json['queue_ahead']
          : int.tryParse(json['queue_ahead'].toString()) ?? 0,
      createdAt: json['created_at'],
      items: itemsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'queue_number': queueNumber,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'total_price': totalPrice,
      'status': status,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'paid_at': paidAt,
      'note': note,
      'queue_ahead': queueAhead,
      'created_at': createdAt,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }

  // คำอธิบายสถานะภาษาไทยตามข้อกำหนด
  String get statusThai {
    switch (status) {
      case 'PENDING':
        return 'รอยืนยันออเดอร์';
      case 'PREPARING':
        return 'กำลังเตรียมเครื่องดื่ม';
      case 'READY':
        return 'เสร็จสิ้น / รับเครื่องดื่มได้เลย!';
      case 'COMPLETED':
        return 'รับเครื่องดื่มแล้ว';
      case 'CANCELLED':
        return 'คำสั่งซื้อถูกยกเลิก';
      default:
        return status;
    }
  }

  String get statusDescription {
    switch (status) {
      case 'PENDING':
        return 'ร้านได้รับคำสั่งซื้อแล้ว กรุณารอการยืนยันและดำเนินการจากทางร้าน';
      case 'PREPARING':
        return 'บาริสต้ากำลังเตรียมเครื่องดื่มของคุณ';
      case 'READY':
        return 'เครื่องดื่มของคุณพร้อมแล้ว กรุณามารับที่ร้าน';
      case 'COMPLETED':
        return 'คำสั่งซื้อของคุณเสร็จสมบูรณ์แล้ว';
      case 'CANCELLED':
        return 'คำสั่งซื้อนี้ถูกยกเลิกเรียบร้อยแล้ว';
      default:
        return '';
    }
  }

  // สเต็ปของ Progress Stepper (1 ถึง 4)
  int get currentStep {
    switch (status) {
      case 'PENDING':
        return 1;
      case 'PREPARING':
        return 2;
      case 'READY':
        return 3;
      case 'COMPLETED':
        return 4;
      default:
        return 1;
    }
  }

  bool get isReady => status == 'READY';
  bool get isCompleted => status == 'COMPLETED';
  bool get isCancelled => status == 'CANCELLED';
}

class OrderItemModel {
  final int productId;
  final String name;
  final int quantity;
  final double price;
  final String? options;

  OrderItemModel({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    this.options,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['product_id'] is int
          ? json['product_id']
          : int.tryParse(json['product_id'].toString()) ?? 0,
      name: json['name'] ?? 'สินค้า',
      quantity: json['quantity'] is int
          ? json['quantity']
          : int.tryParse(json['quantity'].toString()) ?? 1,
      price: (json['price'] != null)
          ? double.tryParse(json['price'].toString()) ?? 0.0
          : 0.0,
      options: json['options'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'options': options,
    };
  }
}
