class Product {
  final int id;
  final String name;
  final String category; // 'Coffee', 'Non-Coffee', 'Cake'
  final String? subcategory;
  final String? description;
  final double price;
  final String? image;
  final bool isAvailable;
  final String? badge; // 'Special', 'Signature', 'Recommended', 'Best Seller'
  final List<String> availableOptions; // ['temperature', 'sweetness', 'toppings']
  final String? tasteNotes;
  final String? roastLevel;

  Product({
    required this.id,
    required this.name,
    required this.category,
    this.subcategory,
    this.description,
    required this.price,
    this.image,
    this.isAvailable = true,
    this.badge,
    this.availableOptions = const ['temperature', 'sweetness', 'toppings'],
    this.tasteNotes,
    this.roastLevel,
  });

  bool get isDrink {
    final cat = category.toLowerCase();
    return cat.contains('coffee') ||
        cat.contains('noncoffee') ||
        cat.contains('non-coffee') ||
        cat.contains('ชา') ||
        cat.contains('เครื่องดื่ม');
  }

  bool get isCake {
    final cat = category.toLowerCase();
    return cat.contains('cake') ||
        cat.contains('bakery') ||
        cat.contains('เค้ก') ||
        cat.contains('เบเกอรี่');
  }

  String get displayCategory {
    final cat = category.toLowerCase();
    if (cat == 'coffee') return 'Coffee';
    if (cat == 'noncoffee' || cat == 'non-coffee') return 'Non-Coffee';
    if (cat == 'cake' || cat == 'bakery') return 'Cake';
    return category;
  }

  String get availabilityText => isAvailable ? 'พร้อมขาย' : 'หมด/ปิดขาย';

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawAvailable = json['is_available'] ?? json['available'];
    final bool available = rawAvailable == null
        ? true
        : (rawAvailable == true ||
            rawAvailable == 1 ||
            rawAvailable == '1' ||
            rawAvailable.toString().toLowerCase() == 'true');

    final cat = json['category']?.toString() ?? 'Coffee';
    final isCakeCategory = cat.toLowerCase().contains('cake') ||
        cat.toLowerCase().contains('bakery') ||
        cat.contains('เค้ก') ||
        cat.contains('เบเกอรี่');

    List<String> options = [];
    if (json['available_options'] is List) {
      options = (json['available_options'] as List)
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    } else {
      options = isCakeCategory
          ? const []
          : const ['temperature', 'sweetness', 'toppings'];
    }

    return Product(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      category: cat,
      subcategory: json['subcategory']?.toString(),
      description: json['description']?.toString(),
      price: (json['price'] != null)
          ? double.tryParse(json['price'].toString()) ?? 0.0
          : 0.0,
      image: json['image']?.toString(),
      isAvailable: available,
      badge: json['badge']?.toString(),
      availableOptions: options,
      tasteNotes: json['taste_notes']?.toString(),
      roastLevel: json['roast_level']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'subcategory': subcategory,
      'description': description,
      'price': price,
      'image': image,
      'is_available': isAvailable,
      'badge': badge,
      'available_options': availableOptions,
      'taste_notes': tasteNotes,
      'roast_level': roastLevel,
    };
  }

  Product copyWith({
    int? id,
    String? name,
    String? category,
    String? subcategory,
    String? description,
    double? price,
    String? image,
    bool? isAvailable,
    String? badge,
    List<String>? availableOptions,
    String? tasteNotes,
    String? roastLevel,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      isAvailable: isAvailable ?? this.isAvailable,
      badge: badge ?? this.badge,
      availableOptions: availableOptions ?? this.availableOptions,
      tasteNotes: tasteNotes ?? this.tasteNotes,
      roastLevel: roastLevel ?? this.roastLevel,
    );
  }
}
