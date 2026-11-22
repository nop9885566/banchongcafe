import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/mobile_container.dart';
import '../widgets/app_header.dart';
import '../widgets/app_drawer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MobileContainer(
      appBar: const AppHeader(title: 'เกี่ยวกับร้าน'),
      drawer: const AppDrawer(currentRoute: '/about'),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Story Header Card
              _buildStoryCard(),

              const SizedBox(height: 24),

              // 2. Feature Cards (4 จุดเด่น)
              _buildFeatureHighlights(),

              const SizedBox(height: 24),

              // 3. Cafe Experience Card
              _buildExperienceCard(),

              const SizedBox(height: 28),

              // 4. CTA to Menu
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/menu');
                },
                icon: const Icon(Icons.coffee_rounded, size: 20),
                label: Text(
                  'ดูเมนูและสั่งเครื่องดื่ม',
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

  Widget _buildStoryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.soft,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: AppColors.primaryDarkGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'เรื่องราวของเรา',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    Text(
                      'The Story of Banchong Cafe',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            '“บรรจงคาเฟ่” ก่อตั้งขึ้นจากความหลงใหลในความพิถีพิถันของการชงกาแฟและการอบเค้กโฮมเมด เราเชื่อว่ากาแฟที่ดีไม่ได้เป็นเพียงแค่เครื่องดื่ม แต่คือช่วงเวลาแห่งความสงบและการพักผ่อนอย่างแท้จริง',
            style: GoogleFonts.notoSansThai(
              fontSize: 14,
              color: AppColors.darkText,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'คำว่า “บรรจง” สื่อถึงความตั้งใจในทุกขั้นตอน ตั้งแต่การคัดสรรเมล็ดกาแฟ Specialty คุณภาพ การสกัดช็อตกาแฟอย่างแม่นยำ ไปจนถึงการทำเบเกอรี่สดใหม่ทุกวัน เพื่อให้ลูกค้าทุกคนได้รับประสบการณ์ที่ดีที่สุด',
            style: GoogleFonts.notoSansThai(
              fontSize: 14,
              color: AppColors.secondaryText,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureHighlights() {
    final features = [
      {
        'icon': Icons.forest_rounded,
        'title': 'ธรรมชาติและพื้นที่สีเขียว',
        'desc': 'ล้อมรอบด้วยต้นไม้และวิวธรรมชาติ อากาศโปร่งโล่ง ให้ความรู้สึกผ่อนคลายเหมือนได้พักผ่อน',
      },
      {
        'icon': Icons.camera_alt_rounded,
        'title': 'มุมถ่ายรูปสวยงาม',
        'desc': 'จัดมุมถ่ายภาพทั้งโซน Indoor และ Outdoor แสงธรรมชาติลงตัว เหมาะกับสายถ่ายรูป',
      },
      {
        'icon': Icons.wifi_rounded,
        'title': 'Free Wi-Fi สำหรับลูกค้า',
        'desc': 'สัญญาณอินเทอร์เน็ตความเร็วสูง รองรับการนั่งทำงาน ดื่มกาแฟ และพักผ่อนได้อย่างสะดวกสบาย',
      },
      {
        'icon': Icons.local_cafe_rounded,
        'title': 'Specialty Coffee & Homemade Cakes',
        'desc': 'เมล็ดกาแฟคัดเกรดพิเศษ และเค้กโฮมเมดสูตรเฉพาะที่อบสดใหม่วันต่อวัน ไร้สารกันบูด',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.sageGreen,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'สิ่งที่คุณจะได้สัมผัสที่ร้าน',
              style: GoogleFonts.notoSansThai(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...features.map((f) => Container(
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
                  f['icon'] as IconData,
                  color: AppColors.primaryDarkGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f['title'] as String,
                      style: GoogleFonts.notoSansThai(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      f['desc'] as String,
                      style: GoogleFonts.notoSansThai(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildExperienceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warmCream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite_rounded, color: AppColors.coffeeBrown, size: 20),
              const SizedBox(width: 8),
              Text(
                'ความตั้งใจของบาริสต้า',
                style: GoogleFonts.notoSansThai(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '“เราตั้งใจชงทุกแก้ว และอบขนมทุกชิ้น เพื่อให้คุณได้มีความสุขกับช่วงเวลาเล็กๆ ที่มีคุณค่าที่บรรจงคาเฟ่”',
            style: GoogleFonts.notoSansThai(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: AppColors.secondaryText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
