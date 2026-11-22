import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MobileContainer extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;

  const MobileContainer({
    super.key,
    required this.child,
    this.appBar,
    this.drawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFECEFEA), // Ambient background on desktop/tablet
      alignment: Alignment.center,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.background,
          boxShadow: const [
            BoxShadow(
              color: Color(0x15000000),
              blurRadius: 24,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Scaffold(
          backgroundColor: backgroundColor ?? AppColors.background,
          appBar: appBar,
          drawer: drawer,
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
          body: SafeArea(
            bottom: true,
            top: appBar == null,
            child: child,
          ),
        ),
      ),
    );
  }
}
