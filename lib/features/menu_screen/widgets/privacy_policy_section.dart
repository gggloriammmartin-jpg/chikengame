import 'package:chiken_odyssey/theme/app_colors.dart';
import 'package:chiken_odyssey/theme/app_styles.dart';
import 'package:flutter/material.dart';

class PrivactyPolicySection extends StatelessWidget {
  const PrivactyPolicySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 36,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.white247Color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('Privacy Policy', style: AppStyles.poppins16s300w),
      ),
    );
  }
}
