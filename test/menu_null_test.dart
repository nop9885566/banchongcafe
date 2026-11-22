import 'package:flutter_test/flutter_test.dart';
import 'package:moblieapp/services/api_service.dart';
import 'package:moblieapp/models/product.dart';

void main() {
  test('ApiService getProducts returns valid non-null strings', () async {
    final api = ApiService();
    for (var cat in ['Coffee', 'Non-Coffee', 'Cake']) {
      final products = await api.getProducts(category: cat);
      expect(products.isNotEmpty, true);
      for (var p in products) {
        expect(p.name, isNotNull);
        expect(p.category, isNotNull);
        expect(p.isAvailable, isNotNull);
        expect(p.displayCategory, isNotNull);
        expect(p.availabilityText, isNotNull);
      }
    }
  });
}
