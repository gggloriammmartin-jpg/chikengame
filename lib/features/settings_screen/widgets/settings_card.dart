import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chiken_odyssey/theme/app_styles.dart';
import 'package:chiken_odyssey/theme/app_colors.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool>? onChanged; // Теперь может быть null

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppStyles.poppins16s400w.copyWith(
              fontSize: 17,
              color: Colors.black,
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.blackColor,
            trackColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }
}
