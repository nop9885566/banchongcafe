import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../services/mock_data.dart';
import '../services/cart_service.dart';
import '../widgets/product_image.dart';

class ProductDetailSheet extends StatefulWidget {
  final Product product;

  const ProductDetailSheet({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<ProductDetailSheet> {
  // Drink Options (เริ่มต้นเป็น null เพราะเป็นตัวเลือกบังคับที่ลูกค้าต้องเลือกเอง)
  String? _selectedTemperature;
  String? _selectedSweetness;
  final Set<ToppingItem> _selectedToppings = {};

  int _quantity = 1;
  String? _validationError;

  bool get _isDrink => widget.product.isDrink;

  double get _unitPrice {
    double total = widget.product.price;
    for (var t in _selectedToppings) {
      total += t.price;
    }
    return total;
  }

  double get _totalPrice => _unitPrice * _quantity;

  void _onAddToCart() {
    setState(() => _validationError = null);

    if (_isDrink) {
      if (_selectedTemperature == null) {
        setState(() => _validationError = 'กรุณาเลือกอุณหภูมิ (ร้อน หรือ เย็น)');
        return;
      }
      if (_selectedSweetness == null) {
        setState(() => _validationError = 'กรุณาเลือกระดับความหวาน');
        return;
      }
    }

    final item = CartItem(
      product: widget.product,
      quantity: _quantity,
      temperature: _selectedTemperature,
      sweetness: _selectedSweetness,
      toppings: _selectedToppings.toList(),
    );

    CartService().addItem(item);

    // ปิด Modal Sheet
    Navigator.pop(context);

    // พาไปหน้าตะกร้าทันทีตาม User Flow ในข้อ 8
    Navigator.pushNamed(context, '/cart');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Product Header Info
                  _buildProductHeader(),

                  const SizedBox(height: 20),

                  // Drink Options: Temperature (Required)
                  if (_isDrink) ...[
                    _buildOptionSection(
                      title: 'อุณหภูมิ',
                      isRequired: true,
                      child: Row(
                        children: MockData.standardTemperatures.map((temp) {
                          final isSelected = _selectedTemperature == temp;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: _buildChoiceChip(
                                label: temp,
                                isSelected: isSelected,
                                icon: temp == 'ร้อน' ? Icons.local_fire_department_rounded : Icons.ac_unit_rounded,
                                onTap: () {
                                  setState(() {
                                    _selectedTemperature = temp;
                                    _validationError = null;
                                  });
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Drink Options: Sweetness (Required)
                    _buildOptionSection(
                      title: 'ระดับความหวาน',
                      isRequired: true,
                      child: Row(
                        children: MockData.standardSweetness.map((sweet) {
                          final isSelected = _selectedSweetness == sweet;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: _buildChoiceChip(
                                label: sweet,
                                isSelected: isSelected,
                                onTap: () {
                                  setState(() {
                                    _selectedSweetness = sweet;
                                    _validationError = null;
                                  });
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Drink Options: Toppings (Multi-select)
                    _buildOptionSection(
                      title: 'ท็อปปิ้งเพิ่มเติม (เลือกได้มากกว่า 1 อย่าง)',
                      isRequired: false,
                      child: Column(
                        children: MockData.standardToppings.map((topping) {
                          final isSelected = _selectedToppings.contains(topping);
                          return _buildToppingRow(topping, isSelected);
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Quantity Selector
                  _buildQuantitySection(),

                  // Inline Validation Error
                  if (_validationError != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.errorRed.withAlpha(80)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppColors.errorRed, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _validationError!,
                              style: GoogleFonts.notoSansThai(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.errorRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom Action Bar (Price & Add to Cart button)
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildProductHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image 1:1 (clean without text overlay)
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            width: 100,
            height: 100,
            child: ProductImage(
              imagePath: widget.product.image,
              category: widget.product.category,
              width: 100,
              height: 100,
              borderRadius: 18,
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product.name,
                style: GoogleFonts.notoSansThai(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (widget.product.subcategory != null && widget.product.subcategory!.trim().isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warmCream,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        widget.product.subcategory ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.coffeeBrown,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.product.isAvailable
                          ? AppColors.lightGreen.withAlpha(50)
                          : AppColors.errorRed.withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: widget.product.isAvailable
                            ? AppColors.primaryDarkGreen.withAlpha(80)
                            : AppColors.errorRed.withAlpha(80),
                      ),
                    ),
                    child: Text(
                      widget.product.isAvailable ? 'พร้อมขาย' : 'สินค้าหมด / ปิดขาย',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: widget.product.isAvailable
                            ? AppColors.primaryDarkGreen
                            : AppColors.errorRed,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '฿${widget.product.price.toInt()}',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.coffeeBrown,
                ),
              ),
              if (widget.product.description != null && widget.product.description!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  widget.product.description ?? '',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionSection({
    required String title,
    required bool isRequired,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: GoogleFonts.notoSansThai(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '* จำเป็น',
                style: GoogleFonts.notoSansThai(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.errorRed,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightGreen : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.sageGreen : AppColors.border,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected ? AppShadows.card : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: isSelected ? AppColors.primaryDarkGreen : AppColors.secondaryText,
              ),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.notoSansThai(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primaryDarkGreen : AppColors.darkText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToppingRow(ToppingItem topping, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedToppings.remove(topping);
            } else {
              _selectedToppings.add(topping);
            }
          });
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.lightGreen : AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.sageGreen : AppColors.border,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                color: isSelected ? AppColors.primaryDarkGreen : AppColors.secondaryText,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  topping.name,
                  style: GoogleFonts.notoSansThai(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: AppColors.darkText,
                  ),
                ),
              ),
              Text(
                '+฿${topping.price.toInt()}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.coffeeBrown,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantitySection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'จำนวน',
            style: GoogleFonts.notoSansThai(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                icon: const Icon(Icons.remove_circle_outline_rounded),
                color: AppColors.primaryDarkGreen,
                iconSize: 26,
              ),
              SizedBox(
                width: 36,
                child: Text(
                  '$_quantity',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _quantity++),
                icon: const Icon(Icons.add_circle_outline_rounded),
                color: AppColors.primaryDarkGreen,
                iconSize: 26,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
        border: const Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Total Price Summary
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ราคารวม',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 11,
                    color: AppColors.secondaryText,
                  ),
                ),
                Text(
                  '฿${_totalPrice.toInt()}',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.coffeeBrown,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),

            // Add to Cart Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.product.isAvailable ? _onAddToCart : null,
                icon: Icon(
                  widget.product.isAvailable ? Icons.shopping_bag_outlined : Icons.block_rounded,
                  size: 20,
                ),
                label: Text(
                  widget.product.isAvailable ? 'ใส่ตะกร้า' : 'สินค้าหมดชั่วคราว',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.product.isAvailable
                      ? AppColors.primaryDarkGreen
                      : AppColors.secondaryText,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: Colors.grey.shade400,
                  disabledForegroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
