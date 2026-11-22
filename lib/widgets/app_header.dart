import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/cart_service.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;
  final VoidCallback? onBack;
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;

  const AppHeader({
    super.key,
    this.showBack = false,
    this.onBack,
    this.title,
    this.actions,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final cartService = CartService();

    return AppBar(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: leading ?? (showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: AppColors.primaryDarkGreen,
              onPressed: onBack ?? () => Navigator.pop(context),
            )
          : Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded, size: 24),
                color: AppColors.primaryDarkGreen,
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            )),
      title: title != null
          ? Text(
              title!,
              style: GoogleFonts.notoSansThai(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDarkGreen,
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.eco_rounded,
                      color: AppColors.sageGreen,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'บรรจงคาเฟ่',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDarkGreen,
                      ),
                    ),
                  ],
                ),
                Text(
                  'BANCHONG CAFE',
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
      actions: [
        // Prepend any custom actions (e.g. Refresh in QueueScreen)
        if (actions != null) ...actions!,
        // Default: Cart badge button
        ListenableBuilder(
          listenable: cartService,
          builder: (context, _) {
            final count = cartService.itemCount;
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 24,
                    color: AppColors.primaryDarkGreen,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/cart');
                  },
                ),
                if (count > 0)
                  Positioned(
                    top: 10,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.coffeeBrown,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: GoogleFonts.inter(
                          color: AppColors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppColors.border,
          height: 1,
        ),
      ),
    );
  }
}
