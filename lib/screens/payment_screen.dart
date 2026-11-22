import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../models/order.dart';
import '../services/api_service.dart';
import '../widgets/mobile_container.dart';
import '../widgets/app_header.dart';
import '../widgets/app_drawer.dart';
import 'queue_screen.dart';

class PaymentScreen extends StatefulWidget {
  final OrderModel order;

  const PaymentScreen({super.key, required this.order});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  XFile? _pickedFile;
  Uint8List? _fileBytes;
  bool _isUploading = false;
  bool _isPayLaterLoading = false;

  Future<void> _pickSlipImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _pickedFile = picked;
          _fileBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ไม่สามารถเลือกรูปภาพได้: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _confirmUploadSlip() async {
    if (_fileBytes == null || _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเลือกไฟล์สลิปก่อนยืนยัน'),
          backgroundColor: AppColors.statusPending,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final result = await _apiService.uploadSlip(
        orderId: widget.order.id,
        bytes: _fileBytes!,
        filename: _pickedFile!.name,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'อัปโหลดสลิปเรียบร้อยแล้ว'),
            backgroundColor: AppColors.primaryDarkGreen,
          ),
        );

        // นำทางไปยังหน้าคิว (QueueScreen)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QueueScreen(
              orderId: widget.order.id,
              initialOrder: widget.order,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'เกิดข้อผิดพลาดในการอัปโหลด'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _handlePayLater() async {
    setState(() => _isPayLaterLoading = true);

    try {
      await _apiService.payLater(widget.order.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('บันทึกคำสั่งซื้อเรียบร้อยแล้ว'),
          backgroundColor: AppColors.primaryDarkGreen,
        ),
      );

      // นำทางไปยังหน้าคิว (QueueScreen)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QueueScreen(
            orderId: widget.order.id,
            initialOrder: widget.order,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QueueScreen(
            orderId: widget.order.id,
            initialOrder: widget.order,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isPayLaterLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // URL สำหรับ QR Code จาก Backend
    final qrUrl = '${_apiService.baseUrl.replaceAll('/api', '')}/images/my-qr.jpg';

    return MobileContainer(
      appBar: AppHeader(
        title: 'ชำระเงินออเดอร์ #${widget.order.id}',
        showBack: true,
        onBack: () => Navigator.pushNamedAndRemoveUntil(
          context,
          '/menu',
          (route) => false,
        ),
      ),
      drawer: const AppDrawer(currentRoute: '/cart'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 1. Payment Card Box (ตรงตาม payment.blade.php)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppShadows.card,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  // QR Icon Header
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.qr_code_2_rounded,
                      size: 34,
                      color: AppColors.primaryDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    'ชำระเงินออเดอร์ #${widget.order.id}',
                    style: GoogleFonts.notoSansThai(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'กรุณาสแกน QR Code ด้านล่างเพื่อชำระเงิน',
                    style: GoogleFonts.notoSansThai(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // QR Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF9F6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFD1C8C1),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            qrUrl,
                            width: 200,
                            height: 200,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // แสดงตัวจำลอง QR Code สวยงามกรณีออฟไลน์
                              return Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.qr_code_rounded,
                                      size: 100,
                                      color: AppColors.primaryDarkGreen,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'พร้อมเพย์ (PromptPay)',
                                      style: GoogleFonts.notoSansThai(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryDarkGreen,
                                      ),
                                    ),
                                    Text(
                                      'ร้านบรรจงคาเฟ่',
                                      style: GoogleFonts.notoSansThai(
                                        fontSize: 11,
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'สแกนผ่านแอปธนาคารทุกแห่ง',
                          style: GoogleFonts.notoSansThai(
                            fontSize: 11,
                            color: AppColors.secondaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Total Price Display
                  Text(
                    'ยอดชำระ: ฿${widget.order.totalPrice.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 20),

                  // Upload Slip Section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'แนบหลักฐานการโอนเงิน (สลิป)',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Pick File Container
                  InkWell(
                    onTap: _isUploading ? null : _pickSlipImage,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDFDFB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _fileBytes != null
                              ? AppColors.primaryDarkGreen
                              : AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: _fileBytes != null
                          ? Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    _fileBytes!,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _pickedFile?.name ?? 'สลิปโอนเงิน',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.darkText,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'แตะเพื่อเปลี่ยนรูปภาพ',
                                        style: GoogleFonts.notoSansThai(
                                          fontSize: 11,
                                          color: AppColors.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.primaryDarkGreen,
                                  size: 24,
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: AppColors.primaryDarkGreen,
                                  size: 24,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'เลือกรูปภาพสลิปจากเครื่อง',
                                  style: GoogleFonts.notoSansThai(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryDarkGreen,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Confirm Upload Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: (_isUploading || _fileBytes == null)
                          ? null
                          : _confirmUploadSlip,
                      icon: _isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : const Icon(Icons.cloud_upload_rounded, size: 20),
                      label: Text(
                        _isUploading ? 'กำลังอัปโหลด...' : 'ยืนยันการชำระเงิน',
                        style: GoogleFonts.notoSansThai(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDarkGreen,
                        foregroundColor: AppColors.white,
                        disabledBackgroundColor: AppColors.border,
                        disabledForegroundColor: AppColors.secondaryText,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Pay Later Button (ชำระเงินที่เคาน์เตอร์)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: (_isUploading || _isPayLaterLoading)
                          ? null
                          : _handlePayLater,
                      icon: _isPayLaterLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.coffeeBrown,
                              ),
                            )
                          : const Icon(
                              Icons.storefront_rounded,
                              size: 19,
                              color: AppColors.coffeeBrown,
                            ),
                      label: Text(
                        'จ่ายเงินภายหลัง (หน้าร้าน)',
                        style: GoogleFonts.notoSansThai(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.coffeeBrown,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.coffeeBrown),
                        backgroundColor: AppColors.warmCream.withAlpha(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Back to Menu Link
            TextButton.icon(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/menu',
                  (route) => false,
                );
              },
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: Text(
                'กลับไปหน้าเลือกเมนู',
                style: GoogleFonts.notoSansThai(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
