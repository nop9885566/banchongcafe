import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProductImage extends StatelessWidget {
  final String? imagePath;
  final String category;
  final double? width;
  final double? height;
  final double borderRadius;

  const ProductImage({
    super.key,
    this.imagePath,
    this.category = 'Coffee',
    this.width,
    this.height,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final catLower = category.toLowerCase();
    final bool isCake = catLower.contains('cake') || catLower.contains('เค้ก') || catLower.contains('bakery');
    final bool isNonCoffee = catLower.contains('non') || catLower.contains('ชา') || catLower.contains('นม') || catLower.contains('tea') || catLower.contains('cocoa');

    String emoji = '☕';
    Color bgColor = const Color(0xFFF7F4ED);
    Color accentColor = AppColors.coffeeBrown;

    if (isCake) {
      emoji = '🍰';
      bgColor = const Color(0xFFFFF3E0);
      accentColor = const Color(0xFFD87D4A);
    } else if (isNonCoffee) {
      emoji = '🧋';
      bgColor = AppColors.lightGreen;
      accentColor = AppColors.primaryDarkGreen;
    }

    Widget fallbackPlaceholder = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: TextStyle(fontSize: (width != null && width! < 80) ? 26 : 42),
            ),
          ],
        ),
      ),
    );

    final bool isNetwork = imagePath != null && (imagePath!.startsWith('http://') || imagePath!.startsWith('https://'));

    if (!isNetwork) {
      return fallbackPlaceholder;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        imagePath!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallbackPlaceholder,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: bgColor,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: accentColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
