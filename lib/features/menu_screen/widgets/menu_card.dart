import 'package:chiken_odyssey/features/menu_screen/models/menu_model.dart';
import 'package:chiken_odyssey/features/global/widgets/animated_tap.dart';
import 'package:chiken_odyssey/theme/app_colors.dart';
import 'package:chiken_odyssey/theme/app_styles.dart';
import 'package:flutter/material.dart';

class MenuCard extends StatelessWidget {
  const MenuCard({super.key, required this.data});

  final MenuCardModel data;

  @override
  Widget build(BuildContext context) {
    return AnimatedTap(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: data.screenBuilder),
        );
      },
      child: Container(
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.menuCardColor,
          border: Border.all(color: AppColors.menuCardColor, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(data.title, style: AppStyles.poppins32s500w),
      ),
    );
  }
}
