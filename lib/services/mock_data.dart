import '../models/product.dart';
import '../models/cart_item.dart';

class MockData {
  static const List<ToppingItem> standardToppings = [
    ToppingItem(id: 'extra_shot', name: 'Extra Shot', price: 20.0),
    ToppingItem(id: 'oat_milk', name: 'Oat Milk', price: 15.0),
    ToppingItem(id: 'whipped_cream', name: 'Whipped Cream', price: 15.0),
    ToppingItem(id: 'konjac_pearl', name: 'Konjac Pearl', price: 5.0),
  ];

  static const List<String> standardTemperatures = ['ร้อน', 'เย็น'];
  static const List<String> standardSweetness = ['หวาน 100%', 'หวาน 50%', 'ไม่หวาน 0%'];

  // Prototype Mock Products (ตรงตามที่กำหนดใน Requirement ข้อ 4 และ 5)
  static final List<Product> prototypeProducts = [
    // --- Coffee ---
    Product(
      id: 1,
      name: 'Espresso Shot',
      category: 'Coffee',
      price: 50.0,
      description: 'เอสเปรสโซ่ช็อตเข้มข้น สกัดจากเมล็ดกาแฟ Specialty คั่วกลางเข้ม ให้รสชาติหนักแน่น',
      image: '/assets/images/products/coffee/espresso.jpg',
    ),
    Product(
      id: 2,
      name: 'Americano',
      category: 'Coffee',
      price: 55.0,
      description: 'อเมริกาโน่ กลิ่นหอมสะอาด ดื่มง่าย นุ่มละมุน ชูคาแรคเตอร์เมล็ดกาแฟธรรมชาติ',
      image: '/assets/images/products/coffee/americano.jpg',
    ),
    Product(
      id: 3,
      name: 'Latte',
      category: 'Coffee',
      price: 60.0,
      description: 'ลาเต้ กาแฟเอสเปรสโซ่ผสานนมสดนุ่ม หอมละมุน กลมกล่อมลงตัว',
      image: '/assets/images/products/coffee/latte.jpg',
    ),
    Product(
      id: 4,
      name: 'Cappuccino',
      category: 'Coffee',
      price: 60.0,
      description: 'คาปูชิโน่ ฟองนมนุ่มละเอียด โรยผงโกโก้บางเบา หอมกรุ่นทุกจิบ',
      image: '/assets/images/products/coffee/cappuccino.jpg',
    ),
    Product(
      id: 5,
      name: 'Caramel Macchiato',
      category: 'Coffee',
      price: 65.0,
      description: 'คาราเมล มัคคิอาโต้ หอมหวานซอสคาราเมลแท้ผสานชั้นนมและกาแฟ',
      image: '/assets/images/products/coffee/caramel_macchiato.jpg',
    ),
    Product(
      id: 6,
      name: 'White Choc Macchiato',
      category: 'Coffee',
      price: 65.0,
      description: 'ไวท์ช็อก มัคคิอาโต้ ความหวานนุ่มของไวท์ช็อกโกแลตตัดกับเอสเปรสโซ่เข้มข้น',
      image: '/assets/images/products/coffee/white_choc.jpg',
    ),
    Product(
      id: 7,
      name: 'Salted Caramel Latte',
      category: 'Coffee',
      price: 65.0,
      description: 'ซอลท์เท็ดคาราเมล ลาเต้ รสชาติหวานมันเค็มปลายลิ้นที่เป็นเอกลักษณ์',
      image: '/assets/images/products/coffee/salted_caramel.jpg',
    ),
    Product(
      id: 8,
      name: 'Banchong Signature',
      category: 'Coffee',
      price: 70.0,
      badge: 'Signature',
      description: 'บรรจง ซิกเนเจอร์ กาแฟสูตรพิเศษของทางร้าน สกัดอย่างพิถีพิถัน ละมุน เข้มข้น',
      image: '/assets/images/products/coffee/signature.jpg',
    ),

    // --- Non-Coffee ---
    Product(
      id: 9,
      name: 'Matcha Latte',
      category: 'Non-Coffee',
      price: 65.0,
      badge: 'Special',
      description: 'มัทฉะ ลาเต้ ชาเขียวมัทฉะแท้เข้มข้น ตีฟองนุ่ม ผสานนมสดสดชื่น',
      image: '/assets/images/products/non-coffee/matcha.jpg',
    ),
    Product(
      id: 10,
      name: 'Cocoa',
      category: 'Non-Coffee',
      price: 60.0,
      description: 'โกโก้เข้มข้น รสชาติดาร์กช็อกโกแลตพรีเมียม หวานมันกำลังดี',
      image: '/assets/images/products/non-coffee/cocoa.jpg',
    ),
    Product(
      id: 11,
      name: 'Thai Tea',
      category: 'Non-Coffee',
      price: 55.0,
      description: 'ชาไทยคลาสสิก หอมใบชาแท้คั่วพิเศษ สีส้มทอง รสชาติเข้มข้น',
      image: '/assets/images/products/non-coffee/thai_tea.jpg',
    ),
    Product(
      id: 12,
      name: 'Green Tea',
      category: 'Non-Coffee',
      price: 55.0,
      description: 'ชาเขียวนม หอมกลิ่นมะลิอ่อนๆ นุ่มละมุน ชื่นใจ',
      image: '/assets/images/products/non-coffee/green_tea.jpg',
    ),
    Product(
      id: 13,
      name: 'Strawberry Milk',
      category: 'Non-Coffee',
      price: 65.0,
      description: 'สตรอว์เบอร์รีมิลค์ นมสดผสานซอสสตรอว์เบอร์รีโฮมเมดพร้อมเนื้อผลไม้',
      image: '/assets/images/products/non-coffee/strawberry_milk.jpg',
    ),
    Product(
      id: 14,
      name: 'Italian Soda',
      category: 'Non-Coffee',
      price: 55.0,
      description: 'อิตาเลียนโซดา ซ่าสดชื่น คลายร้อน พร้อมกลิ่นผลไม้หอมหวาน',
      image: '/assets/images/products/non-coffee/soda.jpg',
    ),

    // --- Cake ---
    Product(
      id: 15,
      name: 'Basque Cheesecake',
      category: 'Cake',
      price: 95.0,
      badge: 'Recommended',
      availableOptions: const [],
      description: 'ชีสเค้กหน้าไหม้สไตล์บาสก์ เนื้อครีมมี่นุ่มละมุน หอมกลิ่นคาราเมลไหม้',
      image: '/assets/images/products/cake/cheesecake.jpg',
    ),
    Product(
      id: 16,
      name: 'Chocolate Cake',
      category: 'Cake',
      price: 95.0,
      availableOptions: const [],
      description: 'ช็อกโกแลตฟัดจ์เค้ก เข้มข้น เนื้อเค้กชุ่มฉ่ำ สอดไส้กานาชดาร์กช็อกโกแลต',
      image: '/assets/images/products/cake/chocolate_cake.jpg',
    ),
    Product(
      id: 17,
      name: 'Coconut Cake',
      category: 'Cake',
      price: 90.0,
      availableOptions: const [],
      description: 'เค้กมะพร้าวอ่อน เนื้อชิฟฟอนนุ่มเบา ครีมสดมะพร้าวน้ำหอมแท้',
      image: '/assets/images/products/cake/coconut_cake.jpg',
    ),
    Product(
      id: 18,
      name: 'Strawberry Cake',
      category: 'Cake',
      price: 105.0,
      badge: 'Special',
      availableOptions: const [],
      description: 'สตรอว์เบอร์รีชอร์ตเค้ก เนื้อสปันจ์นุ่ม ท็อปด้วยสตรอว์เบอร์รีสดลูกโต',
      image: '/assets/images/products/cake/strawberry_cake.jpg',
    ),
    Product(
      id: 19,
      name: 'Homemade Cake',
      category: 'Cake',
      price: 90.0,
      availableOptions: const [],
      description: 'เค้กโฮมเมดประจำวัน อบสดใหม่ทุกเช้าจากเตาด้วยวัตถุดิบธรรมชาติ',
      image: '/assets/images/products/cake/homemade_cake.jpg',
    ),
  ];
}
