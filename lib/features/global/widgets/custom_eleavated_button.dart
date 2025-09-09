import 'package:auto_size_text/auto_size_text.dart';
import 'package:chiken_odyssey/theme/app_colors.dart';
import 'package:chiken_odyssey/theme/app_styles.dart';
import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 54,
    this.color = AppColors.greenColor,
  });

  final String text;
  final double height;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: AutoSizeText(maxLines: 1, text, style: AppStyles.poppins17s500w),
      ),
    );
  }
}
