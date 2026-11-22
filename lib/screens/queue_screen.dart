import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/order.dart';
import '../services/api_service.dart';
import '../widgets/mobile_container.dart';
import '../widgets/app_header.dart';
import '../widgets/app_drawer.dart';

class QueueScreen extends StatefulWidget {
  final int orderId;
  final OrderModel? initialOrder;

  const QueueScreen({
    super.key,
    required this.orderId,
    this.initialOrder,
  });

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  late OrderModel _order;
  bool _isRefreshing = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _order = widget.initialOrder ??
        OrderModel(
          id: widget.orderId,
          orderNumber: '#${widget.orderId}',
          queueNumber: widget.orderId,
          customerName: 'ลูกค้า',
          customerPhone: '',
          totalPrice: 0.0,
          status: 'PENDING',
        );
    if (widget.initialOrder == null) {
      _refreshStatus();
    }
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted && !_order.isCompleted && !_order.isCancelled) {
        _refreshStatus();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshStatus() async {
    setState(() => _isRefreshing = true);
    try {
      final updated = await ApiService().getOrder(widget.orderId);
      if (mounted) {
        setState(() => _order = updated);
      }
    } catch (e) {
      debugPrint('Error refreshing order: $e');
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ถ้า Order ถูกยกเลิก ให้แสดงหน้า CANCELLED
    if (_order.isCancelled) {
      return _buildCancelledView();
    }

    return MobileContainer(
      appBar: AppHeader(
        title: 'ติดตามสถานะคิว',
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryDarkGreen,
                    ),
                  )
                : const Icon(
                    Icons.refresh_rounded,
                    color: AppColors.primaryDarkGreen,
                  ),
            onPressed: _refreshStatus,
            tooltip: 'รีเฟรชสถานะ',
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/queue'),
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Queue Number Hero Card
          _buildQueueHeroCard(),
          const SizedBox(height: 18),

          // 2. Progress Stepper
          _buildProgressStepper(),
          const SizedBox(height: 18),



          // 4. Order Details
          _buildOrderDetails(),
          const SizedBox(height: 20),

          // 5. Return Home Button
          ElevatedButton.icon(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            icon: const Icon(Icons.home_outlined, size: 20),
            label: Text(
              'กลับหน้าหลัก / สั่งเพิ่มเติม',
              style: GoogleFonts.notoSansThai(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDarkGreen,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildQueueHeroCard() {
    final isReady = _order.isReady;
    final isCompleted = _order.isCompleted;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isReady || isCompleted
              ? [const Color(0xFF1F493A), const Color(0xFF2C6B4D)]
              : [AppColors.primaryDarkGreen, const Color(0xFF2C5343)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDarkGreen.withAlpha(55),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Order Number
          Text(
            'หมายเลขออเดอร์',
            style: GoogleFonts.notoSansThai(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _order.orderNumber,
            style: GoogleFonts.inter(
              color: AppColors.white,
              fontSize: 44,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: _statusBadgeColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              _order.statusThai,
              style: GoogleFonts.notoSansThai(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Queue Ahead
          if (!isCompleted)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 16, color: Color(0xFF88D49E)),
                const SizedBox(width: 6),
                Text(
                  _order.queueAhead > 0
                      ? 'มีอีก ${_order.queueAhead} คิวก่อนหน้า • ประมาณ ${_order.queueAhead * 3} นาที'
                      : isReady
                          ? 'เครื่องดื่มพร้อมแล้ว! มารับได้เลย 🎉'
                          : 'ใกล้ถึงคิวของคุณแล้ว!',
                  style: GoogleFonts.notoSansThai(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          if (isCompleted)
            Text(
              'ขอบคุณที่อุดหนุน บรรจงคาเฟ่ 🌿',
              style: GoogleFonts.notoSansThai(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
        ],
      ),
    );
  }

  Color get _statusBadgeColor {
    switch (_order.status) {
      case 'PENDING':
        return AppColors.statusPending;
      case 'PREPARING':
        return AppColors.statusPreparing;
      case 'READY':
      case 'COMPLETED':
        return AppColors.statusReady;
      default:
        return AppColors.sageGreen;
    }
  }

  Widget _buildProgressStepper() {
    final steps = [
      _StepInfo(
        title: 'รับออเดอร์แล้ว',
        subtitle: 'PENDING — ร้านได้รับคำสั่งซื้อของคุณแล้ว',
        icon: Icons.receipt_long_outlined,
      ),
      _StepInfo(
        title: 'กำลังเตรียมเครื่องดื่ม',
        subtitle: 'PREPARING — บาริสต้ากำลังจัดทำเครื่องดื่ม',
        icon: Icons.blender_outlined,
      ),
      _StepInfo(
        title: 'พร้อมรับสินค้า',
        subtitle: 'READY — มารับได้ที่เคาน์เตอร์',
        icon: Icons.check_circle_outline_rounded,
      ),
      _StepInfo(
        title: 'เสร็จสิ้น',
        subtitle: 'COMPLETED — ขอบคุณที่อุดหนุน',
        icon: Icons.favorite_border_rounded,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ขั้นตอนการดำเนินการ',
            style: GoogleFonts.notoSansThai(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 18),
          ...List.generate(steps.length, (i) {
            final stepNum = i + 1;
            final isDone = _order.currentStep > stepNum;
            final isCurrent = _order.currentStep == stepNum;
            final step = steps[i];

            return Column(
              children: [
                _buildStepRow(
                  stepNumber: stepNum,
                  title: step.title,
                  subtitle: step.subtitle,
                  icon: step.icon,
                  isDone: isDone,
                  isCurrent: isCurrent,
                ),
                if (i < steps.length - 1)
                  _buildStepDivider(_order.currentStep > stepNum),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStepRow({
    required int stepNumber,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDone,
    required bool isCurrent,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Circle indicator
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? AppColors.primaryDarkGreen
                : isCurrent
                    ? AppColors.lightGreen
                    : AppColors.border,
            border: isCurrent
                ? Border.all(color: AppColors.sageGreen, width: 2.5)
                : null,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check_rounded, size: 18, color: AppColors.white)
                : Icon(
                    icon,
                    size: 18,
                    color: isCurrent ? AppColors.primaryDarkGreen : AppColors.secondaryText,
                  ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSansThai(
                    fontSize: 14,
                    fontWeight: isCurrent || isDone ? FontWeight.w700 : FontWeight.w500,
                    color: isCurrent
                        ? AppColors.primaryDarkGreen
                        : isDone
                            ? AppColors.darkText
                            : AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.notoSansThai(
                    fontSize: 11,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider(bool isActive) {
    return Container(
      margin: const EdgeInsets.only(left: 17, top: 4, bottom: 4),
      width: 2,
      height: 22,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryDarkGreen : AppColors.border,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }


  Widget _buildOrderDetails() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'รายการที่สั่ง',
            style: GoogleFonts.notoSansThai(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 10),

          Text(
            'ชื่อ: ${_order.customerName}',
            style: GoogleFonts.notoSansThai(
              fontSize: 13,
              color: AppColors.secondaryText,
            ),
          ),
          if (_order.customerPhone.isNotEmpty)
            Text(
              'เบอร์โทร: ${_order.customerPhone}',
              style: GoogleFonts.notoSansThai(
                fontSize: 13,
                color: AppColors.secondaryText,
              ),
            ),
          if (_order.note != null && _order.note!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.chat_bubble_outline_rounded,
                    size: 14, color: AppColors.sageGreen),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'หมายเหตุ: ${_order.note}',
                    style: GoogleFonts.notoSansThai(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],

          Divider(height: 20, color: AppColors.border),

          // Items list
          if (_order.items.isNotEmpty)
            ..._order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.name} x${item.quantity}'
                          '${item.options != null && item.options!.isNotEmpty ? ' (${item.options})' : ''}',
                          style: GoogleFonts.notoSansThai(
                            fontSize: 13,
                            color: AppColors.darkText,
                          ),
                        ),
                      ),
                      Text(
                        '฿${(item.price * item.quantity).toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.sageGreen,
                        ),
                      ),
                    ],
                  ),
                )),

          Divider(height: 20, color: AppColors.border),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ยอดรวมทั้งสิ้น',
                style: GoogleFonts.notoSansThai(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              Text(
                '฿${_order.totalPrice.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontSize: 20,
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

  // ---- CANCELLED View ----
  Widget _buildCancelledView() {
    return MobileContainer(
      appBar: const AppHeader(title: 'สถานะออเดอร์'),
      drawer: const AppDrawer(currentRoute: '/queue'),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel_outlined,
                  size: 52,
                  color: AppColors.errorRed,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'คำสั่งซื้อถูกยกเลิก',
                style: GoogleFonts.notoSansThai(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _order.statusDescription,
                style: GoogleFonts.notoSansThai(
                  fontSize: 14,
                  color: AppColors.secondaryText,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'หมายเลข: ${_order.orderNumber}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                icon: const Icon(Icons.home_outlined),
                label: Text(
                  'กลับหน้าหลัก',
                  style: GoogleFonts.notoSansThai(fontWeight: FontWeight.w700),
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
      ),
    );
  }
}

class _StepInfo {
  final String title;
  final String subtitle;
  final IconData icon;
  const _StepInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
