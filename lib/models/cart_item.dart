import 'product.dart';

class ToppingItem {
  final String id;
  final String name;
  final double price;

  const ToppingItem({
    required this.id,
    required this.name,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
  };

  factory ToppingItem.fromJson(Map<String, dynamic> json) => ToppingItem(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    price: (json['price'] != null)
        ? double.tryParse(json['price'].toString()) ?? 0.0
        : 0.0,
  );
}

class CartItem {
  final String id;
  final Product product;
  int quantity;
  final String? temperature; // 'ร้อน', 'เย็น'
  final String? sweetness;   // 'หวาน 100%', 'หวาน 50%', 'ไม่หวาน 0%'
  final List<ToppingItem> toppings;
  final String? note;

  CartItem({
    String? id,
    required this.product,
    this.quantity = 1,
    this.temperature,
    this.sweetness,
    List<ToppingItem>? toppings,
    this.note,
  })  : toppings = toppings ?? [],
        id = id ?? generateId(product.id, temperature, sweetness, toppings ?? []);

  static String generateId(
    int productId,
    String? temp,
    String? sweet,
    List<ToppingItem> toppingsList,
  ) {
    final sortedToppings = List<ToppingItem>.from(toppingsList)
      ..sort((a, b) => a.id.compareTo(b.id));
    final toppingKeys = sortedToppings.map((t) => t.id).join(',');
    return '${productId}_${temp ?? "none"}_${sweet ?? "none"}_$toppingKeys';
  }

  // คำนวณราคาต่อหน่วย = ราคาพื้นฐาน + ท็อปปิ้งทั้งหมด
  double get unitPrice {
    double total = product.price;
    for (var t in toppings) {
      total += t.price;
    }
    return total;
  }

  double get totalPrice => unitPrice * quantity;

  // ข้อความสรุป Options
  String get optionsSummary {
    List<String> parts = [];
    if (temperature != null && temperature!.isNotEmpty) {
      parts.add(temperature!);
    }
    if (sweetness != null && sweetness!.isNotEmpty) {
      parts.add(sweetness!);
    }
    for (var t in toppings) {
      parts.add('${t.name} (+฿${t.price.toInt()})');
    }
    if (note != null && note!.trim().isNotEmpty) {
      parts.add('หมายเหตุ: ${note!.trim()}');
    }
    return parts.join(', ');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'temperature': temperature,
      'sweetness': sweetness,
      'toppings': toppings.map((t) => t.toJson()).toList(),
      'note': note,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    Product prod;
    if (json['product'] is Map) {
      prod = Product.fromJson(Map<String, dynamic>.from(json['product']));
    } else {
      prod = Product(
        id: 0,
        name: 'สินค้า',
        category: 'Coffee',
        price: 0.0,
      );
    }

    return CartItem(
      id: json['id']?.toString(),
      product: prod,
      quantity: json['quantity'] is int
          ? json['quantity'] as int
          : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      temperature: json['temperature']?.toString(),
      sweetness: json['sweetness']?.toString(),
      toppings: (json['toppings'] is List)
          ? (json['toppings'] as List)
              .whereType<Map>()
              .map((t) => ToppingItem.fromJson(Map<String, dynamic>.from(t)))
              .toList()
          : [],
      note: json['note']?.toString(),
    );
  }

  Map<String, dynamic> toApiJson() {
    return {
      'id': product.id,
      'name': product.name,
      'qty': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'temperature': temperature,
      'sweetness': sweetness,
      'toppings': toppings.map((t) => t.name).toList(),
      'options': optionsSummary,
    };
  }
}
