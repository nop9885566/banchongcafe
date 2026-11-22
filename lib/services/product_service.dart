import '../models/product.dart';
import 'mock_data.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final List<Product> _products = List.from(MockData.prototypeProducts);

  Future<List<Product>> getProducts({String? category, String? search}) async {
    // จำลอง Network Delay เล็กน้อยสำหรับ async simulation
    await Future.delayed(const Duration(milliseconds: 50));

    return _products.where((p) {
      if (!p.isAvailable) return false;
      if (category != null && category.isNotEmpty && category != 'ทั้งหมด') {
        if (p.category.toLowerCase() != category.toLowerCase()) return false;
      }
      if (search != null && search.trim().isNotEmpty) {
        final query = search.trim().toLowerCase();
        final matchName = p.name.toLowerCase().contains(query);
        final matchDesc = p.description?.toLowerCase().contains(query) ?? false;
        if (!matchName && !matchDesc) return false;
      }
      return true;
    }).toList();
  }

  Future<Product?> getProductById(int id) async {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<String> getCategories() {
    return const ['Coffee', 'Non-Coffee', 'Cake'];
  }
}
