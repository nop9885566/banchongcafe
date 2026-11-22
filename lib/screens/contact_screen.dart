import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/mobile_container.dart';
import '../widgets/app_header.dart';
import '../widgets/app_drawer.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MobileContainer(
      appBar: const AppHeader(title: 'ติดต่อเรา'),
      drawer: const AppDrawer(currentRoute: '/contact'),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header Card ข้อมูลร้าน
              _buildStoreInfoCard(),

              const SizedBox(height: 20),

              // 2. ข้อมูลการติดต่อหลัก (ที่อยู่, เวลา, เบอร์โทร)
              _buildContactDetails(),

              const SizedBox(height: 20),

              // 3. แผนที่ Google Maps Placeholder
              _buildMapCard(context),

              const SizedBox(height: 20),

              // 4. Social Media
              _buildSocialChannels(),

              const SizedBox(height: 28),

              // 5. CTA Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/menu');
                },
                icon: const Icon(Icons.coffee_rounded, size: 20),
                label: Text(
                  'ดูเมนูเครื่องดื่มและเค้ก',
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
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreInfoCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primaryDarkGreen,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: AppColors.lightGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'บรรจงคาเฟ่',
                    style: GoogleFonts.notoSansThai(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    'BANCHONG CAFE',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: AppColors.lightGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Specialty Coffee & Homemade Cakes',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.warmCream,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactDetails() {
    final contactItems = [
      {
        'icon': Icons.location_on_rounded,
        'title': 'ที่อยู่ร้าน',
        'content': '[จะระบุข้อมูลจริงภายหลัง]',
        'subtitle': 'บรรยากาศธรรมชาติ ท่ามกลางพื้นที่สีเขียว',
      },
      {
        'icon': Icons.access_time_rounded,
        'title': 'วันและเวลาทำการ',
        'content': '[จะระบุข้อมูลจริงภายหลัง]',
        'subtitle': 'เปิดให้บริการทุกวัน มีที่จอดรถสะดวกสบาย',
      },
      {
        'icon': Icons.phone_rounded,
        'title': 'เบอร์โทรศัพท์ติดต่อ',
        'content': '[จะระบุข้อมูลจริงภายหลัง]',
        'subtitle': 'สอบถามเส้นทางหรือข้อมูลเพิ่มเติม',
      },
    ];

    return Column(
      children: contactItems.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppShadows.card,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: AppColors.primaryDarkGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String,
                      style: GoogleFonts.notoSansThai(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['content'] as String,
                      style: GoogleFonts.notoSansThai(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['subtitle'] as String,
                      style: GoogleFonts.notoSansThai(
                        fontSize: 11,
                        color: AppColors.secondaryText.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMapCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.map_outlined, color: AppColors.primaryDarkGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'แผนที่ร้าน (Google Maps)',
                style: GoogleFonts.notoSansThai(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Map Graphic Placeholder
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.pin_drop_rounded, color: AppColors.primaryDarkGreen, size: 36),
                  const SizedBox(height: 6),
                  Text(
                    'พิกัด Google Maps [จะใส่ลิงก์จริงภายหลัง]',
                    style: GoogleFonts.notoSansThai(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryDarkGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialChannels() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ช่องทางติดตาม Social Media',
            style: GoogleFonts.notoSansThai(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 14),

          // Facebook
          _buildSocialRow(
            icon: Icons.facebook,
            name: 'Facebook',
            account: 'Banchong Cafe [จะใส่ลิงก์จริงภายหลัง]',
          ),
          const Divider(color: AppColors.border, height: 20),

          // Instagram
          _buildSocialRow(
            icon: Icons.camera_alt_outlined,
            name: 'Instagram',
            account: '@banchongcafe [จะใส่ลิงก์จริงภายหลัง]',
          ),
        ],
      ),
    );
  }

  Widget _buildSocialRow({
    required IconData icon,
    required String name,
    required String account,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryDarkGreen, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
              Text(
                account,
                style: GoogleFonts.notoSansThai(
                  fontSize: 11,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
