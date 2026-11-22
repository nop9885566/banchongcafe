import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/cart_item.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
import '../widgets/mobile_container.dart';
import '../widgets/app_header.dart';
import '../widgets/app_drawer.dart';
import 'payment_screen.dart';

class CartScreen extends StatefulWidget {
  final List<CartItem>? cartItems;
  final VoidCallback? onCartUpdated;

  const CartScreen({
    super.key,
    this.cartItems,
    this.onCartUpdated,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isLoading = false;

  List<CartItem> get _items =>
      widget.cartItems ?? CartService().items;

  double get _totalPrice =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (_items.isEmpty) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final order = await ApiService().createOrder(
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        items: _items,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      // Clear cart
      if (widget.cartItems != null) {
        widget.cartItems!.clear();
        widget.onCartUpdated?.call();
      } else {
        await CartService().clear();
      }

      if (!mounted) return;

      // นำทางไปหน้าชำระเงิน (PromptPay QR Code / แนบสลิป / ชำระหน้าร้าน)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            order: order,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาดในการส่งคำสั่งซื้อ: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MobileContainer(
      appBar: const AppHeader(title: 'ตะกร้าสินค้า'),
      drawer: const AppDrawer(currentRoute: '/cart'),
      child: _items.isEmpty ? _buildEmptyCart() : _buildCartContent(),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 48,
                color: AppColors.primaryDarkGreen,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'ตะกร้าว่างเปล่า',
              style: GoogleFonts.notoSansThai(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'เลือกเครื่องดื่มและเค้กที่คุณชื่นชอบได้เลย',
              style: GoogleFonts.notoSansThai(
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/menu'),
              icon: const Icon(Icons.coffee_rounded, size: 20),
              label: Text(
                'เลือกสั่งเมนู',
                style: GoogleFonts.notoSansThai(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDarkGreen,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent() {
    return Form(
      key: _formKey,
      child: Stack(
        children: [
          // Scrollable content
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              // Cart Items Section
              _buildSectionHeader(Icons.shopping_bag_outlined, 'รายการที่สั่ง'),
              const SizedBox(height: 10),
              _buildCartItemsList(),
              const SizedBox(height: 20),

              // Customer Info Section
              _buildSectionHeader(Icons.person_outline_rounded, 'ข้อมูลสำหรับรับสินค้า'),
              const SizedBox(height: 10),
              _buildCustomerForm(),
              const SizedBox(height: 20),



              // Price Summary
              _buildPriceSummary(),
            ],
          ),

          // Fixed Bottom Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildConfirmButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryDarkGreen, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.notoSansThai(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
        ),
      ],
    );
  }

  Widget _buildCartItemsList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.border),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _items.length,
        separatorBuilder: (context, _) => Divider(
          height: 1,
          color: AppColors.border,
          indent: 14,
          endIndent: 14,
        ),
        itemBuilder: (context, index) {
          final item = _items[index];
          final isDrink = item.product.category.toLowerCase() == 'coffee' ||
              item.product.category.toLowerCase() == 'non-coffee';

          return Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isDrink ? Icons.coffee_rounded : Icons.cake_rounded,
                    color: AppColors.primaryDarkGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: GoogleFonts.notoSansThai(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                        ),
                      ),
                      if (item.optionsSummary.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          item.optionsSummary,
                          style: GoogleFonts.notoSansThai(
                            fontSize: 12,
                            color: AppColors.secondaryText,
                            height: 1.3,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        '฿${item.unitPrice.toStringAsFixed(0)} / ชิ้น',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.sageGreen,
                        ),
                      ),
                    ],
                  ),
                ),

                // Qty Controls
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        _qtyButton(
                          icon: Icons.remove,
                          onTap: () {
                            setState(() {
                              if (item.quantity > 1) {
                                item.quantity--;
                              } else {
                                if (widget.cartItems != null) {
                                  widget.cartItems!.removeAt(index);
                                } else {
                                  CartService().removeItem(item.id);
                                }
                              }
                              widget.onCartUpdated?.call();
                            });
                          },
                          isDecrease: true,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            '${item.quantity}',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkText,
                            ),
                          ),
                        ),
                        _qtyButton(
                          icon: Icons.add,
                          onTap: () {
                            setState(() {
                              item.quantity++;
                              widget.onCartUpdated?.call();
                            });
                          },
                          isDecrease: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '฿${item.totalPrice.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.coffeeBrown,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _qtyButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDecrease,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isDecrease ? AppColors.border : AppColors.primaryDarkGreen,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: isDecrease ? AppColors.darkText : AppColors.white,
        ),
      ),
    );
  }

  Widget _buildCustomerForm() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'ชื่อลูกค้า *',
              hintText: 'ชื่อสำหรับเรียกตอนรับเครื่องดื่ม',
              prefixIcon: const Icon(Icons.badge_outlined, size: 20, color: AppColors.sageGreen),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'กรุณากรอกชื่อลูกค้า';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'เบอร์โทรศัพท์ *',
              hintText: 'สำหรับติดต่อเกี่ยวกับคำสั่งซื้อ',
              prefixIcon: const Icon(Icons.phone_outlined, size: 20, color: AppColors.sageGreen),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'กรุณากรอกเบอร์โทรศัพท์';
              }
              if (val.trim().length < 9) {
                return 'เบอร์โทรศัพท์ไม่ถูกต้อง';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _noteController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'หมายเหตุเพิ่มเติมถึงร้าน (ถ้ามี)',
              hintText: 'เช่น "ไม่ใส่หลอด", "ขอแยกน้ำแข็ง"',
              prefixIcon: Icon(Icons.chat_bubble_outline_rounded, size: 20, color: AppColors.sageGreen),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'รวมค่าสินค้า (${_items.length} รายการ)',
                style: GoogleFonts.notoSansThai(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
              ),
              Text(
                '฿${_totalPrice.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ค่าดำเนินการ',
                style: GoogleFonts.notoSansThai(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
              ),
              Text(
                'ฟรี',
                style: GoogleFonts.notoSansThai(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.sageGreen,
                ),
              ),
            ],
          ),
          Divider(height: 24, color: AppColors.border),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ยอดรวมทั้งสิ้น',
                style: GoogleFonts.notoSansThai(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              Text(
                '฿${_totalPrice.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDarkGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDarkGreen,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'ยืนยันการสั่งซื้อ • ฿${_totalPrice.toStringAsFixed(0)}',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
