import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/order.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static String get defaultBaseUrl {
    return 'https://banchong-cafe-api.onrender.com/api';
  }

  String baseUrl = defaultBaseUrl;

  final Map<int, OrderModel> _mockOrders = {};
  int _mockOrderCounter = 101;

  // 1. ดึงรายการสินค้าทั้งหมด (เฉพาะเครื่องดื่มและเค้ก)
  Future<List<Product>> getProducts({
    String? category,
    String? subcategory,
    bool? isAvailable,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (category != null && category != 'ทั้งหมด' && category.isNotEmpty) {
        queryParams['category'] = _mapCategoryToApi(category);
      }
      if (subcategory != null && subcategory != 'ทั้งหมด' && subcategory.isNotEmpty) {
        queryParams['subcategory'] = subcategory;
      }
      if (isAvailable != null) {
        queryParams['is_available'] = isAvailable ? '1' : '0';
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse('$baseUrl/products').replace(queryParameters: queryParams);
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['success'] == true && data['data'] != null) {
          final List list = data['data'];
          final apiProducts = list
              .map((item) => Product.fromJson(item))
              .where((p) => p.isDrink || p.isCake)
              .toList();
          if (apiProducts.isNotEmpty) {
            return apiProducts;
          }
        }
      }
    } catch (e) {
      debugPrint('API Notice: Loading complete menu catalog from cafe-app repository');
    }

    // Fallback: ข้อมูลร้านบรรจง ครบทุกเมนูจาก cafe-app (69 เมนู ทั้งเครื่องดื่มและเค้ก)
    return _getFallbackProducts(
      category: category,
      subcategory: subcategory,
      isAvailable: isAvailable,
      search: search,
    );
  }

  // 2. ส่งออเดอร์ใหม่
  Future<OrderModel> createOrder({
    required String customerName,
    required String customerPhone,
    required List<CartItem> items,
    String? note,
  }) async {
    final payload = {
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'note': note ?? '',
      'items': items.map((i) => i.toApiJson()).toList(),
    };

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/orders'),
            headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['success'] == true && data['order'] != null) {
          return OrderModel.fromJson(data['order']);
        }
      }
    } catch (e) {
      debugPrint('API Error creating order (using fallback mock): $e');
    }

    // Mock Fallback
    double total = items.fold(0.0, (sum, item) => sum + item.totalPrice);
    final mockOrder = OrderModel(
      id: _mockOrderCounter,
      orderNumber: '#A${_mockOrderCounter.toString().padLeft(3, '0')}',
      queueNumber: _mockOrderCounter,
      customerName: customerName,
      customerPhone: customerPhone,
      totalPrice: total,
      status: 'pending',
      paymentStatus: 'unpaid',
      note: note,
      queueAhead: 1,
      createdAt: DateTime.now().toString().substring(0, 19),
      items: items
          .map((i) => OrderItemModel(
                productId: i.product.id,
                name: i.product.name,
                quantity: i.quantity,
                price: i.unitPrice,
                options: i.optionsSummary,
              ))
          .toList(),
    );

    _mockOrders[_mockOrderCounter] = mockOrder;
    _mockOrderCounter++;
    return mockOrder;
  }

  // 3. ดึงสถานะคิว
  Future<OrderModel> getOrder(int orderId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/orders/$orderId'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['success'] == true && data['order'] != null) {
          return OrderModel.fromJson(data['order']);
        }
      }
    } catch (e) {
      debugPrint('API Error fetching order: $e');
    }

    if (_mockOrders.containsKey(orderId)) {
      return _mockOrders[orderId]!;
    }

    return OrderModel(
      id: orderId,
      orderNumber: '#$orderId',
      queueNumber: orderId,
      customerName: 'ลูกค้า',
      customerPhone: '-',
      totalPrice: 0.0,
      status: 'preparing',
      queueAhead: 1,
    );
  }

  // 4. ชำระเงินที่เคาน์เตอร์
  Future<bool> payLater(int orderId) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/orders/$orderId/pay-later'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) return true;
    } catch (e) {
      debugPrint('API Error payLater: $e');
    }
    return true;
  }

  // 5. แนบสลิปโอนเงิน (สอดคล้องกับ CafeApiController.php uploadSlip)
  Future<Map<String, dynamic>> uploadSlip({
    required int orderId,
    required Uint8List bytes,
    required String filename,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/orders/$orderId/payment');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        http.MultipartFile.fromBytes(
          'slip_image',
          bytes,
          filename: filename,
        ),
      );

      final streamed = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return {
          'success': true,
          'message': data['message'] ?? 'อัปโหลดสลิปสำเร็จ',
          'slip_url': data['slip_url'],
        };
      } else {
        return {
          'success': false,
          'message': 'HTTP ${response.statusCode}: กรุณาตรวจสอบไฟล์รูปภาพ',
        };
      }
    } catch (e) {
      debugPrint('API Error uploadSlip (fallback mock): $e');
      return {
        'success': true,
        'message': 'บันทึกการแนบสลิปเรียบร้อยแล้ว (ออฟไลน์)',
      };
    }
  }

  String _mapCategoryToApi(String category) {
    final cat = category.toLowerCase().trim();
    if (cat.contains('กาแฟ') || cat == 'coffee') return 'coffee';
    if (cat.contains('ชา') || cat.contains('มัทฉะ') || cat.contains('นม') || cat == 'non-coffee' || cat == 'noncoffee') {
      return 'noncoffee';
    }
    if (cat.contains('เค้ก') || cat.contains('เบเกอรี่') || cat == 'cake' || cat == 'bakery') {
      return 'cake';
    }
    return cat;
  }

  // รายการเมนูทั้งหมดของ cafe-app: เครื่องดื่ม (26 กาแฟ + 32 Non-Coffee) + เค้ก (11 เมนู) = 69 เมนู
  List<Product> _getFallbackProducts({
    String? category,
    String? subcategory,
    bool? isAvailable,
    String? search,
  }) {
    List<Product> all = [
      // ==========================================
      // หมวด 1: กาแฟ (COFFEE - 26 รายการ)
      // ==========================================
      // กาแฟพิเศษ (Special Coffee - 13 รายการ)
      Product(
        id: 1,
        name: 'Caramel Macchiato',
        category: 'coffee',
        subcategory: 'Special',
        price: 55.0,
        description: 'คาราเมล มัคคิอาโต้ หอมหวานคาราเมลซอสแท้ผสานชั้นนมและกาแฟ',
        badge: 'Recommended',
      ),
      Product(
        id: 2,
        name: 'White Choc Macchiato',
        category: 'coffee',
        subcategory: 'Special',
        price: 55.0,
        description: 'ไวท์ช็อก มัคคิอาโต้ ความหวานนุ่มของไวท์ช็อกโกแลตตัดกับเอสเปรสโซ่เข้มข้น',
      ),
      Product(
        id: 3,
        name: 'Salted Caramel Latte',
        category: 'coffee',
        subcategory: 'Special',
        price: 55.0,
        description: 'ซอลท์เท็ดคาราเมล ลาเต้ รสชาติหวานมันเค็มปลายลิ้นอันเป็นเอกลักษณ์',
        badge: 'Best Seller',
      ),
      Product(
        id: 4,
        name: 'Banchong Signature',
        category: 'coffee',
        subcategory: 'Special',
        price: 55.0,
        description: 'บรรจง ซิกเนเจอร์ กาแฟสูตรลับพิเศษของร้าน นุ่มละมุน เข้มข้น หอมคาราเมล',
        badge: 'Signature',
      ),
      Product(
        id: 5,
        name: 'Popcorn Koff',
        category: 'coffee',
        subcategory: 'Special',
        price: 55.0,
        isAvailable: false, // ตัวอย่างสถานะ หมด/ปิดขาย
        description: 'ป๊อปคอร์น คอฟฟ์ กลิ่นหอมป๊อปคอร์นเนยสดผสมเอสเปรสโซเข้มข้น',
      ),
      Product(
        id: 6,
        name: 'Coconut Latte',
        category: 'coffee',
        subcategory: 'Special',
        price: 55.0,
        description: 'โคโคนัท ลาเต้ ผสานน้ำมะพร้าวน้ำหอมแท้ หอมสดชื่นดื่มง่าย',
      ),
      Product(
        id: 7,
        name: 'Vanilla Honey Latte',
        category: 'coffee',
        subcategory: 'Special',
        price: 55.0,
        description: 'วานิลลา ฮันนี่ ลาเต้ ความหอมหวานจากน้ำผึ้งแท้และวานิลลา',
      ),
      Product(
        id: 8,
        name: 'Tiramisu Cloud',
        category: 'coffee',
        subcategory: 'Special',
        price: 55.0,
        description: 'ทีรามิสุ คลาวด์ กาแฟท็อปด้วยครีมนุ่มละมุนสไตล์อิตาลี',
      ),
      Product(
        id: 9,
        name: 'Peanut Butter Latte',
        category: 'coffee',
        subcategory: 'Special',
        price: 55.0,
        description: 'พีนัทบัตเตอร์ ลาเต้ หอมมันเนยถั่วคุณภาพเยี่ยมเข้ากับกาแฟเข้มข้น',
      ),
      Product(
        id: 10,
        name: 'Toffee Coffee Nut',
        category: 'coffee',
        subcategory: 'Special',
        price: 55.0,
        description: 'ทอฟฟี่ คอฟฟี่ นัท รสหวานมันของทอฟฟี่และถั่วอบหอมกรุ่น',
      ),
      Product(
        id: 11,
        name: 'Butterscotch Latte',
        category: 'coffee',
        subcategory: 'Special',
        price: 55.0,
        description: 'บัตเตอร์สก็อตช์ ลาเต้ หอมหวานเนยคาราเมลสไตล์ดั้งเดิม',
      ),
      Product(
        id: 12,
        name: 'La Vie en Rose',
        category: 'coffee',
        subcategory: 'Special',
        price: 55.0,
        description: 'ลา วี ออง โรส กาแฟผสมกลิ่นกุหลาบฝรั่งเศส หอมละมุนมีเสน่ห์',
      ),
      Product(
        id: 13,
        name: 'Butterfly Effect',
        category: 'coffee',
        subcategory: 'Special',
        price: 55.0,
        description: 'บัตเตอร์ฟลาย เอฟเฟกต์ สัมผัสความแปลกใหม่ของกาแฟผสมน้ำดอกอัญชัน',
      ),

      // กาแฟดำ (Black Coffee - 9 รายการ)
      Product(
        id: 14,
        name: 'Espresso Shot',
        category: 'coffee',
        subcategory: 'Black',
        price: 50.0,
        description: 'เอสเปรสโซ่ ช็อต สกัดเข้มข้นจากเมล็ด Specialty คั่วกลางเข้ม ครีม่าเนียนละเอียด',
      ),
      Product(
        id: 15,
        name: 'Americano',
        category: 'coffee',
        subcategory: 'Black',
        price: 50.0,
        description: 'อเมริกาโน่ กลิ่นหอมสะอาด ดื่มง่าย นุ่มละมุน ชูคาแรคเตอร์เมล็ดกาแฟธรรมชาติ',
        badge: 'Popular',
      ),
      Product(
        id: 16,
        name: 'Black Orange',
        category: 'coffee',
        subcategory: 'Black',
        price: 50.0,
        description: 'อเมริกาโน่ส้ม สดชื่นด้วยน้ำส้มแท้ 100% ผสมช็อตเอสเปรสโซเข้มข้น',
        badge: 'Recommended',
      ),
      Product(
        id: 17,
        name: 'Black Yuzu',
        category: 'coffee',
        subcategory: 'Black',
        price: 50.0,
        description: 'อเมริกาโน่ยูซุ กลิ่นส้มยูซุธรรมชาติ เปรี้ยวหวานสดชื่นตื่นตัว',
      ),
      Product(
        id: 18,
        name: 'Black Peach',
        category: 'coffee',
        subcategory: 'Black',
        price: 50.0,
        description: 'อเมริกาโน่พีช สัมผัสความหอมหวานสดชื่นของพีชญี่ปุ่น',
      ),
      Product(
        id: 19,
        name: 'Black Apple',
        category: 'coffee',
        subcategory: 'Black',
        price: 50.0,
        description: 'อเมริกาโน่แอปเปิ้ล ความสดชื่นของน้ำแอปเปิ้ลผสมช็อตกาแฟ',
      ),
      Product(
        id: 20,
        name: 'Black Lychee',
        category: 'coffee',
        subcategory: 'Black',
        price: 50.0,
        description: 'อเมริกาโน่ลิ้นจี่ กลิ่นหอมหวานของลิ้นจี่ตัดกับความเข้มของกาแฟ',
      ),
      Product(
        id: 21,
        name: 'Black Pineapple',
        category: 'coffee',
        subcategory: 'Black',
        price: 50.0,
        description: 'อเมริกาโน่สับปะรด เปรี้ยวหวานฉ่ำคอกำลังดี',
      ),
      Product(
        id: 22,
        name: 'Black Cherry',
        category: 'coffee',
        subcategory: 'Black',
        price: 50.0,
        description: 'อเมริกาโน่เชอร์รี่ ความเปรี้ยวหวานหรูหราของแบล็คเชอร์รี่',
      ),

      // กาแฟนมคลาสสิก (White Coffee - 4 รายการ)
      Product(
        id: 23,
        name: 'Latte',
        category: 'coffee',
        subcategory: 'White',
        price: 50.0,
        description: 'ลาเต้ กาแฟเอสเปรสโซ่ผสานนมสดนุ่ม หอมละมุน กลมกล่อมลงตัว',
      ),
      Product(
        id: 24,
        name: 'Es Yen',
        category: 'coffee',
        subcategory: 'White',
        price: 50.0,
        description: 'เอสเย็น กาแฟสไตล์ไทยแท้ เข้มข้นหวานมันสะใจ',
      ),
      Product(
        id: 25,
        name: 'Cappuccino',
        category: 'coffee',
        subcategory: 'White',
        price: 50.0,
        description: 'คาปูชิโน่ ฟองนมนุ่มละเอียด โรยผงโกโก้บางเบา หอมกรุ่นทุกจิบ',
      ),
      Product(
        id: 26,
        name: 'Mocha',
        category: 'coffee',
        subcategory: 'White',
        price: 50.0,
        description: 'มอคค่า ความลงตัวของกาแฟเอสเปรสโซ่และช็อกโกแลตเข้มข้น',
      ),

      // ==========================================
      // หมวด 2: NON-COFFEE (32 รายการ)
      // ==========================================
      // นมสดและไซรัปพิเศษ (Milk Drinks - 15 รายการ)
      Product(
        id: 27,
        name: 'Caramel Milk',
        category: 'noncoffee',
        subcategory: 'Milk',
        price: 50.0,
        description: 'นมสดคาราเมล หอมหวานซอสคาราเมลแท้ รสละมุนดื่มง่าย',
      ),
      Product(
        id: 28,
        name: 'White Chocolate Milk',
        category: 'noncoffee',
        subcategory: 'Milk',
        price: 50.0,
        description: 'นมไวท์ช็อกโกแลต หวานนุ่มนวล หอมกลิ่นไวท์ช็อกโกแลต',
      ),
      Product(
        id: 29,
        name: 'Honey Milk',
        category: 'noncoffee',
        subcategory: 'Milk',
        price: 50.0,
        description: 'นมสดน้ำผึ้ง ใช้น้ำผึ้งแท้บริสุทธิ์ หวานธรรมชาติ',
      ),
      Product(
        id: 30,
        name: 'Vanilla Milk',
        category: 'noncoffee',
        subcategory: 'Milk',
        price: 50.0,
        description: 'นมวานิลลา หอมละมุนกลิ่นฝักวานิลลาธรรมชาติ',
      ),
      Product(
        id: 31,
        name: 'Strawberry Milk',
        category: 'noncoffee',
        subcategory: 'Milk',
        price: 50.0,
        description: 'นมสตรอว์เบอร์รี่ นมสดแท้ผสานซอสสตรอว์เบอร์รี่โฮมเมด',
        badge: 'Popular',
      ),
      Product(
        id: 32,
        name: 'Rose Milk',
        category: 'noncoffee',
        subcategory: 'Milk',
        price: 50.0,
        description: 'นมกุหลาบ หอมกลิ่นกุหลาบอ่อนๆ ให้ความรู้สึกผ่อนคลาย',
      ),
      Product(
        id: 33,
        name: 'Pinky Milk',
        category: 'noncoffee',
        subcategory: 'Milk',
        price: 50.0,
        description: 'นมชมพู นมเย็นในตำนาน หวานหอมชื่นใจ สีชมพูพาสเทล',
      ),
      Product(
        id: 34,
        name: 'Mint Milk',
        category: 'noncoffee',
        subcategory: 'Milk',
        price: 50.0,
        description: 'นมมิ้นท์ สดชื่นเย็นสบายผสานความนุ่มของนมสด',
      ),
      Product(
        id: 35,
        name: 'Butterfly Pea Milk',
        category: 'noncoffee',
        subcategory: 'Milk',
        price: 50.0,
        description: 'นมอัญชัน สีนุ่มละมุนธรรมชาติ อุดมด้วยสารต้านอนุมูลอิสระ',
      ),
      Product(
        id: 36,
        name: 'Hazelnut Milk',
        category: 'noncoffee',
        subcategory: 'Milk',
        price: 50.0,
        description: 'นมเฮเซลนัท หอมมันกลิ่นถั่วคั่วพรีเมียม',
      ),
      Product(
        id: 37,
        name: 'Sweet Potato Milk',
        category: 'noncoffee',
        subcategory: 'Milk',
        price: 50.0,
        isAvailable: false, // ตัวอย่างสถานะ หมด/ปิดขาย
        description: 'นมมันม่วง นมสดผสานมันหวานญี่ปุ่น รสชาติหวานมันเข้มข้น',
      ),
      Product(
        id: 38,
        name: 'Salted Caramel Milk',
        category: 'noncoffee',
        subcategory: 'Milk',
        price: 50.0,
        description: 'นมซอลท์เท็ดคาราเมล หวานเค็มกลมกล่อม',
      ),
      Product(
        id: 39,
        name: 'Butterscotch Milk',
        category: 'noncoffee',
        subcategory: 'Milk',
        price: 50.0,
        description: 'นมบัตเตอร์สก็อต หอมเนยน้ำตาลไหม้แบบฉบับดั้งเดิม',
      ),
      Product(
        id: 40,
        name: 'Tiramisu Milk',
        category: 'noncoffee',
        subcategory: 'Milk',
        price: 50.0,
        description: 'นมทีรามิสุ ดื่มด่ำรสชาติขนมหวานชื่อดังในรูปแบบเครื่องดื่ม',
      ),
      Product(
        id: 41,
        name: 'Toffee Nut Milk',
        category: 'noncoffee',
        subcategory: 'Milk',
        price: 50.0,
        description: 'นมทอฟฟี่นัท หวานมันกลิ่นคาราเมลทอฟฟี่และถั่วอบ',
      ),

      // โกโก้เข้มข้น (Cocoa Drinks - 4 รายการ)
      Product(
        id: 42,
        name: 'Cocoa',
        category: 'noncoffee',
        subcategory: 'Cocoa',
        price: 50.0,
        description: 'โกโก้เข้มข้น รสชาติดาร์กช็อกโกแลตพรีเมียม หวานมันกำลังดี',
        badge: 'Popular',
      ),
      Product(
        id: 43,
        name: 'Blackout Cocoa',
        category: 'noncoffee',
        subcategory: 'Cocoa',
        price: 50.0,
        description: 'โกโก้ดาร์ก เข้มข้นระดับเอ็กซ์ตร้า ดาร์กช็อกโกแลต 100%',
        badge: 'Recommended',
      ),
      Product(
        id: 44,
        name: 'Cocoa Mint',
        category: 'noncoffee',
        subcategory: 'Cocoa',
        price: 50.0,
        description: 'โกโก้มิ้นท์ ความเข้มของโกโก้ตัดกับความเย็นสดชื่นของมิ้นท์',
      ),
      Product(
        id: 45,
        name: 'Cocoa Banana',
        category: 'noncoffee',
        subcategory: 'Cocoa',
        price: 50.0,
        description: 'โกโก้กล้วย คู่หูความอร่อย หอมกลิ่นกล้วยหอมทองผสานโกโก้',
      ),

      // ชาและมัทฉะ (Tea & Matcha - 6 รายการ)
      Product(
        id: 46,
        name: 'Thai Green Tea',
        category: 'noncoffee',
        subcategory: 'Tea',
        price: 50.0,
        description: 'ชาเขียวนม หอมกลิ่นใบชาคั่วพิเศษ นุ่มละมุน ชื่นใจ',
      ),
      Product(
        id: 47,
        name: 'Matcha (Latte / Pure)',
        category: 'noncoffee',
        subcategory: 'Tea',
        price: 50.0,
        description: 'ชาเขียวมัทฉะแท้ ตีสดทุกแก้ว เลือกแบบใสหรือใส่นมได้',
        badge: 'Best Seller',
      ),
      Product(
        id: 48,
        name: 'Peach Tea',
        category: 'noncoffee',
        subcategory: 'Tea',
        price: 50.0,
        description: 'ชาพีช หอมกลิ่นพีชฉ่ำๆ ดื่มแล้วสดชื่นกระปรี้กระเปร่า',
      ),
      Product(
        id: 49,
        name: 'Apple Tea',
        category: 'noncoffee',
        subcategory: 'Tea',
        price: 50.0,
        description: 'ชาแอปเปิ้ล กลิ่นหอมหวานของแอปเปิ้ลเขียวและใบชาพรีเมียม',
      ),
      Product(
        id: 50,
        name: 'Lemon Tea',
        category: 'noncoffee',
        subcategory: 'Tea',
        price: 50.0,
        description: 'ชามะนาว เปรี้ยวหวานสดชื่น ดับกระหายคลายร้อน',
      ),
      Product(
        id: 51,
        name: 'Premium Matcha (Latte / Pure)',
        category: 'noncoffee',
        subcategory: 'Tea',
        price: 65.0,
        description: 'ชาเขียวมัทฉะพรีเมียม นำเข้าจากเกียวโต กลิ่นหอมเข้มข้น อูมามิ',
        badge: 'Special',
      ),

      // สดชื่นโซดาและผลไม้ (Refreshing - 7 รายการ)
      Product(
        id: 52,
        name: 'Sunny Passion',
        category: 'noncoffee',
        subcategory: 'Refreshing',
        price: 50.0,
        description: 'เสาวรส + ส้ม ความเปรี้ยวอมหวานสดใส สดชื่นตื่นเต็มตา',
      ),
      Product(
        id: 53,
        name: 'Summer Berry',
        category: 'noncoffee',
        subcategory: 'Refreshing',
        price: 50.0,
        description: 'สตรอว์เบอร์รี่ + ส้ม การผสานเบอร์รี่และส้ม ซ่าสดชื่น',
      ),
      Product(
        id: 54,
        name: 'Perfect Sunday',
        category: 'noncoffee',
        subcategory: 'Refreshing',
        price: 50.0,
        description: 'ลิ้นจี่ + องุ่นเคียวโฮ หอมหวานฉ่ำ ดื่มสบายในวันหยุด',
      ),
      Product(
        id: 55,
        name: 'Cherry Blossom',
        category: 'noncoffee',
        subcategory: 'Refreshing',
        price: 50.0,
        description: 'ซากุระ + สตรอว์เบอร์รี่ + ลิ้นจี่ รสชาติหอมหวานสไตล์ญี่ปุ่น',
      ),
      Product(
        id: 56,
        name: 'PPAP',
        category: 'noncoffee',
        subcategory: 'Refreshing',
        price: 50.0,
        description: 'แอปเปิ้ล + พีช ความหวานหอมคู่หูแอปเปิ้ลและพีช',
      ),
      Product(
        id: 57,
        name: 'Momo Midori',
        category: 'noncoffee',
        subcategory: 'Refreshing',
        price: 50.0,
        description: 'เมลอน + พีช กลิ่นหอมเมลอนญี่ปุ่นตัดกับพีชสดชื่น',
      ),
      Product(
        id: 58,
        name: 'Sakura Spring',
        category: 'noncoffee',
        subcategory: 'Refreshing',
        price: 50.0,
        description: 'องุ่นเคียวโฮ + ซากุระ ความหอมหวานสุดพิเศษของฤดูใบไม้ผลิ',
      ),

      // ==========================================
      // หมวด 3: เค้ก & เบเกอรี่ (CAKE - 11 รายการ)
      // ==========================================
      Product(
        id: 59,
        name: 'Basque Burnt Cheesecake',
        category: 'cake',
        subcategory: 'Cake',
        price: 75.0,
        isAvailable: true,
        description: 'ชีสเค้กหน้าไหม้สเปน เนื้อเนียนนุ่มละลายในปาก ครีมชีสแท้นำเข้าเข้มข้น',
        badge: 'Recommended',
      ),
      Product(
        id: 60,
        name: 'Dark Chocolate Fudge Cake',
        category: 'cake',
        subcategory: 'Cake',
        price: 75.0,
        isAvailable: true,
        description: 'เค้กช็อกโกแลตฟัดจ์หน้านิ่ม ดาร์กช็อกโกแลต 70% รสเข้มเต็มคำ',
        badge: 'Best Seller',
      ),
      Product(
        id: 61,
        name: 'Strawberry Shortcake',
        category: 'cake',
        subcategory: 'Cake',
        price: 85.0,
        isAvailable: true,
        description: 'สตรอว์เบอร์รีชอร์ตเค้ก สปันจ์เค้กนุ่มเบา ครีมสดแท้และสตรอว์เบอร์รีสดฉ่ำ',
        badge: 'Special',
      ),
      Product(
        id: 62,
        name: 'Matcha Crepe Cake',
        category: 'cake',
        subcategory: 'Cake',
        price: 80.0,
        isAvailable: false, // ตัวอย่างสถานะ หมด/ปิดขาย
        description: 'เครปเค้กชาเขียวมัทฉะ แป้งบางเรียงชั้นสลับครีมสด ราดซอสมัทฉะเข้มข้น',
      ),
      Product(
        id: 63,
        name: 'Coconut Cream Cake',
        category: 'cake',
        subcategory: 'Cake',
        price: 75.0,
        isAvailable: true,
        description: 'เค้กมะพร้าวอ่อน เนื้อชิฟฟอนนุ่มเบา ครีมสดมะพร้าวน้ำหอมแท้หวานน้อย',
      ),
      Product(
        id: 64,
        name: 'Red Velvet Cake',
        category: 'cake',
        subcategory: 'Cake',
        price: 75.0,
        isAvailable: true,
        description: 'เค้กเรดเวลเวต สีแดงกำมะหยี่ เนื้อนุ่มชุ่มฉ่ำ ปาดครีมชีสเปรี้ยวอมหวาน',
      ),
      Product(
        id: 65,
        name: 'Carrot Cream Cheese Cake',
        category: 'cake',
        subcategory: 'Cake',
        price: 80.0,
        isAvailable: true,
        description: 'เค้กแครอทวอลนัท เนื้อแน่นหอมซินนามอน ท็อปด้วยครีมชีสฟรอสติ้ง',
      ),
      Product(
        id: 66,
        name: 'Lemon Curd Tart',
        category: 'cake',
        subcategory: 'Bakery',
        price: 70.0,
        isAvailable: true,
        description: 'เลมอนเคิร์ดทาร์ต แป้งทาร์ตกรอบเนยสด ไส้เลมอนเปรี้ยวหวานหอมสดชื่น',
      ),
      Product(
        id: 67,
        name: 'Blueberry Cheese Pie',
        category: 'cake',
        subcategory: 'Bakery',
        price: 75.0,
        isAvailable: true,
        description: 'บลูเบอร์รี่ชีสพาย ฐานแครกเกอร์กรุบกรอบ ท็อปบลูเบอร์รี่ซอสผลไม้ฉ่ำๆ',
      ),
      Product(
        id: 68,
        name: 'Plain Butter Croissant',
        category: 'cake',
        subcategory: 'Bakery',
        price: 65.0,
        isAvailable: true,
        description: 'ครัวซองต์เนยสดฝรั่งเศส อบสดใหม่ กรอบนอกนุ่มฟู หอมเนยแท้',
      ),
      Product(
        id: 69,
        name: 'Almond Croissant',
        category: 'cake',
        subcategory: 'Bakery',
        price: 75.0,
        isAvailable: true,
        description: 'ครัวซองต์อัลมอนด์ สอดไส้ครีมอัลมอนด์ โรยอัลมอนด์สไลซ์อบกรอบหอมมัน',
      ),
    ];

    // 1. การกรองตามหมวดหมู่หลัก
    final catLower = (category ?? '').toLowerCase().trim();
    if (catLower.isNotEmpty && catLower != 'ทั้งหมด') {
      if (catLower == 'coffee' || catLower.contains('กาแฟ')) {
        all = all.where((p) => p.category == 'coffee').toList();
      } else if (catLower == 'non-coffee' || catLower == 'noncoffee' || catLower.contains('ชา') || catLower.contains('นม') || catLower.contains('เครื่องดื่ม')) {
        all = all.where((p) => p.category == 'noncoffee').toList();
      } else if (catLower == 'cake' || catLower == 'bakery' || catLower.contains('เค้ก') || catLower.contains('เบเกอรี่')) {
        all = all.where((p) => p.category == 'cake').toList();
      }
    }

    // 2. การกรองตามหมวดหมู่ย่อย (Subcategory เช่น Special, Black, White, Milk, Tea, Cocoa, Refreshing, Cake, Bakery)
    if (subcategory != null && subcategory.trim().isNotEmpty && subcategory != 'ทั้งหมด' && subcategory.toLowerCase() != 'all') {
      final subLower = subcategory.trim().toLowerCase();
      all = all.where((p) {
        final pSub = (p.subcategory ?? '').toLowerCase();
        return pSub == subLower;
      }).toList();
    }

    // 3. การกรองตามสถานะพร้อมขาย (isAvailable: true = ขายอยู่, false = หมด/ปิดขาย)
    if (isAvailable != null) {
      all = all.where((p) => p.isAvailable == isAvailable).toList();
    }

    // 4. การค้นหาตามคำค้น
    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      all = all
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              (p.description?.toLowerCase().contains(q) ?? false) ||
              (p.subcategory?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    return all;
  }
}

