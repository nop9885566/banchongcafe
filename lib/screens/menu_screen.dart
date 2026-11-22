import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
import '../services/storage_service.dart';
import 'queue_screen.dart';
import '../widgets/mobile_container.dart';
import '../widgets/app_header.dart';
import '../widgets/app_drawer.dart';
import '../widgets/product_image.dart';
import 'product_detail_sheet.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'Coffee'; // Default category
  String _selectedSubcategory = 'ทั้งหมด';
  bool? _availabilityFilter; // null = ทั้งหมด, true = ขายอยู่, false = หมด/ปิดขาย
  List<Product> _products = [];
  bool _isLoading = true;
  int? _activeOrderId;

  final List<String> _categories = const ['Coffee', 'Non-Coffee', 'Cake'];

  Map<String, List<String>> get _subcategoriesByCategory => {
    'Coffee': const ['ทั้งหมด', 'Special', 'Black', 'White'],
    'Non-Coffee': const ['ทั้งหมด', 'Milk', 'Tea', 'Cocoa', 'Refreshing'],
    'Cake': const ['ทั้งหมด', 'Cake', 'Bakery'],
  };

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _checkActiveOrder();
  }

  Future<void> _checkActiveOrder() async {
    final activeId = await StorageService().loadActiveOrderId();
    if (mounted) {
      setState(() {
        _activeOrderId = activeId;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final list = await _apiService.getProducts(
        category: _selectedCategory,
        subcategory: _selectedSubcategory == 'ทั้งหมด' ? null : _selectedSubcategory,
        isAvailable: _availabilityFilter,
        search: _searchController.text.trim(),
      );
      if (mounted) {
        setState(() {
          _products = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _products = [];
          _isLoading = false;
        });
      }
    }
  }

  void _onCategoryChanged(String category) {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
      _selectedSubcategory = 'ทั้งหมด';
    });
    _loadProducts();
  }

  void _onSubcategoryChanged(String sub) {
    if (_selectedSubcategory == sub) return;
    setState(() {
      _selectedSubcategory = sub;
    });
    _loadProducts();
  }

  void _onAvailabilityFilterChanged(bool? filter) {
    if (_availabilityFilter == filter) return;
    setState(() {
      _availabilityFilter = filter;
    });
    _loadProducts();
  }

  void _openProductDetail(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ProductDetailSheet(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartService = CartService();

    return MobileContainer(
      appBar: const AppHeader(title: 'เมนูเครื่องดื่ม & เค้ก'),
      drawer: const AppDrawer(currentRoute: '/menu'),
      child: Column(
        children: [
          // Active Order Banner (ถ้าเคยสั่งไว้และรีเฟรชกลับมา)
          if (_activeOrderId != null)
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QueueScreen(orderId: _activeOrderId!),
                  ),
                ).then((_) => _checkActiveOrder());
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: AppColors.primaryDarkGreen,
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'คุณมีออเดอร์ที่กำลังดำเนินการ (#$_activeOrderId)',
                        style: GoogleFonts.notoSansThai(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      'แตะดูสถานะคิว ›',
                      style: GoogleFonts.notoSansThai(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 1. Search Bar & Category Filter Tabs
          _buildFilterHeader(),

          // 2. Products Grid
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryDarkGreen),
                  )
                : _products.isEmpty
                    ? _buildEmptyState()
                    : _buildProductGrid(),
          ),

          // 3. Floating Bottom Cart Bar (if items in cart)
          ListenableBuilder(
            listenable: cartService,
            builder: (context, _) {
              if (cartService.isEmpty) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/cart'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDarkGreen,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.lightGreen.withAlpha(80),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${cartService.itemCount} รายการ',
                            style: GoogleFonts.notoSansThai(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'ดูตะกร้าสินค้า',
                            style: GoogleFonts.notoSansThai(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        Text(
                          '฿${cartService.totalAmount.toStringAsFixed(0)}',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.white),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterHeader() {
    final subcategories = _subcategoriesByCategory[_selectedCategory] ?? const ['ทั้งหมด'];

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Search Bar
          TextField(
            controller: _searchController,
            onChanged: (_) => _loadProducts(),
            decoration: InputDecoration(
              hintText: 'ค้นหาเมนูเครื่องดื่มและเค้ก...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.secondaryText, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: AppColors.secondaryText),
                      onPressed: () {
                        _searchController.clear();
                        _loadProducts();
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primaryDarkGreen, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 2. Main Category Tabs (Coffee, Non-Coffee, Cake)
          Row(
            children: _categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    onTap: () => _onCategoryChanged(cat),
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryDarkGreen : AppColors.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryDarkGreen : AppColors.border,
                        ),
                        boxShadow: isSelected ? AppShadows.card : null,
                      ),
                      child: Center(
                        child: Text(
                          cat,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColors.white : AppColors.darkText,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // 3. Subcategories Horizontal Scroll Chips (Special, Black, White, Milk, Tea, Cocoa, etc.)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: subcategories.map((sub) {
                final isSelected = _selectedSubcategory == sub;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: () => _onSubcategoryChanged(sub),
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.coffeeBrown
                            : AppColors.warmCream.withAlpha(90),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.coffeeBrown : AppColors.border,
                        ),
                      ),
                      child: Text(
                        sub,
                        style: GoogleFonts.notoSansThai(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.white : AppColors.darkText,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),

          // 4. Status Filter Bar: สถานะพร้อมขาย (ทั้งหมด / ขายอยู่ / หมด-ปิดขาย)
          Row(
            children: [
              Text(
                'พบ ${_products.length} รายการ',
                style: GoogleFonts.notoSansThai(
                  fontSize: 11,
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildStatusFilterChip(label: 'ทั้งหมด', value: null),
                      const SizedBox(width: 4),
                      _buildStatusFilterChip(
                        label: 'ขายอยู่',
                        value: true,
                        activeColor: AppColors.primaryDarkGreen,
                      ),
                      const SizedBox(width: 4),
                      _buildStatusFilterChip(
                        label: 'หมด/ปิดขาย',
                        value: false,
                        activeColor: AppColors.errorRed,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterChip({
    required String label,
    required bool? value,
    Color activeColor = AppColors.coffeeBrown,
  }) {
    final isSelected = _availabilityFilter == value;
    return InkWell(
      onTap: () => _onAvailabilityFilterChanged(value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withAlpha(25) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.border,
            width: isSelected ? 1.2 : 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value != null) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: value ? AppColors.primaryDarkGreen : AppColors.errorRed,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.notoSansThai(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return RefreshIndicator(
      color: AppColors.primaryDarkGreen,
      onRefresh: _loadProducts,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 14,
          childAspectRatio: 0.65,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return _buildProductCard(product);
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final isAvailable = product.isAvailable;

    return GestureDetector(
      onTap: () => _openProductDetail(product),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isAvailable ? 1.0 : 0.72,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppShadows.card,
            border: Border.all(
              color: isAvailable ? AppColors.border : AppColors.errorRed.withAlpha(60),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1:1 Image with Sold-out Overlay if not available
              AspectRatio(
                aspectRatio: 1.0,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ProductImage(
                        imagePath: product.image,
                        category: product.category,
                        borderRadius: 18,
                      ),
                    ),
                    if (!isAvailable)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(90),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.errorRed,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(80),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'สินค้าหมด',
                                style: GoogleFonts.notoSansThai(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: GoogleFonts.notoSansThai(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isAvailable ? AppColors.darkText : AppColors.secondaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              if (product.subcategory != null && product.subcategory!.trim().isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.warmCream,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Text(
                                    product.subcategory ?? '',
                                    style: GoogleFonts.inter(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.coffeeBrown,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                              ],
                              Expanded(
                                child: Text(
                                  isAvailable ? 'พร้อมขาย' : 'หมด/ปิดขาย',
                                  style: GoogleFonts.notoSansThai(
                                    fontSize: 10,
                                    color: isAvailable ? AppColors.primaryDarkGreen : AppColors.errorRed,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Price & Add button (+)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '฿${product.price.toInt()}',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isAvailable ? AppColors.coffeeBrown : AppColors.secondaryText,
                            ),
                          ),
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: isAvailable ? AppColors.primaryDarkGreen : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isAvailable ? Icons.add : Icons.block_rounded,
                              size: 17,
                              color: isAvailable ? AppColors.white : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 52, color: AppColors.secondaryText.withAlpha(120)),
          const SizedBox(height: 12),
          Text(
            'ไม่พบรายการเมนูที่ค้นหา',
            style: GoogleFonts.notoSansThai(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'ลองค้นหาด้วยคำอื่น หรือเลือกหมวดหมู่อื่น',
            style: GoogleFonts.notoSansThai(
              fontSize: 13,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
